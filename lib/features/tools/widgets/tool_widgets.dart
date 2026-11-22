import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app_providers.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../shared/widgets/app_widgets.dart';

/// Standard scaffold for a calculator tool page.
class ToolPage extends StatelessWidget {
  const ToolPage({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 32),
          children: children,
        ),
      ),
    );
  }
}

/// Labelled numeric input with an optional microphone button.
class ToolField extends StatelessWidget {
  const ToolField({
    super.key,
    required this.controller,
    required this.label,
    this.onChanged,
    this.prefix,
    this.suffix,
    this.allowVoice = false,
    this.onVoice,
    this.numeric = true,
  });

  final TextEditingController controller;
  final String label;
  final ValueChanged<String>? onChanged;
  final String? prefix;
  final String? suffix;
  final bool allowVoice;
  final VoidCallback? onVoice;
  final bool numeric;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: numeric
            ? const TextInputType.numberWithOptions(decimal: true, signed: true)
            : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixText: prefix,
          suffixText: suffix,
          suffixIcon: allowVoice
              ? IconButton(
                  tooltip: context.tr('voice_tap_to_speak'),
                  onPressed: onVoice,
                  icon: const Icon(Icons.mic_rounded),
                )
              : null,
        ),
      ),
    );
  }
}

class ToolRowData {
  const ToolRowData(this.label, this.value, {this.emphasized = false});

  final String label;
  final String value;
  final bool emphasized;
}

/// Result panel with optional words and speech/copy actions.
class ToolResultCard extends StatelessWidget {
  const ToolResultCard({
    super.key,
    required this.rows,
    this.words,
    this.onSpeak,
    this.onCopy,
    this.onSave,
  });

  final List<ToolRowData> rows;
  final String? words;
  final VoidCallback? onSpeak;
  final VoidCallback? onCopy;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SurfaceCard(
          color: theme.colorScheme.primary.withValues(alpha: 0.06),
          border: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var index = 0; index < rows.length; index++) ...[
                if (index > 0) const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        rows[index].label,
                        style: rows[index].emphasized
                            ? theme.textTheme.titleMedium
                            : theme.textTheme.bodyMedium,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        rows[index].value,
                        textAlign: TextAlign.right,
                        style: (rows[index].emphasized
                                ? theme.textTheme.titleLarge
                                : theme.textTheme.titleMedium)
                            ?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: rows[index].emphasized
                              ? theme.colorScheme.primary
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (words != null && words!.isNotEmpty) ...[
                const Divider(height: 24),
                Text(
                  context.tr('gst_words'),
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  words!,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
                ),
              ],
            ],
          ),
        ),
        if (onSpeak != null || onCopy != null || onSave != null) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              if (onSpeak != null)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onSpeak,
                    icon: const Icon(Icons.volume_up_rounded, size: 18),
                    label: Text(context.tr('speak')),
                  ),
                ),
              if (onSpeak != null && (onCopy != null || onSave != null))
                const SizedBox(width: 10),
              if (onCopy != null)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onCopy,
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: Text(context.tr('copy')),
                  ),
                ),
              if (onCopy != null && onSave != null) const SizedBox(width: 10),
              if (onSave != null)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onSave,
                    icon: const Icon(Icons.bookmark_add_rounded, size: 18),
                    label: Text(context.tr('save')),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}


/// Speaks [text] with the user's speech settings.
Future<void> speakWithSettings(
  BuildContext context,
  WidgetRef ref,
  String text,
) async {
  if (text.trim().isEmpty) return;
  final settings = ref.read(settingsControllerProvider);
  try {
    await ref.read(speechSynthesizerProvider).speak(
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

/// Copies [text] and shows a confirmation snack bar.
Future<void> copyWithFeedback(
  BuildContext context,
  WidgetRef ref,
  String text,
) async {
  if (text.trim().isEmpty) return;
  await ref.read(platformServicesProvider).copy(text);
  if (!context.mounted) return;
  showAppSnack(context, context.tr('copied'));
}

/// Saves a tool calculation to history.
Future<void> saveToolHistory(
  BuildContext context,
  WidgetRef ref, {
  required String expression,
  required String result,
  double? value,
  String type = 'tool',
}) async {
  final settings = ref.read(settingsControllerProvider);
  await ref.read(historyControllerProvider.notifier).add(
        expression: expression,
        result: result,
        value: value,
        type: type,
        languageCode: settings.language.code,
      );
  if (!context.mounted) return;
  showAppSnack(context, context.tr('calc_saved'));
}
