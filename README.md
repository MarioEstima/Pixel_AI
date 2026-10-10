# PixelAI

Aplicação Flutter de edição de fotografias com inteligência artificial. O projeto
está focado na experiência de utilizador: onboarding, catálogo de modelos de
edicao, ferramentas de IA, editor de fotografia e galeria de resultados, com
navegação completa entre ecrãs através do GoRouter.

A interface é escura e segue a identidade visual definida em `AppColors`.

---

## Funcionalidades

- Onboarding introducao com estado guardado localmente (aparece apenas na primeira utilização).
- Home com grelha de modelos de edição e acesso ao Editor.
- AI Tools com oito ferramentas de IA que abrem o Editor já configurado.
- Editor com pré-visualização da fotografia, ferramentas de máscara, controlos
  específicos da ferramenta selecionada e fluxo visual de aplicação.
- Gallery com estado vazio, apresentação dos itens guardados na sessão,
  detalhe do item e reabertura no Editor.
- Navegação de regresso consistente em todos os ecrãs.

---

## Ecrãs e fluxos

### Onboarding

Primeira experiência da aplicação.

1. O ecrã é apresentado quando o onboarding ainda não foi concluído.
2. O botão `Continuar` conclui o onboarding.
3. O estado é guardado em `SharedPreferences` (`onboarding_completed`).
4. O utilizador é encaminhado para a Home.
5. Nas execuções seguintes o onboarding não volta a aparecer.

O redirect global do GoRouter garante que qualquer rota tentada antes da
conclusão do onboarding regressa ao onboarding, e que o onboarding não é
mostrado depois de concluído.

### Home

- Cabeçalho com o nome `Pixel AI`.
- Ação `...` abre o bottom sheet com atalhos para AI Tools, Editor e Gallery.
- Grelha de seis modelos de edição, identificados com a etiqueta `AI Edit` e com
  o respetivo título:
  - Edição de paisagem
  - Edição urbana
  - Estilo de moda
  - Retrato IA
  - Retrato masculino
  - Estilo editorial
- Cada cartão usa `PhotoEditModelCard`, carrega a imagem da Internet e abre o
  Editor com a configuração correspondente (`EditorConfig`).

### AI Tools

Apresenta as oito ferramentas disponíveis, cada uma com nome, descrição, ícone
e área de interação:

| Ferramenta | Descrição |
| --- | --- |
| Background Remover | Remove o fundo de uma fotografia. |
| AI Enhance | Melhora a nitidez, a qualidade e os detalhes. |
| AI Portrait | Aplica melhorias e estilos a retratos. |
| Object Remover | Seleciona um objeto para o remover da imagem. |
| Background Generator | Substitui o fundo através de uma descrição. |
| AI Colorize | Aplica cor a fotografias a preto e branco. |
| Photo Restoration | Prepara uma fotografia antiga para restauro. |
| AI Upscaler | Aumenta a resolução da fotografia. |

Ao selecionar uma ferramenta, o utilizador é encaminhado para o Editor com
`EditorConfig(title: nome da ferramenta, toolId: identificador da ferramenta)`.

### Editor

O Editor é partilhado por todos os pontos de entrada (Home, AI Tools, Gallery).
Não existem ecrãs de edição duplicados.

Estrutura:

- Área principal de pré-visualização da fotografia, carregada com
  `Image.network` a partir do `imageUrl` da configuração, com estado de
  carregamento e estado alternativo discreto em caso de falha.
- Botão de voltar (canto superior esquerdo).
- Painel inferior com:
  - controlos específicos da ferramenta de IA selecionada;
  - controlos da ferramenta de máscara ativa;
  - cartões das ferramentas de máscara (Brush, Lasso, Restore);
  - barra com cancelar, título e aplicar.

Ferramentas de máscara e respetivos controlos:

| Ferramenta | Controlos |
| --- | --- |
| Brush | Tamanho, Dureza |
| Lasso | Suavização |
| Restore | Tamanho, Intensidade |

Ao trocar de ferramenta, o painel de propriedades é atualizado e apresenta
apenas os controlos dessa ferramenta. Os sliders mostram o valor atual em
percentagem.

Fluxo do Editor:

1. Edição: o utilizador configura a ferramenta e os controlos.
2. Aplicar (`check`): estado de processamento com indicador de atividade.
3. Resultado: estado identificado como `Resultado ainda indisponível`, porque a
   integração com um serviço de IA ainda não está configurada.
4. Nesse estado é possível voltar a editar ou guardar a fotografia na galeria
   da sessão atual.

### Gallery

- Estado vazio quando não existem fotografias, com atalho para o Editor.
- Grelha com os itens guardados na sessão, usando `EditedGalleryCard`.
- Toque num item abre o painel de detalhe com imagem, título e opções
  `Fechar` e `Editar`.
- `Editar` reabre o Editor com a configuração original do item.

A persistência permanente ainda não está implementada: os itens existem apenas
durante a sessão e são guardos através de `galleryProvider` (Riverpod).

---

## Estrutura do projeto

```
lib/
├── main.dart                       # Ponto de entrada com ProviderScope
├── app/
│   ├── app.dart                    # MaterialApp.router e tema
│   ├── routing/
│   │   ├── app_routing.dart        # Configuração do GoRouter
│   │   └── route_names.dart        # Nomes das rotas
│   └── themes/
│       └── app_colors.dart         # Paleta de cores da aplicação
├── core/
│   └── storage/
│       └── local_storage.dart      # Armazenamento local (SharedPreferences)
└── features/
    ├── onboarding/
    │   ├── presentation/onboarding_screen.dart
    │   └── widgets/                # PhotoCard, OnboardingButton
    ├── home/
    │   ├── presentation/home_screen.dart
    │   └── widgets/                # PhotoEditModelCard, OptionBottomSheet
    ├── ai_tools/
    │   ├── ai_tools.dart           # Registo partilhado das ferramentas de IA
    │   └── presentation/ai_tools_screen.dart
    ├── editor/
    │   └── presentation/editor_screen.dart   # EditorConfig e EditorScreen
    └── gallery/
        ├── gallery_provider.dart   # Itens guardados na sessão
        ├── presentation/gallery_screen.dart
        └── widgets/                # EditedGalleryCard
test/
├── widget_test.dart                # Arranque da aplicação
└── navigation_flow_test.dart       # Fluxos de navegação
```

---

## Rotas

| Rota | Ecrã | Parâmetro `extra` |
| --- | --- | --- |
| `/onboarding` | OnboardingScreen | não utilizado |
| `/home` | HomeScreen | não utilizado |
| `/ai-tools` | AiToolsScreen | não utilizado |
| `/editor` | EditorScreen | `EditorConfig`, `String` ou nulo |
| `/gallery` | GalleryScreen | não utilizado |

A rota do Editor usa `EditorConfig.fromExtra(state.extra)`, que aceita
`EditorConfig`, texto simples ou qualquer outro valor e recorre sempre a uma
configuração predefinida válida. Assim, nenhuma incompatibilidade de tipos
impede o Editor de abrir.

O botão de voltar do Editor usa `context.pop()` quando existe histórico e
`context.go('/home')` quando não existe.

---

## Dependências

- Flutter
- go_router: navegação declarativa
- flutter_riverpod: estado (galeria da sessão)
- shared_preferences: armazenamento local do estado de onboarding
- google_fonts: tipografia DM Sans
- flutter_lints: regras de análise

Não foram introduzidas dependências novas neste trabalho.

---

## Pré-requisitos

- SDK Flutter instalado (versão compatível com `sdk: ^3.13.5`).
- Dispositivo, emulador ou desktop suportado.

## Execução

```bash
flutter pub get
flutter run
```

## Verificação

```bash
dart analyze      # ou flutter analyze
flutter test
```

Nota: neste ambiente o comando `flutter analyze` falha ao comunicar com o
servidor de análise quando o caminho do projeto contém caracteres não ASCII
(caso da pasta `Secretária`). O `dart analyze` produz o mesmo resultado sem
esse problema.

---

## Testes

- `test/widget_test.dart`: confirma que a aplicação inicia.
- `test/navigation_flow_test.dart`: cobre os fluxos principais:
  - onboarding pendente e conclusão para a Home;
  - onboarding concluído encaminha para a Home;
  - cartão da Home abre o Editor e o botão cancelar regressa à Home;
  - AI Tools apresenta as oito ferramentas e abre o Editor;
  - fluxo aplicar, processamento, resultado e voltar a editar;
  - troca de ferramenta atualiza os controlos;
  - Gallery apresenta o estado vazio e abre o Editor;
  - guardar na galeria, abrir o item e voltar a editar.

---

## Estado atual e trabalho pendente

O âmbito deste trabalho é o frontend e os fluxos de navegação. Continuam
pendentes, por dependerem de uma futura integração:

- Processamento real das ferramentas de IA (o Editor apresenta os estados de
  processamento e de resultado indisponível, sem simular edições).
- Pré-visualização de resultados reais.
- Persistência permanente da galeria (atualmente apenas na sessão).
- Seleção da fotografia pelo utilizador (por agora usa uma imagem de Internet).

Não existem chamadas a APIs de IA, backend, autenticação nem chaves de API no
código da aplicação.
