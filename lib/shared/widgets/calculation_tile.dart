import 'package:material_ui/material_ui.dart';

import '../../core/localization/app_localizations.dart';
import '../../features/history/domain/calculation_record.dart';
import 'app_widgets.dart';

String typeLabel(BuildContext context, String type) {
  return switch (type) {
    CalculationType.scientific => context.tr('calc_scientific'),
    CalculationType.voice => context.tr('feature_voice'),
    CalculationType.words => context.tr('feature_words'),
    CalculationType.gst => context.tr('tool_gst'),
    CalculationType.tool => context.tr('nav_tools'),
    CalculationType.converter => context.tr('feature_converter'),
    _ => context.tr('feature_calculator'),
  };
}

String formatRecordDate(BuildContext context, DateTime date) {
  final now = DateTime.now();
  final sameDay =
      now.year == date.year && now.month == date.month && now.day == date.day;
  final time = TimeOfDay.fromDateTime(date).format(context);
  if (sameDay) return time;
  return '${date.day}/${date.month}/${date.year}  $time';
}

/// A saved calculation row with favourite, reuse, copy, speak and delete
/// actions.
class CalculationTile extends StatelessWidget {
  const CalculationTile({
    super.key,
    required this.record,
    required this.onReuse,
    required this.onToggleFavorite,
    required this.onDelete,
    required this.onCopy,
    required this.onSpeak,
    this.compact = false,
  });

  final CalculationRecord record;
  final VoidCallback onReuse;
  final VoidCallback onToggleFavorite;
  final VoidCallback onDelete;
  final VoidCallback onCopy;
  final VoidCallback onSpeak;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      radius: 20,
      onTap: onReuse,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.expression,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '= ${record.result}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: compact ? 18 : 20,
                  ),
                ),
                if (!compact) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          typeLabel(context, record.type),
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          formatRecordDate(context, record.createdAt),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: record.favorite
                ? context.tr('history_unfavorite')
                : context.tr('history_favorite'),
            onPressed: onToggleFavorite,
            icon: Icon(
              record.favorite ? Icons.star_rounded : Icons.star_border_rounded,
              color: record.favorite
                  ? const Color(0xFFF5A623)
                  : theme.textTheme.bodySmall?.color,
            ),
          ),
          PopupMenuButton<String>(
            tooltip: context.tr('all'),
            onSelected: (value) {
              switch (value) {
                case 'reuse':
                  onReuse();
                case 'copy':
                  onCopy();
                case 'speak':
                  onSpeak();
                case 'delete':
                  onDelete();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'reuse',
                child: _MenuRow(
                  icon: Icons.replay_rounded,
                  label: context.tr('history_reuse'),
                ),
              ),
              PopupMenuItem(
                value: 'copy',
                child: _MenuRow(
                  icon: Icons.copy_rounded,
                  label: context.tr('copy'),
                ),
              ),
              PopupMenuItem(
                value: 'speak',
                child: _MenuRow(
                  icon: Icons.volume_up_rounded,
                  label: context.tr('history_speak'),
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: _MenuRow(
                  icon: Icons.delete_outline_rounded,
                  label: context.tr('history_delete'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 10),
        Text(label),
      ],
    );
  }
}
