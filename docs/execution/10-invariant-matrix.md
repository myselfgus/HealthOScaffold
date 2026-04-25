# Pragmatic invariant matrix (HealthOS / GOS / AACI)

This matrix records **real enforcement currently present in-repo**.
It is not a formal proof claim; it is a pragmatic invariant-enforcement posture.

## Invariant matrix

| Invariant | Layer | Why it matters | Current enforcement | Test coverage | Gap | Next hardening step |
|---|---|---|---|---|---|---|
| 1. HealthOS Core é soberano | Core law | Evita deslocar lei para runtime/app | `SimpleConsentService`, `SimpleHabilitationService`, gate e finalização ficam no Core/FirstSlice services | `testFirstSliceWithActiveGOSDoesNotBypassCoreConsentOrHabilitationChecks` | Ainda é slice-level, não política global multi-runtime | Promover guardas de soberania para contrato transversal de runtime |
| 2. GOS é subordinado ao Core | Core+Runtime boundary | Impede GOS virar engine autônoma | AACI trata GOS como mediação (view resolvida), sem mover consent/gate/finality | Testes AACI + first slice com GOS ativo e sem bypass | Não há lint semântico global | Adicionar check estático para campos/termos proibidos no runtime payload |
| 3. GOS nunca autoriza ato regulatório | Runtime + gate | Evita “aprovação por spec” | `legalAuthorizing = false`, flags `gateStillRequired`, `draftOnly`; finalização só após gate aprovado | Testes Scribe bridge + finalização com gate | Sem política de rejeição automática de vocabulário autoritativo em todos módulos | Adicionar validação contratual de metadata proibida em CI |
| 4. Apps não interpretam spec cru | App boundary | Evita lei no app | `GOSRuntimeStateView` expõe superfície mediada; sem spec JSON/raw binding plan | `testScribeBridgeStateDoesNotExposeRawGOSSpecJSON` | Cobertura só no Scribe bridge | Replicar boundary tests para Sortio/CloudClinic quando existirem |
| 5. Draft não é documento final | Core contracts | Preserva distinção regulatória | `ArtifactDraft.status`, `FinalizedSOAPDocument` separado | Testes draft/gate/finalização atuais | Sem state machine formal em schema dedicado | Adicionar schema explícito de estado documental |
| 6. Documento final exige gate aprovado | Gate/Finalization | Evita bypass regulatório | `FirstSliceInvariantEnforcer.ensureSOAPDraftCanFinalize` | `testFinalizationGuardRejectsDraftFinalizationWithoutApprovedGate`; testes approve/reject | Só cobre SOAP no first slice | Generalizar enforcer para outros artefatos regulatórios |
| 7. Bundle draft não pode ser ativado | GOS registry lifecycle | Evita ativação sem revisão | `activateBundle` exige `.reviewed`/`.active` + review record para reviewed | `testActivationRejectsDraftBundle` | Fluxo bootstrap ainda parte de bundle ativo de exemplo | Endurecer política de bootstrap com exceção explicitamente assinada |
| 8. Bundle revoked não pode ser carregado | GOS loader | Fail-closed de bundle retirado | `loadBundle` rejeita `.revoked` | `testLoaderRejectsRevokedBundle` | Revogação distribuída/malha não implementada | Política de revogação multi-nó + propagação |
| 9. Registry preserva histórico de known bundles | GOS registry state | Provenance e rollback | `normalizedKnownBundleIds` usado em register/review/activate/deprecate/revoke | Testes de preserve em revoke/deprecate/non-active transições | Não há checksum/assinatura de histórico | Append-only journal assinado por transição |
| 10. Runtime falha fechado em lifecycle inválido | GOS loader/activation | Segurança operacional determinística | erros tipados (`invalidLifecycleTransition`, `bundleDeprecated`, `lifecycleStateNotAccepted`, etc.) | suíte de lifecycle/load failures | Cobertura de compatibilidade entre versões ainda limitada | Matriz de compatibilidade spec/runtime/compiler |
| 11. Provenance distingue activation, mediation, gate, finalization | Provenance | Auditoria causal confiável | operações separadas: `gos.activate`, `gos.use.*` (incluindo `gos.use.capture`), `gate.request`, `gate.resolve`, `document.finalize.soap`; resolução de nomes `gos.use.*` agora centralizada no seam AACI (`AACIGOSProvenanceOperationResolver`) | testes de ordenação/proveniência + cobertura explícita de `gos.use.capture` | Não há validador automático de sequência | Validador de trilha de proveniência por sessão |
| 12. First slice não usa GOS para pular consent/habilitation/finality | First slice orchestration | Conserva soberania Core | ordem fixa no `FirstSliceRunner`: habilitação/consentimento antes de mediação e gate antes de finalização | testes de bypass negado + gate obrigatório | Cobertura centrada no fluxo nominal do slice | Expandir testes negativos por comando/estado de sessão |
| 13. Review/activation de bundle é policy-gated e auditável | GOS registry lifecycle | Evita promoção implícita e ativações sem governança mínima | `FileBackedGOSBundleRegistry` agora exige rationale + compiler pass em review, multi-review mínimo, separation-of-duties opcional, pinning determinístico (`GOSActivationPins`) e ações de audit para submissão/negação/aceitação | testes de rationale ausente, compiler report inválido, reviews insuficientes, SoD, pin mismatch, audit deny/accept | Política de autorização por papel/serviço ainda é mínima (sem RBAC completo) | Evoluir para envelopes de autorização e governança multi-nó |
| 14. lawfulContext é contrato de Core (não mapa solto implícito) | Core law + storage | Evita bypass por metadado parcial/vazio | `LawfulContextValidator` + `LawfulContextRequirement` validam contexto tipado a partir do mapa existente; `FileBackedStorageService` aplica fail-closed em get/list/audit com erros tipados `CoreLawError` | testes de ausência de `actorRole`/`scope`/`finalidade`/`patientUserId`/`serviceId`, contexto válido, audit sem contexto e distinção governed-vs-operational | Ainda não aplicado a 100% dos call sites/serviços fora do first-slice | Propagar validação para todos os serviços Core com mesma exigência contratual |

## State machine A — GOS bundle lifecycle

**States:** `draft`, `reviewed`, `active`, `deprecated`, `superseded`, `revoked`.

**Implemented transitions (enforced):**
- `draft -> reviewed`
- `draft -> revoked`
- `reviewed -> active`
- `reviewed -> revoked`
- `active -> deprecated`
- `active -> revoked`
- `active -> superseded` (quando outro bundle é ativado para o mesmo `spec_id`)

**Enforced rules now:**
- `draft` não ativa.
- `revoked` não carrega.
- `deprecated` não carrega quando `acceptedLifecycleStates = [.active]`.
- active pointer deve ser consistente com `knownBundleIds` e manifests ativos.
- `knownBundleIds` é preservado em transições (sem limpeza destrutiva).

## State machine B — Draft / Gate / Final document

**States:** `draft`, `awaitingGate`, `approved`, `rejected`, `finalized`.

**Enforced rules now:**
- draft não vai direto para `finalized`.
- `approved` só é aceito com `GateResolution(.approved)` + `GateOutcomeSummary.approved == true`.
- documento final só nasce após gate aprovado e draft em `awaitingGate`.
- GOS ativo não altera esta máquina (apenas media conteúdo/metadata/proveniência).
