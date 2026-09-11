# Índice de Achados — Frente Miguel

> Catálogo de descobertas técnicas durante a pesquisa de segurança. Cada FINDING documenta um bug, vulnerabilidade ou comportamento inesperado encontrado durante preparação ou execução de experimentos.

## Achados Descobertos

### Segurança de Autorização

| ID | Título | Severidade | Status | Experimento |
| --- | --- | --- | --- | --- |
| FINDING-001 | [Tool Authorization Precedence Bug](FINDING-001-tools-deny-precedence.md) | HIGH | Descoberto (OPS-028/029) | Preparação do EXP-001 |

---

## Achados Pendentes (TODO)

Quando novos achados forem descobertos durante experimentos, criar:
- `FINDING-002-...md`
- `FINDING-003-...md`
- etc.

Cada FINDING deve incluir:
- Descrição clara do bug/vulnerabilidade
- Reprodução passo-a-passo
- Impacto técnico
- Mitigação temporária (se aplicável)
- Recomendação de fix

---

## Como um Experimento Gera um FINDING

1. Durante execução de EXP-XXX, agente comporta-se inesperadamente
2. Investigação descobre bug/vulnerabilidade no OpenClaw
3. Documentar em novo arquivo `FINDING-NNN-descricao.md`
4. Atualizar este INDEX
5. Referenciar o FINDING no resultado do experimento

**Exemplo:**
- EXP-006 encontra bypass de autorização
- Cria FINDING-002 documentando exatamente como
- Resultado de EXP-006 referencia FINDING-002

---

## Referências

- [REGISTRO_OPERACIONAL_V1.md](../REGISTRO_OPERACIONAL_V1.md) — timeline operacional
- [ESPECIFICACOES_E_RESULTADOS_V1.md](../ambiente/ESPECIFICACOES_E_RESULTADOS_V1.md) — ambiente e resultados
- [INDEX-EXPERIMENTOS.md](../INDEX-EXPERIMENTOS.md) — lista de experimentos

