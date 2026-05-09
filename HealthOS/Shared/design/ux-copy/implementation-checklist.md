# Checklist de Implementação — UX Copy HealthOS
> Passos para devs integrarem as mudanças de copy propostas nos alvos CLI e apps GUI.

---

## Fase 1 — Extração e organização de strings

### 1.1 Inventário de strings por alvo
- [ ] Mapear todas as strings literais em `CLIEntrypoint.swift` que aparecem na saída do terminal
- [ ] Mapear todas as strings em `ScribeFirstSliceView.swift` e `ScribeFirstSliceViewModel.swift`
- [ ] Mapear strings em `VeridiaEntrypoint.swift` e `CloudClinicEntrypoint.swift`
- [ ] Verificar se há strings em `SessionRunner.swift`, `ScribeSessionDemoBootstrap.swift` ou outros arquivos de runtime que chegam à UI/CLI

### 1.2 Criação de arquivo de localização (apps GUI)
- [ ] Criar `Localizable.xcstrings` (ou `Localizable.strings`) para Scribe
- [ ] Criar `Localizable.xcstrings` para Veridia (preparatório — UI ainda não implementada)
- [ ] Criar `Localizable.xcstrings` para CloudClinic (preparatório)
- [ ] Nomear chaves de string no padrão `snake_case` por domínio funcional:
  - Ex.: `session.start.button`, `session.error.no_facade`, `capture.empty_state`
- [ ] Nunca concatenar strings dinâmicas — usar `String(format:)` ou interpolação com `NSLocalizedString`

### 1.3 Strings da CLI
- [ ] Criar constantes em `CLIMessages.swift` (novo arquivo) para centralizar saídas da CLI
- [ ] Evitar strings literais espalhadas no `CLIEntrypoint.swift`
- [ ] Definir formato de saída padrão: `chave=valor` para machine-readable; cabeçalhos legíveis para humanos

---

## Fase 2 — Substituições prioritárias (P0)

### 2.1 HealthOSCLI
- [ ] Substituir `"HealthOS first slice complete"` por separador + rótulo localizado
- [ ] Substituir `"HealthOSCLI failed: \(error)"` por mensagem com `localizedDescription` + orientação
- [ ] Substituir `"Could not resolve runtime-data root..."` por mensagem em pt-BR com caminho esperado
- [ ] Substituir `"<not available>"` e `"<not effectuated>"` por equivalentes em snake_case pt-BR
- [ ] Adicionar aviso visível quando captura padrão (hardcoded) for usada
- [ ] Implementar parsing de `--help` com layout padronizado (ver `HealthOSCLI.md`)

### 2.2 Scribe — UI (SwiftUI)
- [ ] Alterar `WindowGroup("Scribe First Slice")` → `WindowGroup("Scribe — Sessão Clínica")`
- [ ] Substituir todos `GroupBox` com títulos em inglês → pt-BR (5 ocorrências)
- [ ] Substituir todos os `Button` em inglês → pt-BR (8 ocorrências)
- [ ] Substituir todos os `Picker` labels em inglês → pt-BR
- [ ] Substituir `"Seeded text"` / `"Local audio file"` nas opções de picker
- [ ] Substituir `LabeledContent` com keys em inglês → pt-BR (10+ ocorrências)
- [ ] Corrigir acentuação em todas as strings em português (7+ ocorrências identificadas)

### 2.3 Scribe — ViewModel (mensagens de erro/estado)
- [ ] Substituir `"Scribe bridge is unavailable..."` → mensagem localizada
- [ ] Substituir `"Scribe demo bootstrap failed..."` → mensagem localizada
- [ ] Substituir `"bootstrap pending"` → `"aguardando inicialização"`
- [ ] Padronizar as 3 variantes de `"Inicie uma sessão antes de..."` em uma única mensagem
- [ ] Substituir `"seeded"` em todos os erros de captura
- [ ] Substituir `"Nao foi possivel selecionar o arquivo de audio local: ..."` → mensagem traduzida e orientadora
- [ ] Criar mapa `IssueCode → String localizada` e `FailureKind → String localizada`

### 2.4 Veridia e CloudClinic
- [ ] Substituir mensagem de modo não interativo → pt-BR estruturado
- [ ] Substituir mensagens de smoke test → pt-BR

---

## Fase 3 — Testes de UI e CLI

### 3.1 Testes de UI (Scribe)
- [ ] Verificar que nenhum `rawValue` de enum aparece diretamente em `Text()` components voltados ao usuário
- [ ] Verificar que todos os `LabeledContent` usam strings legíveis (não `rawValue` de enums de arquitetura)
- [ ] Executar VoiceOver (acessibilidade) nos 5 GroupBox principais — verificar que os rótulos são informativos fora de contexto visual
- [ ] Testar estados vazios: abrir app sem clicar em nada — verificar que empty states aparecem corretamente
- [ ] Testar mensagens de erro: simular `bridge unavailable`, `audio file unreadable`, `session not found`
- [ ] Verificar que botões desabilitados têm tooltip ou contexto que explica por que estão desabilitados

### 3.2 Testes de CLI (HealthOSCLI)
- [ ] Executar `swift run HealthOSCLI` → verificar mensagem de saída localizada
- [ ] Executar `swift run HealthOSCLI --reject-gate` → verificar mensagem de rejeição localizada
- [ ] Executar `swift run HealthOSCLI --help` (quando implementado) → verificar layout completo
- [ ] Simular falha de `resolveRuntimeRoot` → verificar mensagem de erro com caminho esperado
- [ ] Verificar que erros vão para `stderr` e saídas normais vão para `stdout`

### 3.3 Smoke tests
- [ ] `swift run Scribe --smoke-test` → verificar saídas em pt-BR onde aplicável
- [ ] `swift run Veridia --smoke-test` → verificar mensagens de sucesso/falha localizadas
- [ ] `swift run CloudClinic --smoke-test` → verificar mensagem de sucesso localizada

---

## Fase 4 — Acessibilidade

### 4.1 VoiceOver e leitores de tela
- [ ] Adicionar `.accessibilityLabel()` a botões cujo rótulo não descreve a ação completa
  - Ex.: `Button("Aprovar e finalizar")` pode precisar de `accessibilityLabel("Aprovar rascunho SOAP e gerar documento final")`
- [ ] Garantir que `LabeledContent` tem labels descritivos (VoiceOver lê label + value)
- [ ] Verificar que empty states têm texto suficiente para serem interpretados sem contexto visual
- [ ] Não usar apenas cor para indicar estado (ex.: botão verde = aprovado) — sempre complementar com texto

### 4.2 Legibilidade
- [ ] Verificar que nenhuma string usa MAIÚSCULAS decorativas (ex.: `"APROVADO"`) sem ser por convenção de código
- [ ] Usar ponto final em frases completas; omitir em rótulos curtos de UI (botões, labels)
- [ ] Verificar que mensagens de erro cabem em 2-3 linhas na viewport mínima (860px largura)

---

## Fase 5 — Revisão legal e de privacidade

### 5.1 Mensagens que tocam dados de saúde
- [ ] Revisar com equipe jurídica/compliance qualquer mensagem que mencione coleta, armazenamento ou compartilhamento de dados
- [ ] Garantir que mensagens de consentimento citam finalidade, dado coletado e controle do usuário
- [ ] Verificar que mensagens de exportação/exclusão de dados descrevem consequências irreversíveis

### 5.2 Prompts de IA (MSR)
- [ ] Implementar Revisão 6 (privacidade) em todos os três prompts — instrução de não incluir identificadores diretos na saída
- [ ] Implementar Revisão 5 (restrição de `key_insights`) no prompt GEM
- [ ] Implementar Revisão 1 (escopo de análise) no prompt ASL
- [ ] Revisar com equipe clínica se os disclaimers propostos nas Revisões 3 e 4 são adequados
- [ ] Testar que o modelo respeita as restrições adicionadas (avaliação qualitativa com exemplos de transcrição de teste)

---

## Fase 6 — Preparação para i18n

- [ ] Garantir que todas as strings estão em arquivos `.xcstrings` ou `Localizable.strings`
- [ ] Verificar que nenhuma string é construída por concatenação de partes dinâmicas sem format strings
- [ ] Adicionar comentários de contexto para tradutores em cada chave (ex.: `comment: "Rótulo do botão de início de sessão — aparece desabilitado se já há uma sessão ativa"`)
- [ ] Testar com pseudo-localização (strings expandidas em 30%) para verificar quebras de layout

---

## Fase 7 — QA de cópia (revisão final antes de merge)

- [ ] Revisar audit (`ux-copy-audit.md`) — verificar que todos os itens Alta e Média foram endereçados
- [ ] Comparar cada proposta de "Depois" com o código atualizado — confirmar que foi implementada conforme
- [ ] Fazer hallway test rápido: pedir a uma pessoa sem contexto técnico para usar o ScribeApp por 5 minutos e reportar confusões
- [ ] Verificar consistência cross-app: todos os apps usam os mesmos termos para os mesmos conceitos (ver glossário em `ux-copy-guidelines.md`)
- [ ] Atualizar `changelog.md` com itens implementados e data
