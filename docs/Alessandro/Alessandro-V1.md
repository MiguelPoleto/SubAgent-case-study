# Testbed Docker isolado do OpenClaw

Este documento registra o testbed da branch `Alessandro`. Ele não replica uma configuração anterior do Miguel: os arquivos em `docs/Miguel/` estão vazios e não há ali um ambiente Docker. A implementação abaixo segue a documentação atual do OpenClaw para **Gateway em Docker + sandbox de ferramentas Docker**.

O objetivo é experimentar com dados sintéticos em uma instância descartável. O Gateway recebe o token do operador e pode alcançar o provedor de modelo; toda execução de ferramentas pelo agente acontece em outro contêiner, criado sob demanda, com rede desligada e sem acesso ao host.

## Arquitetura e limites

```text
navegador do operador
        │  http://127.0.0.1:18789 (token)
        ▼
Gateway OpenClaw (Docker, porta só no loopback)
        │  Docker socket — fronteira de operador confiável
        ▼
Sandbox por sessão (Docker)
  rede: none · root FS: somente leitura · cap_drop: ALL
  workspace próprio · sem mount do workspace do agente/host
```

O socket Docker é necessariamente entregue ao **Gateway**, pois ele cria os contêineres-sandbox irmãos. Isso torna o Gateway um componente confiável e não uma fronteira contra seu próprio comprometimento. O socket **não é montado** no sandbox. O Gateway mantém saída para a API do modelo; o sandbox do agente usa `network: none` e não possui saída de rede.

O modo `all`, escopo `session` e `workspaceAccess: none` priorizam isolamento: inclusive a sessão principal usa um sandbox próprio e não vê o workspace permanente do agente. O diretório temporário do sandbox é descartável e limitado a 1 CPU, 768 MiB, 128 processos e dois dias de vida máxima.

## Conteúdo versionado

- `testbed/openclaw/compose.yaml`: Gateway e perfil de build da imagem de sandbox.
- `testbed/openclaw/sandbox/Dockerfile`: imagem mínima, baseada no Dockerfile indicado pelo OpenClaw, com ferramentas necessárias para operações de arquivo.
- `testbed/openclaw/config/openclaw.json`: política de sandbox e permissões restritas.
- `testbed/openclaw/.env.example`: variáveis sem segredos.
- `testbed/openclaw/bootstrap.sh`: prepara diretórios e instala o arquivo de configuração inicial sem sobrescrever uma configuração já criada.

`testbed/openclaw/.env` e `testbed/openclaw/runtime/` são locais e estão no `.gitignore`: não faça commit de token, perfil de autenticação, conversas, logs ou resultados de experimentos sem revisão. O diretório `runtime/auth-profile-secrets` é montado separadamente e também deve ser tratado como credencial.

## Pré-requisitos

- Docker Engine/Docker Desktop com integração WSL habilitada, se aplicável;
- Docker Compose v2 (`docker compose version`);
- acesso à imagem oficial `ghcr.io/openclaw/openclaw:2026.9.3` e à imagem base Debian durante o primeiro build;
- pelo menos 6 GB de RAM se optar por construir uma imagem completa do OpenClaw a partir do código-fonte. Este testbed usa a imagem oficial pré-construída e não exige esse build.

## Criar e iniciar

No repositório, copie as variáveis e gere um token local forte:

```bash
cd testbed/openclaw
cp .env.example .env
openssl rand -hex 32
# cole o valor em OPENCLAW_GATEWAY_TOKEN no .env
stat -c '%g' /var/run/docker.sock
# cole o GID retornado em DOCKER_GID no .env
./bootstrap.sh
sudo chown -R 1000:1000 runtime
docker compose build gateway sandbox-image
docker compose up -d gateway
```

`bootstrap.sh` copia `config/openclaw.json` apenas na primeira vez. A imagem `gateway` adiciona somente o cliente Docker à imagem oficial, pois o Gateway precisa criar os sandboxes irmãos; o contêiner sandbox não recebe socket nem cliente Docker. Execute o onboarding para configurar o provedor, informando credenciais somente no prompt/segredo local:

```bash
docker compose run --rm --no-deps gateway onboard --auth-choice openai-api-key --no-install-daemon
```

Não coloque chaves de API no Git nem em um `openclaw.json` versionado.

Depois, acesse `http://127.0.0.1:18789/` e informe o token definido no `.env`. Em uma VM remota, mantenha a porta fechada externamente e use túnel SSH:

```bash
ssh -N -L 18789:127.0.0.1:18789 USUARIO@IP_DA_VM
```

## Verificação operacional

```bash
cd testbed/openclaw
docker compose ps
docker compose logs -f gateway
docker compose exec gateway node dist/index.js doctor
docker compose exec gateway node dist/index.js sandbox list
docker compose exec gateway node dist/index.js sandbox explain
```

Após abrir uma sessão que use ferramentas, `openclaw sandbox list` deve mostrar um contêiner com o prefixo `openclaw-testbed-sbx-`. Valide também no daemon:

```bash
docker ps --filter 'name=openclaw-testbed-sbx-'
docker inspect NOME_DO_SANDBOX --format '{{.HostConfig.NetworkMode}} {{.HostConfig.ReadonlyRootfs}}'
```

O resultado esperado é `none true`. Uma tentativa de rede feita pelo agente deve falhar; uma ferramenta pode gravar apenas no workspace efêmero do sandbox, nunca no host ou em `runtime/workspace`.

## Operação e limpeza

```bash
# parar sem apagar evidências locais
docker compose stop gateway

# iniciar novamente
docker compose up -d gateway

# remover contêineres e a rede do compose
docker compose down

# recriar sandboxes após mudar a política
docker compose exec gateway node dist/index.js sandbox recreate
```

Para descartar completamente uma execução, pare a stack e remova manualmente `testbed/openclaw/runtime/`. Esse diretório contém estado e pode incluir dados sensíveis; revise-o antes de arquivar qualquer artefato. Não use o testbed com canais de mensageria, contas ou dados reais.

## Atualização controlada

O arquivo de exemplo fixa `2026.9.3`, evitando que a imagem `latest` altere um experimento sem registro. Para atualizar: altere o tag no `.env`, execute `docker compose pull gateway`, recrie o Gateway, rode `openclaw doctor` e registre a nova versão no experimento. Reconstrua `sandbox-image` quando o Dockerfile ou sua imagem base mudar.

## Referências

- [Docker — OpenClaw](https://docs.openclaw.ai/install/docker)
- [Docker backend — OpenClaw](https://docs.openclaw.ai/gateway/sandboxing/docker-backend)
- [Configuração de sandbox — OpenClaw](https://docs.openclaw.ai/gateway/config-agents/sandbox)
- [Imagens e preparação do sandbox — OpenClaw](https://docs.openclaw.ai/gateway/sandboxing/images-and-setup)
- [Permissões de ferramentas — OpenClaw](https://docs.openclaw.ai/gateway/security/tool-permissions)
