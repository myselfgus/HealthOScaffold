# Proposta de UX Copy — HealthOSScribeStage
> Revisões de rótulos, diálogos, empty states e fluxos críticos para o app de captura clínica.

---

## Contexto

HealthOSScribeStage é a interface de captura de sessão clínica para profissionais de saúde. É o alvo com mais texto visível ao usuário. Atualmente mistura inglês e português, expõe jargão técnico e arquitetural ao clínico, e carece de mensagens de orientação em estados críticos. Esta proposta cobre o fluxo completo: bootstrap → sessão → paciente → captura → rascunho → revisão → documento final.

---

## Fluxo 1 — Inicialização e título da janela

**Contexto:** O app é aberto. O usuário vê o título da janela e o estado inicial.

### Problema 1a — Título da janela
- Antes: `"Scribe First Slice"`
- Depois: `"Scribe — Sessão Clínica"`
- Racional: Remove jargão de engenharia; identifica o produto e o contexto.
- Impacto UX: Primeira impressão profissional; acessível para VoiceOver.

### Problema 1b — Subtítulo da superfície
- Antes: `"Superficie minima de validacao funcional. A UI consome a bridge do first slice e apenas mostra estado, gate e degradacao."`
- Depois: `"Superfície de validação da sessão clínica. Exibe estado da sessão, revisão de portão e indicadores de degradação."`
- Racional: Mantém a natureza técnica da superfície (é uma tela de validação, não produção final), mas usa linguagem legível.
- Impacto UX: Clareza sobre o propósito sem remover aviso de maturidade.

### Problema 1c — Estado inicial de última ação
- Antes: `"bootstrap pending"`
- Depois: `"Aguardando inicialização…"`
- Racional: Estado legível para humanos.

### Problema 1d — Falha de bootstrap
- Antes: `"Scribe demo bootstrap failed: \(error.localizedDescription)"`
- Depois:
```
"Falha ao inicializar o ambiente de sessão: \(error.localizedDescription).
 Reinicie o aplicativo ou verifique a configuração."
```
- Racional: Sistema como agente; orientação concreta.

---

## Fluxo 2 — Seção de início de sessão

**Contexto:** Profissional clica para iniciar sessão.

### Problema 2a — Título da seção
- Antes: `GroupBox("1. Session Start")`
- Depois: `GroupBox("Iniciar sessão")`

### Problema 2b — Botão de ação
- Antes: `Button("Open professional session")`
- Depois: `Button("Iniciar sessão profissional")`

### Problema 2c — Instrução de estado inativo
- Antes: `"Abra a sessao para habilitar selecao de paciente e captura por texto seeded ou audio local."`
- Depois: `"Inicie a sessão para selecionar o paciente e enviar a captura (texto ou áudio)."`
- Racional: Corrige acentuação; remove "seeded"; instrução mais direta.
- Impacto UX: Orienta o clínico ao próximo passo sem jargão.

### Problema 2d — Bridge indisponível
- Antes: `"Scribe bridge is unavailable before session start."`
- Depois: `"Serviço de sessão indisponível. Reinicie o aplicativo."`

---

## Fluxo 3 — Seleção de paciente e captura

**Contexto:** Profissional seleciona paciente e envia captura.

### Problema 3a — Título da seção
- Antes: `GroupBox("2. Patient, Capture, Gate")`
- Depois: `GroupBox("Paciente, Captura e Revisão")`

### Problema 3b — Picker de paciente
- Antes: `Picker("Patient token", ...)` / placeholder `"Select a patient"`
- Depois: `Picker("Paciente", ...)` / placeholder `"Selecione um paciente"`
- Racional: "Token" oculto; idioma consistente.

### Problema 3c — Botão confirmar paciente
- Antes: `Button("Select patient")`
- Depois: `Button("Confirmar paciente")`

### Problema 3d — Exibição de paciente selecionado
- Antes: `"Current patient: \(patient.civilToken)"`
- Depois: `"Paciente: \(patient.civilToken)"`

### Problema 3e — Picker de modo de captura
- Antes: `Picker("Capture mode", ...)` com opções `"Seeded text"` e `"Local audio file"`
- Depois: `Picker("Modo de captura", ...)` com opções `"Texto de exemplo"` e `"Arquivo de áudio local"`
- Racional: "Seeded" é jargão de QA; nunca visível ao clínico.

### Problema 3f — Label do editor de texto
- Antes: `Text("Capture text (seeded)")`
- Depois: `Text("Texto da consulta")`

### Problema 3g — Seleção de áudio local
- Antes: `Text("Local audio file")` + `Button("Choose audio file")`
- Depois: `Text("Arquivo de áudio local")` + `Button("Selecionar arquivo de áudio")`

### Problema 3h — Label de áudio não selecionado
- Antes: `"Nenhum arquivo de audio selecionado."`
- Depois: `"Nenhum arquivo selecionado."`
- Racional: Mais conciso; sem redundância.

### Problema 3i — Botão reverter para texto
- Antes: `Button("Use seeded text instead")`
- Depois: `Button("Usar texto de exemplo")`

### Problema 3j — Botões de submissão e revisão
- Antes: `Button("Submit capture")` + `Button("Advance to draft preview")`
- Depois: `Button("Enviar captura")` + `Button("Visualizar rascunho")`

### Problema 3k — Botões de gate
- Antes: `Button("Approve gate")` / `Button("Reject gate")`
- Depois: `Button("Aprovar e finalizar")` / `Button("Rejeitar rascunho")`
- Racional: Consequências explícitas; "gate" oculto.

### Problema 3l — Erro: paciente não selecionado
- Antes: `"Selecione um paciente pseudonimizado antes de continuar."`
- Depois: `"Selecione um paciente antes de continuar."`

### Problema 3m — Erro: sessão não encontrada (múltiplos pontos)
- Antes (3 variações): `"Inicie uma sessão antes de submeter captura."` / `"...pedir preview de draft."` / `"...resolver o gate."`
- Depois (unificado): `"Inicie uma sessão antes de continuar."`
- Racional: Elimina inconsistência; mensagem genérica suficiente pois o contexto visual já indica o que o usuário tentou fazer.

### Problema 3n — Erro: captura incompleta
- Antes: `"Escolha texto seeded ou um arquivo de audio local antes de submeter a captura."`
- Depois: `"Escolha um texto de exemplo ou um arquivo de áudio antes de enviar."`

### Problema 3o — Seleção de áudio falhou
- Antes: `"Nao foi possivel selecionar o arquivo de audio local: \(error.localizedDescription)"`
- Depois: `"Não foi possível abrir o arquivo de áudio. Verifique se o formato é suportado e tente novamente."`
- Racional: Esconde o erro técnico bruto; orienta ação; sugere causa.

---

## Fluxo 4 — Resultados da sessão

**Contexto:** Resultados exibidos após captura e resolução do gate.

### Problema 4a — Título da seção
- Antes: `GroupBox("3. Slice Outputs")`
- Depois: `GroupBox("Resultados da sessão")`

### Problema 4b — Empty state: transcrição
- Antes: `"Nenhuma captura submetida ainda."`
- Depois: `"Nenhuma transcrição disponível. Envie uma captura para gerar a transcrição."`

### Problema 4c — Empty state: rascunho SOAP
- Antes: `"Nenhum draft SOAP visivel ainda."`
- Depois: `"Nenhum rascunho SOAP disponível. Envie a captura e visualize o rascunho."`

### Problema 4d — Empty state: retrieval
- Antes: `"Nenhum retrieval executado ainda."`
- Depois: `"Nenhuma busca de contexto realizada ainda."`

### Problema 4e — Empty state: transcript normalization
- Antes: `"Transcript normalization ainda nao executou nesta sessao."`
- Depois: `"Normalização de transcrição ainda não executou nesta sessão."`

### Problema 4f — Empty state: MSR
- Antes: `"MSR ainda nao executou nesta sessao."`
- Depois: `"Análise de espaço mental ainda não executou nesta sessão."`

### Problema 4g — Empty state: GOS runtime
- Antes: `"GOS runtime ainda nao observado nesta sessao."`
- Depois: `"Sistema de governança ainda não observado nesta sessão."`

### Problema 4h — Empty state: gate review
- Antes: `"Nenhuma revisão de gate visível ainda."`
- Depois: `"Nenhuma revisão de portão visível ainda."`

### Problema 4i — Empty state: referral draft
- Antes: `"Nenhum referral draft ainda."`
- Depois: `"Nenhum rascunho de encaminhamento gerado."`

### Problema 4j — Empty state: prescription draft
- Antes: `"Nenhum prescription draft ainda."`
- Depois: `"Nenhum rascunho de prescrição gerado."`

### Problema 4k — Documento final
- Antes: `"Sem documento final ainda."`
- Depois: `"Documento final não gerado. Aprove o portão de revisão para gerar o documento."`

---

## Fluxo 5 — Alertas e problemas

**Contexto:** Seção que exibe issues/erros da sessão.

### Problema 5a — Título da seção
- Antes: `GroupBox("4. Issues / Degraded / Deny")`
- Depois: `GroupBox("Alertas e problemas")`

### Problema 5b — Empty state de alertas
- Antes: `"Nenhum issue ativo no momento."`
- Depois: `"Nenhum alerta ativo."`

### Problema 5c — Formato de linha de issue
- Antes: `"\(issue.code.rawValue) [\(failureKind.rawValue)] \(issue.message)"`
- Depois: Mapear códigos e falhas para rótulos legíveis em pt-BR antes de exibir.
  - Exemplo: `"CAPTURA_INCOMPLETA [validação] Escolha texto ou áudio antes de enviar."`
- Racional: `rawValue` expõe nomenclatura interna de código; clínicos não conseguem interpretar.
- Impacto UX: Alertas passam a ser acionáveis, não apenas informativos.
- Dependências: Criar mapa de `IssueCode` → string localizada; `FailureKind` → string localizada.

---

## Labels de estado — padronização

| Antes | Depois |
|---|---|
| `session_state: idle` | `Aguardando` |
| `session_state: opening` | `Iniciando sessão…` |
| `session_state: active` | `Sessão ativa` |
| `session_state: degraded` | `Sessão ativa (modo reduzido)` |
| `session_state: closed` | `Sessão encerrada` |
| `session_state: failed` | `Falha na sessão` |
| `runtime_health: unknown` | `–` |
| `runtime_health: healthy` | `Operacional` |
| `runtime_health: degraded` | `Modo reduzido` |
| `runtime_health: failed` | `Falha` |
| `degraded_mode: none` | `–` |
| `degraded_mode: transcription_degraded` | `Transcrição degradada` |
| `degraded_mode: retrieval_degraded` | `Busca de contexto degradada` |
| `degraded_mode: partial_results` | `Resultados parciais` |
