import 'package:material_ui/material_ui.dart';

import '../../core/localization/app_localizations.dart';

/// One entry in a [SearchableDropdown].
class SearchableOption<T> {
  const SearchableOption({
    required this.value,
    required this.label,
    this.subtitle,
    this.leading,
  });

  final T value;
  final String label;
  final String? subtitle;
  final String? leading;
}

/// A dropdown-style selector that opens a searchable bottom sheet.
///
/// Used for language, unit and tool pickers so long lists stay usable on
/// phones and tablets.
class SearchableDropdown<T> extends StatelessWidget {
  const SearchableDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.icon,
    this.hint,
    this.searchHint,
  });

  final String label;
  final T value;
  final List<SearchableOption<T>> options;
  final ValueChanged<T> onChanged;
  final IconData? icon;
  final String? hint;
  final String? searchHint;

  SearchableOption<T>? get _selected {
    for (final option in options) {
      if (option.value == value) return option;
    }
    return options.isEmpty ? null : options.first;
  }

  Future<void> _open(BuildContext context) async {
    final selected = await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _SearchSheet<T>(
        title: label,
        options: options,
        selected: value,
        searchHint: searchHint ?? context.tr('search'),
      ),
    );
    if (selected != null && selected != value) onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final current = _selected;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _open(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon == null ? null : Icon(icon, size: 20),
          suffixIcon: const Icon(Icons.expand_more_rounded),
        ),
        child: Text(
          current == null
              ? (hint ?? '—')
              : [
                  if (current.leading != null) current.leading!,
                  current.label,
                ].join('  '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium,
        ),
      ),
    );
  }
}

class _SearchSheet<T> extends StatefulWidget {
  const _SearchSheet({
    required this.title,
    required this.options,
    required this.selected,
    required this.searchHint,
  });

  final String title;
  final List<SearchableOption<T>> options;
  final T selected;
  final String searchHint;

  @override
  State<_SearchSheet<T>> createState() => _SearchSheetState<T>();
}

class _SearchSheetState<T> extends State<_SearchSheet<T>> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = widget.options
        .where((option) {
          if (_query.trim().isEmpty) return true;
          final query = _query.toLowerCase();
          return option.label.toLowerCase().contains(query) ||
              (option.subtitle?.toLowerCase().contains(query) ?? false);
        })
        .toList(growable: false);

    return Padding(
      padding: EdgeInsets.only(
        left: 18,
        right: 18,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 18,
      ),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.66,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            TextField(
              autofocus: false,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: widget.searchHint,
                prefixIcon: const Icon(Icons.search_rounded),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: filtered.isEmpty
                  ? Center(child: Text(context.tr('history_empty')))
                  : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 6),
                      itemBuilder: (context, index) {
                        final option = filtered[index];
                        final isSelected = option.value == widget.selected;
                        return ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          tileColor: isSelected
                              ? theme.colorScheme.primary.withValues(
                                  alpha: 0.09,
                                )
                              : null,
                          leading: option.leading == null
                              ? null
                              : Text(
                                  option.leading!,
                                  style: const TextStyle(fontSize: 20),
                                ),
                          title: Text(option.label),
                          subtitle: option.subtitle == null
                              ? null
                              : Text(
                                  option.subtitle!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle_rounded,
                                  color: theme.colorScheme.primary,
                                )
                              : null,
                          onTap: () => Navigator.of(context).pop(option.value),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
