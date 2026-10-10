import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_ai/app/routing/route_names.dart';
import 'package:pixel_ai/app/themes/app_colors.dart';
import 'package:pixel_ai/features/editor/presentation/editor_screen.dart';
import 'package:pixel_ai/features/gallery/gallery_provider.dart';
import 'package:pixel_ai/features/gallery/widgets/edited_gallery_card.dart';
import 'package:pixel_ai/features/home/widgets/option_bottom_sheet.dart';
import 'package:pixel_ai/features/onboarding/widgets/onboarding_button.dart';

class GalleryScreen extends ConsumerWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(galleryProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        title: const Column(
          children: [
            Text(
              "Gallery",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.white),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (_) => const OptionBottomSheet(),
              );
            },
          ),
        ],
      ),
      body: items.isEmpty
          ? _EmptyGallery(onOpenEditor: () {
              context.push(
                RouteNames.editor,
                extra: const EditorConfig(title: 'Editor'),
              );
            })
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
                children: [
                  for (final item in items)
                    EditedGalleryCard(
                      imageUrl: item.imageUrl,
                      badge: 'Nesta sessão',
                      subtitle: item.title,
                      onTap: () => _showItemDetails(context, item),
                    ),
                ],
              ),
            ),
    );
  }

  /// Detalhe do item guardado, com opção de voltar a editar.
  void _showItemDetails(BuildContext context, GalleryItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 200,
                    child: Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: AppColors.surface,
                        alignment: Alignment.center,
                        child: const Text(
                          'Imagem indisponível',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  item.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Guardado nesta sessão',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: const BorderSide(color: AppColors.glassBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text('Fechar'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          Navigator.of(sheetContext).pop();
                          context.push(
                            RouteNames.editor,
                            extra: EditorConfig(
                              title: item.title,
                              imageUrl: item.imageUrl,
                              toolId: item.toolId,
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
                        child: const Text('Editar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Estado vazio da galeria, apresentado quando não existem fotografias.
class _EmptyGallery extends StatelessWidget {
  final VoidCallback onOpenEditor;

  const _EmptyGallery({required this.onOpenEditor});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.glass,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.photo_library_outlined,
                color: AppColors.textSecondary,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ainda não tem fotografias',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'As fotografias que guardar no Editor aparecem aqui.\n'
              'Os itens são mantidos apenas durante a sessão atual.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: OnboardingButton(
                label: 'Abrir o Editor',
                onPressed: onOpenEditor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
