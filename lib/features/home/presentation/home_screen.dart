import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app_providers.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../../shared/widgets/calculation_tile.dart';
import '../../history/domain/calculation_record.dart';
import '../../settings/domain/app_settings.dart';

/// Main dashboard with quick access cards, statistics and recent history.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _features = <_Feature>[
    _Feature(
      titleKey: 'feature_calculator',
      subtitleKey: 'feature_calculator_desc',
      icon: Icons.calculate_rounded,
      route: '/calculator',
      colors: [Color(0xFFFF7A18), Color(0xFFFFA53C)],
    ),
    _Feature(
      titleKey: 'feature_voice',
      subtitleKey: 'feature_voice_desc',
      icon: Icons.mic_rounded,
      route: '/voice',
      colors: [Color(0xFF2563EB), Color(0xFF60A5FA)],
    ),
    _Feature(
      titleKey: 'feature_words',
      subtitleKey: 'feature_words_desc',
      icon: Icons.text_fields_rounded,
      route: '/words',
      colors: [Color(0xFF0D9488), Color(0xFF2DD4BF)],
    ),
    _Feature(
      titleKey: 'feature_speak',
      subtitleKey: 'feature_speak_desc',
      icon: Icons.volume_up_rounded,
      route: '/speak',
      colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
    ),
    _Feature(
      titleKey: 'feature_history',
      subtitleKey: 'feature_history_desc',
      icon: Icons.history_rounded,
      route: '/history',
      colors: [Color(0xFFE11D48), Color(0xFFFB7185)],
    ),
    _Feature(
      titleKey: 'feature_converter',
      subtitleKey: 'feature_converter_desc',
      icon: Icons.swap_horiz_rounded,
      route: '/converter',
      colors: [Color(0xFF0EA5E9), Color(0xFF38BDF8)],
    ),
    _Feature(
      titleKey: 'feature_settings',
      subtitleKey: 'feature_settings_desc',
      icon: Icons.tune_rounded,
      route: '/settings',
      colors: [Color(0xFF64748B), Color(0xFF94A3B8)],
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final history = ref.watch(historyControllerProvider);
    final todayCount = history
        .where((record) => _isToday(record.createdAt))
        .length;
    final favoriteCount = history.where((record) => record.favorite).length;
    final recent = history.take(3).toList(growable: false);
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 900 ? 4 : (width >= 640 ? 3 : 2);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 120),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('home_greeting'),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        context.tr('app_name'),
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ],
                  ),
                ),
                _LanguageChip(settings: settings),
                const SizedBox(width: 6),
                IconButton(
                  tooltip: context.tr('settings_theme'),
                  onPressed: () {
                    final next = settings.themeMode == AppThemeMode.dark
                        ? AppThemeMode.light
                        : AppThemeMode.dark;
                    ref
                        .read(settingsControllerProvider.notifier)
                        .setThemeMode(next);
                  },
                  icon: Icon(
                    settings.themeMode == AppThemeMode.dark
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GradientHeader(
              title: context.tr('app_tagline'),
              subtitle: context.tr('home_voice_hint'),
              icon: Icons.auto_awesome_rounded,
              child: Row(
                children: [
                  Expanded(
                    child: _HeroButton(
                      label: context.tr('voice_tap_to_speak'),
                      icon: Icons.mic_rounded,
                      filled: true,
                      onTap: () => context.push('/voice'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _HeroButton(
                      label: context.tr('feature_words'),
                      icon: Icons.translate_rounded,
                      filled: false,
                      onTap: () => context.push('/words'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: StatPill(
                    label: context.tr('home_stats_today'),
                    value: '$todayCount',
                    icon: Icons.today_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatPill(
                    label: context.tr('home_stats_total'),
                    value: '${history.length}',
                    icon: Icons.functions_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatPill(
                    label: context.tr('home_stats_favorites'),
                    value: '$favoriteCount',
                    icon: Icons.star_rounded,
                    color: const Color(0xFFF5A623),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            SectionHeader(title: context.tr('home_featured')),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _features.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: width >= 640 ? 1.5 : 1.28,
              ),
              itemBuilder: (context, index) {
                final feature = _features[index];
                return FeatureCard(
                  title: context.tr(feature.titleKey),
                  subtitle: context.tr(feature.subtitleKey),
                  icon: feature.icon,
                  colors: feature.colors,
                  onTap: () {
                    if (feature.route == '/history' ||
                        feature.route == '/settings') {
                      context.go(feature.route);
                    } else {
                      context.push(feature.route);
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 22),
            SectionHeader(
              title: context.tr('home_recent'),
              actionLabel: history.isEmpty ? null : context.tr('home_view_all'),
              onAction: () => context.go('/history'),
            ),
            if (recent.isEmpty)
              SurfaceCard(
                child: Row(
                  children: [
                    Icon(
                      Icons.history_toggle_off_rounded,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        context.tr('home_empty_history'),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  for (final record in recent) ...[
                    CalculationTile(
                      record: record,
                      compact: true,
                      onReuse: () =>
                          context.go('/calculator', extra: record.expression),
                      onToggleFavorite: () => ref
                          .read(historyControllerProvider.notifier)
                          .toggleFavorite(record.id),
                      onDelete: () => ref
                          .read(historyControllerProvider.notifier)
                          .delete(record.id),
                      onCopy: () => _copy(context, ref, record),
                      onSpeak: () => _speak(context, ref, record, settings),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: () => context.push('/voice'),
        backgroundColor: Theme.of(context)
            .extension<CalcPalette>()
            ?.equalsStart,
        foregroundColor: Colors.white,
        child: const Icon(Icons.mic_rounded, size: 30),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return now.year == date.year &&
        now.month == date.month &&
        now.day == date.day;
  }

  Future<void> _copy(
    BuildContext context,
    WidgetRef ref,
    CalculationRecord record,
  ) async {
    await ref
        .read(platformServicesProvider)
        .copy('${record.expression} = ${record.result}');
    if (!context.mounted) return;
    showAppSnack(context, context.tr('copied'));
  }

  Future<void> _speak(
    BuildContext context,
    WidgetRef ref,
    CalculationRecord record,
    AppSettings settings,
  ) async {
    final value = record.value ?? double.tryParse(record.result);
    final text = value == null
        ? record.result
        : ref
              .read(calculationSpeakerProvider)
              .calculationSentence(
                record.expression,
                value,
                settings.effectiveTtsLanguage,
                system: settings.numberSystem,
              );
    try {
      await ref
          .read(speechSynthesizerProvider)
          .speak(
            text,
            locale: settings.effectiveTtsLanguage.ttsLocale,
            rate: settings.speechRate,
            pitch: settings.speechPitch,
          );
    } catch (_) {
      if (!context.mounted) return;
      showAppSnack(context, context.tr('voice_unavailable'), error: true);
    }
  }
}

class _Feature {
  const _Feature({
    required this.titleKey,
    required this.subtitleKey,
    required this.icon,
    required this.route,
    required this.colors,
  });

  final String titleKey;
  final String subtitleKey;
  final IconData icon;
  final String route;
  final List<Color> colors;
}

class _LanguageChip extends StatelessWidget {
  const _LanguageChip({required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => context.push('/language'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(settings.language.flag, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 90),
              child: Text(
                settings.language.nativeName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const Icon(Icons.expand_more_rounded, size: 16),
          ],
        ),
      ),
    );
  }
}

class _HeroButton extends StatelessWidget {
  const _HeroButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: filled ? Colors.white : Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(16),
          border: filled
              ? null
              : Border.all(color: Colors.white.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: filled ? const Color(0xFFFF6A00) : Colors.white,
            ),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: filled ? const Color(0xFF101828) : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
