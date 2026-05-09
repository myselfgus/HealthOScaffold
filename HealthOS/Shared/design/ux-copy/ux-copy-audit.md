# UX Copy Audit — HealthOS
> Inventário de textos visíveis ao usuário por alvo. Cada item inclui local, texto atual, problema, severidade e recomendação.

---

## HealthOSCLI

### CLI-01
- **Local:** `CLIEntrypoint.swift` — saída de sucesso da fatia principal
- **Texto atual:** `"HealthOS first slice complete"`
- **Problema:** Jargão técnico ("first slice") exposto ao operador sem contexto; mistura inglês com saída em português no projeto.
- **Severidade:** Alta
- **Recomendação:** `"HealthOS: sessão clínica concluída."` — ou manter inglês consistentemente em toda a CLI.

### CLI-02
- **Local:** `CLIEntrypoint.swift` — falha fatal
- **Texto atual:** `"HealthOSCLI failed: \(error)"`
- **Problema:** Mensagem vaga; não orienta ação; não diferencia tipos de falha (configuração, rede, dados).
- **Severidade:** Alta
- **Recomendação:** `"[ERRO] HealthOS CLI: \(error.localizedDescription)\nVerifique o log acima e tente novamente."`

### CLI-03
- **Local:** `CLIEntrypoint.swift` — resolução de raiz de runtime não encontrada
- **Texto atual:** `"Could not resolve runtime-data root for GOS promotion command."`
- **Problema:** Inglês; não indica o que o operador deve verificar; sem caminho de correção.
- **Severidade:** Alta
- **Recomendação:** `"Não foi possível localizar o diretório runtime-data. Execute o comando a partir da raiz do repositório ou verifique se o diretório existe."`

### CLI-04
- **Local:** `CLIEntrypoint.swift` — valores de saída de GOS review
- **Texto atual:** `print("gos_bundle_reviewed=true")` e variáveis similares
- **Problema:** Formato machine-readable sem separador legível; operadores humanos não conseguem distinguir rapidamente sucesso de dados.
- **Severidade:** Média
- **Recomendação:** Adicionar cabeçalho `"--- Bundle GOS revisado com sucesso ---"` antes das linhas de chave=valor.

### CLI-05
- **Local:** `CLIEntrypoint.swift` — captura padrão embutida no código
- **Texto atual:** `"Paciente relata dor de cabeça, insônia e piora do sono há uma semana."`
- **Problema:** Dado clínico de exemplo hardcoded no executável; pode vazar em logs de produção ou confundir operadores.
- **Severidade:** Alta
- **Recomendação:** Mover para arquivo de fixture; exibir aviso claro: `"[AVISO] Usando texto de captura de demonstração — não use em ambiente clínico real."`

### CLI-06
- **Local:** `CLIEntrypoint.swift` — saída de transcrição não disponível
- **Texto atual:** `"transcript=<not available>"`
- **Problema:** Tag HTML-like em saída de terminal; jargão de desenvolvedor; mistura idiomas.
- **Severidade:** Média
- **Recomendação:** `"transcript=nao_disponivel"` ou exibir linha separada: `"Transcrição: não disponível nesta sessão."`

### CLI-07
- **Local:** `CLIEntrypoint.swift` — documento final não efetivado
- **Texto atual:** `"final_document=<not effectuated>"`
- **Problema:** Palavra "effectuated" é jargão jurídico em inglês; confuso sem contexto.
- **Severidade:** Média
- **Recomendação:** `"final_document=nao_efetivado"` com nota: `"Gate rejeitado — documento final não foi gerado."`

### CLI-08
- **Local:** `CLIEntrypoint.swift` — rationale padrão de review
- **Texto atual:** `"bundle reviewed via HealthOSCLI"`
- **Problema:** Rationale sem valor semântico; se gravada em audit log, não informa motivo real.
- **Severidade:** Baixa
- **Recomendação:** Tornar obrigatório: exibir aviso quando `--review-rationale` não for fornecido.

### CLI-09
- **Local:** `CLIEntrypoint.swift` — preview de draft refresh com issues
- **Texto atual:** `print("draft_refresh_disposition=\(draftRefresh.disposition.rawValue)")`
- **Problema:** `rawValue` de enum exposto diretamente; valores como `"partialSuccess"` não são claros para operadores.
- **Severidade:** Baixa
- **Recomendação:** Mapear rawValues para rótulos legíveis: `"Atualização de rascunho: parcialmente bem-sucedida"`.

---

## Scribe

### SCR-01
- **Local:** `ScribeFirstSliceView.swift` — título da janela
- **Texto atual:** `WindowGroup("Scribe First Slice")`
- **Problema:** Jargão técnico exposto na barra de título; mistura inglês com conteúdo em português.
- **Severidade:** Alta
- **Recomendação:** `WindowGroup("HealthOS Scribe — Sessão Clínica")`

### SCR-02
- **Local:** `ScribeFirstSliceView.swift` — descrição da superfície
- **Texto atual:** `"Superficie minima de validacao funcional. A UI consome a bridge do first slice e apenas mostra estado, gate e degradacao."`
- **Problema:** Português sem acentuação; jargão técnico ("bridge", "first slice", "gate", "degradacao"); visível ao usuário final.
- **Severidade:** Alta
- **Recomendação:** `"Superfície de validação da sessão clínica. Exibe estado da sessão, revisão de portão e modo de degradação."`

### SCR-03
- **Local:** `ScribeFirstSliceView.swift` — seção 1
- **Texto atual:** `GroupBox("1. Session Start")`
- **Problema:** Inglês; numeração rígida (quebrará com reordenação); "Session Start" vago.
- **Severidade:** Alta
- **Recomendação:** `GroupBox("Iniciar sessão")`

### SCR-04
- **Local:** `ScribeFirstSliceView.swift` — botão iniciar sessão
- **Texto atual:** `Button("Open professional session")`
- **Problema:** Inglês; "Open" não transmite o contexto clínico.
- **Severidade:** Alta
- **Recomendação:** `Button("Iniciar sessão profissional")`

### SCR-05
- **Local:** `ScribeFirstSliceView.swift` — instrução quando sessão não iniciada
- **Texto atual:** `"Abra a sessao para habilitar selecao de paciente e captura por texto seeded ou audio local."`
- **Problema:** Sem acentuação; "seeded" é jargão de desenvolvimento; instrução técnica exposta ao clínico.
- **Severidade:** Alta
- **Recomendação:** `"Inicie a sessão para selecionar paciente e enviar captura de texto ou arquivo de áudio."`

### SCR-06
- **Local:** `ScribeFirstSliceView.swift` — seção 2
- **Texto atual:** `GroupBox("2. Patient, Capture, Gate")`
- **Problema:** Inglês; "Gate" é jargão de governança interna; numeração rígida.
- **Severidade:** Alta
- **Recomendação:** `GroupBox("Paciente, Captura e Revisão")`

### SCR-07
- **Local:** `ScribeFirstSliceView.swift` — picker de paciente
- **Texto atual:** `Picker("Patient token", ...)` / `Text("Select a patient")`
- **Problema:** "Token" é jargão técnico de privacidade; "Select a patient" em inglês.
- **Severidade:** Alta
- **Recomendação:** `Picker("Paciente", ...)` / `Text("Selecione um paciente")`

### SCR-08
- **Local:** `ScribeFirstSliceView.swift` — botão selecionar paciente
- **Texto atual:** `Button("Select patient")`
- **Problema:** Inglês.
- **Severidade:** Alta
- **Recomendação:** `Button("Confirmar paciente")`

### SCR-09
- **Local:** `ScribeFirstSliceView.swift` — picker de modo de captura
- **Texto atual:** `Picker("Capture mode", ...)` / `"Seeded text"` / `"Local audio file"`
- **Problema:** Inglês; "Seeded text" é jargão de teste.
- **Severidade:** Alta
- **Recomendação:** `Picker("Modo de captura", ...)` / `"Texto de exemplo"` / `"Arquivo de áudio local"`

### SCR-10
- **Local:** `ScribeFirstSliceView.swift` — label do TextEditor
- **Texto atual:** `Text("Capture text (seeded)")`
- **Problema:** Inglês; "(seeded)" exposto ao clínico.
- **Severidade:** Alta
- **Recomendação:** `Text("Texto da consulta")`

### SCR-11
- **Local:** `ScribeFirstSliceView.swift` — botão escolher áudio
- **Texto atual:** `Button("Choose audio file")`
- **Problema:** Inglês.
- **Severidade:** Alta
- **Recomendação:** `Button("Selecionar arquivo de áudio")`

### SCR-12
- **Local:** `ScribeFirstSliceView.swift` — botão reverter para texto
- **Texto atual:** `Button("Use seeded text instead")`
- **Problema:** Inglês; "seeded text" é jargão.
- **Severidade:** Alta
- **Recomendação:** `Button("Usar texto de exemplo")`

### SCR-13
- **Local:** `ScribeFirstSliceView.swift` — botão submeter captura
- **Texto atual:** `Button("Submit capture")`
- **Problema:** Inglês; "Submit" e "capture" são termos técnicos.
- **Severidade:** Alta
- **Recomendação:** `Button("Enviar captura")`

### SCR-14
- **Local:** `ScribeFirstSliceView.swift` — botão avançar para draft
- **Texto atual:** `Button("Advance to draft preview")`
- **Problema:** Inglês; "draft preview" é jargão.
- **Severidade:** Alta
- **Recomendação:** `Button("Visualizar rascunho")`

### SCR-15
- **Local:** `ScribeFirstSliceView.swift` — botões de gate
- **Texto atual:** `Button("Approve gate")` / `Button("Reject gate")`
- **Problema:** Inglês; "gate" é jargão de governança; "Approve/Reject" muito técnico para clínicos.
- **Severidade:** Alta
- **Recomendação:** `Button("Aprovar e finalizar")` / `Button("Rejeitar rascunho")`

### SCR-16
- **Local:** `ScribeFirstSliceView.swift` — seção de saídas
- **Texto atual:** `GroupBox("3. Slice Outputs")`
- **Problema:** Inglês; "Slice Outputs" é jargão interno.
- **Severidade:** Alta
- **Recomendação:** `GroupBox("Resultados da sessão")`

### SCR-17
- **Local:** `ScribeFirstSliceView.swift` — texto vazio de transcrição
- **Texto atual:** `"Nenhuma captura submetida ainda."`
- **Problema:** "submetida" é formalismo; sem orientação de ação.
- **Severidade:** Média
- **Recomendação:** `"Nenhuma captura enviada. Envie a captura para ver a transcrição."`

### SCR-18
- **Local:** `ScribeFirstSliceView.swift` — seção de issues
- **Texto atual:** `GroupBox("4. Issues / Degraded / Deny")`
- **Problema:** Inglês; jargão técnico; mistura de conceitos (Issues + Degraded + Deny).
- **Severidade:** Alta
- **Recomendação:** `GroupBox("Alertas e problemas")`

### SCR-19
- **Local:** `ScribeFirstSliceView.swift` — empty state de issues
- **Texto atual:** `"Nenhum issue ativo no momento."`
- **Problema:** "issue" é anglicismo; levemente frio.
- **Severidade:** Média
- **Recomendação:** `"Nenhum alerta no momento."`

### SCR-20
- **Local:** `ScribeFirstSliceViewModel.swift` — mensagem de erro de captura incompleta
- **Texto atual:** `"Escolha texto seeded ou um arquivo de audio local antes de submeter a captura."`
- **Problema:** "seeded" e "submeter a captura" são jargões; sem acentuação.
- **Severidade:** Alta
- **Recomendação:** `"Escolha texto de exemplo ou um arquivo de áudio antes de enviar."`

### SCR-21
- **Local:** `ScribeFirstSliceViewModel.swift` — estado inicial de ação
- **Texto atual:** `var lastAction = "bootstrap pending"`
- **Problema:** "bootstrap pending" é jargão de desenvolvedor visível ao usuário.
- **Severidade:** Média
- **Recomendação:** `var lastAction = "aguardando inicialização"`

### SCR-22
- **Local:** `ScribeFirstSliceViewModel.swift` — falha de bootstrap
- **Texto atual:** `"Scribe demo bootstrap failed: \(error.localizedDescription)"`
- **Problema:** "demo bootstrap" exposto; linguagem técnica; não orienta ação.
- **Severidade:** Alta
- **Recomendação:** `"Falha ao inicializar o ambiente de sessão: \(error.localizedDescription). Verifique a configuração e tente novamente."`

### SCR-23
- **Local:** `ScribeFirstSliceViewModel.swift` — bridge indisponível
- **Texto atual:** `"Scribe bridge is unavailable before session start."`
- **Problema:** Inglês; "bridge" é arquitetura interna; não orientado ao usuário.
- **Severidade:** Alta
- **Recomendação:** `"Serviço de sessão indisponível. Reinicie o aplicativo."`

### SCR-24
- **Local:** `ScribeFirstSliceViewModel.swift` — seleção de áudio falhou
- **Texto atual:** `"Nao foi possivel selecionar o arquivo de audio local: \(error.localizedDescription)"`
- **Problema:** Sem acentuação; concatena erro técnico diretamente.
- **Severidade:** Média
- **Recomendação:** `"Não foi possível abrir o arquivo de áudio. Verifique se o arquivo é válido e tente novamente."`

---

## Veridia

### VER-01
- **Local:** `VeridiaEntrypoint.swift` — modo interativo não disponível
- **Texto atual:** `"HealthOSVeridia: patient health identity app scaffold placeholder - no final UI shell, no clinical authority (see HealthOS/Shared/docs/architecture/12-veridia.md)"`
- **Problema:** Inglês; "scaffold placeholder" não faz sentido para usuário; referência a doc interna exposta.
- **Severidade:** Alta
- **Recomendação:** `"Veridia — Identidade de Saúde do Paciente\nEsta versão ainda não possui interface interativa. Use --smoke-test para validação."`

### VER-02
- **Local:** `VeridiaEntrypoint.swift` — falha no smoke test (session start)
- **Texto atual:** `"HealthOSVeridia smoke FAIL: session start returned \(startResult.disposition.rawValue) — \(startResult.issueMessage ?? "no detail")"`
- **Problema:** Inglês; "smoke FAIL" é jargão de QA; "no detail" vago.
- **Severidade:** Média
- **Recomendação:** `"Veridia: falha no teste de fumaça — início de sessão retornou '\(startResult.disposition.rawValue)'. Detalhe: \(startResult.issueMessage ?? "sem informação adicional")"`

### VER-03
- **Local:** `VeridiaEntrypoint.swift` — sucesso no smoke test
- **Texto atual:** `"HealthOSVeridia scaffold: smoke OK (veridia.session.start + veridia.session.end boundary verified)"`
- **Problema:** Inglês; "scaffold" e "boundary verified" são jargões técnicos.
- **Severidade:** Baixa
- **Recomendação:** `"Veridia: teste de fumaça concluído — fronteiras de início e fim de sessão verificadas."`

---

## CloudClinic

### CC-01
- **Local:** `CloudClinicEntrypoint.swift` — modo interativo não disponível
- **Texto atual:** `"HealthOSCloudClinic: scaffold placeholder - no final UI shell, no session behavior, no clinical authority (see HealthOS/Shared/docs/architecture/13-cloudclinic.md)"`
- **Problema:** Inglês; jargão de engenharia exposto ao operador; referência interna exposta.
- **Severidade:** Alta
- **Recomendação:** `"CloudClinic — Interface de Operações Profissionais\nEsta versão ainda não possui interface interativa completa."`

### CC-02
- **Local:** `CloudClinicEntrypoint.swift` — sucesso no smoke test
- **Texto atual:** `"HealthOSCloudClinic scaffold: smoke OK (no final UI, no clinical authority)"`
- **Problema:** Inglês; "no final UI, no clinical authority" lembra ao operador as limitações mas sem clareza.
- **Severidade:** Baixa
- **Recomendação:** `"CloudClinic: teste de fumaça concluído. Interface e autoridade clínica pendentes para versão final."`

---

## HealthOSCore / SessionRuntime (mensagens de superfície)

### CORE-01
- **Local:** `ScribeFirstSliceViewModel.swift` — mensagem de patiente não selecionado
- **Texto atual:** `"Selecione um paciente pseudonimizado antes de continuar."`
- **Problema:** "pseudonimizado" é jargão técnico/jurídico; confuso para o clínico.
- **Severidade:** Média
- **Recomendação:** `"Selecione um paciente antes de continuar."`

### CORE-02
- **Local:** `ScribeFirstSliceViewModel.swift` — sessão não encontrada (múltiplas ocorrências)
- **Texto atual:** `"Inicie uma sessão antes de submeter captura."` / `"Inicie uma sessão antes de pedir preview de draft."` / `"Inicie uma sessão antes de resolver o gate."`
- **Problema:** "submeter captura", "preview de draft" e "resolver o gate" são jargões; mensagens inconsistentes entre si.
- **Severidade:** Média
- **Recomendação:** Padronizar para: `"Inicie uma sessão antes de continuar."` com contexto via toast/seção de destaque.

---

## Resumo de severidade

- **Alta (P0/P1):** CLI-01, CLI-02, CLI-03, CLI-05, SCR-01 a SCR-16, SCR-20, SCR-22, SCR-23, VER-01, CC-01 — 26 itens
- **Média (P1/P2):** CLI-04, CLI-06, CLI-07, SCR-17, SCR-19, SCR-21, SCR-24, VER-02, CORE-01, CORE-02 — 10 itens
- **Baixa (P2):** CLI-08, CLI-09, VER-03, CC-02 — 4 itens
