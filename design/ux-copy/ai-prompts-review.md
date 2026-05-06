# Revisão de Prompts de IA — HealthOSMSR/Prompts
> Avaliação de consistência de tom, clareza, mitigação de vieses, privacidade e segurança nos prompts do pipeline MSR (ASL → VDLP → GEM).

---

## Visão geral

Os prompts do MSR são prompts de sistema enviados a modelos de linguagem (Claude Sonnet/Haiku) para análise psicolinguística clínica. São altamente técnicos, em português, e estruturados para produzir JSON determinístico. O público dos prompts é o modelo de IA, não o usuário final — mas falhas de instrução têm impacto direto nos outputs que chegam ao clínico.

### Arquivos avaliados
- `Prompts/asl-system.md` — Análise Sistêmica da Linguagem
- `Prompts/vdlp-system.md` — Vetores-Dimensão do Espaço-Campo Mental
- `Prompts/gem-system.md` — Grafo do Espaço-Campo Mental

---

## Avaliação global

### Pontos fortes
- Missão e princípios estão declarados explicitamente em cada prompt.
- Regras críticas de "NUNCA/SEMPRE" são claras e diretas.
- Esquema JSON é completo e detalhado.
- Instruções de temperatura, timeout e caching estão nos implementation notes.

### Riscos identificados
- **Linguagem clínica sem limitação de escopo:** prompts usam termos como "perfil psicolinguístico" e "espaço mental" sem indicar ao modelo que esses são construtos analíticos, não diagnósticos clínicos.
- **Saída JSON sem aviso de privacidade:** nenhum prompt instrui o modelo a não incluir dados identificadores na saída.
- **Citações literais de fala do paciente:** os prompts exigem `evidencias_textuais` com citações literais — isso é útil para rastreabilidade, mas é dado sensível que deve ser tratado como PHI.
- **`sintese_interpretativa` no ASL:** o campo `consideracoes_finais` pode induzir o modelo a fazer afirmações clínicas além da análise linguística.
- **Ausência de disclaimers de limitação nos prompts:** nenhum prompt instrui o modelo a declarar os limites de sua análise na saída.

---

## Revisão 1 — ASL: risco de linguagem clínica na síntese

**Arquivo:** `asl-system.md` — Parte 1, REGRAS CRÍTICAS

**Trecho atual:**
```
✅ SEMPRE: analisar APENAS o paciente; citar exemplos literais; comparar com norma; interpretar no contexto
```

**Problema:** "interpretar no contexto" é abrangente demais e pode levar o modelo a inferências clínicas não autorizadas na `sintese_interpretativa`.

**Proposta:**
```
✅ SEMPRE:
- Analisar APENAS o paciente
- Citar exemplos literais e rastreáveis
- Comparar métricas com fala típica de adultos
- Interpretar no contexto linguístico e psicolinguístico — nunca clínico ou diagnóstico
- Indicar limitações da análise em `limitacoes_analise`
```

**Racional:** Adiciona o qualificador "linguístico e psicolinguístico — nunca clínico ou diagnóstico" para reduzir o risco de afirmações além do escopo.

---

## Revisão 2 — ASL: campo `consideracoes_finais` sem limite de escopo

**Arquivo:** `asl-system.md` — Part 2, campo JSON

**Trecho atual:**
```
"sintese_interpretativa": { "perfil_linguistico_geral", "achados_mais_salientes", "padroes_integrados", "consideracoes_finais", "limitacoes_analise" }
```

**Problema:** `consideracoes_finais` não tem instrução de escopo — o modelo pode gerar considerações clínicas ou diagnósticas.

**Proposta:** Adicionar instrução explícita no User Prompt Template:
```
RESTRIÇÃO: Qualquer consideração final deve se limitar a padrões linguísticos e psicolinguísticos observados.
Não faça afirmações diagnósticas, prognósticas ou de recomendação clínica.
```

**Racional:** Limita o escopo da saída sem eliminar o campo, que tem valor analítico legítimo.

---

## Revisão 3 — VDLP: scores dimensionais sem aviso de uso indireto

**Arquivo:** `vdlp-system.md` — Parte 1, PRINCÍPIOS FUNDAMENTAIS

**Trecho atual:**
```
2. VALIDAÇÃO CIENTÍFICA: cada dimensão ancorada em frameworks validados (RDoC, HiTOP, Big5, PERMA)
```

**Problema:** Citar frameworks diagnósticos (RDoC, HiTOP) sem disclaimers pode fazer o modelo ou o consumidor do output tratar scores VDLP como instrumentos diagnósticos validados.

**Proposta:** Adicionar princípio explícito:
```
6. LIMITES DE USO: scores dimensionais são instrumentos de análise psicolinguística para apoio clínico.
   Não constituem diagnóstico, não substituem avaliação clínica, e devem ser revisados por profissional habilitado.
```

**Racional:** Alinha o prompt com o modelo de governança do HealthOS (clínico decide, sistema apoia).

---

## Revisão 4 — GEM: linguagem prognóstica sem ressalva

**Arquivo:** `gem-system.md` — System Prompt, camada `.epe`

**Trecho atual:**
```
.epe (Emergenable Pathways) — PROGNÓSTICO
  Caminhos emergenáveis — trajetórias de transformação POTENCIAL (o que pode acontecer).
```

**Problema:** A palavra PROGNÓSTICO em maiúsculas sem ressalva pode ser interpretada como prognóstico clínico real, especialmente em consumo downstream.

**Proposta:**
```
.epe (Emergenable Pathways) — ANÁLISE DE POTENCIAL (não constitui prognóstico clínico)
  Caminhos emergenáveis — trajetórias de transformação POTENCIAL identificadas no discurso.
  AVISO: Esta análise é especulativa e baseada em padrões linguísticos. Não constitui prognóstico
  clínico e deve ser interpretada por profissional habilitado.
```

**Racional:** Remove ambiguidade; adiciona aviso que pode ser propagado ao output JSON.

---

## Revisão 5 — GEM: `key_insights` sem limitação de conteúdo

**Arquivo:** `gem-system.md` — Output Structure

**Trecho atual:**
```
"key_insights": ["string x5"],
```

**Problema:** Sem instrução de conteúdo, `key_insights` pode conter afirmações clínicas diretas sobre o paciente (ex.: "paciente apresenta sintomas depressivos").

**Proposta:** Adicionar instrução no User Prompt Template:
```
RESTRIÇÃO para key_insights:
- Limite-se a padrões observados no discurso
- Use linguagem descritiva, nunca diagnóstica
- Evite afirmações sobre estado clínico, diagnóstico ou prognóstico
- Exemplo aceitável: "Discurso apresenta alta frequência de orientação temporal passada e baixa agência"
- Exemplo inaceitável: "Paciente apresenta quadro depressivo com ruminação"
```

**Racional:** Define o tom correto para um campo de linguagem livre que tem alto risco de drift para afirmações clínicas.

---

## Revisão 6 — Todos os prompts: ausência de instrução de privacidade

**Arquivo:** Todos (`asl-system.md`, `vdlp-system.md`, `gem-system.md`)

**Problema:** Nenhum prompt instrui o modelo a tratar transcrições clínicas como dados sensíveis ou a não incluir identificadores nos outputs. O campo `metadata.falante_id` é um vetor de risco.

**Proposta:** Adicionar em todos os prompts, na seção de REGRAS CRÍTICAS:
```
PRIVACIDADE:
❌ NUNCA: incluir nome real, CPF, data de nascimento, endereço ou qualquer identificador direto na saída JSON
✅ SEMPRE: usar apenas o falante_id fornecido como referência ao paciente
✅ SEMPRE: tratar a transcrição clínica como dado sensível — não reproduzi-la além do necessário para evidências
```

**Racional:** A transcrição clínica é PHI (Protected Health Information). O modelo não deve propagar dados além do mínimo necessário para a análise.

---

## Resumo de prioridade das revisões de prompts

- **P0 (crítico):** Revisões 5 (key_insights sem limite) e 6 (privacidade ausente) — risco direto de saída clínica indevida ou vazamento de PHI.
- **P1 (importante):** Revisões 1 (ASL síntese), 2 (consideracoes_finais) e 4 (GEM prognóstico) — risco de linguagem diagnóstica.
- **P2 (melhoria):** Revisão 3 (VDLP disclaimers de frameworks) — risco de interpretação incorreta downstream.
