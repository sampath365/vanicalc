import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../app_providers.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/result_formatter.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../tools/widgets/tool_widgets.dart';
import '../domain/scan_counter.dart';

/// Camera barcode scanner that counts items and totals optional prices.
class ScanCountScreen extends ConsumerStatefulWidget {
  const ScanCountScreen({super.key});

  @override
  ConsumerState<ScanCountScreen> createState() => _ScanCountScreenState();
}

class _ScanCountScreenState extends ConsumerState<ScanCountScreen> {
  final MobileScannerController _scanner = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  final ScanCounter _counter = ScanCounter();
  String? _lastCode;
  DateTime? _lastScanAt;
  bool _torch = false;

  @override
  void dispose() {
    _scanner.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    for (final barcode in capture.barcodes) {
      final code = (barcode.displayValue ?? barcode.rawValue)?.trim();
      if (code == null || code.isEmpty) continue;
      final now = DateTime.now();
      if (_lastCode == code &&
          _lastScanAt != null &&
          now.difference(_lastScanAt!) < const Duration(milliseconds: 1400)) {
        return;
      }
      _lastCode = code;
      _lastScanAt = now;
      final isNew = _counter.itemFor(code) == null;
      setState(() => _counter.add(code));
      ref.read(platformServicesProvider).lightHaptic();
      if (mounted) {
        showAppSnack(
          context,
          '${context.tr(isNew ? 'scan_added' : 'scan_qty')}: '
          '${_counter.itemFor(code)!.quantity} • $code',
        );
      }
      return;
    }
  }

  Future<void> _openItemDialog({ScannedItem? item}) async {
    final codeController = TextEditingController(text: item?.code ?? '');
    final labelController = TextEditingController(text: item?.label ?? '');
    final priceController = TextEditingController(
      text: item?.price == null ? '' : ResultFormatter.format(item!.price!),
    );
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          context.tr(item == null ? 'scan_add_manual' : 'scan_edit_item'),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codeController,
                enabled: item == null,
                decoration: InputDecoration(labelText: context.tr('scan_code')),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: labelController,
                decoration: InputDecoration(
                  labelText: context.tr('scan_label'),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: context.tr('scan_price'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.tr('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.tr('save')),
          ),
        ],
      ),
    );

    final price = double.tryParse(
      priceController.text.trim().replaceAll(',', ''),
    );
    if (saved == true) {
      final code = codeController.text.trim();
      if (item == null && code.isNotEmpty) {
        setState(
          () => _counter.add(
            code,
            label: labelController.text.trim(),
            price: price,
          ),
        );
      } else if (item != null) {
        setState(
          () => _counter.update(
            item.code,
            label: labelController.text.trim(),
            price: price,
            clearPrice: price == null,
          ),
        );
      }
    }
    codeController.dispose();
    labelController.dispose();
    priceController.dispose();
  }

  Future<void> _toggleTorch() async {
    try {
      await _scanner.toggleTorch();
      setState(() => _torch = !_torch);
    } catch (_) {
      // Some devices or cameras do not expose a torch.
    }
  }

  Future<void> _switchCamera() async {
    try {
      await _scanner.switchCamera();
    } catch (_) {
      // Single-camera devices ignore this.
    }
  }

  String _totalWords() {
    if (_counter.isEmpty) return '';
    final settings = ref.read(settingsControllerProvider);
    final engine = ref.read(numberToWordsEngineProvider);
    final language = settings.effectiveTtsLanguage;
    final items = engine.convert(
      _counter.totalItems,
      languageCode: language.code,
      system: settings.numberSystem,
    );
    final amount = engine.fromString(
      ResultFormatter.format(_counter.totalAmount),
      languageCode: language.code,
      system: settings.numberSystem,
    );
    return '$items ${context.tr('scan_items_word')} • $amount';
  }

  Future<void> _speakTotal() async {
    final text = _totalWords();
    if (text.isEmpty) return;
    final settings = ref.read(settingsControllerProvider);
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
      if (mounted) {
        showAppSnack(context, context.tr('voice_unavailable'), error: true);
      }
    }
  }

  void _saveTotal() {
    if (_counter.isEmpty) return;
    final settings = ref.read(settingsControllerProvider);
    saveToolHistory(
      context,
      ref,
      expression:
          'Scan & count • ${_counter.lineCount} lines • '
          '${settings.language.code}',
      result:
          '${_counter.totalItems} ${context.tr('scan_items_word')} • '
          '₹${ResultFormatter.grouped(_counter.totalAmount, system: settings.numberSystem)}',
      value: _counter.totalItems.toDouble(),
    );
  }

  void _clearAll() {
    if (_counter.isEmpty) return;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tr('scan_clear')),
        content: Text(context.tr('history_clear_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(context.tr('cancel')),
          ),
          FilledButton(
            onPressed: () {
              setState(_counter.clear);
              Navigator.of(dialogContext).pop();
            },
            child: Text(context.tr('delete')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('tool_scan_count')),
        actions: [
          IconButton(
            tooltip: context.tr('scan_clear'),
            onPressed: _clearAll,
            icon: const Icon(Icons.delete_sweep_rounded),
          ),
          IconButton(
            tooltip: context.tr('scan_add_manual'),
            onPressed: () => _openItemDialog(),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: SizedBox(
                  height: 240,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      MobileScanner(
                        controller: _scanner,
                        onDetect: _onDetect,
                        errorBuilder: (context, error) =>
                            _CameraError(onManual: () => _openItemDialog()),
                      ),
                      IgnorePointer(
                        child: Center(
                          child: Container(
                            width: 210,
                            height: 130,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.9),
                                width: 2.5,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Row(
                          children: [
                            _CameraButton(
                              icon: _torch
                                  ? Icons.flash_on_rounded
                                  : Icons.flash_off_rounded,
                              tooltip: context.tr('scan_torch'),
                              onTap: _toggleTorch,
                            ),
                            const SizedBox(width: 8),
                            _CameraButton(
                              icon: Icons.cameraswitch_rounded,
                              tooltip: context.tr('scan_switch_camera'),
                              onTap: _switchCamera,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.16),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _TotalBlock(
                            label: context.tr('scan_total_items'),
                            value: '${_counter.totalItems}',
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 42,
                          color: theme.dividerColor,
                        ),
                        Expanded(
                          child: _TotalBlock(
                            label: context.tr('scan_total_amount'),
                            value:
                                '₹${ResultFormatter.grouped(_counter.totalAmount, system: settings.numberSystem)}',
                          ),
                        ),
                      ],
                    ),
                    if (_counter.totalAmount > 0) ...[
                      const SizedBox(height: 8),
                      Text(
                        _totalWords(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _counter.isEmpty ? null : _speakTotal,
                            icon: const Icon(Icons.volume_up_rounded, size: 18),
                            label: Text(
                              context.tr('scan_speak_total'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _counter.isEmpty ? null : _saveTotal,
                            icon: const Icon(
                              Icons.bookmark_add_rounded,
                              size: 18,
                            ),
                            label: Text(
                              context.tr('scan_save'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      context.tr('scan_subtitle'),
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _counter.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.qr_code_scanner_rounded,
                            size: 54,
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            context.tr('scan_empty'),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      itemCount: _counter.items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = _counter.items[index];
                        return _ItemTile(
                          item: item,
                          onIncrement: () =>
                              setState(() => _counter.increment(item.code)),
                          onDecrement: () =>
                              setState(() => _counter.decrement(item.code)),
                          onEdit: () => _openItemDialog(item: item),
                          onRemove: () =>
                              setState(() => _counter.remove(item.code)),
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

class _CameraError extends StatelessWidget {
  const _CameraError({required this.onManual});

  final VoidCallback onManual;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black87,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.no_photography_rounded,
                color: Colors.white70,
                size: 34,
              ),
              const SizedBox(height: 8),
              Text(
                context.tr('scan_camera_error'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.tr('scan_camera_permission'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: onManual,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                ),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(context.tr('scan_add_manual')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CameraButton extends StatelessWidget {
  const _CameraButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.45),
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _TotalBlock extends StatelessWidget {
  const _TotalBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onEdit,
    required this.onRemove,
  });

  final ScannedItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onEdit,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    [
                      item.code,
                      if (item.price != null)
                        '₹${ResultFormatter.format(item.price!)}',
                    ].join(' • '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onDecrement,
            icon: const Icon(Icons.remove_circle_outline_rounded, size: 20),
          ),
          SizedBox(
            width: 26,
            child: Text(
              '${item.quantity}',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onIncrement,
            icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onRemove,
            icon: Icon(
              Icons.close_rounded,
              size: 18,
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }
}
