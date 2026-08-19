# Tutorial completo: OpenRouter + OpenClaw
## Configuração, Guardrails, modo gratuito, testes e solução de erros

> **Objetivo:** configurar o OpenRouter corretamente no OpenClaw, usando uma única API key, selecionar modelos gratuitos, configurar os Guardrails sem bloquear os endpoints, testar a API diretamente e diagnosticar os erros mais comuns.
>
> Este tutorial foi montado a partir da configuração que funcionou neste ambiente e das documentações atuais do OpenRouter e OpenClaw. Interfaces e disponibilidade de modelos podem mudar com o tempo.

---

# 1. Como funciona a arquitetura

A estrutura que queremos é:

```text
OpenClaw
   │
   │ OPENROUTER_API_KEY
   ▼
OpenRouter
   │
   ├── NVIDIA
   │    └── Nemotron 3 Ultra (free)
   │
   ├── outros provedores/modelos
   │
   └── outros modelos gratuitos
```

O OpenClaw não precisa de uma API key da NVIDIA quando o modelo é acessado através do OpenRouter.

A autenticação é:

```text
OpenClaw → API key do OpenRouter → OpenRouter → NVIDIA/Nemotron
```

Portanto, para usar:

```text
openrouter/nvidia/nemotron-3-ultra-550b-a55b:free
```

a credencial importante é a **API key do OpenRouter**.

Documentação oficial do OpenClaw:
- https://docs.openclaw.ai/openrouter
- https://docs.openclaw.ai/gateway/authentication

---

# 2. Criar a conta no OpenRouter

Acesse:

https://openrouter.ai/

Crie/login na conta.

Depois entre na área de API Keys:

https://openrouter.ai/keys

Crie uma nova API key.

Ela terá um formato semelhante a:

```text
sk-or-v1-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

## IMPORTANTE

Nunca coloque a API key:

- em GitHub;
- em código público;
- em README;
- em mensagens públicas;
- diretamente no frontend;
- em arquivos que serão enviados para outras pessoas.

---

# 3. Usar o OpenRouter no modo gratuito

O OpenRouter possui modelos `:free`.

Exemplo:

```text
nvidia/nemotron-3-ultra-550b-a55b:free
```

No OpenClaw, a referência fica:

```text
openrouter/nvidia/nemotron-3-ultra-550b-a55b:free
```

A diferença é importante:

### OpenRouter

```text
nvidia/nemotron-3-ultra-550b-a55b:free
```

### OpenClaw

```text
openrouter/nvidia/nemotron-3-ultra-550b-a55b:free
```

A documentação do OpenClaw usa o padrão:

```text
openrouter/<provider>/<model>
```

Fonte:
https://docs.openclaw.ai/openrouter

---

# 4. Limitações do modo gratuito

O plano gratuito do OpenRouter não significa uso ilimitado.

Atualmente, a página de preços informa:

- modelos gratuitos disponíveis;
- acesso gratuito;
- limite de aproximadamente 50 requisições/dia no plano Free;
- modelos gratuitos não são indicados para produção;
- os modelos gratuitos e seus limites podem mudar.

Se forem adquiridos pelo menos US$10 em créditos, o limite de modelos gratuitos pode subir para 1000 requisições/dia, conforme a documentação atual do OpenRouter.

Fontes oficiais:

https://openrouter.ai/pricing

https://openrouter.ai/docs/faq

Modelos gratuitos atuais:

https://openrouter.ai/collections/free-models

---

# 5. Configurar a API key no servidor

O ideal é colocar a chave na máquina onde o Gateway do OpenClaw roda.

Exemplo:

```bash
export OPENROUTER_API_KEY="sk-or-v1-SUA_CHAVE"
```

Confirme que a variável existe:

```bash
echo "$OPENROUTER_API_KEY"
```

Não é necessário mostrar a chave inteira.

Uma forma mais segura para verificar:

```bash
echo "${OPENROUTER_API_KEY:0:10}..."
```

Se estiver usando systemd para o Gateway, é importante que o serviço também tenha acesso à variável.

Não basta funcionar no seu shell se o `openclaw-gateway.service` não enxergar a variável.

---

# 6. Testar o OpenRouter antes do OpenClaw

Esta é uma das etapas mais importantes.

Antes de culpar o OpenClaw, teste diretamente o OpenRouter.

Exemplo:

```bash
curl https://openrouter.ai/api/v1/chat/completions \
  -H "Authorization: Bearer $OPENROUTER_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "nvidia/nemotron-3-ultra-550b-a55b:free",
    "messages": [
      {
        "role": "user",
        "content": "Responda apenas: teste ok"
      }
    ],
    "max_tokens": 16
  }'
```

Se funcionar, deverá aparecer uma resposta contendo algo semelhante a:

```json
{
  "model": "nvidia/nemotron-3-ultra-550b-a55b:free",
  "provider": "Nvidia"
}
```

O conteúdo pode variar.

## O que esse teste comprova?

Ele comprova separadamente:

1. a API key é válida;
2. a variável `OPENROUTER_API_KEY` está disponível;
3. o modelo existe;
4. o OpenRouter possui endpoint disponível;
5. o Guardrail não está bloqueando essa requisição;
6. o provider consegue atender o modelo.

Se o `curl` funciona e o OpenClaw não funciona, o problema provavelmente está no OpenClaw/configuração/sessão.

---

# 7. Configurar o OpenClaw

Há duas maneiras principais.

## Opção A — onboarding

```bash
openclaw onboard --auth-choice openrouter-api-key
```

## Opção B — autenticação em uma instalação já configurada

```bash
openclaw models auth login --provider openrouter --method api-key
```

Também existe a opção de inserir o token manualmente:

```bash
openclaw models auth paste-token --provider openrouter
```

A documentação atual do OpenClaw recomenda API key para hosts que ficam rodando continuamente.

Fonte:

https://docs.openclaw.ai/gateway/authentication

---

# 8. Confirmar a autenticação

Execute:

```bash
openclaw models status
```

Você deve encontrar uma seção parecida com:

```text
[openrouter] endpoint: default
auth: openrouter:default=sk-or-v1...
```

O token aparecerá mascarado.

Isso é correto.

Também é possível:

```bash
openclaw models auth list --provider openrouter
```

Esse comando não deve mostrar a chave completa.

---

# 9. Listar os modelos

Execute:

```bash
openclaw models list
```

Para procurar modelos gratuitos:

```bash
openclaw models scan
```

A documentação atual informa que `models scan` consegue consultar o catálogo público de modelos `:free`.

Fonte:

https://docs.openclaw.ai/pt-BR/cli/models

---

# 10. Selecionar o modelo

Para usar o Nemotron:

```bash
openclaw models set openrouter/nvidia/nemotron-3-ultra-550b-a55b:free
```

Depois:

```bash
openclaw models status
```

O resultado esperado é semelhante a:

```text
Default:
openrouter/nvidia/nemotron-3-ultra-550b-a55b:free
```

E:

```text
Configured models:
openrouter/auto
openai/gpt-5.6
openrouter/nvidia/nemotron-3-ultra-550b-a55b:free
```

---

# 11. Atenção: `openrouter/auto` não é o mesmo que o Nemotron

Existe:

```text
openrouter/auto
```

e existe:

```text
openrouter/nvidia/nemotron-3-ultra-550b-a55b:free
```

`openrouter/auto` deixa o OpenRouter escolher uma rota/modelo.

Se a intenção é testar especificamente o Nemotron, selecione:

```text
openrouter/nvidia/nemotron-3-ultra-550b-a55b:free
```

Não use `openrouter/auto` durante o diagnóstico inicial.

---

# 12. Guardrails — visão geral

Os Guardrails ficam nas configurações de Privacy do OpenRouter:

https://openrouter.ai/settings/privacy

A documentação oficial:

https://openrouter.ai/docs/guides/features/guardrails/overview

Os Guardrails podem controlar:

- orçamento;
- modelos permitidos;
- providers permitidos;
- Zero Data Retention;
- prompt injection;
- informações sensíveis;
- padrões personalizados.

---

# 13. Configuração recomendada de Guardrails para começar

Para um servidor pessoal/OpenClaw, uma configuração simples e funcional é:

```text
Model allowlist:
ativada, se você quiser restringir os modelos

Provider allowlist:
ativada, se você quiser restringir os providers

Prompt Injection:
ativado

Sensitive Info:
ativado conforme sua necessidade

ZDR:
não force inicialmente, a menos que você realmente precise dessa política

Budget:
opcional
```

A regra principal é:

> Quanto mais restrições você colocar, menor será o conjunto de endpoints que o OpenRouter poderá usar.

Isso foi exatamente o que aconteceu durante o diagnóstico.

---

# 14. Model Allowlist

O Model Allowlist limita quais modelos podem ser usados.

Se você quiser usar somente o Nemotron, permita o modelo correspondente ao:

```text
nvidia/nemotron-3-ultra-550b-a55b:free
```

Se você quiser usar vários modelos NVIDIA, pode permitir os modelos necessários.

### Recomendação

Durante a configuração inicial, não coloque dezenas de modelos.

Comece com:

```text
Nemotron 3 Ultra (free)
```

Depois que funcionar, adicione outros.

Isso torna o diagnóstico muito mais fácil.

---

# 15. Provider Allowlist

Você pode restringir o provider.

Para o Nemotron, o provider exibido pelo OpenRouter é:

```text
NVIDIA
```

Então:

```text
Allowed Providers
└── NVIDIA
```

é uma configuração válida para restringir o tráfego ao provider NVIDIA.

A documentação dos Guardrails confirma que provider allowlists restringem quais providers podem ser usados.

Fonte:

https://openrouter.ai/docs/guides/features/guardrails/overview

---

# 16. Provider + Model Allowlist

É possível combinar:

```text
Allowed Providers
└── NVIDIA
```

com:

```text
Allowed Models
└── Nemotron 3 Ultra (free)
```

Essa configuração significa, na prática:

```text
Só NVIDIA
+
Só o modelo permitido
```

Isso é mais restritivo e mais seguro, mas também aumenta a possibilidade de uma rota ficar indisponível.

---

# 17. O erro mais importante deste tutorial

Durante a configuração apareceu:

```text
No endpoints available matching your guardrail restrictions and data policy.
Configure: https://openrouter.ai/settings/privacy
```

Esse erro **não significa necessariamente que o modelo não existe**.

Significa que, depois de aplicar as restrições:

```text
modelo
+
provider
+
data policy
+
ZDR
+
outras restrições
```

o OpenRouter não encontrou nenhum endpoint que satisfizesse tudo simultaneamente.

---

# 18. Como corrigir `No endpoints available matching your guardrail restrictions and data policy`

Vá para:

https://openrouter.ai/settings/privacy

Verifique principalmente:

```text
Model & Provider Access
```

e:

```text
Data Policy / Zero Data Retention
```

Se você permitir NVIDIA e Nemotron, mas exigir uma política de dados que o endpoint disponível do Nemotron não atende, o OpenRouter rejeitará a requisição.

### Para testar

Use uma configuração menos restritiva.

Por exemplo:

```text
Allowed Providers:
NVIDIA

Allowed Models:
Nemotron 3 Ultra (free)

ZDR:
não forçar

Data collection:
não bloquear além do necessário
```

Salve e teste novamente com `curl`.

Quando funcionar, você pode aumentar as restrições uma por uma.

---

# 19. ZDR — Zero Data Retention

ZDR significa:

```text
Zero Data Retention
```

Ou seja, o endpoint precisa cumprir uma política de não retenção de dados.

Fonte:

https://openrouter.ai/docs/guides/features/zdr

O problema é:

```text
ZDR = mais privacidade
```

mas também:

```text
ZDR = menos endpoints elegíveis
```

Portanto, não ative ZDR simplesmente porque parece "mais seguro".

Ative quando você realmente precisa dessa política e verificou que o modelo/provider escolhido possui endpoint compatível.

---

# 20. Data Collection

O OpenRouter possui regras de política de dados.

Na seleção de provider, existe uma política equivalente a:

```text
data_collection
```

Com:

```text
allow
```

ou:

```text
deny
```

`deny` restringe a rota a providers que não coletam dados conforme a política do OpenRouter.

Fonte:

https://openrouter.ai/docs/guides/routing/provider-selection

Se você combinar:

```text
NVIDIA only
+
Nemotron only
+
data_collection = deny
+
ZDR
```

pode acabar sem nenhum endpoint disponível.

---

# 21. Prompt Injection Guardrail

O Prompt Injection Detection usa padrões regex inspirados em OWASP.

Ele é gratuito e foi projetado para detectar tentativas comuns de manipular instruções.

Fonte:

https://openrouter.ai/docs/guides/features/guardrails/prompt-injection

### Recomendação

Para um agente como OpenClaw:

```text
Prompt Injection Detection:
ON
```

É uma boa camada de segurança.

Se houver opções de ação:

```text
Flag
Redact
Block
```

entenda a diferença:

### Flag

Detecta, registra, mas deixa passar.

### Redact

Substitui o trecho detectado por algo como:

```text
[PROMPT_INJECTION]
```

e envia a requisição modificada.

### Block

Bloqueia a requisição.

Para um agente que executa tarefas, `block` fornece a proteção mais forte, mas pode gerar falsos positivos.

A prioridade quando múltiplos Guardrails se aplicam é:

```text
block > redact > flag
```

---

# 22. Allowlist do Prompt Injection

Existe uma allowlist específica para frases legítimas que poderiam ser confundidas com prompt injection.

Exemplo:

```text
ignore previous instructions
```

pode aparecer em um teste de segurança.

Você pode colocar uma frase específica na allowlist.

Importante:

- a correspondência é por substring;
- não é uma regex;
- diferenciação entre maiúsculas/minúsculas não importa;
- a allowlist não desliga todos os detectores.

Fonte:

https://openrouter.ai/docs/guides/features/guardrails/prompt-injection/allowlist

### Não faça isso

Não coloque frases genéricas demais na allowlist apenas para "parar os erros".

Isso enfraquece a proteção.

---

# 23. Sensitive Info Detection

O Sensitive Info Detection detecta informações potencialmente sensíveis.

Na interface aparecem opções como:

```text
Email address
Phone number
Social Security number
Credit card number
IP address
Person name
Address
```

Algumas detecções podem adicionar latência.

Fonte:

https://openrouter.ai/docs/guides/features/guardrails/sensitive-info

---

# 24. Configuração recomendada do Sensitive Info

Para um agente de programação, uma configuração equilibrada é:

```text
Email:
ON

Phone:
ON

Credit card:
ON

SSN:
ON

IP:
avaliar antes de ativar

Person name:
avaliar antes de ativar

Address:
avaliar antes de ativar
```

Por quê?

Porque agentes de programação frequentemente trabalham com:

```text
IP addresses
nomes de servidores
nomes de usuários
endereços
emails
```

Se tudo for redigido automaticamente, você pode quebrar:

```text
SSH
.env
configurações
scripts
logs
deploys
```

---

# 25. Redact ou Block no Sensitive Info?

Existem duas ações principais:

```text
Redact
Block
```

### Redact

Troca o conteúdo sensível por um placeholder.

Exemplo:

```text
Meu email é teste@example.com
```

pode virar algo semelhante a:

```text
Meu email é [EMAIL]
```

A requisição continua.

### Block

A requisição inteira é rejeitada.

### Recomendação inicial

Comece com:

```text
Redact
```

para itens que você não quer enviar ao provider.

Use:

```text
Block
```

para informações que nunca devem chegar ao modelo.

A própria documentação recomenda começar com Redact para avaliar o comportamento antes de usar Block amplamente.

---

# 26. Custom Patterns

Você também pode criar regex próprias.

Exemplo conceitual para detectar uma chave de API:

```regex
sk-[A-Za-z0-9_-]+
```

Outro exemplo para uma chave específica de um sistema:

```regex
PROJ-\d{4,6}
```

A documentação oficial suporta custom content filters.

Fonte:

https://openrouter.ai/docs/guides/features/guardrails/sensitive-info

### Cuidado

Não coloque regex excessivamente ampla.

Uma regex errada pode bloquear praticamente tudo.

Sempre use:

```text
Test Your Patterns
```

antes de ativar.

---

# 27. Uma configuração segura e prática

Para começar com OpenClaw, uma configuração razoável seria:

```text
MODEL / PROVIDER ACCESS
────────────────────────

Allowed Providers:
NVIDIA

Allowed Models:
Nemotron 3 Ultra (free)


SECURITY
────────────────────────

Prompt Injection:
ON

Action:
Block


SENSITIVE INFO
────────────────────────

Email:
ON

Phone:
ON

Credit Card:
ON

SSN:
ON

IP:
OFF inicialmente

Person Name:
OFF inicialmente

Address:
OFF inicialmente


ZDR
────────────────────────

OFF inicialmente


CUSTOM PATTERNS
────────────────────────

Nenhum inicialmente
```

Depois que tudo estiver funcionando, adicione regras gradualmente.

---

# 28. Não altere várias configurações ao mesmo tempo

Uma das melhores práticas para diagnosticar OpenRouter é:

```text
1 alteração
↓
Save
↓
curl
↓
funcionou?
↓
próxima alteração
```

Não faça:

```text
ZDR ON
Provider allowlist ON
Model allowlist ON
Sensitive Info ON
Prompt Injection ON
Data policy deny
```

tudo ao mesmo tempo.

Se quebrar, você não saberá qual regra causou o problema.

---

# 29. Teste mínimo do OpenRouter

Use:

```bash
curl https://openrouter.ai/api/v1/chat/completions \
  -H "Authorization: Bearer $OPENROUTER_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "nvidia/nemotron-3-ultra-550b-a55b:free",
    "messages": [
      {
        "role": "user",
        "content": "Responda apenas: teste ok"
      }
    ],
    "max_tokens": 16
  }'
```

Se retornar algo como:

```text
"provider":"Nvidia"
```

e:

```text
"model":"nvidia/nemotron-3-ultra-550b-a55b:free"
```

o OpenRouter está funcionando.

---

# 30. Testar o OpenClaw

Depois do `curl`:

```bash
openclaw models status
```

Confira:

```text
Default:
openrouter/nvidia/nemotron-3-ultra-550b-a55b:free
```

Depois:

```bash
openclaw models set openrouter/nvidia/nemotron-3-ultra-550b-a55b:free
```

E:

```bash
openclaw models status
```

---

# 31. Se o OpenClaw continuar usando o modelo antigo

Dentro da sessão do OpenClaw:

```text
/model status
```

Você pode ver algo como:

```text
Current: ...
Active: ...
Default: ...
```

Isso é importante.

O:

```text
Default
```

é o padrão configurado.

O:

```text
Current
```

é o modelo selecionado na sessão.

O:

```text
Active
```

é a rota efetivamente ativa.

Esses valores podem não ser iguais.

---

# 32. Resetar uma sessão antiga

Durante o diagnóstico deste ambiente aconteceu algo importante:

Uma sessão antiga ainda tinha o contexto de uma tentativa de OAuth da OpenAI.

Mesmo depois de configurar o OpenRouter, a sessão continuava mencionando:

```text
The OAuth login is still waiting in the background
```

Isso não significava que o Nemotron estava quebrado.

Era estado/contexto da sessão antiga.

Para começar uma sessão limpa:

```text
/new
```

Depois:

```text
/model openrouter/nvidia/nemotron-3-ultra-550b-a55b:free
```

E:

```text
/model status
```

Finalmente:

```text
responda apenas "teste ok"
```

---

# 33. Reiniciar o Gateway

Quando houver alteração de configuração/autenticação e o Gateway estiver rodando como serviço:

```bash
openclaw gateway restart
```

Depois:

```bash
openclaw models status
```

Isso foi necessário durante o diagnóstico.

---

# 34. Erro: `No API key found for provider "openai"`

Exemplo:

```text
No API key found for provider "openai"
```

Isso significa:

```text
OpenClaw está tentando usar OpenAI diretamente
```

mas não existe autenticação da OpenAI configurada.

Isso é diferente de:

```text
OpenRouter → NVIDIA
```

Se você quer usar somente OpenRouter, não precisa configurar a API da OpenAI para o Nemotron.

---

# 35. Não confundir OpenAI com OpenRouter

São provedores diferentes:

```text
openai/gpt-5.6
```

é OpenAI diretamente.

Enquanto:

```text
openrouter/nvidia/nemotron-3-ultra-550b-a55b:free
```

é OpenRouter.

Mesmo que o OpenRouter ofereça modelos da OpenAI, isso não significa que a autenticação seja a mesma.

---

# 36. Erro: `model not found by the provider`

Exemplo:

```text
The selected model was not found by the provider.
Check the model id or choose a different model.
```

Causas possíveis:

1. ID do modelo incorreto;
2. modelo removido;
3. modelo mudou de provider;
4. endpoint indisponível;
5. modelo não está disponível para aquela rota;
6. Guardrail restringindo a rota;
7. `openrouter/auto` ou alias resolvendo de forma inesperada.

Primeiro teste diretamente com:

```bash
curl ...
```

Se o `curl` funcionar, o modelo existe e a rota está disponível naquele momento.

---

# 37. Erro: `model not allowed`

Exemplo:

```text
GatewayClientRequestError:
model not allowed
```

Isso normalmente indica uma restrição do OpenClaw ou da política de modelos.

Não tente adivinhar uma configuração como:

```text
agents.defaults.modelPolicy.allow
```

sem verificar a versão instalada.

Neste ambiente, uma tentativa desse tipo gerou:

```text
Config validation failed:
agents.defaults: Unrecognized key: "modelPolicy"
```

Ou seja:

> configuração encontrada em alguma documentação/versão diferente não necessariamente é válida na sua versão do OpenClaw.

Primeiro use:

```bash
openclaw models list
openclaw models status
```

e a documentação da versão instalada.

---

# 38. Erro: `openrouter/default`

Outro erro observado:

```text
model not allowed: openrouter/default
```

Isso não é o mesmo que:

```text
openrouter/auto
```

e não deve ser tratado como se fossem iguais.

Use referências de modelos válidas exibidas por:

```bash
openclaw models list
```

ou:

```bash
openclaw models scan
```

---

# 39. Erro: `openrouter/openrouter/auto`

Pode aparecer uma referência como:

```text
openrouter/openrouter/auto
```

Isso pode ser confuso porque o OpenRouter também possui:

```text
openrouter/auto
```

Não misture os dois durante o diagnóstico.

Para um teste determinístico, prefira:

```text
openrouter/nvidia/nemotron-3-ultra-550b-a55b:free
```

---

# 40. Erro: Gateway disconnected

Pode aparecer:

```text
gateway disconnected
```

Nesse caso:

```bash
openclaw gateway restart
```

Depois:

```bash
openclaw models status
```

Se continuar:

```bash
openclaw logs --follow
```

Procure erros relacionados a:

```text
auth
provider
model
gateway
```

---

# 41. Verificação completa

Quando tudo estiver configurado, execute nesta ordem:

```bash
echo "${OPENROUTER_API_KEY:0:10}..."
```

Depois:

```bash
openclaw models list
```

Depois:

```bash
openclaw models status
```

Depois:

```bash
openclaw gateway restart
```

Depois teste o OpenRouter:

```bash
curl https://openrouter.ai/api/v1/chat/completions \
  -H "Authorization: Bearer $OPENROUTER_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "nvidia/nemotron-3-ultra-550b-a55b:free",
    "messages": [
      {
        "role": "user",
        "content": "Responda apenas: teste ok"
      }
    ],
    "max_tokens": 16
  }'
```

Depois abra uma sessão nova:

```text
/new
```

Selecione:

```text
/model openrouter/nvidia/nemotron-3-ultra-550b-a55b:free
```

E teste:

```text
responda apenas "teste ok"
```

---

# 42. Checklist final

## OpenRouter

- [ ] Conta criada
- [ ] API key criada
- [ ] API key disponível na máquina do Gateway
- [ ] `OPENROUTER_API_KEY` configurada
- [ ] `curl` funciona
- [ ] Modelo gratuito disponível

## Guardrails

- [ ] Provider permitido
- [ ] Modelo permitido
- [ ] Data Policy não bloqueia o endpoint
- [ ] ZDR não está bloqueando o endpoint sem necessidade
- [ ] Prompt Injection configurado
- [ ] Sensitive Info configurado
- [ ] Custom Patterns testados antes de ativar

## OpenClaw

- [ ] OpenRouter autenticado
- [ ] `openclaw models list` mostra o modelo
- [ ] `openclaw models status` mostra autenticação
- [ ] Default está correto
- [ ] Gateway reiniciado após alterações
- [ ] Sessão antiga resetada com `/new`
- [ ] `/model status` mostra o modelo correto
- [ ] teste final responde

---

# 43. Configuração recomendada para este caso

Se a intenção for:

> "Quero usar OpenClaw com OpenRouter, de graça, usando Nemotron, sem complicar."

Use:

```text
OpenRouter:
API key

Modelo:
openrouter/nvidia/nemotron-3-ultra-550b-a55b:free

Provider:
NVIDIA

Guardrail:
Prompt Injection = ON

Sensitive Info:
ativar somente o que realmente fizer sentido

ZDR:
OFF inicialmente

Data Policy:
não adicionar restrição além do necessário

OpenClaw:
Default = openrouter/nvidia/nemotron-3-ultra-550b-a55b:free
```

Depois de funcionar, endureça a política gradualmente.

---

# 44. Segurança da API key

Se você suspeitar que a chave vazou:

1. abra:
   https://openrouter.ai/keys
2. revogue a chave comprometida;
3. crie uma nova;
4. atualize `OPENROUTER_API_KEY`;
5. reinicie o Gateway:

```bash
openclaw gateway restart
```

Nunca publique a chave em:

```text
GitHub
README
.env commitado
prints
Discord
WhatsApp
logs
```

Adicione `.env` ao `.gitignore` caso esteja usando arquivo `.env`.

Exemplo:

```gitignore
.env
.env.*
!.env.example
```

---

# 45. Diagnóstico rápido por sintoma

| Erro | Primeiro lugar para verificar |
|---|---|
| `No API key found for provider "openai"` | Você selecionou OpenAI em vez de OpenRouter |
| `No API key found for provider "openrouter"` | API key/OpenRouter auth |
| `No endpoints available matching your guardrail restrictions and data policy` | Guardrails + Data Policy + ZDR |
| `model not found by the provider` | ID/modelo/provider/disponibilidade |
| `model not allowed` | Restrição de modelos |
| `openrouter/default` | Referência de modelo incorreta |
| `gateway disconnected` | Gateway/service |
| OpenClaw continua falando de OAuth antigo | Nova sessão `/new` |
| `curl` funciona, OpenClaw não | Configuração/sessão/Gateway do OpenClaw |
| `curl` também falha | OpenRouter/API key/Guardrails/modelo |
| Modelo gratuito parou de funcionar | Disponibilidade/rate limit/provider |

---

# 46. Regra de ouro para diagnosticar

Sempre siga esta ordem:

```text
1. OpenRouter
   ↓
2. curl
   ↓
3. modelo específico
   ↓
4. Guardrails
   ↓
5. OpenClaw auth
   ↓
6. openclaw models status
   ↓
7. Gateway restart
   ↓
8. nova sessão
   ↓
9. teste final
```

Não comece alterando o OpenClaw se o próprio OpenRouter ainda não funciona.

E não comece alterando cinco Guardrails ao mesmo tempo.

---

# 47. Comandos essenciais — resumo

## Ver variável

```bash
echo "${OPENROUTER_API_KEY:0:10}..."
```

## Listar modelos

```bash
openclaw models list
```

## Ver status

```bash
openclaw models status
```

## Escanear modelos gratuitos

```bash
openclaw models scan
```

## Selecionar Nemotron

```bash
openclaw models set openrouter/nvidia/nemotron-3-ultra-550b-a55b:free
```

## Reiniciar Gateway

```bash
openclaw gateway restart
```

## Ver logs

```bash
openclaw logs --follow
```

## Ver autenticação OpenRouter

```bash
openclaw models auth list --provider openrouter
```

## Autenticar OpenRouter por API key

```bash
openclaw models auth login --provider openrouter --method api-key
```

## Testar diretamente o OpenRouter

```bash
curl https://openrouter.ai/api/v1/chat/completions \
  -H "Authorization: Bearer $OPENROUTER_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "nvidia/nemotron-3-ultra-550b-a55b:free",
    "messages": [
      {
        "role": "user",
        "content": "Responda apenas: teste ok"
      }
    ],
    "max_tokens": 16
  }'
```

---

# 48. Links oficiais

## OpenRouter

https://openrouter.ai/

## API Keys

https://openrouter.ai/keys

## Privacy / Guardrails

https://openrouter.ai/settings/privacy

## Preços

https://openrouter.ai/pricing

## Modelos gratuitos

https://openrouter.ai/collections/free-models

## Guardrails

https://openrouter.ai/docs/guides/features/guardrails/overview

## Prompt Injection

https://openrouter.ai/docs/guides/features/guardrails/prompt-injection

## Sensitive Info

https://openrouter.ai/docs/guides/features/guardrails/sensitive-info

## Zero Data Retention

https://openrouter.ai/docs/guides/features/zdr

## Provider Routing

https://openrouter.ai/docs/guides/routing/provider-selection

## OpenClaw — OpenRouter

https://docs.openclaw.ai/openrouter

## OpenClaw — Autenticação

https://docs.openclaw.ai/gateway/authentication

## OpenClaw — Models CLI

https://docs.openclaw.ai/pt-BR/cli/models

---

# 49. Observação importante sobre disponibilidade

Modelos `:free`, providers, limites, nomes e endpoints do OpenRouter podem mudar.

Portanto, não considere:

```text
nvidia/nemotron-3-ultra-550b-a55b:free
```

como um recurso permanente.

Quando um modelo deixar de funcionar, primeiro consulte:

```bash
openclaw models scan
```

ou a página de modelos gratuitos do OpenRouter.

A configuração correta é sempre baseada no catálogo atual.

---

# 50. Resultado esperado

No final, o cenário ideal será:

```text
OpenClaw
   │
   │ API key OpenRouter
   ▼
OpenRouter
   │
   │ Guardrails
   │  ├── Provider permitido
   │  ├── Modelo permitido
   │  ├── Prompt Injection
   │  └── Sensitive Info
   │
   ▼
NVIDIA
   │
   ▼
Nemotron 3 Ultra
   │
   ▼
OpenClaw
```

E:

```bash
openclaw models status
```

deve mostrar:

```text
Default:
openrouter/nvidia/nemotron-3-ultra-550b-a55b:free
```

Enquanto o teste direto:

```bash
curl ...
```

deve conseguir obter uma resposta do:

```text
nvidia/nemotron-3-ultra-550b-a55b:free
```

Se ambos funcionarem, a integração está configurada corretamente.
