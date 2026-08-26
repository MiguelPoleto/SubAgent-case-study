# Registro operacional — frente Miguel (V1)

> Diário sanitizado das verificações e mudanças do laboratório. Este arquivo registra o objetivo de cada comando, **em qual VM ele foi executado**, seu resultado resumido e a decisão decorrente. Não colar saídas brutas que incluam contas, caminhos pessoais, IPs, tokens, hashes de autenticação, prompts de shell (`usuário@host:~$`) ou outros identificadores.

## Onde executar

O laboratório tem duas VMs com papéis diferentes (detalhe completo em [ambiente/ESPECIFICACOES_E_RESULTADOS_V1.md](../ambiente/ESPECIFICACOES_E_RESULTADOS_V1.md#3-papéis-operacionais)):

- **Cliente** — só tem o OpenClaw instalado. Sem modelos configurados, sem sandbox Docker, sem patch de teste. Não é alvo de nenhuma das alterações abaixo.
- **Servidor de testes** — tem os modelos de pesquisa configurados e é onde a imagem de sandbox foi construída. **Todo o trabalho de sandbox/perfil de teste descrito neste documento acontece só no servidor.**

Quando um comando abaixo não tiver a VM indicada explicitamente no texto original, isso está marcado na coluna "VM" com "(a confirmar)" — não foi inventado, é uma lacuna real do registro anterior.

## Regras de registro

- Registrar comandos de leitura, validação, configuração e teste que sejam relevantes para a reprodução do projeto.
- Registrar resultados em linguagem resumida, não a saída completa do terminal.
- Marcar alterações planejadas como **pendentes** até que sejam executadas e validadas.
- Nunca registrar arquivos `.env`, segredos, perfis de autenticação, arquivos de configuração completos, credenciais ou prompts de shell com usuário/host.

## Execuções concluídas

| ID | VM | Objetivo | Comando(s) executado(s) | Resultado sanitizado | Decisão |
| --- | --- | --- | --- | --- | --- |
| OPS-001 | Cliente + Servidor | Identificar sistemas operacionais | `lsb_release -a` | Cliente e servidor usam Ubuntu Server 22.04.5 LTS (`jammy`). | Ambiente-base registrado. |
| OPS-002 | Cliente + Servidor | Identificar virtualização e recursos | `lscpu`, `free -h`, `df -hT`, `lsblk` | Duas VMs KVM com 4 vCPUs, aproximadamente 3,8 GiB de RAM/swap e disco virtual de 50 GB. | Recursos suficientes para a preparação inicial. |
| OPS-003 | Cliente + Servidor (a confirmar) | Registrar rede e exposição local | `ip -br address`, `ip route`, `ss -tunap`, `sudo ufw status verbose` | Rede acadêmica compartilhada com acesso externo necessário; UFW inativo; serviços OpenClaw expostos apenas em loopback no inventário recebido. | Escopo de teste limitado às VMs e destinos explicitamente autorizados. |
| OPS-004 | Cliente + Servidor | Confirmar versão do OpenClaw | `openclaw --version` | OpenClaw 2026.7.1-2 (build `0790d9f`) nas duas VMs. | Versão de referência fixada. |
| OPS-005 | Cliente + Servidor (a confirmar) | Descobrir superfícies administrativas | `openclaw --help` | CLI possui controles de plugins, skills, MCP, aprovações, política de execução e sandbox. | Inventário direcionado para essas superfícies. |
| OPS-006 | Cliente + Servidor | Inventariar plugins e skills | `openclaw plugins list`, `openclaw skills list` | Mesma listagem nas duas VMs: 50/68 plugins habilitados e 16/53 skills prontas. | Tratar capacidades instaladas como superfície disponível, não como autorização automática. |
| OPS-007 | Cliente + Servidor (a confirmar) | Inspecionar superfícies de controle | `openclaw mcp --help`, `openclaw exec-policy --help`, `openclaw approvals --help`, `openclaw sandbox --help` | Comandos de inspeção e configuração estão disponíveis. | Prosseguir para verificar configuração efetiva. |
| OPS-008 | Cliente + Servidor | Verificar política efetiva, sandbox e MCP | `openclaw exec-policy show`, `openclaw approvals get`, `openclaw sandbox explain`, `openclaw sandbox list`, `openclaw mcp status` | Execução direta no host, `tools.exec` permissivo sem confirmação, sandbox desativado, zero runtimes e nenhum servidor MCP configurado — mesma configuração efetiva nas duas VMs. | Não usar o agente principal com conteúdo não confiável. Preparar perfil/configuração de teste. |
| OPS-009 | Servidor (a confirmar) | Verificar pré-requisito Docker | `docker --version`, `sudo docker info --format '{{.ServerVersion}}'`, `sudo docker image inspect openclaw-sandbox:bookworm-slim --format '{{.Id}}'` | Docker Engine 29.1.3 está disponível; a imagem padrão de sandbox não existia localmente. | Construção da imagem é necessária antes de habilitar sandbox Docker. |
| OPS-010 | Servidor (a confirmar) | Confirmar mecanismo seguro de alteração de configuração | `openclaw config patch --help` | `config patch` aceita JSON5, valida schema e permite `--dry-run` antes de gravar. | Toda alteração de configuração será validada com dry-run primeiro. |
| OPS-011 | Servidor | Construir e validar a imagem de sandbox | Ver comando completo abaixo (§ "Comandos completos") | Imagem construída com sucesso; `docker image inspect` retornou um digest válido, confirmando que a imagem existe localmente. | Pré-requisito de sandbox Docker atendido; prosseguir para o perfil de testes. |
| OPS-012 | Servidor | Mapear a estrutura real de `agents` no schema | `openclaw config schema > /tmp/openclaw-schema.json`; extração local do subtrecho `properties.agents` e inspeção manual (`grep`/`sed`) | Estrutura confirmada: `agents.defaults` (baseline compartilhado) e `agents.list` — um **array**, cada item exigindo `id` e aceitando overrides de `model`, `identity`, `workspace`, `sandbox` e `tools`. **Não existe** `agents.entries`. `sandbox` aceita `mode: off\|non-main\|all`, `workspaceAccess: none\|ro\|rw`, `scope: session\|agent\|shared`, e um bloco `docker: {image, network, readOnlyRoot, capDrop, tmpfs, user, env, ...}`. `tools` aceita `profile: minimal\|coding\|messaging\|full`, `allow`, `alsoAllow` e `deny` (arrays de strings livres, sem enum fixo no schema). | [PATCH_DE_TESTE.json5](PATCH_DE_TESTE.json5) reescrito para usar `agents.list` com `id: "lab-test"`, em vez do formato `agents.entries` do rascunho original (baseado em documentação indireta, que estava errada para esta versão). |
| OPS-013 | Servidor | Criar workspace sintético e validar o patch do agente de teste em dry-run | `mkdir lab-test-workspace`; `openclaw config patch --file ./PATCH_DE_TESTE.json5 --dry-run` | Dry run bem-sucedido: 1 atualização validada contra a configuração ativa. Nenhuma alteração foi gravada ainda. | Patch estruturalmente correto; aplicar sem `--dry-run` (nenhuma flag adicional é necessária — `--allow-exec` mencionado antes em conversa não corresponde a uma opção real deste comando). |
| OPS-014 | Servidor | Aplicar o patch do agente de teste | `openclaw config patch --file ./PATCH_DE_TESTE.json5` (`workspace` apontando para a pasta sintética criada na home do usuário no servidor) | `Applied 1 config update(s). Change will apply without restarting the gateway.` | Agente `lab-test` gravado na configuração ativa, com sandbox Docker restritivo. Pendente: confirmar que o agente aparece corretamente (`openclaw config get agents.list`) e tratar a política de execução (`tools.exec`/aprovações) dele, que este patch não cobre. |
| OPS-015 | Servidor | Ler o documento de aprovações de execução e a política efetiva | `openclaw config get agents.list`, `openclaw exec-policy --help`, `openclaw approvals --help`, `openclaw exec-policy set --help`, `openclaw approvals set --help`, `openclaw approvals get --json` | `config get agents.list` confirma o agente `lab-test` gravado corretamente (sandbox/tools como planejado). O documento de aprovações mostrou que o **agente cotidiano usado neste servidor tem id real `crestodian`** (não `main` — esse era só um rótulo genérico usado nos documentos até aqui) com `security: full, ask: off`. O agente `lab-test` **ainda não tinha entrada própria** no documento, então sua política efetiva de execução herdava o padrão global (`full`/`off`) — o sandbox por si só não bloqueia `tools.exec`. `exec-policy set` não tem escopo por agente (só global); `approvals set` substitui o documento inteiro (sem `--dry-run`) e é o mecanismo correto para definir `agents.lab-test`. | Escrever `agents.lab-test: {security: "deny", ask: "off", askFallback: "deny"}` no documento de aprovações via `approvals set --stdin`, preservando a entrada existente de `crestodian` sem alteração. |
| OPS-016 | Servidor | Aplicar e confirmar a política de execução do `lab-test` | `openclaw approvals set --stdin` (documento com `crestodian` preservado + `lab-test: {security: deny, ask: off, askFallback: deny}`), `openclaw approvals get --json` | Escrita confirmada (2 agentes no documento). Política efetiva: `agent:lab-test` → `security: "deny"`, `mode: "deny"` (execução de comando bloqueada). `agent:crestodian` permanece `full`/`off`, sem alteração. | **Perfil de teste `lab-test` concluído:** sandbox Docker isolado + `tools.deny` + execução de comando negada. Pronto para o primeiro cenário sintético observacional (THR-001). |

**Estado real neste momento:** perfil de teste `lab-test` completo e verificado (OPS-011 a OPS-016): sandbox restritivo, ferramentas negadas e execução de comando bloqueada, sem afetar o agente cotidiano (`crestodian`). Próximo passo é o primeiro cenário sintético — rascunho em [EXP-001-injecao-indireta.md](EXP-001-injecao-indireta.md), ainda não executado.

## Comandos completos (quando não cabem na tabela)

### OPS-011 — construção da imagem de sandbox (Servidor)

O OpenClaw não substitui automaticamente a imagem padrão quando ela está ausente. Para instalação via npm, a documentação oficial orienta construir a imagem localmente. A execução abaixo cria uma imagem Docker local e pode baixar a imagem-base Debian e pacotes necessários; ela não altera o arquivo de configuração do OpenClaw.

```bash
sudo docker build -t openclaw-sandbox:bookworm-slim - <<'DOCKERFILE'
FROM debian:bookworm-slim
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
  bash ca-certificates curl git jq python3 ripgrep \
  && rm -rf /var/lib/apt/lists/*
RUN useradd --create-home --shell /bin/bash sandbox
USER sandbox
WORKDIR /home/sandbox
CMD ["sleep", "infinity"]
DOCKERFILE
```

Validação sem alterar o OpenClaw:

```bash
sudo docker image inspect openclaw-sandbox:bookworm-slim --format '{{.Id}}'
```

Resultado sanitizado confirmado: `docker image inspect` retornou um digest `sha256:...` válido (não repetir o valor completo aqui — não é segredo, mas não agrega informação reprodutível além de "a imagem existe").

## Perfil de testes — aplicado (Servidor)

**Estado:** agente separado `lab-test` (`agents.list`) aplicado com sucesso (OPS-014), preservando o agente `main`/`defaults` intocado. Ele aplica estes objetivos técnicos:

- sandbox Docker ativo (`sandbox.mode: "all"`, `sandbox.backend: "docker"`);
- `workspaceAccess: "ro"`;
- rede do container (`sandbox.docker.network`) definida como `"none"`;
- root filesystem somente leitura (`readOnlyRoot: true`) e capabilities removidas (`capDrop: ["ALL"]`);
- perfil de ferramentas mínimo (`tools.profile: "minimal"`) com `deny` explícito de shell/escrita/navegador/mensageria/MCP.

**Pendente antes de usar `lab-test` com qualquer conteúdo não confiável:**

1. Confirmar a leitura da configuração final (ex.: `openclaw config get agents.list`).
2. Tratar a política de execução (`tools.exec`/aprovações) do agente — esse documento fica separado do arquivo de configuração (já visto em OPS-007/008) e este patch **não** o cobre. Revisar `openclaw exec-policy --help`/`openclaw approvals --help` para uma variante com escopo por agente, em vez de assumir que o `deny` do sandbox já basta.

## Referências

- [Especificações e resultados (ambiente)](../ambiente/ESPECIFICACOES_E_RESULTADOS_V1.md)
- [Plano de trabalho (planejamento)](../planejamento/Miguel-V1.md)
- [Rascunho do primeiro cenário — EXP-001](EXP-001-injecao-indireta.md)
- [Sandboxing — documentação oficial](https://docs.openclaw.ai/gateway/sandboxing)
- [Aprovações de execução — documentação oficial](https://docs.openclaw.ai/cli/approvals)
