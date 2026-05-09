# Proposta de UX Copy — HealthOSVeridiaStage
> Revisões para o app de identidade de saúde do paciente. Foco: linguagem acessível, privacidade clara, ausência de autoridade clínica.

---

## Contexto

HealthOSVeridiaStage é o app de identidade de saúde do paciente (soberania do usuário, consentimento, acesso a dados próprios). Atualmente é um scaffold sem UI final — o único texto visível está na saída de `--smoke-test` e no modo sem argumento. O público principal é o paciente, não o clínico. A linguagem deve ser clara, empática e explícita quanto ao controle de dados.

---

## Fluxo 1 — App iniciado sem argumento (modo interativo não disponível)

**Contexto:** Usuário abre o app sem `--smoke-test`. Recebe mensagem de estado.

- Antes:
```
"HealthOSVeridia: patient health identity app scaffold placeholder - no final UI shell, no clinical authority (see HealthOS/Shared/docs/architecture/12-veridia.md)"
```
- Depois:
```
Veridia — Identidade de Saúde do Paciente

Esta versão do aplicativo ainda não possui interface interativa completa.
Para validação técnica, use: --smoke-test
```
- Racional: Apresenta o nome do produto claramente; remove jargão de engenharia; remove referência interna a doc de arquitetura; oferece alternativa disponível.
- Impacto UX: Menos confuso para quem recebe a saída sem contexto técnico.
- Riscos: Nenhum — saída de texto simples.

---

## Fluxo 2 — Smoke test: falha no início de sessão

**Contexto:** Operador executa `--smoke-test`; sessão não inicia.

- Antes:
```
"HealthOSVeridia smoke FAIL: session start returned \(startResult.disposition.rawValue) — \(startResult.issueMessage ?? "no detail")"
```
- Depois:
```
[FALHA] Veridia — teste de fumaça: início de sessão retornou '\(startResult.disposition.rawValue)'.
Detalhe: \(startResult.issueMessage ?? "sem informação adicional")
```
- Racional: Traduz "smoke FAIL" para português; "no detail" → "sem informação adicional"; estrutura clara.
- Impacto UX: Diagnóstico mais rápido para operadores.

---

## Fluxo 3 — Smoke test: falha no encerramento de sessão

**Contexto:** Operador executa `--smoke-test`; sessão não encerra corretamente.

- Antes:
```
"HealthOSVeridia smoke FAIL: session end returned \(endResult.disposition.rawValue) — \(endResult.issueMessage ?? "no detail")"
```
- Depois:
```
[FALHA] Veridia — teste de fumaça: encerramento de sessão retornou '\(endResult.disposition.rawValue)'.
Detalhe: \(endResult.issueMessage ?? "sem informação adicional")
```

---

## Fluxo 4 — Smoke test: sucesso

**Contexto:** Smoke test concluído com sucesso.

- Antes:
```
"HealthOSVeridia scaffold: smoke OK (veridia.session.start + veridia.session.end boundary verified)"
```
- Depois:
```
Veridia: teste de fumaça concluído.
Fronteiras de início e encerramento de sessão verificadas.
```
- Racional: Remove "scaffold", "smoke OK", "boundary verified" — jargão de QA/engenharia desnecessário para a mensagem de saída.

---

## Mensagens futuras de UI (planejamento)

Quando a UI final for implementada, as seguintes mensagens são recomendadas com base nos contratos de `UserSovereigntyContracts.swift`:

### Onboarding / consentimento
- **Título:** `"Controle os seus dados de saúde"`
- **Corpo:** `"O Veridia permite que você visualize, exporte e gerencie seus dados de saúde armazenados localmente. Nenhum dado é compartilhado sem o seu consentimento explícito."`
- **CTA:** `"Entrar"`

### Solicitação de consentimento
- **Título:** `"Permissão necessária"`
- **Corpo:** `"Para [finalidade], o sistema precisa acessar [dado]. Você pode revogar essa permissão a qualquer momento nas configurações."`
- **CTAs:** `"Permitir"` / `"Recusar"`
- **Racional:** Explicita finalidade, dado e controle — requisitos mínimos de privacidade.

### Exportação de dados
- **Título:** `"Exportar meus dados"`
- **Corpo:** `"Você receberá um arquivo com todos os dados de saúde armazenados. O arquivo não é cifrado por padrão — mantenha-o seguro."`
- **CTA:** `"Exportar"`

### Exclusão de dados
- **Título:** `"Excluir meus dados"`
- **Corpo:** `"Esta ação remove permanentemente seus dados de saúde armazenados localmente. Esta ação não pode ser desfeita."`
- **CTAs:** `"Excluir permanentemente"` / `"Cancelar"`
- **Racional:** Consequência explícita ("não pode ser desfeita") antes de ação destrutiva.

### Trilha de acesso
- **Título:** `"Histórico de acesso"`
- **Corpo (vazio):** `"Nenhum acesso registrado. O histórico aparecerá aqui conforme o sistema registrar acessos autorizados aos seus dados."`

### Erro de sessão
- **Título:** `"Sessão não iniciada"`
- **Corpo:** `"Não foi possível iniciar sua sessão de identidade. Verifique sua conexão e tente novamente."`
- **CTA:** `"Tentar novamente"`
