# SSH + tmux — Gerenciamento de duas VMs no macOS e Linux

Este tutorial mostra como abrir e administrar, em um único terminal, duas conexões SSH simultâneas: uma para a VM **Cliente** e outra para a VM **Servidor**. As instruções funcionam no **macOS** e no **Linux**.

Ao final, basta executar:

```bash
./vms.sh
```

O script abre uma sessão `tmux` chamada `vms`, com as conexões lado a lado:

```text
┌──────────────────────────┬──────────────────────────┐
│         CLIENTE          │         SERVIDOR         │
│                          │                          │
│      SSH conectado       │      SSH conectado       │
│                          │                          │
└──────────────────────────┴──────────────────────────┘
```

O mesmo arquivo `vms.sh` é usado nos dois sistemas; não é necessário um script específico para Linux.

---

## 1. Pré-requisitos

Você precisa ter:

- acesso SSH às duas VMs;
- o endereço IP e o usuário de cada VM;
- `tmux` instalado;
- Bash disponível (já vem no macOS e na maioria das distribuições Linux).

Teste o acesso manual antes de continuar:

```bash
ssh USUARIO@IP_DA_VM_CLIENTE
ssh USUARIO@IP_DA_VM_SERVIDOR
```

Use `exit` para sair de cada conexão de teste.

---

## 2. Instalar o tmux

### macOS

No macOS, instale o [Homebrew](https://brew.sh/) caso ainda não o tenha:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Siga o comando de configuração de `PATH` exibido ao final da instalação. Em Macs com Apple Silicon, um exemplo comum é:

```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

Depois, instale o tmux:

```bash
brew install tmux
```

### Linux

Instale pelo gerenciador de pacotes da sua distribuição:

```bash
# Ubuntu, Debian e derivados
sudo apt update && sudo apt install -y tmux

# Fedora, RHEL e Rocky Linux recentes
sudo dnf install -y tmux

# Arch Linux e derivados
sudo pacman -S tmux
```

Verifique a instalação em qualquer sistema:

```bash
tmux -V
```

---

## 3. Configurar os dados das VMs

Na raiz deste projeto, crie ou edite o arquivo `.env`:

```env
CLIENT_USER=SEU_USUARIO
CLIENT_IP=IP_DA_VM_CLIENTE

SERVER_USER=SEU_USUARIO
SERVER_IP=IP_DA_VM_SERVIDOR
```

Exemplo:

```env
CLIENT_USER=ubuntu
CLIENT_IP=192.168.1.10

SERVER_USER=ubuntu
SERVER_IP=192.168.1.11
```

Não envie esse arquivo ao repositório: ele pode conter dados privados. Confirme que `.env` está no `.gitignore`.

---

## 4. Configurar chave SSH (recomendado)

Com chaves SSH, o script conecta sem pedir senha. Gere uma chave na máquina local, caso ainda não exista:

```bash
ssh-keygen -t ed25519
```

Aceite o local padrão quando solicitado. Em seguida, copie a chave pública para cada VM.

### Linux

Em muitas distribuições, `ssh-copy-id` já está disponível:

```bash
ssh-copy-id CLIENT_USER@CLIENT_IP
ssh-copy-id SERVER_USER@SERVER_IP
```

Caso o comando não exista, instale o pacote `openssh-client` (Debian/Ubuntu) ou `openssh-clients` (Fedora/RHEL), ou use o método abaixo.

### macOS ou qualquer sistema sem `ssh-copy-id`

```bash
cat ~/.ssh/id_ed25519.pub | ssh CLIENT_USER@CLIENT_IP 'mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys'
cat ~/.ssh/id_ed25519.pub | ssh SERVER_USER@SERVER_IP 'mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys'
```

Teste as duas conexões novamente:

```bash
ssh CLIENT_USER@CLIENT_IP
ssh SERVER_USER@SERVER_IP
```

---

## 5. Executar o script

Na primeira vez, dê permissão de execução:

```bash
chmod +x vms.sh
```

Depois, inicie as duas VMs no tmux:

```bash
./vms.sh
```

Se a sessão `vms` já existir, o script apenas se reconecta a ela. Funciona da mesma forma no macOS e no Linux.

---

## 6. Comandos essenciais do tmux

O prefixo padrão do tmux é `Ctrl + B`: pressione e solte essas teclas antes da próxima tecla.

| Ação | Atalho ou comando |
| --- | --- |
| Alternar de painel | `Ctrl + B`, depois seta para a direção desejada |
| Desanexar sem encerrar a sessão | `Ctrl + B`, depois `D` |
| Listar sessões | `tmux ls` |
| Retomar a sessão das VMs | `tmux attach -t vms` |
| Encerrar a sessão das VMs | `tmux kill-session -t vms` |

Para sair definitivamente de uma VM, execute `exit` no painel correspondente. Para encerrar os dois painéis e remover a sessão, use `tmux kill-session -t vms`.

---

## 7. Solução de problemas

**`tmux: command not found`**: instale o tmux conforme a seção 2 e abra um novo terminal.

**`Erro: arquivo .env não encontrado.`**: crie o `.env` na mesma pasta que o `vms.sh` e preencha as quatro variáveis.

**A conexão pede senha ou é recusada**: teste o comando `ssh` manualmente; confirme usuário, IP, conectividade de rede e a configuração da chave pública na VM.

**Uma sessão antiga está aberta**: retome-a com `tmux attach -t vms` ou finalize-a com `tmux kill-session -t vms` antes de executar o script novamente.
