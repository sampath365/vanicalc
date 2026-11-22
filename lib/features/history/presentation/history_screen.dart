import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app_providers.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../../shared/widgets/calculation_tile.dart';
import '../domain/calculation_record.dart';

/// Searchable, favouritable calculation history.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _query = '';
  bool _favoritesOnly = false;

  @override
  Widget build(BuildContext context) {
    final records = ref.watch(historyControllerProvider);
    final filtered = ref
        .read(historyControllerProvider.notifier)
        .search(_query, favoritesOnly: _favoritesOnly);
    final settings = ref.watch(settingsControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('history_title')),
        actions: [
          IconButton(
            tooltip: context.tr('history_clear_all'),
            onPressed: records.isEmpty ? null : _confirmClear,
            icon: const Icon(Icons.delete_sweep_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 0),
              child: TextField(
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: context.tr('history_search_hint'),
                  prefixIcon: const Icon(Icons.search_rounded),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  ChoiceChip(
                    label: Text(context.tr('history_all')),
                    selected: !_favoritesOnly,
                    onSelected: (_) => setState(() => _favoritesOnly = false),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text(context.tr('history_favorites')),
                    selected: _favoritesOnly,
                    onSelected: (_) => setState(() => _favoritesOnly = true),
                  ),
                  const Spacer(),
                  Text('${filtered.length}', style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: filtered.isEmpty
                  ? EmptyState(
                      icon: _favoritesOnly
                          ? Icons.star_border_rounded
                          : Icons.history_toggle_off_rounded,
                      title: context.tr('history_empty'),
                      subtitle: context.tr('history_empty_desc'),
                      action: GradientButton(
                        expanded: false,
                        label: context.tr('calculate'),
                        icon: Icons.calculate_rounded,
                        onPressed: () => context.go('/calculator'),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(18, 4, 18, 100),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final record = filtered[index];
                        return CalculationTile(
                          record: record,
                          onReuse: () => context.go(
                            '/calculator',
                            extra: record.expression,
                          ),
                          onToggleFavorite: () => ref
                              .read(historyControllerProvider.notifier)
                              .toggleFavorite(record.id),
                          onDelete: () async {
                            await ref
                                .read(historyControllerProvider.notifier)
                                .delete(record.id);
                            if (!context.mounted) return;
                            showAppSnack(
                              context,
                              context.tr('history_deleted'),
                            );
                          },
                          onCopy: () async {
                            await ref
                                .read(platformServicesProvider)
                                .copy(
                                  '${record.expression} = ${record.result}',
                                );
                            if (!context.mounted) return;
                            showAppSnack(context, context.tr('copied'));
                          },
                          onSpeak: () => _speak(record, settings),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _speak(CalculationRecord record, dynamic settings) async {
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
      if (!mounted) return;
      showAppSnack(context, context.tr('voice_unavailable'), error: true);
    }
  }

  Future<void> _confirmClear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('history_clear_all')),
        content: Text(context.tr('history_clear_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.tr('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.tr('delete')),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(historyControllerProvider.notifier).clear();
    if (!mounted) return;
    showAppSnack(context, context.tr('history_cleared'));
  }
}
