# Registro operacional — frente Miguel (V1)

> Diário sanitizado das verificações e mudanças do laboratório. Este arquivo registra o objetivo de cada comando, seu resultado resumido e a decisão decorrente. Não colar saídas brutas que incluam contas, caminhos pessoais, IPs, tokens, hashes de autenticação ou outros identificadores.

## Regras de registro

- Registrar comandos de leitura, validação, configuração e teste que sejam relevantes para a reprodução do projeto.
- Registrar resultados em linguagem resumida, não a saída completa do terminal.
- Marcar alterações planejadas como **pendentes** até que sejam executadas e validadas.
- Nunca registrar arquivos `.env`, segredos, perfis de autenticação, arquivos de configuração completos ou credenciais.

## Execuções concluídas

| ID | Objetivo | Comando(s) executado(s) | Resultado sanitizado | Decisão |
| --- | --- | --- | --- | --- |
| OPS-001 | Identificar sistemas operacionais | `lsb_release -a` | Cliente e servidor usam Ubuntu Server 22.04.5 LTS (`jammy`). | Ambiente-base registrado. |
| OPS-002 | Identificar virtualização e recursos | `lscpu`, `free -h`, `df -hT`, `lsblk` | Duas VMs KVM com 4 vCPUs, aproximadamente 3,8 GiB de RAM/swap e disco virtual de 50 GB. | Recursos suficientes para a preparação inicial. |
| OPS-003 | Registrar rede e exposição local | `ip -br address`, `ip route`, `ss -tunap`, `sudo ufw status verbose` | Rede acadêmica compartilhada com acesso externo necessário; UFW inativo; serviços OpenClaw expostos apenas em loopback no inventário recebido. | Escopo de teste limitado às VMs e destinos explicitamente autorizados. |
| OPS-004 | Confirmar versão do OpenClaw | `openclaw --version` | OpenClaw 2026.7.1-2 (build `0790d9f`) nas duas VMs. | Versão de referência fixada. |
| OPS-005 | Descobrir superfícies administrativas | `openclaw --help` | CLI possui controles de plugins, skills, MCP, aprovações, política de execução e sandbox. | Inventário direcionado para essas superfícies. |
| OPS-006 | Inventariar plugins e skills | `openclaw plugins list`, `openclaw skills list` | Mesma listagem nas duas VMs: 50/68 plugins habilitados e 16/53 skills prontas. | Tratar capacidades instaladas como superfície disponível, não como autorização automática. |
| OPS-007 | Inspecionar superfícies de controle | `openclaw mcp --help`, `openclaw exec-policy --help`, `openclaw approvals --help`, `openclaw sandbox --help` | Comandos de inspeção e configuração estão disponíveis. | Prosseguir para verificar configuração efetiva. |
| OPS-008 | Verificar política efetiva, sandbox e MCP | `openclaw exec-policy show`, `openclaw approvals get`, `openclaw sandbox explain`, `openclaw sandbox list`, `openclaw mcp status` | Execução direta no host, `tools.exec` permissivo sem confirmação, sandbox desativado, zero runtimes e nenhum servidor MCP configurado. | Não usar o agente principal com conteúdo não confiável. Preparar perfil/configuração de teste. |
| OPS-009 | Verificar pré-requisito Docker | `docker --version`, `sudo docker info --format '{{.ServerVersion}}'`, `sudo docker image inspect openclaw-sandbox:bookworm-slim --format '{{.Id}}'` | Docker Engine 29.1.3 está disponível; a imagem padrão de sandbox não existe localmente. | Construção da imagem é necessária antes de habilitar sandbox Docker. |
| OPS-010 | Confirmar mecanismo seguro de alteração de configuração | `openclaw config patch --help` | `config patch` aceita JSON5, valida schema e permite `--dry-run` antes de gravar. | Toda alteração de configuração será validada com dry-run primeiro. |

## Próxima alteração planejada — imagem de sandbox

**Estado:** pendente de autorização e execução no servidor de testes.

O OpenClaw não substitui automaticamente a imagem padrão quando ela está ausente. Para instalação via npm, a documentação oficial orienta construir a imagem localmente. A execução abaixo cria uma imagem Docker local e pode baixar a imagem-base Debian e pacotes necessários; ela não altera ainda o arquivo de configuração do OpenClaw.

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

Após a construção, validar sem alterar o OpenClaw:

```bash
sudo docker image inspect openclaw-sandbox:bookworm-slim --format '{{.Id}}'
```

## Próxima alteração planejada — perfil de testes

**Estado:** pendente de decisão entre perfil separado e agente separado, seguido de validação em dry-run.

O perfil/configuração de teste deverá aplicar estes objetivos técnicos:

- sandbox Docker ativo para as sessões de teste;
- `workspaceAccess` somente leitura no primeiro experimento;
- rede do container definida como `none`;
- root filesystem somente leitura e capabilities removidas;
- ferramentas de shell/processo e escrita negadas no primeiro cenário;
- nenhuma integração MCP, mensagem, navegador ou extensão nova habilitada sem necessidade documentada.

Antes de gravar, o patch JSON5 será executado com:

```bash
openclaw config patch --file ./PATCH_DE_TESTE.json5 --dry-run
```

O arquivo de patch será definido e revisado antes da aplicação. Não usar `--allow-exec` nesta validação inicial.

## Referências

- [Especificações e resultados](ESPECIFICACOES_E_RESULTADOS_V1.md)
- [Plano de trabalho](Miguel-V1.md)
- [Sandboxing — documentação oficial](https://docs.openclaw.ai/gateway/sandboxing)
- [Aprovações de execução — documentação oficial](https://docs.openclaw.ai/cli/approvals)
