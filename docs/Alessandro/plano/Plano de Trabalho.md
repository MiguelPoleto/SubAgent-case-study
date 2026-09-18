# Plano de Trabalho

**Projeto:** Análise de vulnerabilidades e desenvolvimento de estratégias de defesa no ecossistema OpenClaw e em agentes autônomos de inteligência artificial

**Instituição:** Instituto Federal do Espírito Santo

**Pesquisador(a):** [NOME DO(A) PESQUISADOR(A) BOLSISTA]

**Orientador(a):** [NOME DO(A) ORIENTADOR(A)]

**Duração:** 12 meses — **Dedicação:** 20 horas semanais

**Local:** Cachoeiro de Itapemirim (ES) — **Ano:** 2026

## Resumo

Este plano de trabalho descreve um projeto de pesquisa aplicada, com duração de doze meses e dedicação de vinte horas semanais, voltado à investigação de vulnerabilidades de segurança no ecossistema OpenClaw, uma plataforma open-source de agente autônomo que integra execução de comandos de sistema operacional, automação de navegador, mensageria multiplataforma e um marketplace de extensões. O projeto combina uma frente ofensiva, dedicada à reprodução controlada e à análise de vetores de ataque documentados na literatura em ambiente isolado, e uma frente defensiva, dedicada à prototipação e à avaliação empírica de mecanismos de defesa. A investigação é organizada em torno de uma taxonomia de vulnerabilidades estruturada em três camadas do agente — cognição, execução e interação — e contempla a reprodução de vetores como a injeção indireta de prompt, o bypass do sistema de aprovação de comandos e o envenenamento de extensões (skills). Como contramedidas, prevê-se a prototipação de quatro mecanismos de defesa complementares: isolamento de privilégio por proveniência de contexto, verificação de integridade de configuração, políticas explícitas de autorização de ferramentas e endurecimento da cadeia de extensões. A avaliação experimental compara um cenário de referência a um cenário com defesa ativa, quantificando redução da taxa de sucesso dos ataques, sobrecarga de latência e usabilidade percebida. Espera-se, como resultado, uma taxonomia consolidada, um testbed reprodutível, protótipos de defesa avaliados empiricamente e um relatório técnico voltado à comunicação responsável de vulnerabilidades identificadas.

Palavras-chave: Segurança de sistemas de inteligência artificial. Agentes autônomos. OpenClaw. Injeção de prompt. Vulnerabilidades de software.

## 1 Introdução

A segurança de ecossistemas de agentes autônomos de inteligência artificial constitui um dos desafios técnicos mais urgentes da atualidade. O OpenClaw é uma plataforma open-source de agente autônomo que combina execução de comandos de sistema operacional, automação de navegador, mensageria multiplataforma e um marketplace de extensões, denominado ClawHub. Em poucos meses de existência pública, o projeto acumulou centenas de milhares de instâncias em uso e se tornou um dos repositórios mais populares da história do GitHub, ao mesmo tempo em que acumulou dezenas de vulnerabilidades documentadas e sofreu um incidente relevante de cadeia de suprimentos em seu marketplace de extensões, conhecido como ClawHavoc (LI et al., 2026). Essa combinação de adoção massiva e imaturidade de segurança faz do OpenClaw um caso de estudo relevante para investigar, de forma sistemática, os riscos de segurança inerentes a agentes autônomos baseados em modelos de linguagem.

Este plano de trabalho descreve um projeto de pesquisa aplicada, com duração de doze meses e dedicação de vinte horas semanais, estruturado em torno de dois eixos complementares: a investigação ofensiva, isto é, a reprodução controlada e a análise de vetores de ataque documentados na literatura, em ambiente isolado; e a investigação defensiva, isto é, a prototipação e a avaliação empírica de mecanismos de defesa capazes de mitigar tais vetores sem comprometer excessivamente a operação do agente.

## 2 Justificativa

O avanço acelerado dos grandes modelos de linguagem catalisou a transição de sistemas de diálogo estáticos para agentes autônomos capazes de interação sustentada com o mundo real: esses agentes operam como processos de longa duração, acessam ferramentas externas, manipulam arquivos, executam comandos no sistema operacional e se comunicam com outros agentes e humanos. O OpenClaw materializa essa realidade ao combinar execução de shell, automação de navegador, gestão de arquivos e mensageria multiplataforma em um ambiente integrado e extensível.

A literatura técnica recente evidencia que essa combinação de capacidades cria superfícies de ataque críticas. Estudos publicados em 2026 documentaram um ataque autopropagante contra o OpenClaw, capaz de comprometer múltiplas instâncias a partir de uma única mensagem maliciosa (ZHANG et al., 2026); identificaram problemas estruturais no ecossistema de extensões do ClawHub, incluindo o sequestro de repositórios abandonados referenciados por dezenas de extensões publicadas (HOLZBAUER et al., 2026); e produziram levantamentos abrangentes que classificam as vulnerabilidades do OpenClaw em taxonomias multidimensionais, com evidência cruzada de diversas avaliações institucionais de segurança (LI et al., 2026; WANG et al., 2026). Esses trabalhos convergem em um diagnóstico comum: as vulnerabilidades do OpenClaw não são falhas pontuais de implementação, mas decorrem de propriedades arquiteturais fundamentais, entre as quais um modelo de confiança plana de contexto, em que mensagens de humanos, de outros agentes e de conteúdo web recebem o mesmo peso; a execução incondicional de arquivos de configuração como instruções de prioridade máxima; a autorização de ferramentas delegada exclusivamente ao raciocínio do modelo de linguagem; e um marketplace de extensões sem revisão de código obrigatória.

O fenômeno da injeção indireta de prompt, central para boa parte dessas vulnerabilidades, já havia sido caracterizado conceitualmente por Greshake et al. (2023) como um vetor no qual instruções maliciosas embutidas em conteúdo externo processado por um sistema baseado em modelo de linguagem são interpretadas como comandos legítimos. Deng et al. (2025) consolidam essa e outras ameaças em uma taxonomia de três níveis de superfície de ataque em agentes autônomos: nível de entrada de dados, nível de uso de ferramentas e nível de sistemas multiagente — estrutura que serve de referência complementar à taxonomia adotada neste projeto (Seção 4).

No contexto nacional, a interseção entre frameworks agentivos, modelos de linguagem e segurança ofensiva e defensiva permanece campo pouco explorado, o que evidencia espaço para contribuições originais. A relevância socioeconômica é direta: o crescimento do uso de agentes de inteligência artificial em setores críticos da economia — finanças, saúde e serviços públicos — torna urgente o desenvolvimento de conhecimento técnico sobre como proteger essas plataformas, alinhando-se às prioridades da Estratégia Brasileira de Inteligência Artificial.

## 3 Objetivos

### 3.1 Objetivo geral

Investigar sistematicamente as vulnerabilidades de segurança do ecossistema OpenClaw, reproduzir experimentalmente, em ambiente controlado e isolado, vetores de ataque documentados na literatura, e propor, prototipar e avaliar mecanismos de defesa técnicos capazes de reduzir a efetividade desses ataques sem comprometer excessivamente a operação dos agentes.

### 3.2 Objetivos específicos

São objetivos específicos deste projeto:

- **a)** mapear e categorizar as vulnerabilidades documentadas e potenciais do OpenClaw, organizando-as por vetor de ataque, fronteira de confiança e fase do ciclo de vida do agente, e classificando sua severidade segundo a escala CVSS 3.1;

- **b)** reproduzir e analisar, em ambiente isolado, vetores de ataque documentados — incluindo injeção de prompt indireta, envenenamento de extensões e bypass do sistema de aprovação de comandos —, mensurando taxa de sucesso, condições de ativação e impacto observável;

- **c)** avaliar a segurança do marketplace ClawHub por meio de inspeção de metadados e de comportamento de extensões, identificando padrões de risco na cadeia de suprimentos de skills;

- **d)** propor e prototipar mecanismos de defesa para as fronteiras de confiança identificadas, cobrindo isolamento de privilégio por proveniência de contexto, verificação de integridade de configuração, autorização de ferramentas por políticas explícitas e endurecimento da cadeia de extensões;

- **e)** avaliar a eficácia das defesas prototipadas por meio de experimentos controlados que comparem um cenário de referência, sem defesa, a um cenário com a defesa ativa, quantificando redução da taxa de sucesso dos ataques, sobrecarga de latência e usabilidade percebida;

- **f)** comunicar os resultados por meio de relatório técnico, documentação reprodutível e, quando cabível, comunicação responsável a mantenedores de projetos afetados.

## 4 Fundamentação teórica

O OpenClaw pode ser descrito, para fins de análise de segurança, como um agente que integra um controlador cognitivo baseado em modelo de linguagem a superfícies de execução de nível de sistema operacional, tais como sistema de arquivos, terminal e rede. Sua arquitetura predominante é a de um processo único de longa duração, no qual o controlador de raciocínio, o mecanismo de execução de ferramentas e o sistema de extensões compartilham o mesmo domínio de privilégio, sem separação formal entre instrução e dado. Essa característica arquitetural é apontada de forma consistente na literatura como a causa raiz de boa parte das vulnerabilidades documentadas (LI et al., 2026; WANG et al., 2026).

Para fins de organização do trabalho experimental, este projeto adota uma taxonomia de vulnerabilidades estruturada em três camadas do agente, cada uma associada a mecanismos de defesa específicos, conforme proposto por Wang et al. (2026).

### 4.1 Camada de cognição

O sequestro de objetivo (goal hijack) ocorre quando instruções maliciosas embutidas em conteúdo externo — páginas web, documentos, e-mails, saídas de ferramentas — são interpretadas pelo agente como instruções legítimas, desviando-o do objetivo original do usuário. Esse fenômeno inclui a injeção indireta de prompt (GRESHAKE et al., 2023), a sobreposição de instrução dentro de extensões e a injeção estrutural que explora marcadores de papel e de template. O envenenamento de memória e contexto ocorre quando conteúdo malicioso é inserido na memória de longo prazo, na memória de recuperação aumentada por geração (RAG) ou no contexto de execução do agente, influenciando de forma persistente seu raciocínio e suas ações futuras. Já o desvio comportamental progressivo, por vezes descrito como comportamento de "agente desviante", pode ocorrer mesmo sem um atacante externo, quando a compressão de contexto ou cadeias longas de execução autônoma fazem o agente perder instruções ou restrições estabelecidas anteriormente.

### 4.2 Camada de execução

O uso indevido de ferramentas caracteriza-se pela invocação de capacidades legítimas em contextos inseguros, com privilégios excessivos ou em sequências de ação prejudiciais, incluindo cadeias de chamadas de ferramentas individualmente benignas que, combinadas, produzem um efeito malicioso. As vulnerabilidades na cadeia de suprimentos de extensões referem-se à publicação de skills maliciosas ou comprometidas no marketplace, com payloads ocultos, dependências não fixadas ou busca de scripts externos durante a instalação. A execução de código inesperada, por fim, corresponde à transformação de instruções em linguagem natural, saídas intermediárias ou conteúdo de extensões em comandos de sistema operacional executáveis além do escopo pretendido pelo usuário.

### 4.3 Camada de interação

O abuso de identidade e privilégio decorre da exploração de configurações incorretas de autenticação do gateway do agente, do acesso não autorizado a credenciais armazenadas em texto plano e da solicitação de permissões excessivas por parte de extensões. A comunicação insegura entre agentes caracteriza-se pela ausência de verificação de origem, integridade ou autenticidade em mensagens trocadas entre instâncias, abrindo espaço para contaminação cruzada de contexto. Por fim, a exploração da confiança humano-agente decorre da ausência de confirmação para ações sensíveis e da fadiga de consentimento, fenômenos que levam usuários a aprovar ações de risco sem escrutínio adequado.

Essa taxonomia orienta tanto a escolha dos vetores de ataque a reproduzir (Seção 6) quanto o desenho das defesas a prototipar (Seção 7), permitindo que cada experimento seja associado de forma explícita a uma camada e a uma fronteira de confiança específica.

## 5 Metodologia

A pesquisa adota abordagem experimental de segurança ofensiva e defensiva, com tipo de pesquisa aplicada, abordagem quantitativa para métricas de ataque e de defesa, e abordagem qualitativa para a análise taxonômica e de código-fonte. Todos os experimentos são conduzidos em ambiente isolado — rede privada, sem conexão com a internet, sem dados ou credenciais reais — em conformidade com princípios de responsible disclosure.

### 5.1 Ambiente experimental (testbed)

O ambiente experimental do projeto observa as seguintes diretrizes:

- **a)** instâncias do OpenClaw executadas em contêineres, em rede privada isolada, sem qualquer exposição a serviços de terceiros ou à internet;

- **b)** backend de modelo de linguagem configurável, com uso de modelos locais para a maior parte dos experimentos repetidos, reservando-se chamadas a modelos comerciais para validações finais de menor volume;

- **c)** uso exclusivo de dados sintéticos, de modo que nenhum dado real de usuário, credencial real ou serviço de produção seja acessível a partir do testbed em qualquer momento do projeto;

- **d)** versionamento e documentação do testbed de forma reprodutível, permitindo que qualquer experimento possa ser recriado a partir da documentação produzida.

### 5.2 Protocolo experimental por vetor de ataque

Cada vetor de ataque investigado segue um protocolo experimental estruturado em cinco etapas, inspirado em ambientes dinâmicos de avaliação de ataques de injeção de prompt já propostos na literatura, como o AgentDojo (WANG et al., 2024): formulação da hipótese, isto é, a descrição objetiva do comportamento esperado do agente diante do vetor em análise; definição do cenário sintético, ou seja, a construção do ambiente mínimo necessário para observar o efeito, sem qualquer conexão com sistemas externos; execução controlada, com repetição do experimento — tomando-se como referência de literatura um mínimo de trinta tentativas por vetor — e registro de taxa de sucesso, tempo até efeito observável e logs de atividade previamente definidos como permitidos; definição de um critério de parada, isto é, uma condição objetiva que interrompe o experimento antes de qualquer efeito que ultrapasse os limites do ambiente isolado; e, por fim, análise e registro, com documentação da hipótese, do procedimento, da evidência coletada e da conclusão, de forma a permitir auditoria e reprodução por terceiros.

### 5.3 Avaliação comparativa das defesas

Cada mecanismo de defesa prototipado é avaliado em duas condições sobre o mesmo conjunto de cenários de ataque: uma condição de referência, sem qualquer defesa ativa, e uma condição com a defesa ativa. As métricas coletadas em ambas as condições são a taxa de redução de sucesso dos ataques por vetor; a latência adicional introduzida por operação, em comparação direta com a condição de referência; a confiabilidade e a cobertura dos controles, isto é, a proporção de tentativas maliciosas corretamente identificadas ou bloqueadas sem afetar operações legítimas; e a usabilidade percebida por usuários técnicos, avaliada por meio da escala SUS (System Usability Scale) em uma amostra reduzida de avaliadores voluntários. A análise estatística das diferenças entre as condições de referência e de defesa ativa é conduzida com testes não paramétricos apropriados ao tamanho amostral disponível, como o teste de Wilcoxon para amostras pareadas.

## 6 Vetores de ataque a investigar

Os vetores a seguir foram selecionados por três critérios: existência de documentação técnica pública suficiente para reprodução responsável; relevância arquitetural, isto é, o vetor expõe uma fronteira de confiança central do agente; e valor de aprendizado direto para pelo menos um dos mecanismos de defesa descritos na Seção 7.

### 6.1 Vetores de tratamento prioritário

- **a)** injeção indireta de prompt: instruções maliciosas embutidas em conteúdo externo — página web, documento, e-mail ou saída de ferramenta — processado pelo agente, causando desvio do objetivo original sem interação direta do usuário com o atacante;

- **b)** bypass do sistema de aprovação de comandos: exploração da divergência entre o comando exibido ao usuário para aprovação e o comando efetivamente executado pelo agente, padrão estrutural análogo a falhas do tipo tempo de checagem/tempo de uso;

- **c)** envenenamento de extensão, segundo padrão de cadeia de suprimentos: instalação de uma extensão sintética, desenvolvida exclusivamente para o testbed, que simula comportamento malicioso documentado na literatura, como payload oculto em etapa de inicialização, dependência não fixada ou download de script externo durante a instalação.

### 6.2 Vetores de tratamento complementar

- **a)** envenenamento de memória persistente: escrita de conteúdo malicioso em arquivos de estado ou configuração carregados pelo agente como contexto de alta prioridade, avaliando sua influência em decisões subsequentes;

- **b)** exposição de gateway por configuração incorreta: análise do impacto de uma configuração de rede que exponha a interface de controle do agente além do escopo pretendido, incluindo o abuso da suposição de confiança em conexões locais.

### 6.3 Vetores de investigação estendida

Os vetores a seguir são condicionados ao avanço do cronograma e tratados como extensão do escopo central, a serem incorporados apenas se o andamento do projeto permitir:

- **a)** propagação entre múltiplas instâncias conectadas, segundo padrão de replicação automática entre agentes, a ser investigada apenas após a consolidação dos protótipos de defesa centrais, dado o custo operacional mais elevado de um testbed multiagente;

- **b)** avaliação preliminar da superfície de ataque do canal de extensibilidade baseado em protocolo, o Model Context Protocol (ANTHROPIC, 2024), como direção de estudo complementar às defesas centrais.

## 7 Mecanismos de defesa a prototipar

O projeto prototipa quatro mecanismos de defesa complementares, cada um endereçando uma fronteira de confiança distinta identificada na fundamentação teórica (Seção 4). A implementação concreta de cada mecanismo é ajustada durante a execução do projeto, conforme a arquitetura do OpenClaw e os resultados dos experimentos descritos na Seção 6, conforme sintetizado no Quadro 1.

Quadro 1 – Mecanismos de defesa e critérios de avaliação

| ID | Direção | Fronteira de confiança endereçada | Critério de sucesso experimental |
| --- | --- | --- | --- |
| D1 | Isolamento de privilégio por proveniência de contexto | Separação entre instrução confiável e conteúdo externo não confiável | Redução mensurável da taxa de sucesso de injeção indireta de prompt, preservando a execução de tarefas legítimas |
| D2 | Integridade de configuração (hash e assinatura) | Alteração indevida de arquivos de configuração e de memória persistente | Detecção determinística de qualquer alteração não assinada antes do carregamento pelo agente |
| D3 | Políticas explícitas (zero-trust) para autorização de ferramentas | Autorização de ferramentas delegada exclusivamente ao raciocínio do modelo | Bloqueio de ações que violem a política declarada, mesmo quando o modelo decide executá-las |
| D4 | Endurecimento da cadeia de extensões (marketplace) | Publicação de extensões sem revisão de código obrigatória | Sinalização e, em etapa avançada, bloqueio de extensões sintéticas com comportamento malicioso conhecido |

Fonte: elaborado pelo autor (2026).

Para o mecanismo D4, prevê-se o uso combinado de análise estática de código, com ferramentas como Semgrep e Bandit, e execução isolada das extensões, em sandbox, antes de sua ativação no agente. Para o mecanismo D3, prevê-se um motor de políticas configurável por regras explícitas, por exemplo em formato YAML, avaliado contra cada invocação de ferramenta de forma independente do raciocínio do modelo.

## 8 Cronograma de atividades

O cronograma a seguir distribui as atividades ao longo de doze meses, com dedicação de vinte horas semanais, o que corresponde a aproximadamente oitenta a oitenta e cinco horas de trabalho por mês. As atividades respeitam a lógica de que a investigação ofensiva de cada vetor deve anteceder ou acompanhar a prototipação da defesa correspondente, sem impor uma separação rígida entre as duas frentes, conforme sintetizado no Quadro 2.

Quadro 2 – Cronograma de atividades (12 meses)

| Atividade | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Revisão sistemática da literatura e fundamentação teórica | X | X |  |  |  |  |  |  |  |  |  |  |
| Elaboração da taxonomia de vulnerabilidades (CVSS 3.1) | X | X |  |  |  |  |  |  |  |  |  |  |
| Análise estática do código-fonte do OpenClaw e mapeamento de fronteiras de confiança |  | X | X |  |  |  |  |  |  |  |  |  |
| Configuração e documentação do testbed isolado |  | X | X |  |  |  |  |  |  |  |  |  |
| Reprodução: injeção indireta de prompt |  |  | X | X |  |  |  |  |  |  |  |  |
| Reprodução: bypass do sistema de aprovação de comandos |  |  |  | X | X |  |  |  |  |  |  |  |
| Reprodução: envenenamento de extensão (cadeia de suprimentos) |  |  |  |  | X | X |  |  |  |  |  |  |
| Reprodução: envenenamento de memória persistente e exposição de gateway |  |  |  |  |  | X | X |  |  |  |  |  |
| Prototipação D1 — isolamento de privilégio por proveniência |  |  |  | X | X | X |  |  |  |  |  |  |
| Prototipação D2 — integridade de configuração |  |  |  |  | X | X | X |  |  |  |  |  |
| Prototipação D3 — políticas zero-trust para ferramentas |  |  |  |  |  | X | X | X |  |  |  |  |
| Prototipação D4 — endurecimento da cadeia de extensões |  |  |  |  |  |  | X | X | X |  |  |  |
| Avaliação comparativa: referência versus defesa ativa (D1 a D4) |  |  |  |  |  |  |  | X | X | X |  |  |
| Investigação estendida (propagação entre instâncias e canal MCP), se o cronograma permitir |  |  |  |  |  |  |  |  | X | X |  |  |
| Consolidação de resultados e análise estatística |  |  |  |  |  |  |  |  |  | X | X |  |
| Redação do relatório técnico e de comunicação responsável, quando cabível |  |  |  |  |  |  |  |  |  | X | X |  |
| Redação de artigo científico e materiais de divulgação |  |  |  |  |  |  |  |  |  |  | X | X |
| Apresentação dos resultados na Jornada de Iniciação Científica |  |  |  |  |  |  |  |  |  |  |  | X |

Fonte: elaborado pelo autor (2026).

## 9 Avaliação e métricas

A avaliação do projeto ocorre em duas frentes: a avaliação experimental de cada vetor de ataque e de cada defesa, descrita na Seção 5.3, e a avaliação do próprio andamento do projeto frente aos objetivos específicos definidos na Seção 3.2.

- **a)** para cada vetor de ataque reproduzido, são registradas a taxa de sucesso, as condições de ativação identificadas e a severidade estimada segundo a escala CVSS 3.1;

- **b)** para cada defesa prototipada, são registradas a redução da taxa de sucesso do ataque correspondente, a latência adicional introduzida e a cobertura de detecção ou bloqueio;

- **c)** para a cadeia de extensões, associada ao mecanismo D4, é registrada a proporção de extensões sintéticas maliciosas corretamente sinalizadas antes da ativação;

- **d)** para o projeto como um todo, é registrado o cumprimento dos seis objetivos específicos ao final dos doze meses, com o registro de eventuais ajustes de escopo e sua justificativa.

## 10 Entregáveis esperados

- **a)** taxonomia de vulnerabilidades do OpenClaw, organizada por camada de cognição, execução e interação, e classificada segundo a escala CVSS 3.1;

- **b)** testbed isolado e reproduzível, com protocolo de experimentos documentado;

- **c)** registros de experimentos e análise das evidências para cada vetor de ataque investigado;

- **d)** quatro protótipos de mecanismos de defesa, identificados como D1 a D4, com testes automatizados associados;

- **e)** relatório de avaliação comparativa entre o cenário de referência e o cenário com defesa ativa, com métricas de eficácia, latência e usabilidade;

- **f)** relatório técnico de segurança e, quando cabível, comunicação responsável a mantenedores de projetos afetados;

- **g)** artigo científico e apresentação dos resultados na Jornada de Iniciação Científica.

## 11 Limites éticos e operacionais

- **a)** todos os experimentos ocorrem em rede privada e ambiente isolado, sem sistemas, dados ou credenciais reais;

- **b)** nenhum teste atinge serviços de terceiros, instâncias públicas ou pessoas fora do ambiente autorizado;

- **c)** resultados potencialmente sensíveis são documentados de forma responsável e encaminhados aos mantenedores de projetos afetados antes de qualquer divulgação ampla, quando cabível;

- **d)** artefatos públicos produzidos pelo projeto privilegiam reprodução segura, dados sintéticos e evidências necessárias para a correção, sem publicar detalhes de exploração além do que já é publicamente documentado na literatura;

- **e)** a pesquisa não envolve acesso não autorizado a sistemas de terceiros, experimentação com seres humanos como sujeitos de pesquisa, nem coleta de dados pessoais.

## Referências

ANTHROPIC. Model context protocol specification. 2024. Disponível em: https://modelcontextprotocol.io. Acesso em: 4 set. 2026.

DENG, Z. et al. AI agents under threat: a survey of key security challenges and future pathways. ACM Computing Surveys, v. 57, n. 7, p. 1-36, 2025.

GRESHAKE, K. et al. Not what you've signed up for: compromising real-world LLM-integrated applications with indirect prompt injections. In: WORKSHOP ON ARTIFICIAL INTELLIGENCE AND SECURITY, AISec, 2023. Anais eletrônicos [...]. [S. l.: s. n.], 2023.

HOLZBAUER, C. et al. From capability to vulnerability: security analysis of OpenClaw skill ecosystems. [S. l.: s. n.], 2026.

LI, S. et al. The rise of autonomous AI agents: a comprehensive survey of OpenClaw — architecture, security, ecosystem, and beyond. Research Square, 2026. Preprint. Disponível em: https://doi.org/10.21203/rs.3.rs-10596296/v1. Acesso em: 4 set. 2026.

PEREZ, F.; RIBEIRO, I. Ignore previous prompt: attack techniques for language models. In: NEURIPS ML SAFETY WORKSHOP, 2022. Anais eletrônicos [...]. [S. l.: s. n.], 2022.

WANG, Y. et al. AgentDojo: a dynamic environment to evaluate prompt injection attacks and defenses for LLM agents. In: ADVANCES IN NEURAL INFORMATION PROCESSING SYSTEMS, NeurIPS, 37., 2024. Anais eletrônicos [...]. [S. l.: s. n.], 2024.

WANG, Y. et al. Security of OpenClaw agents: fundamentals, threats, and countermeasures. arXiv, 2026. Disponível em: https://arxiv.org/abs/2605.25435. Acesso em: 4 set. 2026.

ZHANG, Y. et al. ClawWorm: self-propagating attacks across LLM agent ecosystems. [S. l.: s. n.], 2026.
