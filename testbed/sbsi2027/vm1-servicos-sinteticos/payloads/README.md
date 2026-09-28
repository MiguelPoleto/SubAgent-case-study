# Artefatos de cada rodada

Não versione payloads ativos nem respostas do modelo neste diretório. Para cada rodada, copie um artefato sintético para `../runtime/site/`, calcule seu SHA-256 e registre somente o identificador da rodada, o hash, a condição A/B e as métricas sanitizadas.

O template `runtime/site/index.html` é deliberadamente neutro. O conteúdo de injeção aprovado para a rodada deve ser preparado separadamente pelo pesquisador responsável, sem usar segredos, contas ou sistemas reais.
