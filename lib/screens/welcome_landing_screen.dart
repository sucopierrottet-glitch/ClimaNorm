import 'package:flutter/material.dart';

import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'home_navigation_screen.dart';

class WelcomeLandingScreen extends StatelessWidget {
  const WelcomeLandingScreen({super.key});

  void _enterApp(BuildContext context, {int initialIndex = 0}) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => HomeNavigationScreen(initialIndex: initialIndex),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: StorageService.instance,
      builder: (context, _) {
        final s = StorageService.instance.strings;

        return Scaffold(
          backgroundColor: AppTheme.darkBg,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 2),

                  // App Icon with Ice Blue Ambient Glow
                  Center(
                    child: Container(
                      width: 108,
                      height: 108,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.iceBlue.withValues(alpha: 0.35),
                            blurRadius: 32,
                            spreadRadius: 2,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        'assets/icon/app_icon.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: AppColors.surfaceCard,
                          child: const Icon(
                            Icons.ac_unit_rounded,
                            size: 54,
                            color: AppColors.iceBlue,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Pro Unlocked Pill
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.compliant.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.compliant.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        s.proEditionBadge,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.compliant,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Title & Subtitle
                  Text(
                    s.appTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s.appSubtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Primary Enter Button
                  ElevatedButton.icon(
                    key: const Key('btnWelcomeEnter'),
                    onPressed: () => _enterApp(context, initialIndex: 0),
                    icon: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.black,
                    ),
                    label: Text(
                      s.enterApp,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.iceBlue,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Secondary Action: Quick P-T Diagnostic
                  OutlinedButton.icon(
                    key: const Key('btnWelcomeNewCalculation'),
                    onPressed: () => _enterApp(context, initialIndex: 1),
                    icon: const Icon(
                      Icons.speed_rounded,
                      color: AppColors.compliant,
                    ),
                    label: Text(
                      s.newCalculation,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      side: const BorderSide(color: AppTheme.darkBorder),
                      backgroundColor: AppTheme.darkCard,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
