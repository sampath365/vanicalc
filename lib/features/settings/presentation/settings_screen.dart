import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app_providers.dart';
import '../../../core/constants/app_info.dart';
import '../../../core/constants/number_system.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../domain/app_settings.dart';

/// Theme, language, speech, number and about settings.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('settings_title'))),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 110),
          children: [
            _SectionCard(
              title: context.tr('settings_appearance'),
              icon: Icons.palette_outlined,
              children: [
                Text(
                  context.tr('settings_theme'),
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                SegmentedButton<AppThemeMode>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: AppThemeMode.light,
                      icon: const Icon(Icons.light_mode_rounded, size: 18),
                      label: Text(context.tr('settings_theme_light')),
                    ),
                    ButtonSegment(
                      value: AppThemeMode.dark,
                      icon: const Icon(Icons.dark_mode_rounded, size: 18),
                      label: Text(context.tr('settings_theme_dark')),
                    ),
                    ButtonSegment(
                      value: AppThemeMode.system,
                      icon: const Icon(Icons.brightness_auto_rounded, size: 18),
                      label: Text(context.tr('settings_theme_system')),
                    ),
                  ],
                  selected: {settings.themeMode},
                  onSelectionChanged: (selection) =>
                      controller.setThemeMode(selection.first),
                ),
                const SizedBox(height: 18),
                Text(
                  context.tr('settings_accent'),
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    for (final palette in AccentPalette.values)
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => controller.setAccent(palette),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: palette.gradient,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: settings.accent == palette
                                    ? theme.colorScheme.onSurface
                                    : Colors.transparent,
                                width: 2.4,
                              ),
                            ),
                            child: settings.accent == palette
                                ? const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  )
                                : null,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                _SwitchRow(
                  title: context.tr('settings_large_text'),
                  subtitle: '115%',
                  value: settings.largeText,
                  onChanged: controller.setLargeText,
                ),
              ],
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: context.tr('settings_language'),
              icon: Icons.translate_rounded,
              children: [
                _NavRow(
                  title: context.tr('language_title'),
                  subtitle: settings.language.nativeName,
                  icon: Icons.language_rounded,
                  onTap: () => context.push('/language'),
                ),
                const Divider(height: 24),
                _LanguageDropdown(
                  label: context.tr('settings_voice_input_lang'),
                  value: settings.effectiveSpeechLanguage,
                  onChanged: controller.setSpeechLanguage,
                  onFollowApp: () => controller.setSpeechLanguage(null),
                  isOverride: settings.speechLanguage != null,
                ),
                const SizedBox(height: 14),
                _LanguageDropdown(
                  label: context.tr('settings_tts_lang'),
                  value: settings.effectiveTtsLanguage,
                  onChanged: controller.setTtsLanguage,
                  onFollowApp: () => controller.setTtsLanguage(null),
                  isOverride: settings.ttsLanguage != null,
                ),
              ],
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: context.tr('settings_speech'),
              icon: Icons.record_voice_over_rounded,
              children: [
                _SliderRow(
                  label: context.tr('settings_rate'),
                  value: settings.speechRate,
                  min: 0.2,
                  max: 1.0,
                  divisions: 8,
                  display: settings.speechRate.toStringAsFixed(2),
                  onChanged: controller.setSpeechRate,
                ),
                _SliderRow(
                  label: context.tr('settings_pitch'),
                  value: settings.speechPitch,
                  min: 0.5,
                  max: 2.0,
                  divisions: 15,
                  display: settings.speechPitch.toStringAsFixed(2),
                  onChanged: controller.setSpeechPitch,
                ),
                _SwitchRow(
                  title: context.tr('settings_auto_speak'),
                  value: settings.autoSpeak,
                  onChanged: controller.setAutoSpeak,
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => _testSpeech(context, ref, settings),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(context.tr('speak')),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: context.tr('settings_numbers'),
              icon: Icons.pin_outlined,
              children: [
                SegmentedButton<NumberSystem>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: NumberSystem.indian,
                      label: Text(context.tr('words_indian')),
                    ),
                    ButtonSegment(
                      value: NumberSystem.international,
                      label: Text(context.tr('words_international')),
                    ),
                  ],
                  selected: {settings.numberSystem},
                  onSelectionChanged: (selection) =>
                      controller.setNumberSystem(selection.first),
                ),
                const SizedBox(height: 10),
                _SwitchRow(
                  title: context.tr('settings_haptics'),
                  value: settings.haptics,
                  onChanged: controller.setHaptics,
                ),
              ],
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: context.tr('settings_about'),
              icon: Icons.info_outline_rounded,
              children: [
                _NavRow(
                  title: context.tr('settings_privacy'),
                  icon: Icons.privacy_tip_outlined,
                  onTap: () => _showPrivacy(context),
                ),
                const Divider(height: 24),
                _NavRow(
                  title: context.tr('settings_version'),
                  subtitle: AppInfo.versionLabel,
                  icon: Icons.tag_rounded,
                  onTap: null,
                ),
                const Divider(height: 24),
                _NavRow(
                  title: context.tr('settings_developer'),
                  subtitle: AppInfo.packageName,
                  icon: Icons.code_rounded,
                  onTap: null,
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: () => _confirmReset(context, ref),
                  icon: const Icon(Icons.restart_alt_rounded),
                  label: Text(context.tr('settings_reset')),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                '${AppInfo.name} • ${AppInfo.versionLabel}',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testSpeech(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) async {
    final words = ref.read(numberToWordsEngineProvider).convert(
          1234567,
          languageCode: settings.effectiveTtsLanguage.code,
          system: settings.numberSystem,
        );
    try {
      await ref.read(speechSynthesizerProvider).speak(
            words,
            locale: settings.effectiveTtsLanguage.ttsLocale,
            rate: settings.speechRate,
            pitch: settings.speechPitch,
          );
    } catch (_) {
      if (!context.mounted) return;
      showAppSnack(context, context.tr('voice_unavailable'), error: true);
    }
  }

  void _showPrivacy(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('settings_privacy')),
        content: const SingleChildScrollView(
          child: Text(
            'VaniCalc stores all calculations and settings on your device only. '
            'Speech recognition uses your device or platform speech service and '
            'may send audio to your provider; the app itself never uploads your '
            'data. No accounts, ads or analytics are used. You can clear your '
            'history at any time from the History screen.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.tr('close')),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('settings_reset')),
        content: Text(context.tr('settings_reset_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.tr('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.tr('reset')),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(settingsControllerProvider.notifier).reset();
    if (!context.mounted) return;
    showAppSnack(context, context.tr('settings_saved'));
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.bodyMedium),
              if (subtitle != null)
                Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.title,
    required this.icon,
    this.subtitle,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodyMedium),
                if (subtitle != null)
                  Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          if (onTap != null)
            Icon(
              Icons.chevron_right_rounded,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.display,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String display;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ),
            Text(display, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _LanguageDropdown extends StatelessWidget {
  const _LanguageDropdown({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.onFollowApp,
    required this.isOverride,
  });

  final String label;
  final AppLanguage value;
  final ValueChanged<AppLanguage> onChanged;
  final VoidCallback onFollowApp;
  final bool isOverride;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<AppLanguage>(
                initialValue: value,
                isExpanded: true,
                items: [
                  for (final language in AppLanguage.values)
                    DropdownMenuItem(
                      value: language,
                      child: Text(
                        '${language.flag}  ${language.nativeName}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                ],
                onChanged: (selection) {
                  if (selection != null) onChanged(selection);
                },
              ),
            ),
            if (isOverride)
              IconButton(
                tooltip: context.tr('reset'),
                onPressed: onFollowApp,
                icon: const Icon(Icons.link_off_rounded, size: 18),
              ),
          ],
        ),
      ],
    );
  }
}
