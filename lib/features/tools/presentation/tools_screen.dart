import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../shared/widgets/app_widgets.dart';

/// Grid of financial, maths and unit tools.
class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  static const List<_ToolGroup> _groups = [
    _ToolGroup(
      titleKey: 'tools_smart',
      tools: [
        _Tool(
          'tool_scan_count',
          Icons.qr_code_scanner_rounded,
          '/scan-count',
          Color(0xFF0F766E),
        ),
      ],
    ),
    _ToolGroup(
      titleKey: 'tools_financial',
      tools: [
        _Tool(
          'tool_gst',
          Icons.receipt_long_rounded,
          '/gst',
          Color(0xFFEF7A18),
        ),
        _Tool(
          'tool_discount',
          Icons.percent_rounded,
          '/discount',
          Color(0xFF2563EB),
        ),
        _Tool(
          'tool_profit_loss',
          Icons.trending_up_rounded,
          '/profit-loss',
          Color(0xFF0D9488),
        ),
        _Tool(
          'tool_emi',
          Icons.account_balance_rounded,
          '/emi',
          Color(0xFF7C3AED),
        ),
        _Tool(
          'tool_simple_interest',
          Icons.savings_rounded,
          '/interest',
          Color(0xFFE11D48),
        ),
        _Tool('tool_tip', Icons.restaurant_rounded, '/tip', Color(0xFFF59009)),
        _Tool('tool_ratio', Icons.balance_rounded, '/ratio', Color(0xFF0EA5E9)),
        _Tool(
          'tool_fraction',
          Icons.calculate_rounded,
          '/fraction',
          Color(0xFF64748B),
        ),
      ],
    ),
    _ToolGroup(
      titleKey: 'tools_math',
      tools: [
        _Tool(
          'tool_scientific',
          Icons.functions_rounded,
          '/scientific',
          Color(0xFF2563EB),
        ),
        _Tool(
          'tool_percentage',
          Icons.percent_rounded,
          '/percentage',
          Color(0xFFEF7A18),
        ),
        _Tool('tool_age', Icons.cake_rounded, '/age', Color(0xFF0D9488)),
        _Tool(
          'tool_quadratic',
          Icons.timeline_rounded,
          '/quadratic',
          Color(0xFF0F766E),
        ),
        _Tool(
          'tool_statistics',
          Icons.bar_chart_rounded,
          '/statistics',
          Color(0xFF2563EB),
        ),
        _Tool(
          'tool_base_converter',
          Icons.code_rounded,
          '/base-converter',
          Color(0xFF7C3AED),
        ),
        _Tool(
          'tool_number_tools',
          Icons.tag_rounded,
          '/number-tools',
          Color(0xFFE11D48),
        ),
        _Tool(
          'tool_date_diff',
          Icons.date_range_rounded,
          '/date-difference',
          Color(0xFF7C3AED),
        ),
      ],
    ),
    _ToolGroup(
      titleKey: 'tools_unit',
      tools: [
        _Tool(
          'tool_converter',
          Icons.swap_horiz_rounded,
          '/converter',
          Color(0xFF0EA5E9),
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('tools_title'))),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 110),
          children: [
            Text(
              context.tr('tools_subtitle'),
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 18),
            for (final group in _groups) ...[
              Text(
                context.tr(group.titleKey),
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              for (final tool in group.tools) ...[
                _ToolTile(tool: tool),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _ToolGroup {
  const _ToolGroup({required this.titleKey, required this.tools});

  final String titleKey;
  final List<_Tool> tools;
}

class _Tool {
  const _Tool(this.titleKey, this.icon, this.route, this.color);

  final String titleKey;
  final IconData icon;
  final String route;
  final Color color;
}

class _ToolTile extends StatelessWidget {
  const _ToolTile({required this.tool});

  final _Tool tool;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      radius: 18,
      onTap: () => context.push(tool.route),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: tool.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(tool.icon, color: tool.color, size: 21),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              context.tr(tool.titleKey),
              style: theme.textTheme.titleMedium,
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: theme.textTheme.bodySmall?.color,
          ),
        ],
      ),
    );
  }
}
