-- HealthOS initial canonical schema
--
-- This migration establishes the single-node canonical metadata layer for HealthOS.
-- It is intentionally broad because the scaffold needs one coherent, inspectable foundation.
--
-- Design notes:
-- 1. PostgreSQL stores metadata, governance state, and operational lineage.
-- 2. Filesystem/object paths hold large payloads and artifact bodies.
-- 3. Direct identifiers remain separated from operational content.
-- 4. Provenance is append-only by rule.

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ============================================================================
-- SECTION 01: IDENTITY AND CIVIL LINKAGE
-- ============================================================================
-- usuarios: pseudonymous system-level user anchor.
-- identidades_civis: protected direct-identifier layer.

CREATE TABLE usuarios (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  cpf_hash TEXT UNIQUE NOT NULL,
  civil_token TEXT UNIQUE NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE identidades_civis (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  usuario_id UUID NOT NULL REFERENCES usuarios(id),
  nome_cifrado BYTEA NOT NULL,
  cpf_cifrado BYTEA NOT NULL,
  nascimento_cifrado BYTEA,
  contato_cifrado BYTEA,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================================
-- SECTION 02: PROFESSIONAL IDENTITY, SERVICE, AND HABILITATION
-- ============================================================================
-- registros_profissionais: validated professional identity.
-- servicos: tenant-like service boundary.
-- membros_servico: membership relation between professional record and service.
-- habilitacoes: bounded active window for acting professionally inside a service.

CREATE TABLE registros_profissionais (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  usuario_id UUID NOT NULL REFERENCES usuarios(id),
  conselho_tipo TEXT NOT NULL,
  numero TEXT NOT NULL,
  uf TEXT NOT NULL,
  validado BOOLEAN NOT NULL DEFAULT FALSE,
  validado_em TIMESTAMPTZ,
  UNIQUE (conselho_tipo, numero, uf)
);

CREATE TABLE servicos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nome TEXT NOT NULL,
  tipo TEXT NOT NULL,
  cnpj_token TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE membros_servico (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  servico_id UUID NOT NULL REFERENCES servicos(id),
  registro_profissional_id UUID NOT NULL REFERENCES registros_profissionais(id),
  papel TEXT NOT NULL,
  ativo BOOLEAN NOT NULL DEFAULT TRUE,
  desde TIMESTAMPTZ NOT NULL DEFAULT now(),
  ate TIMESTAMPTZ
);

CREATE TABLE habilitacoes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  usuario_id UUID NOT NULL REFERENCES usuarios(id),
  servico_id UUID NOT NULL REFERENCES servicos(id),
  registro_profissional_id UUID NOT NULL REFERENCES registros_profissionais(id),
  aberta_em TIMESTAMPTZ NOT NULL DEFAULT now(),
  fechada_em TIMESTAMPTZ,
  contexto JSONB NOT NULL DEFAULT '{}'::jsonb
);

-- ============================================================================
-- SECTION 03: CONSENT AND ACCESS GOVERNANCE
-- ============================================================================
-- consentimentos: first-class consent object with scope and time.

CREATE TABLE consentimentos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  titular_usuario_id UUID NOT NULL REFERENCES usuarios(id),
  finalidade TEXT NOT NULL,
  escopo JSONB NOT NULL,
  validade_inicio TIMESTAMPTZ NOT NULL,
  validade_fim TIMESTAMPTZ,
  revogado BOOLEAN NOT NULL DEFAULT FALSE,
  revogado_em TIMESTAMPTZ,
  prova_criptografica BYTEA,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================================
-- SECTION 04: CANONICAL DATA OBJECT METADATA
-- ============================================================================
-- dados maps a stored object reference to owner, layer, governance metadata, and time axes.
-- Invariant: an object belongs either to one user or to one service, never both at once.

CREATE TABLE dados (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  titular_usuario_id UUID REFERENCES usuarios(id),
  titular_servico_id UUID REFERENCES servicos(id),
  data_layer TEXT NOT NULL,
  kind TEXT NOT NULL,
  object_path TEXT NOT NULL,
  content_hash TEXT NOT NULL,
  policy_json JSONB NOT NULL,
  deidentified BOOLEAN NOT NULL DEFAULT FALSE,
  tempo_usuario TIMESTAMPTZ NOT NULL,
  tempo_sistema TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK (
    (titular_usuario_id IS NOT NULL AND titular_servico_id IS NULL) OR
    (titular_usuario_id IS NULL AND titular_servico_id IS NOT NULL)
  )
);

-- ============================================================================
-- SECTION 05: WORK SESSIONS AND SESSION EVENTS
-- ============================================================================
-- sessoes_trabalho: runtime session anchor.
-- eventos_sessao: event trail within a session.

CREATE TABLE sessoes_trabalho (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  kind TEXT NOT NULL,
  servico_id UUID NOT NULL REFERENCES servicos(id),
  professional_user_id UUID NOT NULL REFERENCES usuarios(id),
  patient_user_id UUID REFERENCES usuarios(id),
  habilitacao_id UUID REFERENCES habilitacoes(id),
  consent_snapshot JSONB,
  estado TEXT NOT NULL DEFAULT 'active',
  tempo_usuario_inicio TIMESTAMPTZ NOT NULL,
  tempo_sistema_inicio TIMESTAMPTZ NOT NULL DEFAULT now(),
  tempo_sistema_fim TIMESTAMPTZ
);

CREATE TABLE eventos_sessao (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sessao_id UUID NOT NULL REFERENCES sessoes_trabalho(id),
  kind TEXT NOT NULL,
  payload_ref TEXT,
  payload_json JSONB,
  tempo_usuario TIMESTAMPTZ,
  tempo_sistema TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================================
-- SECTION 06: ARTIFACTS, DRAFTS, AND GATES
-- ============================================================================
-- artefatos: persisted structured outputs and references.
-- drafts: pre-effective forms awaiting further action.
-- gate_requests / gate_resolutions: human-approval mechanism.

CREATE TABLE artefatos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sessao_id UUID REFERENCES sessoes_trabalho(id),
  owner_user_id UUID REFERENCES usuarios(id),
  owner_service_id UUID REFERENCES servicos(id),
  kind TEXT NOT NULL,
  status TEXT NOT NULL,
  object_path TEXT,
  content_hash TEXT,
  source_event_ids JSONB NOT NULL DEFAULT '[]'::jsonb,
  provider_name TEXT,
  model_name TEXT,
  model_version TEXT,
  prompt_version TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE drafts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  artefato_id UUID NOT NULL REFERENCES artefatos(id),
  draft_type TEXT NOT NULL,
  payload_json JSONB NOT NULL,
  status TEXT NOT NULL DEFAULT 'draft',
  author_actor_id TEXT NOT NULL,
  author_semantic_role TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  superseded_by UUID
);

CREATE TABLE gate_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  draft_id UUID NOT NULL REFERENCES drafts(id),
  requested_action TEXT NOT NULL,
  required_role TEXT NOT NULL,
  required_review_type TEXT NOT NULL,
  finalization_target TEXT NOT NULL,
  requires_signature BOOLEAN NOT NULL DEFAULT FALSE,
  rationale_note TEXT,
  status TEXT NOT NULL DEFAULT 'pending',
  requested_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  resolved_at TIMESTAMPTZ
);

CREATE TABLE gate_resolutions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  gate_request_id UUID NOT NULL REFERENCES gate_requests(id),
  resolver_user_id UUID NOT NULL REFERENCES usuarios(id),
  resolver_role TEXT NOT NULL,
  resolution TEXT NOT NULL,
  rationale_note TEXT,
  signature_blob BYTEA,
  reviewed_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================================
-- SECTION 07: VERSIONING AND MODEL/PROVIDER REGISTRIES
-- ============================================================================
-- versoes tracks versioned artifacts such as prompts, models, adapters, or scripts.
-- provider_configs and model_registry_entries define available inference/tuning surface.

CREATE TABLE versoes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  artifact_name TEXT NOT NULL,
  versao TEXT NOT NULL,
  content_hash TEXT NOT NULL,
  entrou_em_uso TIMESTAMPTZ NOT NULL,
  saiu_de_uso TIMESTAMPTZ,
  UNIQUE(artifact_name, versao)
);

CREATE TABLE provider_configs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  provider_kind TEXT NOT NULL,
  provider_name TEXT NOT NULL,
  config_json JSONB NOT NULL,
  enabled BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE model_registry_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  provider_name TEXT NOT NULL,
  model_name TEXT NOT NULL,
  model_version TEXT NOT NULL,
  modality TEXT NOT NULL,
  role_hint TEXT,
  config_json JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(provider_name, model_name, model_version)
);

CREATE TABLE fine_tuning_jobs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  provider_name TEXT NOT NULL,
  base_model TEXT NOT NULL,
  adapter_name TEXT NOT NULL,
  dataset_ref TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'created',
  metrics_json JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================================
-- SECTION 08: DE-IDENTIFICATION AND MESSAGE/TOOL LOGGING
-- ============================================================================
-- deidentification_maps protects the mapping between tokenized identity references and encrypted values.
-- agent_messages captures mailbox/message traffic.
-- tool_definitions and tool_invocations record tool surface and usage.

CREATE TABLE deidentification_maps (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  usuario_id UUID NOT NULL REFERENCES usuarios(id),
  direct_identifier_kind TEXT NOT NULL,
  token TEXT NOT NULL,
  encrypted_value BYTEA NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(usuario_id, direct_identifier_kind, token)
);

CREATE TABLE agent_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  runtime_kind TEXT NOT NULL,
  from_agent TEXT NOT NULL,
  to_agent TEXT NOT NULL,
  kind TEXT NOT NULL,
  payload_json JSONB NOT NULL,
  correlation_id TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE tool_definitions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT UNIQUE NOT NULL,
  contract_json JSONB NOT NULL,
  permission_requirements JSONB NOT NULL,
  enabled BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE tool_invocations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tool_name TEXT NOT NULL,
  actor_id TEXT NOT NULL,
  args_json JSONB NOT NULL,
  result_ref TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================================
-- SECTION 09: AUDIT AND PROVENANCE
-- ============================================================================
-- audit_entries records important audited actions.
-- proveniencia is append-only lineage for operational/model/runtime actions.

CREATE TABLE audit_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  actor_id TEXT,
  action TEXT NOT NULL,
  subject_kind TEXT NOT NULL,
  subject_id TEXT NOT NULL,
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE proveniencia (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  agente_id TEXT,
  operation TEXT NOT NULL,
  input_hash TEXT,
  output_hash TEXT,
  provider_name TEXT,
  model_name TEXT,
  model_version TEXT,
  prompt_version TEXT,
  cost_estimate NUMERIC,
  tempo_sistema TIMESTAMPTZ NOT NULL DEFAULT now(),
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb
);

-- Provenance must remain append-only at the DB rule layer.
CREATE RULE proveniencia_no_update AS ON UPDATE TO proveniencia DO INSTEAD NOTHING;
CREATE RULE proveniencia_no_delete AS ON DELETE TO proveniencia DO INSTEAD NOTHING;

-- ============================================================================
-- SECTION 10: INDEXES
-- ============================================================================
-- Indexes favor owner-centric lookup, session-centric traversal, consent lookup, and provenance review.

CREATE INDEX idx_dados_usuario ON dados(titular_usuario_id, kind);
CREATE INDEX idx_dados_servico ON dados(titular_servico_id, kind);
CREATE INDEX idx_sessoes_servico ON sessoes_trabalho(servico_id, professional_user_id);
CREATE INDEX idx_eventos_sessao ON eventos_sessao(sessao_id, kind);
CREATE INDEX idx_artefatos_sessao ON artefatos(sessao_id, kind, status);
CREATE INDEX idx_consentimentos_usuario ON consentimentos(titular_usuario_id, finalidade);
CREATE INDEX idx_proveniencia_agente ON proveniencia(agente_id, tempo_sistema);
