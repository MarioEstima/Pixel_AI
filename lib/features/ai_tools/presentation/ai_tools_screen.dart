import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_ai/app/routing/route_names.dart';
import 'package:pixel_ai/app/themes/app_colors.dart';
import 'package:pixel_ai/features/ai_tools/ai_tools.dart';
import 'package:pixel_ai/features/editor/presentation/editor_screen.dart';

class AiToolsScreen extends StatelessWidget {
  const AiToolsScreen({super.key});

  /// Abre o Editor já configurado com a ferramenta de IA escolhida.
  void _openEditor(BuildContext context, AiTool tool) {
    context.push(
      RouteNames.editor,
      extra: EditorConfig(title: tool.name, toolId: tool.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'AI Tools',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.95,
          children: [
            for (final tool in aiTools)
              _AiToolCard(tool: tool, onTap: () => _openEditor(context, tool)),
          ],
        ),
      ),
    );
  }
}

/// Cartão de uma ferramenta de IA: ícone, nome, descrição e área de interação.
class _AiToolCard extends StatelessWidget {
  final AiTool tool;
  final VoidCallback onTap;

  const _AiToolCard({required this.tool, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.glass,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(tool.icon, color: AppColors.pinkVibrant, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              tool.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              tool.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.3,
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Text(
                  'Abrir no Editor',
                  style: TextStyle(
                    color: AppColors.pinkVibrant,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.pinkVibrant,
                  size: 12,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
