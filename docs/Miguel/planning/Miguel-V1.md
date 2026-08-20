# Plano de trabalho — frente Miguel (V1)

> Documento vivo da branch `Miguel`, criado para orientar, registrar e tornar reproduzível a contribuição individual ao projeto. Ele detalha a execução local a partir de `planning/PROJECT_PLAN_V1.md`; em caso de divergência de escopo, prevalecem os limites éticos e operacionais do plano central e as orientações do projeto.

## 1. Propósito e resultado esperado

Esta frente de trabalho busca transformar o tema amplo de segurança em agentes OpenClaw em uma sequência de investigação verificável: compreender o ambiente, mapear superfícies de ataque e fronteiras de confiança, construir cenários sintéticos seguros, medir o comportamento observado e, somente então, priorizar controles defensivos.

O resultado não será apenas uma lista de riscos. Cada conclusão deverá estar associada a uma hipótese, uma configuração reproduzível, evidências minimizadas e uma decisão técnica registrada. Sempre que um controle for implementado ou proposto, ele será comparado a um comportamento de referência para permitir avaliar benefício, custo operacional e limitações.

## 2. Escopo desta frente

### Incluído

- Análise da instalação e da configuração do OpenClaw utilizada como laboratório autorizado.
- Inventário de ativos, permissões, integrações, modelos, arquivos de configuração e fontes de contexto.
- Estudo de riscos em entrada/contexto, uso de ferramentas, integridade de configuração, extensões e delegação entre agentes ou subagentes.
- Construção de testbed isolado, dados sintéticos, casos de teste e mecanismos defensivos em modo de observação antes de qualquer bloqueio.
- Documentação técnica, automação de verificações e registro de decisões e resultados.

### Excluído

- Testes contra serviços públicos, contas de terceiros, sistemas em produção ou pessoas fora do ambiente autorizado.
- Uso, armazenamento ou publicação de credenciais, identificadores pessoais, e-mails, chaves, tokens, endereços internos ou conteúdo real de conversas.
- Divulgação de procedimentos que ampliem indevidamente a exploração de uma falha antes de avaliação responsável.

## 3. Estado inicial conhecido

O laboratório possui duas VMs Ubuntu Server 22.04.5 LTS virtualizadas por KVM. OpenClaw está disponível nas duas, e a VM de servidor de testes possui OpenClaw **2026.7.1-2** (build `0790d9f`) com a configuração de modelo de referência. A instalação possui um modelo principal baseado em OpenAI e também modelos configurados de OpenAI e OpenRouter, incluindo uma opção de modelo de raciocínio e um modelo alternativo gratuito.

No estado registrado, não há fallback de execução ativado. Assim, o modelo alternativo configura uma possibilidade de teste ou de futura contingência, mas não deve ser tratado como fallback automático até que isso seja configurado e validado. A autenticação do provedor principal está operacional segundo o diagnóstico local; detalhes de perfil, conta, saldo, validade de sessão, caminhos de banco de dados e qualquer segredo são deliberadamente omitidos deste documento.

Antes de modificar essa configuração, será gerado um inventário sanitizado que descreva apenas: versão, componentes, tipos de integração, permissões efetivas, política de fallback e presença de segredos — nunca seus valores.

As VMs estão em uma rede acadêmica controlada, porém compartilhada com outros ambientes autorizados e com conectividade externa necessária para as APIs. Não há isolamento de rede exclusivo do projeto. Nesta fase, o isolamento da pesquisa será aplicado por escopo, permissões e destinos sintéticos: experimentos devem interagir apenas com os recursos explicitamente autorizados para o projeto, sem descoberta ou teste contra outros equipamentos da sub-rede. Não haverá uso de snapshot ou backup operacional nesta fase; por isso, as mudanças devem ser pequenas, reversíveis e registradas antes da execução.

O baseline de execução atual é permissivo: o agente principal opera diretamente no host, sem sandbox ativo, e a execução de comandos possui autorização efetiva ampla sem confirmação interativa. Esse baseline será tratado como objeto de análise, não como ambiente para receber conteúdo não confiável. Os primeiros cenários com entradas potencialmente adversariais exigem perfil/configuração de teste separada com permissões reduzidas ou, na ausência disso, execução estritamente observacional sem ferramentas de efeito externo.

## 4. Princípios de execução

1. **Ambiente isolado primeiro.** Experimentos ocorrerão em VM, container ou rede privada controlada, com dados e identidades sintéticas.
2. **Privilégio mínimo.** O agente, suas ferramentas e subagentes receberão somente as permissões necessárias para cada cenário.
3. **Observação antes de bloqueio.** Um controle novo deve inicialmente registrar a decisão em modo de auditoria; o bloqueio será considerado após análise de falsos positivos e impacto.
4. **Reprodutibilidade.** Toda execução relevante terá versão do software, configuração sanitizada, roteiro, artefatos e resultado esperados registrados.
5. **Separação de proveniência.** Conteúdo externo deve ser distinguido de instruções confiáveis; informação recebida não equivale a autorização para agir.
6. **Minimização de evidência.** Logs devem conter apenas o necessário para sustentar a análise, com dados sintéticos ou redigidos.
7. **Decisão orientada por evidência.** Hipóteses podem ser descartadas; esse resultado também é útil e deve ser documentado.

## 5. Fases de trabalho

| Fase | Objetivo | Atividades principais | Critério de saída |
| --- | --- | --- | --- |
| F0 — Preparação | Garantir segurança e rastreabilidade | Validar isolamento, criar convenções de registro e inventário sanitizado | Ambiente autorizado e checklist de segurança aprovados para uso |
| F1 — Reconhecimento técnico | Entender como a instalação opera | Mapear arquitetura, fluxos de contexto, ferramentas, permissões e configurações | Diagrama de confiança e inventário de ativos concluídos |
| F2 — Modelagem de ameaças | Priorizar hipóteses de pesquisa | Identificar atores, ativos, fronteiras, abusos e impacto; classificar riscos | Backlog priorizado com cenários sintéticos e critérios de parada |
| F3 — Testbed e baseline | Medir o comportamento sem nova defesa | Criar cenários seguros, instrumentação e repetição controlada | Casos de teste reproduzíveis e baseline registrado |
| F4 — Controles defensivos | Projetar e testar mitigação | Prototipar controles, primeiro em auditoria; testar regressões | Comparação baseline/defesa e decisão de adoção ou descarte |
| F5 — Consolidação | Transformar achados em resultado técnico | Revisar evidências, automatizar verificações e redigir documentação | Entregáveis versionados e comunicação responsável avaliada |

As fases podem se sobrepor quando houver uma evidência que justifique isso, porém uma experiência não deve avançar de F2 para F3 sem cenário sintético, métrica e critério de interrupção definidos.

## 6. Detalhamento das atividades

### F0 — Preparação do laboratório

- Confirmar que as VMs e a rede estão no escopo autorizado, que não há dados de produção disponíveis ao agente e que os destinos de teste são exclusivamente os autorizados.
- Registrar versão do OpenClaw, sistema operacional, método de instalação e componentes ativos, sem copiar arquivos sensíveis.
- Criar uma configuração de teste separada da configuração de uso cotidiano; preservar o original sem expor seu conteúdo.
- Definir local de logs, retenção, redatores de dados sensíveis e procedimento de limpeza de artefatos sintéticos.
- Estabelecer convenções de nomes para cenários, execuções e evidências.

**Entrega:** checklist de segurança do laboratório e inventário sanitizado da instalação.

### F1 — Inventário e fronteiras de confiança

- Identificar de onde o agente recebe instruções e dados: conversa direta, arquivos, páginas, mensagens, extensões, memória e resultados de ferramentas.
- Mapear as ações possíveis: leitura/escrita de arquivos, comandos, rede, navegador, mensageria, instalação de extensões e delegação.
- Registrar permissões por componente, quem as concede e o que ocorreria caso o componente fosse influenciado por conteúdo não confiável.
- Diferenciar configuração estática, configuração gerada em execução e estado persistente do agente.
- Produzir um diagrama simples com fontes de contexto, agente, política de autorização, ferramentas, armazenamento e saídas externas.

**Entrega:** inventário de ativos e diagrama de fronteiras de confiança.

### F2 — Taxonomia e priorização de ameaças

Cada hipótese será registrada com ativo afetado, pré-condições, origem do conteúdo, fronteira cruzada, ação indevida possível, impacto, evidência necessária e mitigação candidata. A classificação pode usar CVSS 3.1 quando aplicável, sem substituir a análise contextual de agentes.

Prioridades iniciais:

1. **Injeção indireta de contexto:** conteúdo externo tentando alterar objetivos, expor informação ou induzir uso de ferramentas.
2. **Autorização de ferramentas:** decisão do modelo sendo confundida com permissão para executar uma ação de efeito externo.
3. **Integridade de configuração e instruções:** alteração não autorizada de arquivos ou estados que definem o comportamento do agente.
4. **Cadeia de extensões:** procedência, revisão, permissões e isolamento de habilidades instaladas.
5. **Delegação entre agentes:** propagação indevida de contexto, permissões ou tarefas entre agente principal e subagentes.

**Entrega:** backlog priorizado de ameaças, com uma primeira hipótese de baixo risco selecionada para baseline.

### F3 — Cenários seguros e baseline

Os cenários utilizarão documentos, páginas, arquivos, ferramentas simuladas e identidades fictícias. Eles devem demonstrar somente o comportamento necessário para medir a hipótese, sem tocar dados reais ou destinos externos.

Para cada cenário:

1. Definir a pergunta de pesquisa e a condição que caracteriza sucesso, falha ou resultado inconclusivo.
2. Criar entradas sintéticas e registrar sua proveniência como confiável ou não confiável.
3. Fixar versão, configuração sanitizada, permissões e número de repetições.
4. Executar o baseline sem a nova defesa e coletar logs mínimos.
5. Validar se o resultado pode ser reproduzido antes de interpretar seu impacto.

Métricas iniciais: taxa de acionamento indevido, taxa de bloqueio correto, falsos positivos, falsos negativos, latência adicional, cobertura de eventos e estabilidade entre repetições.

**Entrega:** suíte inicial de cenários e relatório de baseline.

### F4 — Controles defensivos

As direções do plano geral serão avaliadas de forma incremental:

- **D1 — Proveniência de contexto:** marcar e manter a origem de conteúdo externo, impedindo que ele seja interpretado automaticamente como instrução de autoridade superior.
- **D2 — Integridade:** detectar mudanças inesperadas em configuração, instruções e extensões por meio de inventário, hash ou assinatura, conforme viabilidade.
- **D3 — Política de ferramentas:** colocar uma camada determinística de autorização entre intenção do modelo e execução da ferramenta, considerando ação, destino, parâmetros, origem e risco.
- **D4 — Extensões:** revisar procedência, permissões declaradas, dependências e possibilidade de execução isolada antes de habilitar uma habilidade.

Cada controle começará em modo de auditoria. A transição para bloqueio exige evidência de que ele reduz o comportamento indesejado e não impede fluxos legítimos definidos no cenário.

**Entrega:** protótipo ou especificação de controle, testes automatizados e comparação com baseline.

### F5 — Consolidação e comunicação

- Revisar resultados e separar observações, inferências e limitações.
- Reexecutar cenários essenciais após atualização de versão ou mudança de configuração relevante.
- Organizar artefatos que possam ser publicados com segurança: dados sintéticos, scripts de preparação, testes e documentação.
- Caso surja uma vulnerabilidade concreta, preparar relato responsável com impacto, pré-condições, evidência mínima e correção sugerida; não divulgar detalhes exploráveis antes de coordenar a comunicação.

**Entrega:** relatório técnico, matriz de evidências, documentação de reprodução segura e materiais de divulgação aprovados.

## 7. Protocolo obrigatório para experimentos

Nenhum experimento será iniciado sem este registro mínimo:

```text
ID do cenário:
Hipótese:
Ativo e fronteira de confiança:
Ambiente e versões:
Dados sintéticos utilizados:
Permissões e ferramentas habilitadas:
Procedimento de execução:
Métrica(s) e número de repetições:
Critério de parada:
Evidências permitidas e redações aplicadas:
Resultado / limitação / próxima decisão:
```

O critério de parada deve incluir interrupção imediata se houver tentativa de acesso a recurso fora do laboratório, solicitação de segredo, contato externo não previsto ou comportamento que exceda o cenário autorizado.

## 8. Organização dos artefatos e rastreabilidade

Os documentos e artefatos deverão usar identificadores estáveis, por exemplo `THR-001` para ameaça, `EXP-001` para experimento, `CTRL-001` para controle e `DEC-001` para decisão. Uma execução pode então relacionar, de forma rastreável, `THR-001 → EXP-001 → CTRL-001 → DEC-001`.

Registros de configuração devem ser sanitizados: reter nomes genéricos de provedores, categorias de modelos, versão, flags e permissões necessárias; remover identificadores de conta, e-mails, tokens, chaves, caminhos privados, IDs de sessão e saídas de diagnóstico que os revelem. Segredos não devem entrar no Git, em capturas de tela, logs de teste ou documentação.

## 9. Riscos do próprio projeto e mitigação

| Risco | Mitigação |
| --- | --- |
| Exposição acidental de segredo ou dado pessoal | Usar dados sintéticos, revisar diffs e logs antes de versionar e redigir evidências. |
| Cenário afetar ambiente externo | Isolamento de rede, destinos simulados, permissões mínimas e critério de parada. |
| Conclusão baseada em execução isolada | Repetições controladas, baseline e registro de versões/configuração. |
| Defesa bloquear uso legítimo | Modo de auditoria, métricas de falso positivo e testes de regressão. |
| Atualização alterar o comportamento estudado | Fixar a versão por experimento e revalidar a suíte essencial após atualizações. |
| Divulgação prematura de achado sensível | Tratamento responsável, acesso restrito às evidências e coordenação antes da publicação. |

## 10. Próximas ações imediatas

1. Criar o checklist do laboratório e o inventário sanitizado da VM/OpenClaw na versão de referência.
2. Desenhar a arquitetura e as fronteiras de confiança da instalação atual.
3. Abrir a primeira entrada de ameaça para injeção indireta de contexto e definir um cenário inteiramente sintético.
4. Preparar uma ferramenta ou destino simulado para observar decisões sem efeito externo.
5. Registrar o baseline, revisar os dados coletados e escolher entre D1 e D3 como primeiro controle defensivo a avaliar.

## 11. Critérios de acompanhamento

O plano será revisado ao final de cada fase, após cada descoberta relevante ou sempre que houver mudança de versão, configuração ou permissões. Uma atividade só será marcada como concluída quando sua entrega estiver versionada, sem dados sensíveis, e ligada a uma evidência ou decisão.

Perguntas que exigem decisão antes de avançar além da preparação:

- Qual mecanismo de isolamento estará disponível para o testbed (VM dedicada, container, ou ambos)?
- Quais integrações e ferramentas poderão ser habilitadas no laboratório, e quais deverão ser obrigatoriamente simuladas?
- Quem revisará resultados potencialmente sensíveis e autorizará eventual comunicação aos mantenedores?

## Referências internas

- [Planejamento geral do projeto](../../../planning/PROJECT_PLAN_V1.md)
- [Registro operacional da frente Miguel](REGISTRO_OPERACIONAL_V1.md)
- [Tutorial de configuração do dashboard](../../Tutorials/openclaw-dashboard-configuracao.md)
- [Tutorial de OpenClaw em Ubuntu](../../Tutorials/OPENCLAW_UBUNTU.md)
