import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app_providers.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/result_formatter.dart';
import '../../../shared/voice_input.dart';
import '../../gst/domain/financial_calculators.dart';
import '../widgets/tool_widgets.dart';

String _money(BuildContext context, WidgetRef ref, double value) {
  final settings = ref.read(settingsControllerProvider);
  return '₹ ${ResultFormatter.grouped(value, system: settings.numberSystem)}';
}

String _words(BuildContext context, WidgetRef ref, double value) {
  final settings = ref.read(settingsControllerProvider);
  return ref.read(numberToWordsEngineProvider).fromString(
        ResultFormatter.format(value),
        languageCode: settings.language.code,
        system: settings.numberSystem,
        currency: true,
      );
}

Widget _invalid(BuildContext context) => Text(
      context.tr('invalid_input'),
      style: TextStyle(color: Theme.of(context).colorScheme.error),
    );

/// Discount calculator.
class DiscountScreen extends ConsumerStatefulWidget {
  const DiscountScreen({super.key});

  @override
  ConsumerState<DiscountScreen> createState() => _DiscountScreenState();
}

class _DiscountScreenState extends ConsumerState<DiscountScreen> {
  final TextEditingController _price = TextEditingController(text: '2500');
  final TextEditingController _percent = TextEditingController(text: '20');

  @override
  void dispose() {
    _price.dispose();
    _percent.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final price = double.tryParse(_price.text.trim());
    final percent = double.tryParse(_percent.text.trim());
    final invalid =
        price == null || percent == null || price < 0 || percent < 0 || percent > 100;

    return ToolPage(
      title: context.tr('tool_discount'),
      children: [
        ToolField(
          controller: _price,
          label: context.tr('amount'),
          prefix: '₹ ',
          onChanged: (_) => setState(() {}),
          allowVoice: true,
          onVoice: () async {
            final value = await captureSpokenNumber(context, ref);
            if (value == null) return;
            setState(() => _price.text = ResultFormatter.format(value));
          },
        ),
        ToolField(
          controller: _percent,
          label: context.tr('discount'),
          suffix: '%',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 4),
        if (invalid)
          _invalid(context)
        else
          _result(context, price, percent),
      ],
    );
  }

  Widget _result(BuildContext context, double price, double percent) {
    final saved = FinancialCalculators.discountAmount(price, percent);
    final finalPrice = FinancialCalculators.finalPrice(price, percent);
    final words = _words(context, ref, finalPrice);
    return ToolResultCard(
      rows: [
        ToolRowData(context.tr('discount_result'), _money(context, ref, saved)),
        ToolRowData(
          context.tr('final_price'),
          _money(context, ref, finalPrice),
          emphasized: true,
        ),
      ],
      words: words,
      onSpeak: () => speakWithSettings(context, ref, words),
      onCopy: () => copyWithFeedback(
        context,
        ref,
        '${_price.text} − ${_percent.text}% = ${_money(context, ref, finalPrice)}',
      ),
      onSave: () => saveToolHistory(
        context,
        ref,
        expression: '${_price.text} − ${_percent.text}%',
        result: _money(context, ref, finalPrice),
        value: finalPrice,
      ),
    );
  }
}

/// Profit and loss calculator.
class ProfitLossScreen extends ConsumerStatefulWidget {
  const ProfitLossScreen({super.key});

  @override
  ConsumerState<ProfitLossScreen> createState() => _ProfitLossScreenState();
}

class _ProfitLossScreenState extends ConsumerState<ProfitLossScreen> {
  final TextEditingController _cost = TextEditingController(text: '1000');
  final TextEditingController _selling = TextEditingController(text: '1250');

  @override
  void dispose() {
    _cost.dispose();
    _selling.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cost = double.tryParse(_cost.text.trim());
    final selling = double.tryParse(_selling.text.trim());
    final invalid = cost == null || selling == null || cost <= 0;

    return ToolPage(
      title: context.tr('tool_profit_loss'),
      children: [
        ToolField(
          controller: _cost,
          label: context.tr('cost_price'),
          prefix: '₹ ',
          onChanged: (_) => setState(() {}),
        ),
        ToolField(
          controller: _selling,
          label: context.tr('selling_price'),
          prefix: '₹ ',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 4),
        if (invalid)
          _invalid(context)
        else
          _result(context, cost, selling),
      ],
    );
  }

  Widget _result(BuildContext context, double cost, double selling) {
    final difference = FinancialCalculators.profitAmount(cost, selling);
    final percent = FinancialCalculators.profitPercent(cost, selling);
    final isProfit = difference >= 0;
    final words = _words(context, ref, difference.abs());
    return ToolResultCard(
      rows: [
        ToolRowData(
          isProfit ? context.tr('profit') : context.tr('loss'),
          _money(context, ref, difference.abs()),
          emphasized: true,
        ),
        ToolRowData(
          isProfit ? context.tr('profit_percent') : context.tr('loss_percent'),
          '${percent.abs().toStringAsFixed(2)} %',
        ),
      ],
      words: words,
      onSpeak: () => speakWithSettings(context, ref, words),
      onCopy: () => copyWithFeedback(
        context,
        ref,
        '${isProfit ? 'Profit' : 'Loss'}: ${_money(context, ref, difference.abs())}',
      ),
      onSave: () => saveToolHistory(
        context,
        ref,
        expression: '${_cost.text} → ${_selling.text}',
        result: '${isProfit ? '+' : '-'}${_money(context, ref, difference.abs())}',
        value: difference,
      ),
    );
  }
}

/// Loan EMI calculator.
class EmiScreen extends ConsumerStatefulWidget {
  const EmiScreen({super.key});

  @override
  ConsumerState<EmiScreen> createState() => _EmiScreenState();
}

class _EmiScreenState extends ConsumerState<EmiScreen> {
  final TextEditingController _principal = TextEditingController(text: '500000');
  final TextEditingController _rate = TextEditingController(text: '9.5');
  final TextEditingController _months = TextEditingController(text: '60');

  @override
  void dispose() {
    _principal.dispose();
    _rate.dispose();
    _months.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final principal = double.tryParse(_principal.text.trim());
    final rate = double.tryParse(_rate.text.trim());
    final months = int.tryParse(_months.text.trim());
    final invalid =
        principal == null || rate == null || months == null || principal <= 0 || months <= 0;

    return ToolPage(
      title: context.tr('tool_emi'),
      children: [
        ToolField(
          controller: _principal,
          label: context.tr('loan_amount'),
          prefix: '₹ ',
          onChanged: (_) => setState(() {}),
          allowVoice: true,
          onVoice: () async {
            final value = await captureSpokenNumber(context, ref);
            if (value == null) return;
            setState(() => _principal.text = ResultFormatter.format(value));
          },
        ),
        ToolField(
          controller: _rate,
          label: context.tr('annual_rate'),
          suffix: '%',
          onChanged: (_) => setState(() {}),
        ),
        ToolField(
          controller: _months,
          label: context.tr('tenure_months'),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 4),
        if (invalid)
          _invalid(context)
        else
          _result(context, principal, rate, months),
      ],
    );
  }

  Widget _result(
    BuildContext context,
    double principal,
    double rate,
    int months,
  ) {
    final result = FinancialCalculators.emi(
      principal: principal,
      annualRate: rate,
      months: months,
    );
    final words = _words(context, ref, result.monthlyEmi);
    return ToolResultCard(
      rows: [
        ToolRowData(
          context.tr('monthly_emi'),
          _money(context, ref, result.monthlyEmi),
          emphasized: true,
        ),
        ToolRowData(
          context.tr('total_interest'),
          _money(context, ref, result.totalInterest),
        ),
        ToolRowData(
          context.tr('total_payment'),
          _money(context, ref, result.totalPayment),
        ),
      ],
      words: words,
      onSpeak: () => speakWithSettings(context, ref, words),
      onCopy: () => copyWithFeedback(
        context,
        ref,
        'EMI: ${_money(context, ref, result.monthlyEmi)}',
      ),
      onSave: () => saveToolHistory(
        context,
        ref,
        expression: 'EMI ₹${_principal.text} @ ${_rate.text}% × ${_months.text}m',
        result: _money(context, ref, result.monthlyEmi),
        value: result.monthlyEmi,
      ),
    );
  }
}

/// Simple and compound interest calculator.
class InterestScreen extends ConsumerStatefulWidget {
  const InterestScreen({super.key});

  @override
  ConsumerState<InterestScreen> createState() => _InterestScreenState();
}

class _InterestScreenState extends ConsumerState<InterestScreen> {
  final TextEditingController _principal = TextEditingController(text: '100000');
  final TextEditingController _rate = TextEditingController(text: '8');
  final TextEditingController _years = TextEditingController(text: '5');
  bool _compound = false;

  @override
  void dispose() {
    _principal.dispose();
    _rate.dispose();
    _years.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final principal = double.tryParse(_principal.text.trim());
    final rate = double.tryParse(_rate.text.trim());
    final years = double.tryParse(_years.text.trim());
    final invalid = principal == null || rate == null || years == null || principal < 0;

    return ToolPage(
      title: context.tr('tool_simple_interest'),
      children: [
        SegmentedButton<bool>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(value: false, label: Text(context.tr('simple'))),
            ButtonSegment(value: true, label: Text(context.tr('compound'))),
          ],
          selected: {_compound},
          onSelectionChanged: (selection) =>
              setState(() => _compound = selection.first),
        ),
        const SizedBox(height: 16),
        ToolField(
          controller: _principal,
          label: context.tr('principal'),
          prefix: '₹ ',
          onChanged: (_) => setState(() {}),
        ),
        ToolField(
          controller: _rate,
          label: context.tr('annual_rate'),
          suffix: '%',
          onChanged: (_) => setState(() {}),
        ),
        ToolField(
          controller: _years,
          label: context.tr('years'),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 4),
        if (invalid)
          _invalid(context)
        else
          _result(context, principal, rate, years),
      ],
    );
  }

  Widget _result(
    BuildContext context,
    double principal,
    double rate,
    double years,
  ) {
    final interest = _compound
        ? FinancialCalculators.compoundInterest(
            principal: principal,
            annualRate: rate,
            years: years,
          )
        : FinancialCalculators.simpleInterest(
            principal: principal,
            annualRate: rate,
            years: years,
          );
    final total = principal + interest;
    final words = _words(context, ref, total);
    return ToolResultCard(
      rows: [
        ToolRowData(
          context.tr('interest'),
          _money(context, ref, interest),
          emphasized: true,
        ),
        ToolRowData(context.tr('total_amount'), _money(context, ref, total)),
      ],
      words: words,
      onSpeak: () => speakWithSettings(context, ref, words),
      onCopy: () => copyWithFeedback(
        context,
        ref,
        '${_compound ? 'Compound' : 'Simple'} interest: ${_money(context, ref, interest)}',
      ),
      onSave: () => saveToolHistory(
        context,
        ref,
        expression:
            '${_compound ? 'CI' : 'SI'} ₹${_principal.text} @ ${_rate.text}% × ${_years.text}y',
        result: _money(context, ref, interest),
        value: interest,
      ),
    );
  }
}

/// Tip split calculator.
class TipScreen extends ConsumerStatefulWidget {
  const TipScreen({super.key});

  @override
  ConsumerState<TipScreen> createState() => _TipScreenState();
}

class _TipScreenState extends ConsumerState<TipScreen> {
  final TextEditingController _bill = TextEditingController(text: '1200');
  final TextEditingController _percent = TextEditingController(text: '10');
  final TextEditingController _people = TextEditingController(text: '4');

  @override
  void dispose() {
    _bill.dispose();
    _percent.dispose();
    _people.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bill = double.tryParse(_bill.text.trim());
    final percent = double.tryParse(_percent.text.trim());
    final people = int.tryParse(_people.text.trim());
    final invalid = bill == null ||
        percent == null ||
        people == null ||
        bill < 0 ||
        percent < 0 ||
        people <= 0;

    return ToolPage(
      title: context.tr('tool_tip'),
      children: [
        ToolField(
          controller: _bill,
          label: context.tr('bill_amount'),
          prefix: '₹ ',
          onChanged: (_) => setState(() {}),
        ),
        ToolField(
          controller: _percent,
          label: context.tr('tip_percent'),
          suffix: '%',
          onChanged: (_) => setState(() {}),
        ),
        ToolField(
          controller: _people,
          label: context.tr('people'),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 4),
        if (invalid)
          _invalid(context)
        else
          _result(context, bill, percent, people),
      ],
    );
  }

  Widget _result(BuildContext context, double bill, double percent, int people) {
    final tip = FinancialCalculators.tipAmount(bill, percent);
    final total = bill + tip;
    final perPerson = FinancialCalculators.perPerson(total, people);
    final words = _words(context, ref, total);
    return ToolResultCard(
      rows: [
        ToolRowData(context.tr('tip_amount'), _money(context, ref, tip)),
        ToolRowData(
          context.tr('total'),
          _money(context, ref, total),
          emphasized: true,
        ),
        ToolRowData(context.tr('per_person'), _money(context, ref, perPerson)),
      ],
      words: words,
      onSpeak: () => speakWithSettings(context, ref, words),
      onCopy: () => copyWithFeedback(
        context,
        ref,
        'Tip: ${_money(context, ref, tip)} • Total: ${_money(context, ref, total)}',
      ),
      onSave: () => saveToolHistory(
        context,
        ref,
        expression: 'Tip ${_percent.text}% on ${_bill.text}',
        result: _money(context, ref, total),
        value: total,
      ),
    );
  }
}
