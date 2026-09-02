# Especificações e resultados — frente Miguel (V1)

> Registro vivo do ambiente de laboratório e dos resultados validados. Este documento contém somente informações técnicas necessárias à reprodução segura; não registrar nomes de pessoas, contas, e-mails, tokens, chaves, endereços privados, caminhos pessoais ou saídas brutas de diagnóstico.

## 1. Finalidade

Concentrar as especificações verificadas do laboratório e os resultados dos experimentos da frente Miguel. O documento complementa o [plano de trabalho](../planejamento/Miguel-V1.md): o plano define o que e como investigar; este registro descreve o ambiente utilizado e o que foi efetivamente observado.

## 2. Ambiente de referência

| Componente | Especificação conhecida | Situação |
| --- | --- | --- |
| VM cliente | Ubuntu Server 22.04.5 LTS (`jammy`) | Confirmado |
| VM servidor | Ubuntu Server 22.04.5 LTS (`jammy`) | Confirmado |
| Virtualização | KVM, virtualização completa | Confirmado |
| OpenClaw — cliente | Versão 2026.7.1-2 (build `0790d9f`) | Confirmado em OPS-004; não reconfirmado desde então |
| OpenClaw — servidor | Atualizado para 2026.8.2 em 2026-09-02 (era 2026.7.1-2) — ver [REGISTRO_OPERACIONAL_V1.md](../replicacoes/REGISTRO_OPERACIONAL_V1.md), OPS-018 a OPS-021 | Confirmado |
| CPU por VM | 4 vCPUs x86_64 (QEMU Virtual CPU) | Confirmado |
| Memória por VM | Aproximadamente 3,8 GiB de RAM e 3,8 GiB de swap | Confirmado |
| Disco por VM | Disco virtual de 50 GB, partição raiz ext4 | Confirmado |
| Espaço disponível — cliente | Aproximadamente 37 GB na partição raiz no inventário inicial | Confirmado |
| Espaço disponível — servidor | Aproximadamente 34 GB na partição raiz no inventário inicial | Confirmado |
| Rede | Sub-rede acadêmica compartilhada, com comunicação entre VMs e acesso externo necessário às APIs; não é exclusiva do projeto | Confirmado |
| Firewall local | UFW inativo nas duas VMs no inventário inicial | Confirmado |
| Snapshot/backup operacional | Sem snapshot de VM. Primeiro backup verificado do servidor (`openclaw backup create --verify`) feito antes da atualização 2026.8.2 (OPS-018) | Decisão revisada: usar backup do próprio OpenClaw antes de mudanças de maior risco (ex.: atualização de versão), mesmo sem snapshot de VM |

Os rótulos **cliente** e **servidor** são funcionais. Eles não devem ser substituídos na documentação por nomes de host, usuários, IPs ou outros identificadores do ambiente.

O ambiente é controlado no contexto acadêmico, mas a rede não é exclusiva deste projeto: existem outras VMs autorizadas na mesma sub-rede. Portanto, os testes devem limitar seus destinos às VMs e serviços sintéticos expressamente autorizados. Não devem incluir descoberta, varredura ou interação de teste com outros equipamentos da rede.

O requisito de isolamento para esta fase será atendido por escopo operacional: dados sintéticos, permissões mínimas, ferramentas limitadas e lista explícita de destinos autorizados. Não se afirma isolamento físico ou de rede exclusiva.

## 3. Papéis operacionais

| Papel | VM | Uso previsto | Estado de configuração atual |
| --- | --- | --- | --- |
| Cliente | VM cliente | Operação, coleta/consulta de logs e apoio aos cenários sintéticos. | Apenas OpenClaw instalado (versão de referência confirmada em OPS-004). Sem modelos configurados, sem sandbox Docker, sem patch de teste. Não é alvo de nenhuma alteração de configuração nesta fase. |
| Servidor de testes | VM servidor | Execução dos cenários e principal ambiente com configuração de modelos para pesquisa. | OpenClaw instalado e configurado com os modelos da seção 4; imagem de sandbox `openclaw-sandbox:bookworm-slim` construída e validada (OPS-011 em [replicações](../replicacoes/REGISTRO_OPERACIONAL_V1.md)). É o único alvo do patch de perfil de teste em andamento. |
| Ator adversarial | Papel lógico do cenário | Representado por conteúdo, instrução ou serviço sintético autorizado; não corresponde a uma máquina ou pessoa externa. | Não se aplica. |

Embora OpenClaw esteja disponível nas duas VMs, **toda a configuração de modelos, sandbox e o perfil de teste (`agents.entries.lab-test`) acontece somente no servidor de testes.** O cliente segue sem alteração até que um cenário específico exija seu uso; o uso do OpenClaw no cliente será registrado quando isso ocorrer.

### Destinos autorizados

1. VM cliente do projeto;
2. VM servidor de testes do projeto;
3. futuramente, VMs de outros integrantes ou novas VMs do projeto, somente quando forem explicitamente incluídas no cenário e autorizadas pelos responsáveis.

Qualquer destino fora dessa lista está fora do escopo. A existência de conectividade de rede não é autorização para testá-lo.

## 4. Configuração de modelos

| Função | Modelo/provedor | Situação atual | Observação |
| --- | --- | --- | --- |
| Modelo principal de pesquisa | `openai/gpt-5.6-sol` | Ativo como padrão | Usado como referência nas primeiras medições. |
| Alternativa manual | `openrouter/nvidia/nemotron-3-ultra-550b-a55b:free` | Configurado | Pode ser avaliado quando necessário; não é fallback automático. |
| Modelo configurado | `openai/gpt-5.6` | Configurado | Não definido como padrão neste registro. |
| Roteamento automático | `openrouter/auto` | Configurado | Não definido como padrão neste registro. |
| Fallback em execução | — | Não configurado | Qualquer alteração deve ser documentada, testada e aprovada no laboratório. |

O acesso aos provedores é considerado um pré-requisito operacional do ambiente, mas detalhes de autenticação, perfis, consumo, validade de sessão e segredos ficam fora deste repositório.

## 5. Premissas para comparação de modelos

Quando houver comparação entre o modelo principal e uma alternativa, devem permanecer constantes, sempre que possível: versão do OpenClaw, cenário sintético, ferramentas habilitadas, permissões, política defensiva, número de repetições e critério de sucesso. A troca de modelo deve ser registrada como uma variável experimental, não como uma conclusão de segurança por si só.

Cada resultado deve informar qual modelo foi usado, sem registrar conta, credencial ou identificador de sessão.

### Comparação entre versões do OpenClaw (ideia registrada, ainda não usada)

O mesmo princípio vale para versão do OpenClaw: ela também pode ser tratada como variável experimental, não só como algo a manter fixo. O CLI suporta isso diretamente — `openclaw update --tag <versão>` aceita uma versão específica (inclusive uma anterior à instalada; o próprio `--help` confirma que downgrade é suportado, com aviso de que "pode quebrar configuração"). Antes de qualquer downgrade, criar backup verificado (`openclaw backup create --verify`).

Uso possível: rodar o mesmo cenário sintético em duas versões do OpenClaw (ex.: a linha 2026.7.x anterior ao "OpenClaw 2.0" e uma versão 2026.8.x), mantendo cenário, modelo, permissões e critério de sucesso constantes, pra comparar se o comportamento de segurança mudou entre versões — por exemplo, mudanças de default relatadas em changelogs (como `sessionToolsVisibility` ou comportamento "fail-closed" do sandbox em releases mais recentes) são candidatas naturais a esse tipo de comparação. Ainda não foi usado nenhum experimento assim; fica registrado aqui como possibilidade a explorar.

## 6. Inventário sanitizado inicial

Este inventário registra somente atributos técnicos necessários para o projeto. Ele é atualizado por resumo manual, nunca pela cópia integral de arquivos de configuração ou saídas de diagnóstico.

| Categoria | Registro atual | Regra de sanitização |
| --- | --- | --- |
| Sistemas | Duas VMs Ubuntu Server 22.04.5 LTS, virtualizadas por KVM | Não registrar IPs, hostnames ou usuários. |
| OpenClaw | Instalado nas duas VMs, versão 2026.7.1-2 | Não registrar diretórios de perfil, banco de autenticação ou saída completa de status. |
| Modelos | Configuração de referência no servidor, descrita na seção 4 | Registrar somente provedor, identificador público do modelo, função e fallback. |
| Rede | Rede acadêmica compartilhada, conectividade externa necessária e escopo limitado aos destinos autorizados | Não registrar endereços, gateway, DNS, MAC ou conexões SSH. |
| Ferramentas e extensões | Inventário detalhado ainda não realizado | Registrar nome, origem, estado, categoria de permissão e justificativa; nunca credenciais ou parâmetros sensíveis. |
| Dados de teste | Ainda não definidos | Usar apenas conteúdo sintético, sem conversas, contas ou arquivos reais. |
| Recuperação | Sem snapshot/backup operacional nesta fase | Priorizar ações reversíveis e mudanças pequenas, registradas antes da execução. |

### Como completar o inventário de ferramentas e extensões

Para cada VM, preencher uma linha por ferramenta, integração ou extensão efetivamente habilitada. O levantamento deve ser feito por leitura e resumo manual; não anexar arquivos de configuração.

| VM | Item | Origem | Estado | Permissão/capacidade | Justificativa no cenário | Dados que não registrar |
| --- | --- | --- | --- | --- | --- | --- |
| Cliente/servidor | Nome público do item | Nativo, local ou terceiro | Habilitado/desabilitado | Ex.: leitura de arquivos, escrita em diretório de teste, rede, navegador ou delegação | Por que é necessário | Tokens, URLs privadas, contas, caminhos pessoais e parâmetros sensíveis |

Também registrar, de forma agregada, se o agente pode ler arquivos fora do diretório de teste, escrever arquivos, executar comandos, acessar rede, usar navegador, enviar mensagens ou delegar a subagentes. Para o primeiro cenário, qualquer capacidade não indispensável deve permanecer desabilitada ou fora do escopo de uso.

### Descobertas iniciais de capacidades

As duas VMs apresentam o mesmo resultado de inventário inicial. A instalação lista **50 de 68 plugins habilitados** e **16 de 53 skills prontas**. Os plugins listados são fornecidos pela instalação padrão; o inventário recebido não deve ser interpretado como prova de que todas as capacidades estejam disponíveis para um agente em execução.

Capacidades relevantes identificadas na listagem:

| Categoria | Evidência inicial | Implicação para a pesquisa |
| --- | --- | --- |
| Navegação e conteúdo | Plugin de navegador, extração de documentos e skill de automação de navegador disponíveis | Relevante para cenários de conteúdo externo e injeção indireta. |
| Arquivos e nós pareados | Plugin de transferência de arquivos e recursos de pareamento de dispositivos disponíveis | Não habilitar no primeiro cenário sem necessidade e permissão explícita. |
| Extensões | Skill para busca/instalação de habilidades disponível | Não instalar novas extensões durante o baseline. |
| Operação do agente | Skills prontas para tmux, tarefas duráveis, depuração e criação de skills | Manter fora do primeiro cenário, exceto quando forem o objeto específico da análise. |
| MCP | A CLI possui comandos para listar, verificar, configurar e filtrar servidores MCP | A existência ou o estado de servidores MCP configurados ainda não foi confirmado. |
| Execução de comandos | A CLI oferece política de execução e aprovações por agente | A política efetiva e a lista de aprovações ainda precisam ser verificadas. |
| Sandbox | Há suporte a containers Docker e comando para explicar a política efetiva | A presença de containers e a política efetiva ainda precisam ser verificadas. |

O resultado de `plugins list` recebido foi truncado no compartilhamento. Por isso, este registro não afirma a ausência de plugins de terceiros nem usa a listagem como inventário exaustivo.

### Política efetiva e isolamento de execução

No inventário inicial (F0), as duas VMs tinham a mesma configuração efetiva para o agente principal (id real `crestodian`, ver REGISTRO_OPERACIONAL_V1.md OPS-015): opera diretamente no host, com sandbox desativado e sem containers de sandbox em execução. Isso continua valendo para o `crestodian` depois da atualização do servidor (OPS-018 a OPS-021 não alteraram sua política). A simetria entre as VMs, porém, não é mais garantida desde então: o **servidor** também tem o agente de teste `lab-test` (sandbox restritivo, ver seção 6) e está em OpenClaw 2026.8.2, enquanto o **cliente** permanece só com a instalação padrão em 2026.7.1-2.

| Controle | Estado confirmado | Consequência |
| --- | --- | --- |
| Execução de comandos (`tools.exec`) | `security=full` e `ask=off` | Comandos podem ser executados sem confirmação interativa; não usar o agente principal para conteúdo não confiável. |
| Lista de aprovações | Arquivo presente, sem entradas de allowlist | Não há restrição explícita por comando baseada em allowlist. |
| Sandbox | Modo desativado; execução direta; nenhum runtime em execução | Não há isolamento por container para limitar efeitos de ferramentas. |
| Ferramentas na política de sandbox | Execução, processo, leitura e escrita constam como permitidas por padrão | Essa política só produzirá isolamento se o sandbox for efetivamente ativado e validado. |
| Elevação | Não autorizada para o canal atual | Não tratar como mecanismo de proteção principal do cenário. |
| MCP | Nenhum servidor MCP configurado | Não há integração MCP a incluir no primeiro baseline. |

Esses dados descrevem um **baseline permissivo**, útil para análise de risco, mas inadequado para receber conteúdo externo não confiável sem uma configuração de teste separada e restritiva.

## 7. Pré-requisitos para o primeiro cenário

Antes de executar um cenário de ação, devem estar concluídos:

1. criar uma configuração ou perfil de teste separado do agente principal;
2. definir uma política de execução restritiva nesse perfil, sem `tools.exec` de privilégio pleno e sem aprovações automáticas;
3. ativar e validar um sandbox aplicável ao perfil de teste, ou, se isso não for viável, limitar o primeiro cenário a observação sem ferramentas de efeito externo;
4. registrar que não há servidores MCP configurados e mantê-los fora do primeiro cenário;
5. inventariar manualmente as ferramentas e extensões relevantes para o cenário em cada VM;
6. definir as permissões que permanecerão habilitadas no cenário e desabilitar as que não forem necessárias;
7. criar um diretório de trabalho com arquivos inteiramente sintéticos;
8. definir o comportamento esperado, a métrica, o número de repetições e o critério de parada;
9. escolher um método de registro que não retenha prompts, respostas ou segredos desnecessários;
10. revisar que o cenário só alcança os destinos autorizados acima.

O primeiro cenário deve ser de observação e sem efeitos externos: uma entrada sintética é apresentada ao agente e o resultado é classificado, sem habilitar escrita fora do diretório de teste, comandos de sistema ou chamadas de rede que não sejam indispensáveis.

## 8. Registro de resultados

Nenhum experimento foi registrado neste documento até o momento. Ao concluir uma execução validada, adicionar uma entrada usando o modelo abaixo.

### Modelo de entrada

```text
ID: EXP-XXX
Data:
Objetivo / hipótese:
Ambiente: VM cliente/servidor, versões e isolamento relevante
Modelo utilizado:
Cenário e dados sintéticos:
Ferramentas e permissões habilitadas:
Baseline ou controle avaliado:
Repetições e métricas:
Resultado observado:
Limitações:
Evidência sanitizada associada:
Decisão e próximo passo:
```

## Referências internas

- [Plano de trabalho da frente Miguel](../planejamento/Miguel-V1.md)
- [Registro operacional (replicações)](../replicacoes/REGISTRO_OPERACIONAL_V1.md)
- [Planejamento geral do projeto](../../../planning/PROJECT_PLAN_V1.md)
