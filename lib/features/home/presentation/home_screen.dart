import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_ai/features/home/widgets/option_bottom_sheet.dart';
import 'package:pixel_ai/features/home/widgets/photo_edit_model_card.dart';
import 'package:pixel_ai/app/routing/route_names.dart';
import 'package:pixel_ai/features/editor/presentation/editor_screen.dart';

/// Modelos de edição apresentados na grelha da Home: título e imagem de Internet.
const List<(String, String)> _homeModels = [
  (
    'Edição de paisagem',
    'https://picsum.photos/seed/pixelai-landscape/600/800',
  ),
  (
    'Edição urbana',
    'https://picsum.photos/seed/pixelai-urban/600/800',
  ),
  (
    'Estilo de moda',
    'https://picsum.photos/seed/pixelai-fashion/600/800',
  ),
  (
    'Retrato IA',
    'https://picsum.photos/seed/pixelai-portrait/600/800',
  ),
  (
    'Retrato masculino',
    'https://picsum.photos/seed/pixelai-portrait-male/600/800',
  ),
  (
    'Estilo editorial',
    'https://picsum.photos/seed/pixelai-editorial/600/800',
  ),
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        title: const Column(
          children: [
            Text(
              "Pixel AI",
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
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.75,
          children: [
            for (final (title, imageUrl) in _homeModels)
              PhotoEditModelCard(
                imageUrl: imageUrl,
                subtitle: title,
                onTap: () {
                  context.push(
                    RouteNames.editor,
                    extra: EditorConfig(title: title, imageUrl: imageUrl),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
