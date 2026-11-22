import 'package:flutter_test/flutter_test.dart';
import 'package:vanicalc/features/gst/domain/financial_calculators.dart';

void main() {
  group('GST', () {
    test('adds GST to an exclusive amount', () {
      final result = FinancialCalculators.addGst(10000, 18);
      expect(result.baseAmount, 10000);
      expect(result.gstAmount, 1800);
      expect(result.totalAmount, 11800);
      expect(result.cgst, 900);
      expect(result.sgst, 900);
      expect(result.igst, 1800);
      expect(result.added, isTrue);
    });

    test('removes GST from an inclusive amount', () {
      final result = FinancialCalculators.removeGst(11800, 18);
      expect(result.baseAmount, closeTo(10000, 1e-9));
      expect(result.gstAmount, closeTo(1800, 1e-9));
      expect(result.totalAmount, 11800);
      expect(result.added, isFalse);
    });

    test('zero rate leaves the amount unchanged', () {
      final result = FinancialCalculators.addGst(500, 0);
      expect(result.gstAmount, 0);
      expect(result.totalAmount, 500);
    });

    test('5 percent slab', () {
      expect(FinancialCalculators.addGst(1000, 5).totalAmount, 1050);
    });

    test('28 percent slab', () {
      expect(FinancialCalculators.addGst(1000, 28).totalAmount, 1280);
    });
  });

  group('discount and profit', () {
    test('discount amount and final price', () {
      expect(FinancialCalculators.discountAmount(2500, 20), 500);
      expect(FinancialCalculators.finalPrice(2500, 20), 2000);
    });

    test('full discount', () {
      expect(FinancialCalculators.finalPrice(999, 100), 0);
    });

    test('profit', () {
      expect(FinancialCalculators.profitAmount(1000, 1250), 250);
      expect(FinancialCalculators.profitPercent(1000, 1250), 25);
    });

    test('loss is negative', () {
      expect(FinancialCalculators.profitAmount(1000, 800), -200);
      expect(FinancialCalculators.profitPercent(1000, 800), -20);
    });
  });

  group('percentage', () {
    test('percent of a value', () {
      expect(FinancialCalculators.percentOf(15, 200), 30);
    });

    test('what percent', () {
      expect(FinancialCalculators.whatPercent(30, 200), 15);
    });

    test('percent change', () {
      expect(FinancialCalculators.percentChange(100, 125), 25);
      expect(FinancialCalculators.percentChange(100, 75), -25);
    });

    test('division by zero is safe', () {
      expect(FinancialCalculators.whatPercent(10, 0), 0);
      expect(FinancialCalculators.percentChange(0, 10), 0);
    });
  });

  group('interest', () {
    test('simple interest', () {
      expect(
        FinancialCalculators.simpleInterest(
          principal: 100000,
          annualRate: 8,
          years: 5,
        ),
        40000,
      );
    });

    test('compound interest', () {
      expect(
        FinancialCalculators.compoundInterest(
          principal: 100000,
          annualRate: 8,
          years: 5,
        ),
        closeTo(46932.81, 0.01),
      );
    });

    test('zero principal yields zero interest', () {
      expect(
        FinancialCalculators.compoundInterest(
          principal: 0,
          annualRate: 10,
          years: 10,
        ),
        0,
      );
    });
  });

  group('EMI', () {
    test('monthly EMI for a home loan', () {
      final result = FinancialCalculators.emi(
        principal: 500000,
        annualRate: 9.5,
        months: 60,
      );
      expect(result.monthlyEmi, closeTo(10500.93, 0.01));
      expect(result.months, 60);
      expect(result.totalPayment, closeTo(result.monthlyEmi * 60, 0.01));
      expect(result.totalInterest, closeTo(result.totalPayment - 500000, 0.01));
    });

    test('zero interest loan splits evenly', () {
      final result = FinancialCalculators.emi(
        principal: 12000,
        annualRate: 0,
        months: 12,
      );
      expect(result.monthlyEmi, 1000);
      expect(result.totalInterest, 0);
    });

    test('invalid tenure is safe', () {
      final result = FinancialCalculators.emi(
        principal: 1000,
        annualRate: 10,
        months: 0,
      );
      expect(result.monthlyEmi, 0);
    });
  });

  group('tip', () {
    test('tip and split', () {
      expect(FinancialCalculators.tipAmount(1200, 10), 120);
      expect(FinancialCalculators.perPerson(1320, 4), 330);
      expect(FinancialCalculators.perPerson(1320, 0), 0);
    });
  });

  group('ratio and fraction', () {
    test('simplifies a ratio', () {
      expect(FinancialCalculators.simplifyRatio(16, 24), '2 : 3');
    });

    test('keeps decimals in ratios', () {
      expect(FinancialCalculators.simplifyRatio(0.5, 1.5), '1 : 3');
    });

    test('fraction to decimal', () {
      expect(FinancialCalculators.fractionValue(3, 8), 0.375);
      expect(FinancialCalculators.fractionValue(1, 0), 0);
    });

    test('simplifies a fraction', () {
      expect(FinancialCalculators.simplifyFraction(6, 8), '3 / 4');
      expect(FinancialCalculators.simplifyFraction(-6, 8), '-3 / 4');
    });
  });

  group('dates', () {
    test('age in years, months and days', () {
      final result = FinancialCalculators.dateDifference(
        DateTime(2000, 1, 15),
        DateTime(2024, 3, 20),
      );
      expect(result.years, 24);
      expect(result.months, 2);
      expect(result.days, 5);
      expect(result.totalDays, greaterThan(8000));
    });

    test('order does not matter', () {
      final forward = FinancialCalculators.dateDifference(
        DateTime(2020, 1, 1),
        DateTime(2021, 1, 1),
      );
      final backward = FinancialCalculators.dateDifference(
        DateTime(2021, 1, 1),
        DateTime(2020, 1, 1),
      );
      expect(forward.totalDays, backward.totalDays);
      expect(forward.years, 1);
    });

    test('same day is zero', () {
      final result = FinancialCalculators.dateDifference(
        DateTime(2024, 5, 5),
        DateTime(2024, 5, 5),
      );
      expect(result.totalDays, 0);
      expect(result.years, 0);
      expect(result.months, 0);
      expect(result.days, 0);
    });
  });
}
