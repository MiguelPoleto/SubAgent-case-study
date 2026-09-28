#!/bin/bash

SESSION="vms"

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