import 'package:flutter/material.dart';
import 'package:pixel_ai/app/themes/app_colors.dart';
import 'package:pixel_ai/features/onboarding/widgets/onboarding_button.dart';
import 'package:pixel_ai/features/onboarding/widgets/photo_card.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onCompleted;

  const OnboardingScreen({super.key, required this.onCompleted});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _spread = false;

  static const _duration = Duration(milliseconds: 450);
  static const _curve = Curves.easeOutBack;

  void _setSpread(bool value) {
    if (_spread != value) setState(() => _spread = value);
  }

  Widget _card({
    required String image,
    required Offset rest,
    required double restDeg,
    required Offset open,
    required double openDeg,
    double width = 180,
    double height = 240,
    double opacity = 1,
  }) {
    return AnimatedSlide(
      offset: _spread ? open : rest,
      duration: _duration,
      curve: _curve,
      child: AnimatedRotation(
        turns: (_spread ? openDeg : restDeg) / 360,
        duration: _duration,
        curve: _curve,
        child: Opacity(
          opacity: opacity,
          child: SizedBox(
            width: width,
            height: height,
            child: PhotoCard(imageUrl: image),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MouseRegion(
                        onEnter: (_) => _setSpread(true),
                        onExit: (_) => _setSpread(false),
                        child: Listener(
                          onPointerDown: (_) => _setSpread(true),
                          onPointerUp: (_) => _setSpread(false),
                          onPointerCancel: (_) => _setSpread(false),
                          child: Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: [
                              _card(
                                image:
                                    'assets/images/background_landscape.jpeg',
                                rest: const Offset(-0.38, 0.14),
                                restDeg: -9,
                                open: const Offset(-0.46, 0.15),
                                openDeg: -12,
                                opacity: 0.55,
                              ),
                              _card(
                                image: 'assets/images/person_background.jpeg',
                                rest: const Offset(0.38, -0.10),
                                restDeg: 9,
                                open: const Offset(0.46, -0.11),
                                openDeg: 12,
                                opacity: 0.55,
                              ),
                              _card(
                                image: 'assets/images/person_background.jpeg',
                                rest: Offset.zero,
                                restDeg: 0,
                                open: const Offset(0, -0.02),
                                openDeg: 0,
                                width: 165,
                                height: 220,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      const Text(
                        'Edite suas fotos com PixelAI',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Mundo a espera da sua criatividade.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              OnboardingButton(
                label: "Continuar",
                onPressed: () {
                  debugPrint('Botão Continuar recebeu o clique');
                  widget.onCompleted();
                  debugPrint('widget.onCompleted executado');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
