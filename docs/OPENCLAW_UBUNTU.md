# OpenClaw em Ubuntu Server

Este guia instala e configura o OpenClaw em uma VM Ubuntu Server. Ele é adequado às duas VMs deste projeto, mas comece por apenas uma delas para validar a configuração. Só instale uma segunda instância quando houver uma necessidade de pesquisa definida e um plano de isolamento entre elas.

> Os comandos usam a instalação oficial. Execute-os com um usuário normal que tenha `sudo`; não use `root` para operar o Gateway.

## 1. Preparar a VM

Conecte-se por SSH e atualize os pacotes:

```bash
sudo apt update
sudo apt upgrade -y
sudo apt install -y ca-certificates curl git
```

Confirme a versão do sistema:

```bash
cat /etc/os-release
```

Para o ambiente de pesquisa, mantenha a VM isolada, sem dados pessoais, chaves de produção ou contas de mensageria reais.

## 2. Instalar o OpenClaw

O instalador oficial identifica o Linux, prepara uma versão compatível do Node quando necessário, instala a CLI e inicia o onboarding:

```bash
curl -fsSL --proto '=https' --tlsv1.2 https://openclaw.ai/install.sh | bash
```

Após a instalação, abra um novo terminal SSH ou recarregue o perfil de shell caso o comando não seja encontrado. Verifique a CLI:

```bash
openclaw --version
openclaw doctor
```

Se preferir instalar a CLI manualmente, use uma versão de Node suportada e então:

```bash
npm install -g openclaw@latest --allow-scripts openclaw
```

Consulte a documentação oficial antes de escolher um método alternativo (Docker, código-fonte ou prefixo local), pois as versões suportadas podem mudar.

## 3. Escolher como o OpenClaw usará modelos

Para este projeto, a opção principal é a **API da OpenAI**, usando uma chave de projeto e cobrança por uso da API. Essa opção é independente de uma assinatura do ChatGPT e é a mais apropriada para controlar credenciais, orçamento e experimentos nas VMs.

| Opção | Quando usar | Observação |
| --- | --- | --- |
| **OpenAI API (recomendada)** | Experimentos controlados com modelos GPT e cobrança por uso | Crie uma chave de projeto na plataforma OpenAI e escolha **OpenAI API Key** no onboarding. |
| OpenAI via ChatGPT/Codex | Quando a conta tiver acesso compatível e o uso estiver autorizado pelos termos do plano | Usa autenticação OAuth; não é a mesma modalidade da API por chave. |
| Outro provedor hospedado | Comparar modelos ou custos (Anthropic, Gemini, OpenRouter, etc.) | Cada provedor requer sua própria conta, credencial e revisão de termos. |
| Modelo local | Reduzir dependência externa e testar isolamento | Pode usar Ollama, LM Studio, vLLM ou servidor compatível; exige recursos locais e normalmente reduz a capacidade do modelo. |

### Opção recomendada: OpenAI API

1. Crie uma chave de API em um projeto dedicado na plataforma OpenAI.
2. Defina limites de uso e acompanhe o consumo desse projeto antes de iniciar experimentos.
3. No onboarding abaixo, selecione a autenticação **OpenAI API Key** e informe a chave somente no prompt local.
4. Depois, liste os modelos disponíveis para essa credencial e escolha explicitamente o modelo padrão:

```bash
openclaw models list --provider openai
openclaw models set openai/ID_DO_MODELO
```

Substitua `ID_DO_MODELO` por um item exibido pelo primeiro comando. Isso evita documentar ou fixar um modelo que talvez não esteja disponível para a conta do projeto.

O OpenClaw usa `OPENAI_API_KEY` como credencial da API quando configurado por variável de ambiente. Porém, para um Gateway executado como serviço, prefira informar a chave durante o onboarding ou usar o mecanismo de segredos do ambiente de serviço: uma variável exportada apenas no shell SSH pode não estar disponível para o `systemd`.

### Outras opções

- **ChatGPT/Codex OAuth:** execute `openclaw onboard --auth-choice openai` ou `openclaw models auth login --provider openai`. Use apenas se essa modalidade fizer parte do ambiente autorizado do projeto.
- **Outro provedor hospedado:** execute `openclaw onboard` e selecione o provedor desejado; confira os modelos com `openclaw models list --provider ID_DO_PROVEDOR` antes de defini-lo.
- **Modelo local:** instale e mantenha o servidor de modelos exclusivamente dentro do testbed. Registre modelo, quantização, hardware, endpoint e limitações, pois eles influenciam diretamente os resultados de segurança.

Uma mesma instalação pode ter mais de um provedor configurado. Para experimentos comparativos, mude o modelo de forma explícita e registre a versão, o provedor e a configuração usados em cada execução.

## 4. Executar o onboarding e instalar o serviço

O onboarding configura o Gateway, o workspace e o provedor de modelo. Execute-o no usuário que será dono do processo:

```bash
openclaw onboard --auth-choice openai-api-key --install-daemon
```

Informe segredos e tokens apenas nos prompts locais. Não os salve neste repositório, não os envie em chat e não os coloque em arquivos versionados.

No Ubuntu, esse comando instala normalmente um serviço `systemd` de usuário. Confira o estado:

```bash
openclaw gateway status
systemctl --user status openclaw-gateway
```

Se o nome da unidade variar por perfil, use:

```bash
systemctl --user list-units --type=service | grep openclaw
```

## 5. Acessar o Gateway com segurança

Para uma VM remota, mantenha o Gateway ligado apenas a `127.0.0.1` enquanto estiver em desenvolvimento. Acesse a interface pela máquina local usando um túnel SSH:

```bash
ssh -N -L 18789:127.0.0.1:18789 USUARIO@IP_DA_VM
```

Com o túnel aberto, acesse `http://127.0.0.1:18789/` no navegador local e autentique-se com o segredo configurado no onboarding.

Não abra a porta do Gateway na internet nem altere o bind para a rede local sem uma necessidade explícita, autenticação forte e revisão da configuração de rede.

## 6. Configuração para o projeto

Antes de habilitar integrações, registre no planejamento:

1. a finalidade da instância (cliente, servidor ou testbed);
2. as ferramentas e permissões necessárias;
3. as fontes de entrada permitidas;
4. os limites de rede e de arquivos;
5. como a instância será apagada ou restaurada após cada experimento.

Use dados sintéticos e contas de teste. Em especial, não conecte WhatsApp, Telegram, e-mail ou outros canais reais a uma instância usada para experimentos ofensivos.

## 7. Operação e diagnóstico

Comandos úteis:

```bash
openclaw gateway status
openclaw doctor
openclaw gateway restart
```

Quando terminar uma sessão de pesquisa, pare o Gateway se ele não precisar continuar em execução:

```bash
openclaw gateway stop
```

Para atualizações, migrações ou remoção, consulte a documentação oficial em vez de remover diretórios manualmente.

## Referências oficiais

- [Instalação do OpenClaw](https://docs.openclaw.ai/install)
- [OpenClaw no Linux](https://docs.openclaw.ai/platforms/linux)
- [OpenAI como provedor no OpenClaw](https://docs.openclaw.ai/providers/openai)
- [Provedores de modelos do OpenClaw](https://docs.openclaw.ai/concepts/model-providers)
- [Início rápido da API da OpenAI](https://platform.openai.com/docs/quickstart/make-your-first-api-request)
- [Atualizações](https://docs.openclaw.ai/install/updating)
