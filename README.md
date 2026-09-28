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

O plano de trabalho da pesquisa está em [docs/experiments/sbsi2027/plano-de-trabalho.md](docs/experiments/sbsi2027/plano-de-trabalho.md).

## Documentação

Os tutoriais ficam em `docs/`, para manter a raiz do repositório focada no README:

- [documentação](docs/README.md)
- [tmux + SSH para as VMs (macOS e Linux)](docs/tutorials/tmux-ssh.md)
- [instalação e configuração do OpenClaw em Ubuntu Server](docs/tutorials/openclaw-ubuntu.md)
- [testbed SBSI 2027 — injeção indireta de prompt](docs/experiments/sbsi2027/README.md)

## Ambiente de VMs

O script [scripts/vms.sh](scripts/vms.sh) abre uma sessão `tmux` com duas conexões SSH lado a lado: uma VM cliente e uma VM servidor. As variáveis de conexão devem ficar no arquivo local `.env`, que não deve ser versionado.

O tutorial completo está em [docs/tutorials/tmux-ssh.md](docs/tutorials/tmux-ssh.md).

Uso rápido:

```bash
chmod +x scripts/vms.sh
./scripts/vms.sh
```

## Equipe

- Miguel Santuchi Poleto — GitHub: [**MiguelPoleto**](https://github.com/MiguelPoleto)
- Alessandro Mion Batista — GitHub: [**alessandromionb**](https://github.com/alessandromionb)
- Orientador/professor: Everson Scherrer Borges

## Segurança e divulgação responsável

Não execute testes contra sistemas públicos, contas de terceiros ou dados reais. Vulnerabilidades novas ou sensíveis devem ser tratadas por divulgação responsável aos mantenedores antes de qualquer publicação detalhada.
