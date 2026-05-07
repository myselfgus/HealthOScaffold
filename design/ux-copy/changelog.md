# Changelog — UX Copy HealthOS
> Resumo das mudanças propostas, priorização e rastreabilidade.

---

## v0.1 — 2026-05-06 — Auditoria e propostas iniciais

### Escopo
Auditoria completa de strings visíveis ao usuário em todos os alvos:
- HealthOSCLI (9 itens)
- HealthOSScribeStage (24 itens)
- HealthOSVeridiaStage (3 itens)
- HealthOSCloudClinicStage (2 itens)
- HealthOSCore/SessionRuntime — superfície de mensagens (2 itens)
- HealthOSMSR/Prompts — 6 revisões de prompts de IA

Total de itens identificados: **40 + 6 revisões de prompts**

---

## Priorização

### P0 — Crítico (implementar antes da próxima demo pública)

Estes itens causam confusão imediata, expõem jargão técnico ao usuário final ou representam risco de segurança/privacidade.

- **[SCR-01 a SCR-16]** — HealthOSScribeStage: todos os rótulos, botões, seções e empty states em inglês ou com jargão
  - Ver: [ux-copy-proposals/HealthOSScribeStage.md](ux-copy-proposals/HealthOSScribeStage.md) — Fluxos 1 a 5
  - Esforço: Médio (substituição de strings, sem refactor de lógica)

- **[CLI-01, CLI-02, CLI-03, CLI-05]** — HealthOSCLI: mensagens de sucesso/erro sem orientação, captura demo sem aviso
  - Ver: [ux-copy-proposals/HealthOSCLI.md](ux-copy-proposals/HealthOSCLI.md) — Problemas 1, 2, 3, 5
  - Esforço: Baixo

- **[VER-01, CC-01]** — VeridiaApp e CloudClinicApp: modo não interativo com jargão de scaffold
  - Ver: [ux-copy-proposals/HealthOSVeridiaStage.md](ux-copy-proposals/HealthOSVeridiaStage.md) — Fluxo 1
  - Ver: [ux-copy-proposals/HealthOSCloudClinicStage.md](ux-copy-proposals/HealthOSCloudClinicStage.md) — Fluxo 1
  - Esforço: Baixo

- **[Prompt-5, Prompt-6]** — Prompts MSR: `key_insights` sem limite de escopo e ausência de instrução de privacidade
  - Ver: [ai-prompts-review.md](ai-prompts-review.md) — Revisões 5 e 6
  - Esforço: Baixo (edição de arquivos de prompt)

---

### P1 — Importante (implementar no próximo sprint)

Estes itens degradam a experiência mas não bloqueiam uso ou criam risco imediato.

- **[SCR-17 a SCR-24]** — HealthOSScribeStage: empty states sem orientação, acentuação incorreta, mensagens de erro não orientadas
  - Ver: [ux-copy-proposals/HealthOSScribeStage.md](ux-copy-proposals/HealthOSScribeStage.md) — Fluxos 4 e 5
  - Esforço: Baixo

- **[CLI-04, CLI-06, CLI-07]** — HealthOSCLI: saídas GOS sem separador, tags HTML-like na saída
  - Ver: [ux-copy-proposals/HealthOSCLI.md](ux-copy-proposals/HealthOSCLI.md) — Problemas 4 e 6
  - Esforço: Baixo

- **[CORE-01, CORE-02]** — SessionRuntime: mensagens de erro com jargão e inconsistência
  - Ver: [ux-copy-audit.md](ux-copy-audit.md) — CORE-01, CORE-02
  - Esforço: Baixo

- **[Prompt-1, Prompt-2, Prompt-4]** — Prompts MSR: linguagem clínica sem limitação de escopo em ASL síntese, GEM prognóstico
  - Ver: [ai-prompts-review.md](ai-prompts-review.md) — Revisões 1, 2, 4
  - Esforço: Baixo

- **Mapa IssueCode → string localizada** — ScribeApp: issues exibem `rawValue` de código ao clínico
  - Ver: [ux-copy-proposals/HealthOSScribeStage.md](ux-copy-proposals/HealthOSScribeStage.md) — Problema 5c
  - Esforço: Médio (criar mapa de tradução)

---

### P2 — Melhoria (backlog / iterações futuras)

Estes itens melhoram consistência e preparam para i18n/acessibilidade.

- **[CLI-08, CLI-09]** — HealthOSCLI: rationale padrão sem valor; `rawValue` de disposição sem mapeamento
  - Ver: [ux-copy-audit.md](ux-copy-audit.md)
  - Esforço: Baixo

- **[VER-03, CC-02]** — Smoke tests: saídas técnicas com jargão de QA
  - Ver: [ux-copy-proposals/HealthOSVeridiaStage.md](ux-copy-proposals/HealthOSVeridiaStage.md) — Fluxo 4
  - Esforço: Baixo

- **[Prompt-3]** — VDLP: disclaimers de frameworks diagnósticos
  - Ver: [ai-prompts-review.md](ai-prompts-review.md) — Revisão 3
  - Esforço: Baixo

- **Extração de strings para `.xcstrings`** — ScribeApp e futuras UIs
  - Ver: [implementation-checklist.md](implementation-checklist.md) — Fase 1.2
  - Esforço: Médio-Alto (setup de i18n)

- **Implementação de `--help`** — HealthOSCLI
  - Ver: [ux-copy-proposals/HealthOSCLI.md](ux-copy-proposals/HealthOSCLI.md) — Layout de help
  - Esforço: Médio

- **Labels de estado mapeados** — ScribeApp: enums de estado exibidos diretamente na UI
  - Ver: [ux-copy-proposals/HealthOSScribeStage.md](ux-copy-proposals/HealthOSScribeStage.md) — Labels de estado
  - Esforço: Baixo

---

## Itens implementados

_(Nenhum ainda — este é o documento inicial de propostas)_

---

## Decisões de tom/voz registradas

1. **Idioma único:** Todo texto visível ao usuário em pt-BR. Nenhum termo técnico em inglês sem tradução.
2. **Sistema como agente:** "Não foi possível conectar" — nunca "você não tem conexão".
3. **Sem jargão de arquitetura:** `gate`, `bridge`, `scaffold`, `seeded`, `slice`, `bundle`, `token` — nunca em superfícies de usuário.
4. **Sem autoridade clínica:** O sistema descreve; o clínico decide. Prompts MSR reforçam isso explicitamente.
5. **Privacidade explícita:** Toda mensagem que toca dados de saúde explica o que é feito, por que e como controlar.
