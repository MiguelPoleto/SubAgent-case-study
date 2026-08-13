# Planejamento do projeto V1 — Segurança no ecossistema OpenClaw e agentes autônomos

> Documento vivo baseado na proposta submetida ao PICTI 2026. Ele preserva o contexto e os objetivos de pesquisa, mas não substitui a proposta nem impõe o cronograma original. As prioridades e a ordem das atividades podem mudar conforme os achados, a viabilidade técnica e a orientação do projeto.

## Contexto

Agentes autônomos baseados em LLM podem executar comandos, manipular arquivos, usar navegador, integrar mensageria, consumir extensões e coordenar subagentes. Essas capacidades tornam o OpenClaw um caso relevante para estudar segurança de sistemas agentivos: dados e instruções de origens distintas podem influenciar ações com efeitos no ambiente e na cadeia de ferramentas.

A pesquisa tem caráter aplicado. O foco é entender, medir e reduzir riscos de segurança em um ambiente controlado, contribuindo com conhecimento reproduzível e melhorias defensivas para o ecossistema OpenClaw.

## Objetivo norteador

Investigar vulnerabilidades de segurança no ecossistema OpenClaw e em padrões aplicáveis a agentes autônomos e subagentes, validar hipóteses apenas em ambiente isolado e desenvolver mecanismos de defesa que reduzam a efetividade dos vetores identificados sem comprometer excessivamente a operação dos agentes.

## Escopo de investigação

As linhas abaixo vêm da proposta e funcionam como um mapa de investigação, não como uma sequência obrigatória:

1. **Taxonomia de vulnerabilidades** — organizar riscos por vetor de ataque, fronteira de confiança, fase do ciclo de vida e impacto potencial, usando CVSS 3.1 quando aplicável.
2. **Segurança de entrada e contexto** — estudar injeção de prompt, especialmente a indireta por páginas, documentos, e-mails e outras fontes externas.
3. **Uso e autorização de ferramentas** — avaliar como o agente decide executar ferramentas e quais controles independentes do LLM são necessários.
4. **Configuração e persistência** — analisar a integridade de configurações e instruções carregadas pelo agente.
5. **Cadeia de suprimentos de extensões** — investigar riscos associados a habilidades, repositórios e ao marketplace ClawHub.
6. **Ambientes multiagente e subagentes** — compreender delegação, propagação de confiança, limites de autorização e possíveis impactos entre instâncias conectadas.

## Direções defensivas a avaliar

O projeto parte de quatro hipóteses de defesa complementares. A implementação dependerá da arquitetura e dos resultados dos experimentos.

| Identificador | Direção | Resultado esperado |
| --- | --- | --- |
| D1 | Isolamento de privilégios por proveniência de contexto | Diferenciar instruções confiáveis de conteúdo externo não confiável. |
| D2 | Integridade de configuração | Detectar alteração indevida de arquivos e instruções de configuração, por exemplo com hash e assinatura. |
| D3 | Políticas zero-trust para ferramentas | Autorizar chamadas de ferramentas por regras explícitas, além do raciocínio do modelo. |
| D4 | Endurecimento da cadeia de extensões | Adotar análise estática, revisão e execução isolada de habilidades quando viável. |

## Limites éticos e operacionais

- Todos os experimentos devem ocorrer em rede privada e ambiente isolado, sem sistemas, dados ou credenciais reais.
- Nenhum teste deve atingir serviços de terceiros, instâncias públicas ou pessoas fora do ambiente autorizado.
- Resultados potencialmente sensíveis devem ser documentados de forma responsável e encaminhados aos mantenedores antes de divulgação ampla, quando cabível.
- Artefatos públicos devem privilegiar reprodução segura, dados sintéticos e evidências necessárias para a correção, sem publicar material que aumente indevidamente o risco de exploração.

## Etapa inicial — fundação do projeto

Esta é a próxima etapa recomendada. Ela serve para reduzir incertezas antes de qualquer experimento mais profundo.

1. Confirmar a versão, a arquitetura e os pontos de extensão do OpenClaw que serão estudados.
2. Montar um inventário de ativos, fronteiras de confiança e permissões do agente.
3. Definir um testbed isolado e documentar como recriá-lo; Docker, máquinas virtuais e modelos locais são opções a avaliar.
4. Registrar uma taxonomia inicial de ameaças, fundamentada na literatura e na inspeção do código.
5. Definir um protocolo de experimentos seguro: hipótese, cenário sintético, métricas, logs permitidos e critério de parada.
6. Escolher um primeiro caso defensivo de menor risco e maior valor de aprendizado, como verificação de integridade de configuração ou políticas de ferramentas em modo de auditoria.

## Avaliação e evidências

Quando houver protótipos, a avaliação deve comparar um baseline com a defesa ativa. Métricas previstas na proposta incluem:

- redução da taxa de sucesso dos cenários de ataque;
- latência adicional por operação;
- confiabilidade e cobertura dos controles;
- usabilidade percebida por usuários técnicos, quando houver avaliação apropriada.

As metas da proposta — reduzir substancialmente o sucesso dos ataques, limitar a sobrecarga de latência e manter boa usabilidade — são referências de pesquisa, não critérios que obriguem decisões prematuras. As métricas e metas finais serão refinadas com a orientação e com o testbed disponível.

## Entregáveis que orientam o trabalho

- taxonomia de vulnerabilidades e fronteiras de confiança;
- testbed reproduzível e protocolo de experimentos;
- registros de experimentos e análise das evidências;
- protótipos defensivos e testes automatizados;
- avaliação comparativa das defesas;
- documentação técnica e, quando adequado, comunicação responsável aos mantenedores;
- materiais de divulgação científica derivados dos resultados validados.

## Forma de trabalho

O projeto combina perspectivas ofensiva e defensiva, mas elas não precisam avançar em blocos rígidos. Descobertas na análise podem orientar testes e defesas; por sua vez, a implementação defensiva pode começar a partir de riscos já documentados. Cada mudança de direção deve ser registrada neste planejamento com a hipótese, a evidência e a decisão tomada.

## Referência de origem

Este plano V1 foi elaborado a partir de `Projeto_PICTI_2026_openclaw.pdf`, proposta submetida em 2026 com o título *Análise de Vulnerabilidades e Desenvolvimento de Estratégias de Defesa em Ecossistemas de Agentes Autônomos de IA: Um Estudo de Caso com o OpenClaw*.
