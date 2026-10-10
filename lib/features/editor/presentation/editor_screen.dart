import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_ai/app/routing/route_names.dart';
import 'package:pixel_ai/app/themes/app_colors.dart';
import 'package:pixel_ai/features/ai_tools/ai_tools.dart';
import 'package:pixel_ai/features/gallery/gallery_provider.dart';

/// Configuração partilhada usada para abrir o Editor a partir da Home,
/// das AI Tools e da Gallery.
class EditorConfig {
  final String title;
  final String imageUrl;
  final String? toolId;

  const EditorConfig({
    required this.title,
    this.imageUrl = defaultImageUrl,
    this.toolId,
  });

  /// Imagem de Internet usada quando ainda não existe fotografia selecionada.
  static const String defaultImageUrl =
      'https://picsum.photos/seed/pixelai/800/1200';

  /// Configuração predefinida, usada quando a rota não recebe parâmetros.
  static const EditorConfig defaults = EditorConfig(title: 'Editor');

  /// Converte o `extra` recebido pelo GoRouter no tipo esperado pelo Editor.
  ///
  /// Aceita [EditorConfig], [String] (apenas o título) ou qualquer outro valor,
  /// recorrendo sempre a uma configuração predefinida válida. Assim, nenhuma
  /// incompatibilidade de tipos impede o Editor de abrir.
  factory EditorConfig.fromExtra(Object? extra) {
    if (extra is EditorConfig) return extra;
    if (extra is String && extra.trim().isNotEmpty) {
      return EditorConfig(title: extra.trim());
    }
    return defaults;
  }
}

class EditorTool {
  final String name;
  final IconData icon;
  final Map<String, double> properties;

  EditorTool(this.name, this.icon, this.properties);
}

/// Controlo numérico específico de uma ferramenta de IA.
class _AiToolControl {
  final String label;
  final double initial;

  const _AiToolControl(this.label, {this.initial = 0.5});
}

/// Controlos apresentados no Editor para cada ferramenta de IA selecionada.
///
/// Os `id` correspondem aos definidos em `features/ai_tools/ai_tools.dart`.
const Map<String, List<_AiToolControl>> _aiToolControls = {
  'backgroundRemover': [_AiToolControl('Suavização', initial: 0.6)],
  'aiEnhance': [
    _AiToolControl('Nitidez', initial: 0.6),
    _AiToolControl('Detalhes', initial: 0.5),
    _AiToolControl('Ruído', initial: 0.4),
  ],
  'aiPortrait': [
    _AiToolControl('Suavização', initial: 0.5),
    _AiToolControl('Iluminação', initial: 0.5),
  ],
  'objectRemover': [_AiToolControl('Tolerância', initial: 0.5)],
  'backgroundGenerator': [_AiToolControl('Intensidade', initial: 0.7)],
  'colorize': [
    _AiToolControl('Intensidade', initial: 0.7),
    _AiToolControl('Vibrância', initial: 0.5),
  ],
  'restoration': [
    _AiToolControl('Reparação', initial: 0.6),
    _AiToolControl('Contraste', initial: 0.5),
  ],
  'upscaler': [_AiToolControl('Definição', initial: 0.7)],
};

/// Fases do fluxo do Editor.
enum _EditorPhase { editing, processing, result }

class EditorScreen extends StatefulWidget {
  /// Configuração recebida da origem da navegação (Home, AI Tools, Gallery).
  final EditorConfig config;

  const EditorScreen({super.key, this.config = EditorConfig.defaults});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  // Cada ferramenta tem suas próprias propriedades
  final List<EditorTool> _tools = [
    EditorTool('Brush', Icons.brush_outlined, {'Tamanho': 0.5, 'Dureza': 0.7}),
    EditorTool('Lasso', Icons.gesture, {'Suavização': 0.3}),
    EditorTool('Restore', Icons.restore, {'Tamanho': 0.5, 'Intensidade': 1.0}),
  ];

  int _selected = 0;

  /// Valores dos controlos da ferramenta de IA, guardados por `ferramenta/controlo`.
  final Map<String, double> _aiValues = {};

  final TextEditingController _backgroundPrompt = TextEditingController();

  _EditorPhase _phase = _EditorPhase.editing;
  Timer? _processingTimer;

  EditorTool get _tool => _tools[_selected];

  EditorConfig get _config => widget.config;

  @override
  void dispose() {
    _processingTimer?.cancel();
    _backgroundPrompt.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------- navegação

  void _goBack() {
    _processingTimer?.cancel();
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.home);
    }
  }

  // ------------------------------------------------------------------- fluxo

  void _apply() {
    if (_phase != _EditorPhase.editing) return;
    setState(() => _phase = _EditorPhase.processing);
    _processingTimer = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _phase = _EditorPhase.result);
    });
  }

  void _resetToEditing() {
    _processingTimer?.cancel();
    setState(() => _phase = _EditorPhase.editing);
  }

  // --------------------------------------------------------------- controles

  double _controlValue(String toolId, String label, double fallback) {
    return _aiValues['$toolId/$label'] ?? fallback;
  }

  void _setControlValue(String toolId, String label, double value) {
    setState(() => _aiValues['$toolId/$label'] = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        // Stack: a imagem fica por trás do painel, assim o radius aparece
        child: Stack(
          children: [
            // Pré-visualização da fotografia
            Positioned.fill(child: _buildPreview()),
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildBottomPanel(),
            ),
            Positioned(top: 12, left: 12, child: _buildBackButton()),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------ pré-visualização

  /// Fotografia carregada pela Internet, com estados de carregamento e falha.
  Widget _buildPreview() {
    return Image.network(
      _config.imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        final total = progress.expectedTotalBytes;
        final loaded = progress.cumulativeBytesLoaded;
        return Center(
          child: CircularProgressIndicator(
            value: total != null ? loaded / total : null,
            strokeWidth: 2,
            color: AppColors.textPrimary,
          ),
        );
      },
      // Estado alternativo discreto caso a imagem não consiga ser carregada.
      errorBuilder: (_, _, _) => Container(
        color: AppColors.surface,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.broken_image_outlined,
              color: AppColors.textSecondary,
              size: 28,
            ),
            SizedBox(height: 8),
            Text(
              'Imagem indisponível',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // Botão de voltar com fundo glass (só o botão, sem barra de header)
  Widget _buildBackButton() {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: 44,
          height: 44,
          color: AppColors.glass,
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary,
              size: 20,
            ),
            onPressed: _goBack,
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------- painel inferior

  Widget _buildBottomPanel() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_phase == _EditorPhase.editing) ...[
            // Secção específica da ferramenta de IA selecionada
            ..._buildAiToolSection(),
            // Propriedades da ferramenta de máscara selecionada
            ..._buildPropertyRows(),
            const SizedBox(height: 12),
            // Cards das ferramentas
            _buildToolCards(),
            const SizedBox(height: 8),
          ],
          if (_phase == _EditorPhase.processing) ...[
            _buildProcessingState(),
            const SizedBox(height: 4),
          ],
          if (_phase == _EditorPhase.result) ...[
            _buildResultState(),
            const SizedBox(height: 12),
          ],
          // Barra inferior: cancelar / título / confirmar
          _buildActionBar(),
        ],
      ),
    );
  }

  /// Linha de controlo deslizante com valor percentual.
  Widget _buildSliderRow({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    final clamped = value.clamp(0.0, 1.0);
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Slider(
            value: clamped,
            activeColor: AppColors.pinkVibrant,
            inactiveColor: AppColors.glassBorder,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 44,
          child: Text(
            '${(clamped * 100).round()}%',
            textAlign: TextAlign.end,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ),
      ],
    );
  }

  /// Controlos específicos da ferramenta de IA escolhida na origem.
  List<Widget> _buildAiToolSection() {
    final toolId = _config.toolId;
    if (toolId == null) return const [];

    AiTool? tool;
    final matches = aiTools.where((t) => t.id == toolId);
    if (matches.isNotEmpty) tool = matches.first;

    final controls = _aiToolControls[toolId] ?? const <_AiToolControl>[];

    return [
      Row(
        children: [
          if (tool != null) ...[
            Icon(tool.icon, size: 16, color: AppColors.pinkVibrant),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              _config.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      if (tool != null) ...[
        const SizedBox(height: 4),
        Text(
          tool.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
      const SizedBox(height: 8),
      for (final control in controls)
        _buildSliderRow(
          label: control.label,
          value: _controlValue(toolId, control.label, control.initial),
          onChanged: (v) => _setControlValue(toolId, control.label, v),
        ),
      if (toolId == 'backgroundGenerator') ...[
        const SizedBox(height: 4),
        TextField(
          controller: _backgroundPrompt,
          maxLines: 2,
          minLines: 1,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
          decoration: InputDecoration(
            labelText: 'Descrição do fundo',
            hintText: 'Ex.: praia ao pôr do sol',
            labelStyle: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
            hintStyle: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
            filled: true,
            fillColor: AppColors.textPrimary.withValues(alpha: 0.06),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
      const SizedBox(height: 8),
    ];
  }

  /// Propriedades da ferramenta de máscara (Brush, Lasso, Restore).
  List<Widget> _buildPropertyRows() {
    return _tool.properties.entries
        .map(
          (e) => _buildSliderRow(
            label: e.key,
            value: e.value,
            onChanged: (v) => setState(() => _tool.properties[e.key] = v),
          ),
        )
        .toList();
  }

  Widget _buildToolCards() {
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _tools.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final t = _tools[i];
          final selected = i == _selected;
          return GestureDetector(
            onTap: () => setState(() => _selected = i),
            child: Container(
              width: 96,
              decoration: BoxDecoration(
                color: AppColors.textPrimary.withValues(
                  alpha: selected ? 0.16 : 0.06,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? AppColors.textPrimary : Colors.transparent,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(t.icon, color: AppColors.textPrimary),
                  const SizedBox(height: 6),
                  Text(
                    t.name,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Estado visual de processamento após confirmar a edição.
  Widget _buildProcessingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.pinkVibrant,
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              'A processar com ${_config.title}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  /// Estado apresentado quando ainda não existe integração com um serviço de IA.
  Widget _buildResultState() {
    return Consumer(
      builder: (context, ref, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Resultado ainda indisponível',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'A integração com o serviço de IA ainda não está configurada '
              'nesta versão. Assim que o processamento estiver disponível, '
              'o resultado aparecerá aqui.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetToEditing,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.glassBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text('Voltar a editar'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      ref.read(galleryProvider.notifier).save(
                            title: _config.title,
                            imageUrl: _config.imageUrl,
                            toolId: _config.toolId,
                          );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Guardado na galeria para esta sessão',
                            style: TextStyle(color: AppColors.textPrimary),
                          ),
                          backgroundColor: AppColors.surface,
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.pinkVibrant,
                      foregroundColor: AppColors.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text('Guardar na galeria'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  /// Botões de cancelar (voltar) e confirmar (aplicar).
  Widget _buildActionBar() {
    final canApply = _phase == _EditorPhase.editing;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          tooltip: 'Cancelar',
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: _goBack,
        ),
        Expanded(
          child: Text(
            _config.title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (_phase == _EditorPhase.processing)
          const SizedBox(
            width: 48,
            height: 48,
            child: Padding(
              padding: EdgeInsets.all(14),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.pinkVibrant,
              ),
            ),
          )
        else
          IconButton(
            tooltip: 'Aplicar',
            icon: Icon(
              Icons.check,
              color: canApply ? AppColors.pinkVibrant : AppColors.textSecondary,
            ),
            onPressed: canApply ? _apply : null,
          ),
      ],
    );
  }
}
