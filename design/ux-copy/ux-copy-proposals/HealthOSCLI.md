# Proposta de UX Copy — HealthOSCLI
> Revisões de help, flags, erros, saídas e exemplos de uso. Foco: operadores técnicos e de governança.

---

## Contexto

HealthOSCLI é a interface de linha de comando para operadores e engenheiros. Não é usada por clínicos diretamente. O público é técnico, mas precisa de mensagens claras, rastreáveis e orientadas a ação. Atualmente o CLI mistura inglês e português, expõe jargão de arquitetura e não diferencia tipos de falha.

---

## Problema 1 — Saída de sucesso da fatia principal

**Local:** `CLIEntrypoint.swift:73`

- Antes: `"HealthOS first slice complete"`
- Depois:
```
--- HealthOS: sessão clínica concluída ---
```
- Racional: Separador visual clarifica o início do bloco de saída de sucesso; "first slice" substituído por descrição funcional.
- Impacto UX: Operadores identificam imediatamente o resultado sem precisar parsear chave=valor.
- Riscos/Dependências: Nenhum — saída de texto não estruturada para operadores humanos.

---

## Problema 2 — Falha fatal genérica

**Local:** `CLIEntrypoint.swift:97` (bloco `catch`)

- Antes: `"HealthOSCLI failed: \(error)\n"`
- Depois:
```
[ERRO] HealthOS CLI: \(error.localizedDescription)
Verifique o log acima para detalhes técnicos e tente novamente.
```
- Racional: Usa `localizedDescription` (mais legível); separa a mensagem de contexto do erro bruto; orienta ação.
- Impacto UX: Reduz tempo de diagnóstico do operador; identifica se é erro de configuração, dados ou runtime.
- Riscos: Erros sem `localizedDescription` adequado exibirão mensagem genérica — garantir que `CLIError.errorDescription` esteja sempre preenchido.

---

## Problema 3 — Resolução de runtime-data falhou

**Local:** `CLIEntrypoint.swift:resolveRuntimeRoot`

- Antes: `"Could not resolve runtime-data root for GOS promotion command."`
- Depois:
```
Não foi possível localizar o diretório runtime-data.
Execute o comando a partir da raiz do repositório, ou verifique se o diretório existe:
  <raiz>/runtime-data/Users/Shared/HealthOS
```
- Racional: Indica o caminho esperado; instrução de recuperação concreta.
- Impacto UX: Elimina pesquisa de "onde fica o runtime-data" em doc.
- Riscos: Caminho hardcoded na mensagem pode ficar defasado se a estrutura mudar.

---

## Problema 4 — Saídas de GOS bundle review/promote

**Local:** `CLIEntrypoint.swift:15–50`

- Antes:
```
gos_bundle_reviewed=true
gos_spec_id=aaci.first-slice
gos_bundle_id=<uuid>
gos_review_record_id=<uuid>
gos_reviewer_id=<id>
gos_reviewer_role=operator
```
- Depois:
```
--- Bundle GOS revisado com sucesso ---
spec_id=aaci.first-slice
bundle_id=<uuid>
review_record_id=<uuid>
reviewer_id=<id>
reviewer_role=operator
```
- Racional: Cabeçalho explícito; remove prefixo redundante `gos_` em cada linha; mais scaneável.
- Impacto UX: Operadores confirmam sucesso sem ambiguidade; scripts de CI podem parsear o cabeçalho.
- Riscos: Scripts existentes que parseem `gos_bundle_reviewed=true` precisarão ser atualizados.

---

## Problema 5 — Captura de texto padrão (hardcoded)

**Local:** `CLIEntrypoint.swift:makeCaptureInput`

- Antes: captura silenciosa com texto clínico de exemplo
- Depois: exibir aviso visível quando captura padrão for usada:
```
[AVISO] Usando captura de demonstração. Não use em sessão clínica real.
Texto: "Paciente relata dor de cabeça, insônia e piora do sono há uma semana."
```
- Racional: O dado clínico de exemplo não deve passar despercebido por operadores.
- Impacto UX: Previne uso acidental de captura demo em ambientes que não sejam de teste.
- Riscos/Dependências: Nenhum para a CLI; verificar se a saída vai para stdout ou stderr.

---

## Problema 6 — Transcript/final document não disponíveis

**Local:** `CLIEntrypoint.swift:84–95`

- Antes:
```
transcript=<not available>
final_document=<not effectuated>
```
- Depois:
```
transcript=nao_disponivel
final_document=nao_efetivado  # gate rejeitado — documento final não gerado
```
- Racional: Remove tags HTML-like; adiciona comentário inline para leitura humana.
- Impacto UX: Legível sem interpretação adicional.
- Riscos: Parsers de CI que busquem `<not available>` precisarão ser atualizados.

---

## Proposta de layout de `--help` (não implementado atualmente)

```
HealthOS CLI — Interface de linha de comando para operadores

USO
  healthos-cli [OPÇÕES]

OPÇÕES PRINCIPAIS
  --audio-file <caminho>         Usa arquivo de áudio local como captura
  --reject-gate                  Rejeita o portão de revisão (resultado: sem documento final)

GESTÃO DE BUNDLES GOS
  --gos-review-bundle <id>       Revisa um bundle GOS
  --gos-promote-bundle <id>      Promove um bundle GOS revisado para ativo
  --gos-spec-id <id>             ID da especificação GOS (padrão: aaci.first-slice)
  --reviewer-id <id>             Identificador do revisor (padrão: usuário atual)
  --review-rationale <texto>     Justificativa da revisão (obrigatório em produção)

EXEMPLOS
  # Executar fatia completa com aprovação de portão
  healthos-cli

  # Rejeitar portão (documento final não é gerado)
  healthos-cli --reject-gate

  # Revisar bundle de governança
  healthos-cli --gos-review-bundle <id> --gos-spec-id aaci.first-slice \
    --reviewer-id op-123 --review-rationale "Revisão semanal de governança"

SAÍDAS
  Todas as saídas são em formato chave=valor. Erros são escritos em stderr.
  Exit code 0 = sucesso; 1 = falha.

DOCUMENTAÇÃO
  docs/architecture/ — arquitetura de componentes
  docs/execution/    — protocolos operacionais
```

- Racional: Estrutura clara com seções; exemplos concretos; documentação referenciada.
- Impacto UX: Operadores não precisam inspecionar o código-fonte para entender os flags.
- Dependências: Implementar parsing de `--help` no `CLIEntrypoint.swift`.
