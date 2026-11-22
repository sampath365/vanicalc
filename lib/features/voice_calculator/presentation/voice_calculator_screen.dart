import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app_providers.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../presentation/voice_controller.dart';

/// Voice driven calculator with live transcription, editable expression,
/// confirmation for ambiguous speech and spoken results.
class VoiceCalculatorScreen extends ConsumerStatefulWidget {
  const VoiceCalculatorScreen({super.key});

  @override
  ConsumerState<VoiceCalculatorScreen> createState() =>
      _VoiceCalculatorScreenState();
}

class _VoiceCalculatorScreenState extends ConsumerState<VoiceCalculatorScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );
  final TextEditingController _expressionController = TextEditingController();
  final FocusNode _expressionFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _pulse.repeat();
  }

  @override
  void dispose() {
    _pulse.dispose();
    _expressionController.dispose();
    _expressionFocus.dispose();
    super.dispose();
  }

  void _syncExpression(String expression) {
    if (_expressionFocus.hasFocus) return;
    if (_expressionController.text == expression) return;
    _expressionController.text = expression;
    _expressionController.selection = TextSelection.fromPosition(
      TextPosition(offset: expression.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(voiceControllerProvider);
    final settings = ref.watch(settingsControllerProvider);
    final theme = Theme.of(context);
    final palette = theme.extension<CalcPalette>()!;
    final listening = state.status == VoiceStatus.listening;

    ref.listen<VoiceState>(voiceControllerProvider, (previous, next) {
      _syncExpression(next.expression);
      if (next.navigateTo != null) {
        final target = next.navigateTo!;
        ref.read(voiceControllerProvider.notifier).consumeNavigation();
        if (target == '/history') {
          context.push('/history');
        } else if (target == '/scientific') {
          context.push('/scientific');
        }
      }
      if (next.notice != null && next.notice != previous?.notice) {
        showAppSnack(context, context.tr(next.notice!));
      }
    });

    final errorText = state.errorCode == null
        ? null
        : context.tr(state.errorCode!);
    final noticeText = state.notice == null ? null : context.tr(state.notice!);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('voice_title')),
        actions: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => context.push('/language'),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Text(settings.language.flag),
                  const SizedBox(width: 6),
                  Text(
                    settings.effectiveSpeechLanguage.nativeName,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
          children: [
            Text(
              context.tr('voice_subtitle'),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: _MicOrb(
                pulse: _pulse,
                listening: listening,
                speaking: state.speaking,
                palette: palette,
                onTap: () {
                  final controller = ref.read(voiceControllerProvider.notifier);
                  if (listening) {
                    controller.stopListening();
                  } else {
                    controller.startListening();
                  }
                },
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                switch (state.status) {
                  VoiceStatus.listening => context.tr('voice_listening'),
                  VoiceStatus.processing => context.tr('voice_processing'),
                  VoiceStatus.needsConfirmation => context.tr(
                    'voice_confirm_title',
                  ),
                  VoiceStatus.result => context.tr('voice_recognized'),
                  VoiceStatus.error => context.tr('voice_no_speech'),
                  VoiceStatus.idle => context.tr('voice_tap_to_speak'),
                },
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            if (state.transcript.isNotEmpty) ...[
              const SizedBox(height: 16),
              SurfaceCard(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Icon(
                      Icons.graphic_eq_rounded,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        state.transcript,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                    if (state.confidence > 0)
                      Text(
                        '${(state.confidence * 100).round()}%',
                        style: theme.textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
            ],
            if (errorText != null) ...[
              const SizedBox(height: 12),
              _Banner(
                icon: Icons.error_outline_rounded,
                color: AppColors.danger,
                text: errorText,
              ),
            ],
            if (noticeText != null) ...[
              const SizedBox(height: 12),
              _Banner(
                icon: Icons.info_outline_rounded,
                color: theme.colorScheme.primary,
                text: noticeText,
              ),
            ],
            const SizedBox(height: 18),
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('voice_expression'),
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _expressionController,
                    focusNode: _expressionFocus,
                    keyboardType: TextInputType.text,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontSize: 24,
                    ),
                    decoration: InputDecoration(
                      hintText: context.tr('voice_edit_hint'),
                    ),
                    onChanged: (value) => ref
                        .read(voiceControllerProvider.notifier)
                        .editExpression(value),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.tr('voice_edit_hint'),
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: GradientButton(
                          label: context.tr('calculate'),
                          icon: Icons.bolt_rounded,
                          height: 48,
                          onPressed: state.expression.trim().isEmpty
                              ? null
                              : () => ref
                                    .read(voiceControllerProvider.notifier)
                                    .calculate(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        onPressed: () {
                          ref.read(voiceControllerProvider.notifier).reset();
                          _expressionController.clear();
                        },
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: Text(context.tr('reset')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (state.hasResult) ...[
              const SizedBox(height: 14),
              _ResultCard(state: state),
            ],
            const SizedBox(height: 18),
            SectionHeader(title: context.tr('voice_examples')),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final key in const [
                  'voice_example_1',
                  'voice_example_2',
                  'voice_example_3',
                  'voice_example_4',
                ])
                  ActionChip(
                    label: Text(context.tr(key)),
                    onPressed: () => ref
                        .read(voiceControllerProvider.notifier)
                        .process(context.tr(key)),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.record_voice_over_rounded,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        context.tr('voice_command_hint'),
                        style: theme.textTheme.titleSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '“Clear calculator” • “Delete last number” • '
                    '“Repeat answer” • “Show history” • '
                    '“Switch to scientific calculator” • '
                    '“Change language to Telugu” • “Read result in Hindi”',
                    style: theme.textTheme.bodySmall?.copyWith(height: 1.7),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.tr('voice_auto_speak'),
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                Switch(
                  value: settings.autoSpeak,
                  onChanged: (value) => ref
                      .read(settingsControllerProvider.notifier)
                      .setAutoSpeak(value),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MicOrb extends StatelessWidget {
  const _MicOrb({
    required this.pulse,
    required this.listening,
    required this.speaking,
    required this.palette,
    required this.onTap,
  });

  final AnimationController pulse;
  final bool listening;
  final bool speaking;
  final CalcPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: AnimatedBuilder(
        animation: pulse,
        builder: (context, child) {
          final value = listening ? pulse.value : 0.0;
          return Stack(
            alignment: Alignment.center,
            children: [
              if (listening) _ring(1 + value * 0.55, (1 - value) * 0.35),
              if (listening)
                _ring(
                  1 + ((value + 0.5) % 1) * 0.55,
                  (1 - ((value + 0.5) % 1)) * 0.3,
                ),
              PressableScale(
                key: const Key('voice_mic_button'),
                onTap: onTap,
                scale: 0.94,
                child: Container(
                  width: 116,
                  height: 116,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [palette.equalsStart, palette.equalsEnd],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: palette.equalsStart.withValues(alpha: 0.4),
                        blurRadius: 28,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Icon(
                    listening
                        ? Icons.stop_rounded
                        : (speaking
                              ? Icons.volume_up_rounded
                              : Icons.mic_rounded),
                    color: Colors.white,
                    size: 46,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _ring(double scale, double opacity) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: 116,
        height: 116,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: palette.equalsStart.withValues(alpha: opacity.clamp(0, 1)),
            width: 2,
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends ConsumerWidget {
  const _ResultCard({required this.state});

  final VoiceState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final controller = ref.read(voiceControllerProvider.notifier);
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                context.tr('calc_result'),
                style: theme.textTheme.titleSmall,
              ),
              const Spacer(),
              if (state.speaking)
                IconButton(
                  onPressed: controller.stopSpeaking,
                  icon: const Icon(Icons.stop_circle_outlined),
                  tooltip: context.tr('stop'),
                )
              else
                IconButton(
                  onPressed: () =>
                      controller.speakCalculation(answerOnly: true),
                  icon: const Icon(Icons.volume_up_rounded),
                  tooltip: context.tr('voice_speak_answer'),
                ),
              IconButton(
                onPressed: () async {
                  await ref.read(platformServicesProvider).copy(state.result);
                  if (!context.mounted) return;
                  showAppSnack(context, context.tr('copied'));
                },
                icon: const Icon(Icons.copy_rounded),
                tooltip: context.tr('copy'),
              ),
            ],
          ),
          Text(
            state.result,
            key: const Key('voice_result_text'),
            style: theme.textTheme.displayMedium,
          ),
          const SizedBox(height: 4),
          Text(state.expression, style: theme.textTheme.bodySmall),
          const SizedBox(height: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlinedButton.icon(
                onPressed: () => controller.speakCalculation(answerOnly: true),
                icon: const Icon(Icons.record_voice_over_rounded, size: 18),
                label: Text(
                  context.tr('voice_speak_answer'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => controller.speakCalculation(),
                icon: const Icon(Icons.subject_rounded, size: 18),
                label: Text(
                  context.tr('voice_speak_result'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.icon, required this.color, required this.text});

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: color, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
