import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Item guardado na galeria a partir do Editor.
///
/// A persistência permanente ainda não está implementada: os itens existem
/// apenas durante a sessão atual da aplicação.
class GalleryItem {
  final String id;
  final String title;
  final String imageUrl;
  final String? toolId;
  final DateTime savedAt;

  const GalleryItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.toolId,
    required this.savedAt,
  });
}

class GalleryNotifier extends Notifier<List<GalleryItem>> {
  @override
  List<GalleryItem> build() => const [];

  /// Guarda uma fotografia do Editor na galeria (apenas nesta sessão).
  void save({
    required String title,
    required String imageUrl,
    String? toolId,
  }) {
    state = [
      GalleryItem(
        id: '${DateTime.now().microsecondsSinceEpoch}-${state.length}',
        title: title,
        imageUrl: imageUrl,
        toolId: toolId,
        savedAt: DateTime.now(),
      ),
      ...state,
    ];
  }
}

/// Lista de fotografias guardadas na sessão atual.
final galleryProvider =
    NotifierProvider<GalleryNotifier, List<GalleryItem>>(GalleryNotifier.new);
