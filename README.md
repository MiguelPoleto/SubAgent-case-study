# Segurança no ecossistema OpenClaw

Repositório de apoio ao projeto de pesquisa sobre análise de vulnerabilidades e desenvolvimento de estratégias de defesa para ecossistemas de agentes autônomos de IA, subagentes e suas interações, usando o OpenClaw como estudo de caso inicial.

O trabalho investiga fronteiras de confiança em agentes com acesso a ferramentas, configuração e extensões. A pesquisa será realizada de forma responsável, com experimentos exclusivamente em ambientes isolados e dados não reais.

## Projeto

O objetivo é produzir conhecimento e artefatos reproduzíveis para compreender riscos em agentes autônomos e avaliar contramedidas técnicas. As linhas principais incluem:

- taxonomia de vulnerabilidades e fronteiras de confiança;
- segurança de contexto e injeção de prompt;
- autorização zero-trust para ferramentas;
- integridade de configurações;
- segurança da cadeia de extensões e do ClawHub;
- delegação, isolamento e limites de confiança entre agentes e subagentes;
- avaliação de mecanismos defensivos.

O plano de trabalho vivo, derivado da proposta submetida e livre de obrigações administrativas ou cronograma fixo, está em [planning/PROJECT_PLAN_V1.md](planning/PROJECT_PLAN_V1.md).

## Documentação

Os tutoriais ficam em `docs/`, para manter a raiz do repositório focada no README:

- [tmux + SSH para as VMs (macOS e Linux)](docs/TMUX.md)
- [instalação e configuração do OpenClaw em Ubuntu Server](docs/OPENCLAW_UBUNTU.md)

## Ambiente de VMs

O script [vms.sh](vms.sh) abre uma sessão `tmux` com duas conexões SSH lado a lado: uma VM cliente e uma VM servidor. As variáveis de conexão devem ficar no arquivo local `.env`, que não deve ser versionado.

O tutorial completo está em [docs/TMUX.md](docs/TMUX.md).

Uso rápido:

```bash
chmod +x vms.sh
./vms.sh
```

## Equipe

- Miguel Santuchi Poleto — GitHub: [**MiguelPoleto**](https://github.com/MiguelPoleto)
- Alessandro Mion Batista — GitHub: [**alessandromionb**](https://github.com/alessandromionb)
- Orientador/professor: Everson Scherrer Borges

## Segurança e divulgação responsável

Não execute testes contra sistemas públicos, contas de terceiros ou dados reais. Vulnerabilidades novas ou sensíveis devem ser tratadas por divulgação responsável aos mantenedores antes de qualquer publicação detalhada.
