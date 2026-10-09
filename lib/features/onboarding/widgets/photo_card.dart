import 'package:flutter/material.dart';
import 'package:pixel_ai/app/themes/app_colors.dart';

class PhotoCard extends StatelessWidget {
  final String imageUrl;
  const PhotoCard({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glass,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.glassBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.asset(imageUrl, fit: BoxFit.cover),
      ),
    );
  }
}