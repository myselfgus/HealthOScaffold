# UX Copy Guidelines — HealthOS
> Guia de tom, voz e padrões de mensagem para todos os alvos (CLI e apps GUI).

---

## 1. Princípios fundamentais

### Clareza antes de completude
Prefira uma frase curta e entendida a um parágrafo tecnicamente correto mas confuso. Se o clínico ou operador precisar reler, a mensagem falhou.

### Ação explícita
Toda mensagem de erro, alerta ou estado vazio deve responder: o que aconteceu, por que aconteceu e o que o usuário pode fazer a seguir.

### Precisão sem alarmismo
Em contextos de saúde, a linguagem imprecisa pode causar ansiedade desnecessária ou, pior, confiança indevida. Seja específico sobre o que o sistema fez — nunca sobre o que o clínico deve decidir clinicamente.

### Responsabilidade do sistema
O sistema erra, não o usuário. Use a voz passiva ou nomeie o sistema como agente: "Não foi possível conectar" em vez de "Você não tem conexão".

### Consistência de idioma
Todo o produto está em **português (pt-BR)**. Termos técnicos de arquitetura interna (gate, bundle, scaffold, bridge, seeded) nunca aparecem em superfícies voltadas ao usuário. Termos clínicos reconhecidos internacionalmente (SOAP, CID) podem ser usados com explicação na primeira ocorrência.

---

## 2. Tom e voz

| Dimensão | Direção |
|----------|---------|
| Formalidade | Profissional, respeitoso. Nem robótico, nem casual. |
| Empatia | Presente em erros e estados críticos. Ausente em ações rotineiras. |
| Precisão | Máxima. Nunca arredonde ou omita consequências de uma ação. |
| Confiança | Transmita que o sistema protege dados e flui de forma governada, sem exageros. |
| Autoridade clínica | Zero. O sistema auxilia; o clínico decide. Nunca sugira diagnósticos. |

### Voz em contextos específicos

- **Sucesso:** Conciso e informativo. Evite "Parabéns!" — prefira confirmação do que foi feito.
  - Antes: "Great! Session started."
  - Depois: "Sessão iniciada."

- **Erro:** Empático e orientador. Identifique o sistema como responsável.
  - Antes: "Error: invalid state"
  - Depois: "Não foi possível iniciar a sessão. Verifique sua conexão e tente novamente."

- **Aviso:** Direto, sem alarme. Indique o que pode ocorrer se nada for feito.
  - Antes: "Warning: degraded mode"
  - Depois: "O serviço de transcrição está operando em modo reduzido. Os resultados podem ser parciais."

- **Estado vazio:** Explique por que está vazio e convide à ação.
  - Antes: "No data."
  - Depois: "Nenhuma captura enviada. Envie a captura para ver a transcrição aqui."

- **Carregamento:** Defina expectativa e reduza ansiedade.
  - Antes: "Loading…"
  - Depois: "Processando captura… Isso pode levar alguns instantes."

- **Permissão / dados de saúde:** Explique o que é coletado, por que e como o usuário controla.
  - Antes: "Allow microphone access"
  - Depois: "O microfone é necessário para gravar a consulta. O áudio é processado localmente e não é compartilhado."

---

## 3. Antes/depois por categoria

### Títulos e seções

- Antes: `"1. Session Start"`
- Depois: `"Iniciar sessão"`
- Racional: Remove numeração rígida e traduz para o idioma do produto.

- Antes: `"2. Patient, Capture, Gate"`
- Depois: `"Paciente, Captura e Revisão"`
- Racional: "Gate" substituído por "Revisão", que é o conceito compreensível ao clínico.

- Antes: `"3. Slice Outputs"`
- Depois: `"Resultados da sessão"`
- Racional: "Slice" é jargão de engenharia; "Outputs" é inglês.

- Antes: `"4. Issues / Degraded / Deny"`
- Depois: `"Alertas e problemas"`
- Racional: Consolida três conceitos técnicos em linguagem funcional.

- Antes: `"Scribe First Slice Surface"`
- Depois: `"Superfície de sessão clínica — Scribe"`
- Racional: Describe o que o usuário vê, sem jargão de arquitetura.

### Botões e CTAs

- Antes: `"Open professional session"`
- Depois: `"Iniciar sessão profissional"`
- Racional: "Open" é ambíguo; "Iniciar" é mais preciso para o contexto clínico.

- Antes: `"Submit capture"`
- Depois: `"Enviar captura"`
- Racional: Traduz mantendo o verbo de ação.

- Antes: `"Approve gate"` / `"Reject gate"`
- Depois: `"Aprovar e finalizar"` / `"Rejeitar rascunho"`
- Racional: "Gate" oculto; consequências ficam explícitas.

- Antes: `"Advance to draft preview"`
- Depois: `"Visualizar rascunho"`
- Racional: Remove "Advance" que sugere progressão irreversível; "draft preview" → "rascunho".

- Antes: `"Choose audio file"`
- Depois: `"Selecionar arquivo de áudio"`
- Racional: Traduz e torna o verbo mais descritivo.

- Antes: `"Use seeded text instead"`
- Depois: `"Usar texto de exemplo"`
- Racional: Remove "seeded" (jargão) e traduz.

### Erros

- Antes: `"HealthOSCLI failed: \(error)"`
- Depois: `"[ERRO] HealthOS CLI: \(error.localizedDescription)\nVerifique o log e tente novamente."`
- Racional: Nomeia o produto, usa erro localizado, orienta ação.

- Antes: `"Session start failed: \(describeIssues(...))"`
- Depois: `"Não foi possível iniciar a sessão. Detalhes: \(describeIssues(...))"`
- Racional: Sistema como agente; detalhe preservado mas após contexto.

- Antes: `"Capture submission failed: \(describeIssues(...))"`
- Depois: `"Falha ao enviar captura. Detalhes: \(describeIssues(...))"`
- Racional: Traduz e humaniza.

- Antes: `"Gate resolution failed: \(describeIssues(...))"`
- Depois: `"Falha na revisão de portão. Detalhes: \(describeIssues(...))"`
- Racional: "Gate" → "portão" (ou simplesmente ocultar o termo técnico se o usuário for clínico).

- Antes: `"No demo patient available."`
- Depois: `"Nenhum paciente disponível no ambiente de demonstração."`
- Racional: Traduz e especifica o contexto (demo).

### Estados vazios

- Antes: `"Nenhuma captura submetida ainda."`
- Depois: `"Nenhuma captura enviada. Envie uma captura para ver a transcrição aqui."`
- Racional: Adiciona orientação de ação.

- Antes: `"Nenhum draft SOAP visivel ainda."`
- Depois: `"Nenhum rascunho SOAP disponível. Envie a captura e avance para o rascunho."`
- Racional: Sem acentuação corrigida; ação adicionada.

- Antes: `"Nenhum issue ativo no momento."`
- Depois: `"Nenhum alerta ativo."`
- Racional: "Issue" → "alerta"; mais conciso.

- Antes: `"Nenhum retrieval executado ainda."`
- Depois: `"Nenhuma busca de contexto realizada ainda."`
- Racional: "retrieval" → "busca de contexto".

### Carregamento e progresso

- Antes: `var lastAction = "bootstrap pending"`
- Depois: `var lastAction = "aguardando inicialização"`
- Racional: Traduz e remove jargão.

- Antes: `"bootstrapping demo environment"` (beginAction)
- Depois: `"inicializando ambiente de sessão"` (beginAction)
- Racional: Traduz; remove "demo" quando visível em contexto de produção.

---

## 4. Glossário — termos padronizados

### Termos aprovados

| Conceito técnico | Termo para UI (pt-BR) | Notas |
|---|---|---|
| Session | Sessão | Sempre com maiúscula em títulos |
| Capture | Captura | Pode ser qualificado: "captura de texto", "captura de áudio" |
| Draft / SOAP draft | Rascunho SOAP | SOAP pode ser mantido com nota na primeira ocorrência |
| Gate (review gate) | Revisão de portão | Em UX simplificado: apenas "Revisão" |
| Gate approve | Aprovar e finalizar | |
| Gate reject | Rejeitar rascunho | |
| Retrieval | Busca de contexto | Nunca "retrieval" para usuários |
| Transcript | Transcrição | |
| Transcript normalization | Normalização de transcrição | |
| GOS runtime | Sistema de governança | Ou ocultar completamente na UI |
| Bundle | Configuração de governança | Apenas para operadores, nunca clínicos |
| Habilitation | Habilitação | |
| Consent | Consentimento | |
| Provenance | Proveniência / rastreabilidade | Dependendo do contexto |
| MSR | MSR (Análise de Espaço Mental) | Explicar na primeira ocorrência |
| Referral draft | Rascunho de encaminhamento | |
| Prescription draft | Rascunho de prescrição | |
| Final document | Documento final | |
| Professional | Profissional de saúde | Em contextos formais |
| Patient | Paciente | |
| Smoke test | Teste de fumaça | Apenas em saídas técnicas/CLI |

### Termos proibidos em superfícies de usuário

| Termo proibido | Motivo | Alternativa |
|---|---|---|
| `scaffold` / `placeholder` | Jargão de maturidade de engenharia | Remover ou descrever o estado real |
| `bridge` | Arquitetura interna | Ocultar ou descrever por função |
| `seeded` | Jargão de teste | "de exemplo" ou "de demonstração" |
| `bootstrap` | Jargão de inicialização | "inicialização" ou "configuração" |
| `gate` (sozinho) | Ambíguo; jargão de governança | "revisão", "aprovação" ou "portão" |
| `bundle` | Jargão de empacotamento | "configuração" ou ocultar |
| `slice` | Jargão de arquitetura | Ocultar ou descrever por função |
| `rawValue` | Jargão de código | Nunca expor |
| `token` (para paciente/profissional) | Jargão de privacidade técnico | "identificador" ou ocultar |
| `pseudonimizado` | Jargão jurídico | Ocultar ou "anonimizado" em contexto simplificado |
| `first slice` | Jargão de fatia de produto | Ocultar |
| `degraded` (raw) | Inglês | "modo reduzido", "degradado" |

---

## 5. Padrões de mensagem

### Padrão: Erro

```
Estrutura: O que falhou + Por que (se possível) + O que fazer

Template:
"Não foi possível [ação]. [Causa se conhecida.] [Orientação de recuperação.]"

Exemplos:
- "Não foi possível enviar a captura. Verifique sua conexão e tente novamente."
- "Não foi possível iniciar a sessão. O serviço pode estar temporariamente indisponível."
- "Não foi possível abrir o arquivo de áudio. Verifique se o formato é suportado (ex.: .m4a, .mp3)."
```

### Padrão: Sucesso

```
Estrutura: O que foi feito (conciso) + Próximo passo opcional

Template:
"[Ação] concluída[.] [Próximo passo opcional.]"

Exemplos:
- "Sessão iniciada."
- "Captura enviada. Visualize o rascunho para revisar."
- "Rascunho aprovado. O documento final foi gerado."
```

### Padrão: Estado vazio

```
Estrutura: O que ainda não existe + Por que + Como iniciar

Template:
"Nenhum(a) [item] disponível. [Contexto.] [Ação para iniciar.]"

Exemplos:
- "Nenhuma transcrição disponível. Envie uma captura para gerar a transcrição."
- "Nenhum rascunho SOAP gerado. Avance para visualizar o rascunho após a captura."
- "Nenhum alerta ativo."
```

### Padrão: Carregamento

```
Estrutura: O que está acontecendo + Expectativa de tempo (se possível)

Template:
"[Processando/Gerando/Enviando] [item]… [Contexto de tempo se relevante.]"

Exemplos:
- "Processando captura… Isso pode levar alguns instantes."
- "Gerando rascunho SOAP…"
- "Inicializando sessão…"
```

### Padrão: Permissão / dados de saúde

```
Estrutura: O que é solicitado + Para que é usado + Controle do usuário

Template:
"[Permissão] necessária para [finalidade]. [Dados/uso.] [Como controlar.]"

Exemplos:
- "Acesso ao microfone necessário para gravar a consulta. O áudio é processado localmente e não é compartilhado externamente."
- "Este aplicativo armazena dados clínicos localmente. Você pode exportar ou excluir seus dados nas configurações."
- "A sessão será registrada para fins de auditoria clínica conforme exigido pela regulação vigente."
```

---

## 6. Regras de internacionalização (i18n)

- Nunca concatenar strings dinâmicas: use interpolação estruturada com placeholders nomeados.
  - Errado: `"Arquivo " + filename + " não encontrado."`
  - Certo: `String(format: NSLocalizedString("file.not_found", comment: ""), filename)`
- Evite pressuposições de gênero gramatical em mensagens reutilizáveis.
- Nomes de ações e entidades clínicas devem ser externalizados em `.strings` ou `Localizable.xcstrings`.
- Não use emojis ou ícones como único indicador de estado — complementem texto.
- Deixe 30% de espaço extra para expansão em outras línguas (alemão, espanhol são mais longos).
