import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app_providers.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/result_formatter.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../history/domain/calculation_record.dart';
import '../presentation/calculator_controller.dart';
import '../widgets/calculator_keypad.dart';

/// Standard and scientific calculator screen (MVVM view over
/// [CalculatorController]).
class CalculatorScreen extends ConsumerStatefulWidget {
  const CalculatorScreen({
    super.key,
    this.scientific = false,
    this.initialExpression,
  });

  final bool scientific;
  final String? initialExpression;

  @override
  ConsumerState<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends ConsumerState<CalculatorScreen> {
  bool _speaking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _configure());
  }

  @override
  void didUpdateWidget(covariant CalculatorScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialExpression != widget.initialExpression ||
        oldWidget.scientific != widget.scientific) {
      _configure();
    }
  }

  void _configure() {
    if (!mounted) return;
    final controller = ref.read(calculatorControllerProvider.notifier);
    controller.setType(
      widget.scientific ? CalculationType.scientific : CalculationType.standard,
    );
    if (widget.initialExpression != null &&
        widget.initialExpression!.trim().isNotEmpty) {
      controller.loadExpression(widget.initialExpression!);
    }
  }

  void _onKey(String key) {
    final settings = ref.read(settingsControllerProvider);
    if (settings.haptics) {
      final services = ref.read(platformServicesProvider);
      if (key == '=') {
        services.mediumHaptic();
      } else {
        services.lightHaptic();
      }
    }
    ref.read(calculatorControllerProvider.notifier).press(key);
    if (key == '=') {
      final state = ref.read(calculatorControllerProvider);
      if (settings.autoSpeak && state.value != null) {
        _speak();
      }
    }
  }

  Future<void> _speak({bool answerOnly = false}) async {
    final state = ref.read(calculatorControllerProvider);
    final value = state.value ?? double.tryParse(state.preview);
    if (value == null || state.expression.trim().isEmpty) return;
    final settings = ref.read(settingsControllerProvider);
    final speaker = ref.read(calculationSpeakerProvider);
    final language = settings.effectiveTtsLanguage;
    final text = answerOnly
        ? speaker.resultWords(value, language, system: settings.numberSystem)
        : speaker.calculationSentence(
            state.expression,
            value,
            language,
            system: settings.numberSystem,
          );
    setState(() => _speaking = true);
    try {
      await ref
          .read(speechSynthesizerProvider)
          .speak(
            text,
            locale: language.ttsLocale,
            rate: settings.speechRate,
            pitch: settings.speechPitch,
          );
    } catch (_) {
      if (!mounted) return;
      showAppSnack(context, context.tr('voice_unavailable'), error: true);
    } finally {
      if (mounted) setState(() => _speaking = false);
    }
  }

  Future<void> _stopSpeaking() async {
    await ref.read(speechSynthesizerProvider).stop();
    if (mounted) setState(() => _speaking = false);
  }

  Future<void> _copy() async {
    final state = ref.read(calculatorControllerProvider);
    final text = state.result.isNotEmpty ? state.result : state.expression;
    if (text.isEmpty) return;
    await ref.read(platformServicesProvider).copy(text);
    if (!mounted) return;
    showAppSnack(context, context.tr('copied'));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(calculatorControllerProvider);
    final settings = ref.watch(settingsControllerProvider);
    final isWide = MediaQuery.sizeOf(context).width >= 700;
    final wordsValue = state.value ?? double.tryParse(state.preview);
    final words = wordsValue == null
        ? ''
        : ref
              .read(numberToWordsEngineProvider)
              .fromString(
                ResultFormatter.format(wordsValue),
                languageCode: settings.language.code,
                system: settings.numberSystem,
              );

    final keypad = CalculatorKeypad(
      scientific: widget.scientific,
      onKey: _onKey,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.scientific
              ? context.tr('calc_scientific')
              : context.tr('calc_title'),
        ),
        actions: [
          IconButton(
            tooltip: context.tr('calc_voice'),
            onPressed: () => context.push('/voice'),
            icon: const Icon(Icons.mic_rounded),
          ),
          IconButton(
            tooltip: context.tr('calc_history'),
            onPressed: () => context.push('/history'),
            icon: const Icon(Icons.history_rounded),
          ),
          IconButton(
            tooltip: context.tr('copy'),
            onPressed: _copy,
            icon: const Icon(Icons.copy_rounded),
          ),
          IconButton(
            tooltip: widget.scientific
                ? context.tr('calc_title')
                : context.tr('calc_scientific'),
            onPressed: () {
              if (widget.scientific) {
                context.go('/calculator');
              } else {
                context.push('/scientific');
              }
            },
            icon: Icon(
              widget.scientific
                  ? Icons.calculate_outlined
                  : Icons.functions_rounded,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                children: [
                  _DisplayCard(
                    state: state,
                    words: words,
                    speaking: _speaking,
                    onSpeak: _speak,
                    onStopSpeaking: _stopSpeaking,
                    memoryLabel: state.memorySet
                        ? context.tr('calc_memory_set')
                        : context.tr('calc_memory_empty'),
                    onMemoryKey: _onKey,
                  ),
                  if (!widget.scientific) ...[
                    const SizedBox(height: 10),
                    FunctionStrip(onKey: _onKey),
                  ],
                  const SizedBox(height: 10),
                  Expanded(
                    child: isWide
                        ? Row(
                            children: [
                              Expanded(flex: 3, child: keypad),
                              const SizedBox(width: 14),
                              Expanded(
                                flex: 2,
                                child: _SidePanel(state: state, onKey: _onKey),
                              ),
                            ],
                          )
                        : keypad,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DisplayCard extends StatelessWidget {
  const _DisplayCard({
    required this.state,
    required this.words,
    required this.speaking,
    required this.onSpeak,
    required this.onStopSpeaking,
    required this.memoryLabel,
    required this.onMemoryKey,
  });

  final CalculatorState state;
  final String words;
  final bool speaking;
  final VoidCallback onSpeak;
  final VoidCallback onStopSpeaking;
  final String memoryLabel;
  final ValueChanged<String> onMemoryKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<CalcPalette>()!;
    final errorText = state.errorCode == null
        ? null
        : context.tr(state.errorCode!);
    final display = state.result.isNotEmpty
        ? state.result
        : (state.preview.isNotEmpty ? state.preview : '0');
    final isPreview = state.result.isEmpty && state.preview.isNotEmpty;
    final showWords = words.isNotEmpty && errorText == null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 10, 10, 14),
      decoration: BoxDecoration(
        color: palette.displayBackground,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: MemoryBar(
                  memorySet: state.memorySet,
                  memory: state.memory,
                  memoryLabel: memoryLabel,
                  onKey: onMemoryKey,
                ),
              ),
              IconButton(
                key: const Key('calc_speak_button'),
                tooltip: speaking
                    ? context.tr('stop')
                    : context.tr('voice_speak_result'),
                visualDensity: VisualDensity.compact,
                onPressed: speaking ? onStopSpeaking : onSpeak,
                icon: Icon(
                  speaking
                      ? Icons.stop_circle_outlined
                      : Icons.volume_up_rounded,
                  size: 21,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 2),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 24,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  state.expression.isEmpty
                      ? context.tr('calc_expression')
                      : _pretty(state.expression),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 58,
            child: Align(
              alignment: Alignment.centerRight,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(
                      begin: 0.94,
                      end: 1,
                    ).animate(animation),
                    alignment: Alignment.centerRight,
                    child: child,
                  ),
                ),
                child: FittedBox(
                  key: ValueKey('$display-$isPreview-$errorText'),
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    errorText ?? display,
                    key: const Key('calc_display_result'),
                    maxLines: 1,
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: errorText != null
                          ? AppColors.danger
                          : isPreview
                          ? theme.colorScheme.primary.withValues(alpha: 0.55)
                          : theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (showWords)
            Padding(
              padding: const EdgeInsets.only(top: 2, right: 8),
              child: Text(
                words,
                key: const Key('calc_words_text'),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 11.5,
                  height: 1.3,
                ),
              ),
            ),
        ],
      ),
    );
  }

  static String _pretty(String expression) {
    return expression
        .replaceAll('*', ' × ')
        .replaceAll('/', ' ÷ ')
        .replaceAll('-', ' − ')
        .replaceAll('+', ' + ')
        .replaceAll('sqrt', '√')
        .replaceAll(RegExp(r'\s+'), ' ');
  }
}

class _SidePanel extends StatelessWidget {
  const _SidePanel({required this.state, required this.onKey});

  final CalculatorState state;
  final ValueChanged<String> onKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('home_quick_tools'),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final entry in const {
                    'sqrt(': '√',
                    'square': 'x²',
                    'cube': 'x³',
                    '^': 'xʸ',
                    'reciprocal': '1/x',
                    'pi': 'π',
                    '!': '!',
                    '%': '%',
                    'mod': 'mod',
                    'e': 'e',
                  }.entries)
                    ActionChip(
                      label: Text(entry.value),
                      onPressed: () => onKey(entry.key),
                    ),
                ],
              ),
            ),
          ),
          Text(
            state.expression.isEmpty ? '' : state.expression,
            style: theme.textTheme.bodySmall,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
