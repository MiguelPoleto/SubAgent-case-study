# Frente Miguel — índice

Documentação da contribuição individual de Miguel ao projeto, organizada por tipo de conteúdo:

- [planejamento/](planejamento/Miguel-V1.md) — plano de trabalho vivo: propósito, escopo, fases (F0–F5), protocolo de experimentos e próximas ações. Define **o que** e **como** investigar.
- [ambiente/](ambiente/ESPECIFICACOES_E_RESULTADOS_V1.md) — especificações sanitizadas do laboratório: VMs, papéis (cliente/servidor), modelos configurados, política efetiva e resultados de experimentos. Descreve **o estado atual** do ambiente.
- [replicacoes/](replicacoes/REGISTRO_OPERACIONAL_V1.md) — diário operacional com os comandos efetivamente executados, em qual VM, resultado e decisão; inclui os rascunhos de patch de configuração (ex.: [PATCH_DE_TESTE.json5](replicacoes/PATCH_DE_TESTE.json5)) e de cenário experimental (ex.: [EXP-001-injecao-indireta.md](replicacoes/EXP-001-injecao-indireta.md)). Permite **reproduzir** os passos em outro lugar.

Regra geral: nenhum dos três documentos guarda segredos, credenciais, IPs, hostnames, usuários ou saída bruta de terminal — só resumos sanitizados. Veja as regras de registro no topo de cada arquivo em `replicacoes/`.
