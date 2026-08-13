# SSH + tmux — Gerenciamento de duas VMs

Este tutorial mostra como configurar o `tmux` para trabalhar com duas VMs simultaneamente — uma **Cliente** e uma **Servidor** — utilizando SSH e um único terminal.

Ao final, será possível executar apenas um script:

```bash
./vms.sh
```

E abrir automaticamente as duas conexões lado a lado:

```text
┌──────────────────────────┬──────────────────────────┐
│        CLIENTE           │         SERVIDOR         │
│                          │                          │
│  SSH conectado           │  SSH conectado           │
│                          │                          │
└──────────────────────────┴──────────────────────────┘
```

Além disso, a sessão do `tmux` pode ser mantida em segundo plano e retomada posteriormente.

---

## 1. O que é o tmux?

O `tmux` é um **multiplexador de terminal**. Ele permite executar vários terminais dentro de uma única janela.

Neste projeto, a estrutura será:

```text
Terminal
└── tmux
    ├── Painel 1 → SSH → VM Cliente
    └── Painel 2 → SSH → VM Servidor
```

Uma das principais vantagens é poder sair da sessão sem encerrá-la.

---

## 2. Instalação do Homebrew

No macOS, utilizamos o **Homebrew** para instalar ferramentas de desenvolvimento.

Instalação:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Após a instalação, o Homebrew informa os comandos necessários para adicioná-lo ao `PATH`.

Exemplo:

```bash
echo >> ~/.zprofile
echo 'eval "$(/opt/homebrew/bin/brew shellenv zsh)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv zsh)"
```

Verifique a instalação:

```bash
brew --version
```

---

## 3. Instalação do tmux

Com o Homebrew funcionando:

```bash
brew install tmux
```

Verifique:

```bash
tmux -V
```

Exemplo:

```text
tmux 3.7b
```

---

## 4. Conhecendo o tmux

Para iniciar uma sessão:

```bash
tmux
```

### Dividir o terminal verticalmente

Pressione:

```text
Ctrl + B
```

Solte as teclas e depois pressione:

```text
%
```

Resultado:

```text
┌────────────────────┬────────────────────┐
│                    │                    │
│      Painel 1      │      Painel 2      │
│                    │                    │
└────────────────────┴────────────────────┘
```

### Alternar entre os painéis

Use:

```text
Ctrl + B → →
```

ou:

```text
Ctrl + B → ←
```

---

## 5. Detach e Attach

Uma das funcionalidades mais importantes do `tmux` é poder sair da sessão sem encerrá-la.

Para fazer **detach**:

```text
Ctrl + B
D
```

A sessão continua executando em segundo plano.

Para visualizar as sessões existentes:

```bash
tmux ls
```

Para voltar à sessão:

```bash
tmux attach
```

Ou, caso exista uma sessão chamada `vms`:

```bash
tmux attach -t vms
```

---

## 6. Encerrando uma sessão

Para encerrar completamente uma sessão:

```bash
tmux kill-session -t vms
```

Isso encerra todos os painéis daquela sessão.

Depois é possível criar uma nova sessão novamente.

---

# 7. Configuração do SSH

Antes de criar o script, é necessário conseguir acessar as duas VMs através de SSH.

Exemplo:

```bash
ssh USUARIO@IP_DA_VM_CLIENTE
```

E:

```bash
ssh USUARIO@IP_DA_VM_SERVIDOR
```

Para evitar precisar digitar a senha a cada conexão, pode-se configurar uma chave SSH.

Na máquina local:

```bash
ssh-keygen
```

Depois:

```bash
ssh-copy-id USUARIO@IP_DA_VM_CLIENTE
```

E:

```bash
ssh-copy-id USUARIO@IP_DA_VM_SERVIDOR
```

Após isso, teste novamente:

```bash
ssh USUARIO@IP_DA_VM_CLIENTE
```

E:

```bash
ssh USUARIO@IP_DA_VM_SERVIDOR
```

Se tudo estiver configurado corretamente, a conexão poderá ser feita sem solicitar a senha da VM.

> **Observação:** as informações específicas das VMs, como usuários e IPs, devem ser armazenadas no arquivo .env. O arquivo .env deve ser adicionado ao .gitignore para evitar que essas informações sejam enviadas ao repositório..

---

# 8. Configurando as variáveis de ambiente

Para não deixar usuários e IPs diretamente no script, as informações das VMs serão armazenadas em um arquivo `.env`.

Na raiz do projeto, crie:

```env
.env
```

Adicione:

```
CLIENT_USER=SEU_USUARIO
CLIENT_IP=IP_DA_VM_CLIENTE

SERVER_USER=SEU_USUARIO
SERVER_IP=IP_DA_VM_SERVIDOR
````

### Exemplo:

```
CLIENT_USER=client
CLIENT_IP=10.10.100.100

SERVER_USER=user
SERVER_IP=10.10.100.100
```
> **Importante:** O arquivo `.env` não deve ser enviado para o GitHub, pois contém informações específicas do ambiente. Adicione `.env` ao arquivo `.gitignore`.

---

# 9. Criando o script

Crie uma pasta para os scripts:

```bash
mkdir -p ~/scripts
cd ~/scripts
```

Crie o arquivo:

```bash
nano vms.sh
```

O script será responsável por:

1. Verificar se a sessão já existe;
2. Criar uma nova sessão caso necessário;
3. Dividir o terminal em dois painéis;
4. Nomear os painéis como `CLIENTE` e `SERVIDOR`;
5. Abrir a conexão SSH da VM Cliente;
6. Abrir a conexão SSH da VM Servidor;
7. Entrar automaticamente na sessão.

---

# 10. Script completo

Substitua os valores abaixo pelos dados reais das suas VMs.

```bash
#!/bin/bash

SESSION="vms"

# Carrega as variáveis do arquivo .env
ENV_FILE="$(dirname "$0")/.env"

if [ ! -f "$ENV_FILE" ]; then
    echo "Erro: arquivo .env não encontrado."
    exit 1
fi

source "$ENV_FILE"

# Se a sessão já existir, apenas conecta nela
if tmux has-session -t "$SESSION" 2>/dev/null; then
    tmux attach-session -t "$SESSION"
    exit 0
fi

# Cria a sessão com o primeiro painel
tmux new-session -d -s "$SESSION"

# Divide a tela verticalmente
tmux split-window -h -t "$SESSION"

# Define os nomes dos painéis
tmux select-pane -t "$SESSION:0.0" -T "CLIENTE"
tmux select-pane -t "$SESSION:0.1" -T "SERVIDOR"

# Mostra os nomes na parte superior dos painéis
tmux set-option -t "$SESSION" pane-border-status top

# Conecta na VM Cliente
tmux send-keys -t "$SESSION:0.0" "ssh $CLIENT_USER@$CLIENT_IP" C-m

# Conecta na VM Servidor
tmux send-keys -t "$SESSION:0.1" "ssh $SERVER_USER@$SERVER_IP" C-m

# Entra na sessão
tmux attach-session -t "$SESSION"
```

---

# 11. Tornando o script executável

Depois de salvar o arquivo:

```bash
chmod +x vms.sh
```

Agora execute:

```bash
./vms.sh
```

O resultado será aproximadamente:

```text
┌──────────────────── CLIENTE ────────────────────┬──────────────────── SERVIDOR ──────────────────┐
│                                                 │                                                 │
│ usuario@cliente:~$                              │ usuario@servidor:~$                              │
│                                                 │                                                 │
│                                                 │                                                 │
└─────────────────────────────────────────────────┴─────────────────────────────────────────────────┘
```

---

# 12. Como o script funciona

### Identificação da sessão

```bash
SESSION="vms"
```

Define o nome da sessão como `vms`.

### Verificação da sessão

```bash
if tmux has-session -t "$SESSION" 2>/dev/null; then
    tmux attach-session -t "$SESSION"
    exit 0
fi
```

Se a sessão já existir, o script simplesmente conecta nela em vez de criar outra.

Isso permite executar:

```bash
./vms.sh
```

várias vezes sem criar várias sessões `vms`.

### Criação da sessão

```bash
tmux new-session -d -s "$SESSION"
```

Cria a sessão `vms` em segundo plano.

### Divisão dos painéis

```bash
tmux split-window -h -t "$SESSION"
```

Divide a janela verticalmente:

```text
┌──────────────────┬──────────────────┐
│                  │                  │
│     Cliente      │     Servidor     │
│                  │                  │
└──────────────────┴──────────────────┘
```

### Nome dos painéis

```bash
tmux select-pane -t "$SESSION:0.0" -T "CLIENTE"
tmux select-pane -t "$SESSION:0.1" -T "SERVIDOR"
```

Define os nomes utilizados pelo `tmux` para identificar cada painel.

### Exibição dos nomes

```bash
tmux set-option -t "$SESSION" pane-border-status top
```

Faz o `tmux` mostrar o nome dos painéis na borda superior.

### Execução do SSH

Cliente:

```bash
tmux send-keys -t "$SESSION:0.0" 'ssh USUARIO@IP_DA_VM_CLIENTE' C-m
```

Servidor:

```bash
tmux send-keys -t "$SESSION:0.1" 'ssh USUARIO@IP_DA_VM_SERVIDOR' C-m
```

O `C-m` representa o **Enter**, fazendo o comando ser executado automaticamente.

### Entrada na sessão

```bash
tmux attach-session -t "$SESSION"
```

Por fim, o terminal entra na sessão criada.

---

# 13. Fluxo final

Depois de toda a configuração, o processo fica muito mais simples.

Basta:

```bash
cd ~/scripts
./vms.sh
```

O script:

```text
                ./vms.sh
                    │
                    ▼
             Verifica "vms"
                    │
          ┌─────────┴─────────┐
          │                   │
       Existe?             Não existe
          │                   │
          ▼                   ▼
       Attach              Cria tmux
                              │
                              ▼
                         Divide painel
                              │
                    ┌─────────┴─────────┐
                    ▼                   ▼
                 Cliente             Servidor
                    │                   │
                    ▼                   ▼
                   SSH                 SSH
```

---

# 14. Comandos principais do tmux

| Comando | Função |
|---|---|
| `tmux` | Criar uma nova sessão |
| `tmux ls` | Listar sessões |
| `tmux attach` | Entrar em uma sessão |
| `tmux attach -t vms` | Entrar na sessão `vms` |
| `tmux kill-session -t vms` | Encerrar a sessão `vms` |
| `Ctrl+B → %` | Dividir verticalmente |
| `Ctrl+B → "` | Dividir horizontalmente |
| `Ctrl+B → ←/→` | Alternar entre painéis |
| `Ctrl+B → D` | Fazer detach da sessão |

---

# 15. Resultado

Com essa configuração, as duas VMs podem ser administradas através de **um único terminal**, mantendo cada conexão SSH em seu próprio painel:

```text
┌─────────────────────────────┬─────────────────────────────┐
│          CLIENTE            │           SERVIDOR          │
├─────────────────────────────┼─────────────────────────────┤
│                             │                             │
│  SSH conectado              │  SSH conectado              │
│                             │                             │
│  usuario@cliente:~$         │  usuario@servidor:~$        │
│                             │                             │
└─────────────────────────────┴─────────────────────────────┘
```

A sessão pode ser desconectada com:

```text
Ctrl+B → D
```

sem destruir a sessão do `tmux`.

Para retomá-la posteriormente:

```bash
tmux attach -t vms
```