import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../features/calculator/presentation/calculator_screen.dart';
import '../../features/converter/presentation/unit_converter_screen.dart';
import '../../features/gst/presentation/gst_calculator_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/home/presentation/main_shell.dart';
import '../../features/home/presentation/onboarding_screen.dart';
import '../../features/home/presentation/splash_screen.dart';
import '../../features/language/presentation/language_screen.dart';
import '../../features/number_to_words/presentation/number_to_words_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/speak/presentation/speak_result_screen.dart';
import '../../features/tools/presentation/finance_tools_screen.dart';
import '../../features/tools/presentation/math_tools_screen.dart';
import '../../features/tools/presentation/tools_screen.dart';
import '../../features/voice_calculator/presentation/voice_calculator_screen.dart';

/// Application routes. The five primary tabs live in an indexed stack so each
/// keeps its scroll position and state.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calculator',
                builder: (context, state) =>
                    CalculatorScreen(initialExpression: state.extra as String?),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/history',
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tools',
                builder: (context, state) => const ToolsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/voice',
        builder: (context, state) => const VoiceCalculatorScreen(),
      ),
      GoRoute(
        path: '/words',
        builder: (context, state) => const NumberToWordsScreen(),
      ),
      GoRoute(
        path: '/speak',
        builder: (context, state) => const SpeakResultScreen(),
      ),
      GoRoute(
        path: '/scientific',
        builder: (context, state) => const CalculatorScreen(scientific: true),
      ),
      GoRoute(
        path: '/gst',
        builder: (context, state) => const GstCalculatorScreen(),
      ),
      GoRoute(
        path: '/converter',
        builder: (context, state) => const UnitConverterScreen(),
      ),
      GoRoute(
        path: '/language',
        builder: (context, state) => const LanguageScreen(),
      ),
      GoRoute(
        path: '/percentage',
        builder: (context, state) => const PercentageScreen(),
      ),
      GoRoute(
        path: '/discount',
        builder: (context, state) => const DiscountScreen(),
      ),
      GoRoute(
        path: '/profit-loss',
        builder: (context, state) => const ProfitLossScreen(),
      ),
      GoRoute(path: '/emi', builder: (context, state) => const EmiScreen()),
      GoRoute(
        path: '/interest',
        builder: (context, state) => const InterestScreen(),
      ),
      GoRoute(path: '/tip', builder: (context, state) => const TipScreen()),
      GoRoute(path: '/ratio', builder: (context, state) => const RatioScreen()),
      GoRoute(
        path: '/fraction',
        builder: (context, state) => const FractionScreen(),
      ),
      GoRoute(path: '/age', builder: (context, state) => const AgeScreen()),
      GoRoute(
        path: '/date-difference',
        builder: (context, state) => const DateDifferenceScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('VaniCalc')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.explore_off_rounded, size: 42),
            const SizedBox(height: 12),
            Text(state.uri.toString()),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => context.go('/home'),
              child: const Text('Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
