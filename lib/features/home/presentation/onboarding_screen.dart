import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app_providers.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../shared/widgets/app_widgets.dart';

/// Three-page introduction shown on first launch.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  static const _pages = <_OnboardingPage>[
    _OnboardingPage(
      titleKey: 'onboarding_1_title',
      descKey: 'onboarding_1_desc',
      icon: Icons.calculate_rounded,
      colors: [Color(0xFFFF7A18), Color(0xFFFFA53C)],
    ),
    _OnboardingPage(
      titleKey: 'onboarding_2_title',
      descKey: 'onboarding_2_desc',
      icon: Icons.mic_rounded,
      colors: [Color(0xFF2563EB), Color(0xFF60A5FA)],
    ),
    _OnboardingPage(
      titleKey: 'onboarding_3_title',
      descKey: 'onboarding_3_desc',
      icon: Icons.translate_rounded,
      colors: [Color(0xFF0D9488), Color(0xFF2DD4BF)],
    ),
  ];

  Future<void> _finish() async {
    await ref.read(settingsControllerProvider.notifier).markOnboardingSeen();
    if (!mounted) return;
    context.go('/home');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLast = _page == _pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: Text(context.tr('onboarding_skip')),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _page = index),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 168,
                          height: 168,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: page.colors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(52),
                            boxShadow: [
                              BoxShadow(
                                color: page.colors.first.withValues(alpha: 0.32),
                                blurRadius: 36,
                                offset: const Offset(0, 18),
                              ),
                            ],
                          ),
                          child: Icon(page.icon, size: 76, color: Colors.white),
                        ),
                        const SizedBox(height: 44),
                        Text(
                          context.tr(page.titleKey),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          context.tr(page.descKey),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.textTheme.bodySmall?.color,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var index = 0; index < _pages.length; index++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: index == _page ? 26 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: index == _page
                          ? theme.colorScheme.primary
                          : theme.colorScheme.primary.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: GradientButton(
                label: isLast
                    ? context.tr('onboarding_start')
                    : context.tr('onboarding_next'),
                icon: isLast ? Icons.rocket_launch_rounded : Icons.arrow_forward_rounded,
                onPressed: () {
                  if (isLast) {
                    _finish();
                  } else {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOut,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage {
  const _OnboardingPage({
    required this.titleKey,
    required this.descKey,
    required this.icon,
    required this.colors,
  });

  final String titleKey;
  final String descKey;
  final IconData icon;
  final List<Color> colors;
}
