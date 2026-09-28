# Configuração do Dashboard do OpenClaw

## 1. Objetivo

Este guia configura o Dashboard do OpenClaw instalado em um **Ubuntu Server**, permitindo acessá-lo a partir de outro computador da mesma rede, mantendo o Gateway do OpenClaw em **loopback**.

### Configuração utilizada

- Gateway: `loopback`
- Autenticação: `token`
- Tailscale: `off`
- Porta padrão: `18789`
- Ubuntu Server: `ip do servidor` (exemplo deste ambiente)
- Acesso remoto: túnel SSH

> **Importante:** não exponha o token do Gateway em mensagens, prints ou repositórios.

---

## 2. Verificar a configuração do Gateway

No Ubuntu Server:

```bash
openclaw config get gateway.bind
```

Resultado esperado:

```text
loopback
```

Verifique a autenticação:

```bash
openclaw config get gateway.auth.mode
```

Resultado esperado:

```text
token
```

Se necessário, configure:

```bash
openclaw config set gateway.bind loopback
openclaw config set gateway.auth.mode token
```

---

## 3. Instalar o Gateway como serviço

Durante o assistente de configuração do OpenClaw, selecione:

```text
Install Gateway service (recommended)
● Yes
```

Isso permite que o Gateway seja iniciado como serviço e possa ser controlado por:

```bash
openclaw gateway start
openclaw gateway stop
openclaw gateway restart
openclaw gateway status
```

Verifique o estado:

```bash
openclaw gateway status
```

---

## 4. Token do Gateway

O Gateway utiliza autenticação por token:

```text
gateway.auth.mode = token
```

Nas versões em que o token é configurado pelo assistente, pode aparecer:

```text
How do you want to provide the gateway token?
● Generate/store plaintext token
○ Use SecretRef
```

Para uma instalação simples, escolha:

```text
Generate/store plaintext token
```

Se o OpenClaw detectar um token já existente e perguntar:

```text
Use existing token?
```

escolha:

```text
Yes
```

### Atenção

O comando:

```bash
openclaw gateway auth-token --show
```

**não está disponível na versão `2026.7.1-2` usada neste ambiente.**

Não tente obter o token dessa forma nessa versão.

O comando abaixo mascara o segredo:

```bash
openclaw config get gateway.auth.token
```

É normal aparecer:

```text
__OPENCLAW_REDACTED__
```

---

## 5. Descobrir o IP do Ubuntu

Execute:

```bash
hostname -I
```

Exemplo:

```text
10.10.100.100
```

Esse é o endereço usado pelo SSH para chegar ao servidor.

Como o Gateway está em `loopback`, **não** será utilizado diretamente:


A porta do Gateway permanece acessível somente no próprio Ubuntu.

---

## 6. Criar o túnel SSH

No computador cliente, abra um terminal/PowerShell.

Exemplo no Windows:

```powershell
ssh -N -L 18789:127.0.0.1:18789 usuario@ip
```

Substitua:

- `usuario` pelo usuário SSH do Ubuntu;
- `ip` pelo IP real do Ubuntu.

Digite a senha do usuário SSH quando solicitado.

### O que esse comando faz?

Ele cria o seguinte encaminhamento:

```text
PC cliente
127.0.0.1:18789
       |
       | SSH
       v
Ubuntu Server
127.0.0.1:18789
       |
       v
OpenClaw Gateway
```

Mantenha o terminal com o SSH aberto enquanto estiver usando o Dashboard.

---

## 7. Abrir o Dashboard

Com o túnel SSH ativo, abra no navegador do computador cliente:

```text
http://127.0.0.1:18789/
```

O navegador acessará a porta local, e o SSH encaminhará a conexão para o Gateway do Ubuntu.

---

## 8. Autenticação do Dashboard

Se aparecer:

```text
Token auto-auth not delivered.

Append your gateway token (from OPENCLAW_GATEWAY_TOKEN or gateway.auth.token)
as a URL fragment with key `token` to authenticate.
```

isso significa que o Dashboard foi alcançado, mas não recebeu o token automaticamente.

O token pode ser fornecido como fragmento da URL:

```text
http://127.0.0.1:18789/#token=SEU_TOKEN
```

Substitua `SEU_TOKEN` pelo token real do Gateway.

### Segurança

Não compartilhe essa URL se ela contiver o token.

O fragmento:

```text
#token=...
```

é uma credencial. Trate-o como uma senha.

Depois que o navegador estiver autenticado, prefira utilizar as credenciais de dispositivo/pareamento oferecidas pelo OpenClaw quando disponíveis.

---

## 9. Tailscale

Para esta configuração, o Tailscale fica desativado:

```text
Tailscale: off
```

Não é necessário instalar ou configurar Tailscale para acessar o Dashboard através de um túnel SSH.

No `openclaw gateway --help`, as opções relacionadas ao Tailscale são:

```text
--tailscale <mode>
  off | serve | funnel
```

Para este cenário:

```text
off
```

é a configuração recomendada.

---

## 10. Verificações úteis

### Verificar o Gateway

```bash
openclaw gateway status
```

### Verificar o bind

```bash
openclaw config get gateway.bind
```

Esperado:

```text
loopback
```

### Verificar autenticação

```bash
openclaw config get gateway.auth.mode
```

Esperado:

```text
token
```

### Verificar a porta

```bash
ss -lntp | grep 18789
```

Com `loopback`, é esperado que a porta esteja associada a `127.0.0.1:18789` ou `::1:18789`.

---

## 11. Problemas comuns

### Dashboard não abre

Verifique:

```bash
openclaw gateway status
```

Depois confirme que o túnel SSH está ativo.

No computador cliente:

```powershell
ssh -N -L 18789:127.0.0.1:18789 usuario@ip
```

E abra:

```text
http://127.0.0.1:18789/
```

### `Connection refused`

Possíveis causas:

- Gateway parado;
- túnel SSH não está ativo;
- porta diferente de `18789`;
- serviço do Gateway não iniciou.

Verifique:

```bash
openclaw gateway status
```

e:

```bash
ss -lntp | grep 18789
```

### `Token auto-auth not delivered`

O Dashboard está acessível, mas precisa da autenticação.

Use o token do Gateway no formato:

```text
http://127.0.0.1:18789/#token=SEU_TOKEN
```

### Não consigo descobrir o token

Na versão `2026.7.1-2`, o comando:

```bash
openclaw gateway auth-token --show
```

não existe.

Não altere o `bind` para `lan` apenas por causa disso.

Se necessário, utilize o assistente de configuração do OpenClaw para configurar/gerar novamente o token.

---

## 12. Configuração final

A configuração desejada é:

```text
Gateway bind:
loopback

Gateway authentication:
token

Tailscale:
off

Gateway port:
18789

Acesso remoto:
SSH tunnel

Dashboard:
http://127.0.0.1:18789/
```

### Fluxo completo

```text
┌──────────────────────┐
│    PC cliente        │
│                      │
│ Browser              │
│ 127.0.0.1:18789      │
└──────────┬───────────┘
           │
           │ SSH Tunnel
           │
           ▼
┌──────────────────────┐
│    Ubuntu Server     │
│    10.10.100.100     │
│                      │
│ 127.0.0.1:18789      │
│         │            │
│         ▼            │
│  OpenClaw Gateway    │
└──────────────────────┘
```

Essa configuração mantém o Gateway do OpenClaw fora da interface de rede LAN e usa o SSH como canal de acesso remoto.
