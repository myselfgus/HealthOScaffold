# Proposta de UX Copy — HealthOSCloudClinicApp
> Revisões para o app de operações profissionais e de serviço. Foco: operadores técnicos e profissionais de saúde em contexto organizacional.

---

## Contexto

HealthOSCloudClinicApp é a interface de operações profissionais e de serviço do HealthOS. Atualmente é um scaffold sem UI final — o único texto visível está nas saídas de `--smoke-test` e do modo padrão. O público inclui operadores de serviço de saúde e profissionais. A linguagem deve ser clara, profissional e sem jargão de engenharia.

---

## Fluxo 1 — App iniciado sem argumento (modo interativo não disponível)

**Contexto:** Usuário abre o app sem argumentos. Recebe mensagem de estado.

- Antes:
```
"HealthOSCloudClinic: scaffold placeholder - no final UI shell, no session behavior, no clinical authority (see docs/architecture/13-cloudclinic.md)"
```
- Depois:
```
CloudClinic — Operações de Serviço de Saúde

Esta versão do aplicativo ainda não possui interface interativa completa.
Para validação técnica, use: --smoke-test
```
- Racional: Apresenta o produto; remove jargão de maturidade e referência interna; oferece alternativa.
- Impacto UX: Menos dissonante para quem recebe a saída em ambiente de demonstração.

---

## Fluxo 2 — Smoke test: sucesso

**Contexto:** Operador executa `--smoke-test`.

- Antes:
```
"HealthOSCloudClinic scaffold: smoke OK (no final UI, no clinical authority)"
```
- Depois:
```
CloudClinic: teste de fumaça concluído.
Interface final e autoridade clínica pendentes para versão de produção.
```
- Racional: Remove "scaffold"; "smoke OK" → "concluído"; limitações expressas de forma neutra.
- Impacto UX: Saída profissional; operadores entendem o estado sem precisar de contexto de engenharia.

---

## Mensagens futuras de UI (planejamento)

Com base nos contratos de `ServiceOperationsContracts.swift`, as seguintes mensagens são recomendadas:

### Tela inicial / dashboard
- **Título:** `"CloudClinic — Painel de Operações"`
- **Subtítulo:** `"Gerencie serviços, profissionais e relatórios operacionais."`

### Lista de serviços vazia
- **Empty state:** `"Nenhum serviço cadastrado. Cadastre o primeiro serviço para começar a operar."`
- **CTA:** `"Cadastrar serviço"`

### Lista de profissionais vazia
- **Empty state:** `"Nenhum profissional vinculado a este serviço. Adicione profissionais para habilitar sessões."`
- **CTA:** `"Adicionar profissional"`

### Sessão em andamento — alerta de governança
- **Título:** `"Revisão pendente"`
- **Corpo:** `"Esta sessão aguarda revisão de portão antes de gerar o documento final. Acesse a seção de revisão para aprovar ou rejeitar."`
- **CTA:** `"Revisar agora"`

### Relatório — estado vazio
- **Empty state:** `"Nenhum relatório disponível para o período selecionado. Ajuste o intervalo de datas ou aguarde a conclusão de sessões."`

### Erro de configuração de serviço
- **Título:** `"Configuração incompleta"`
- **Corpo:** `"O serviço [nome] não está completamente configurado. Complete as informações antes de iniciar sessões."`
- **CTA:** `"Configurar serviço"`

### Sincronização de dados
- **Estado:** `"Sincronizando dados do serviço…"`
- **Sucesso:** `"Dados sincronizados."`
- **Erro:** `"Não foi possível sincronizar. Verifique sua conexão e tente novamente."`

### Confirmação de ação destrutiva (ex.: encerrar serviço)
- **Título:** `"Encerrar serviço?"`
- **Corpo:** `"Esta ação encerra todas as sessões ativas e desvincula os profissionais do serviço [nome]. Esta ação não pode ser desfeita."`
- **CTAs:** `"Encerrar serviço"` / `"Cancelar"`

---

## Padronização de termos para CloudClinic

| Conceito técnico | Termo aprovado | Notas |
|---|---|---|
| Service | Serviço | Sempre com maiúscula em títulos |
| Professional | Profissional | |
| Session | Sessão | |
| Sync | Sincronizar / Sincronização | |
| Report | Relatório | |
| Dashboard | Painel | Em contexto pt-BR |
| Config | Configuração | |
| Bundle GOS | Configuração de governança | Apenas para operadores técnicos |
| Governance spec | Especificação de governança | |
