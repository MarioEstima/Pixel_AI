import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_ai/app/routing/route_names.dart';
import 'package:pixel_ai/app/themes/app_colors.dart';

class OptionBottomSheet extends StatefulWidget {
  const OptionBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (_) => const OptionBottomSheet(),
    );
  }

  @override
  State<OptionBottomSheet> createState() => _OptionBottomSheetState();
}

class _OptionBottomSheetState extends State<OptionBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _option(
              Icons.auto_awesome,
              'Ferramentas de IA',
              RouteNames.aiTools,
            ),
            _option(Icons.edit, 'Editor', RouteNames.editor),
            _option(Icons.photo_library, 'Galeria', RouteNames.gallery),
          ],
        ),
      ),
    );
  }

  Widget _option(IconData icon, String label, String route) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary),
      title: Text(label, style: TextStyle(color: AppColors.textPrimary)),
      onTap: () {
        final router = GoRouter.of(context);
        Navigator.of(context).pop();
        router.push(route);
      },
    );
  }
}
