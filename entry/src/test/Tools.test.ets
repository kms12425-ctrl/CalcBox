import { describe, it, expect } from '@ohos/hypium';
import { parseRadix, toRadix } from '../main/ets/utils/radix';
import { UNIT_CATEGORIES, UnitCategory, convertValue, formatResult } from '../main/ets/utils/units';
import { addDays, daysBetween, formatDate, parseOffset } from '../main/ets/utils/datecalc';
import { changeRate, discountedPrice, formatMoney, formatPercent, shareOf } from '../main/ets/utils/percent';
import { toRmbUpper } from '../main/ets/utils/rmb';
import { addThousands, formatNumberText } from '../main/ets/utils/format';

export default function toolsTest() {
  describe('radix', () => {
    it('parses_each_base', 0, () => {
      expect(parseRadix('255', 10).value).assertEqual(255);
      expect(parseRadix('FF', 16).value).assertEqual(255);
      expect(parseRadix('0xFF', 16).value).assertEqual(255);
      expect(parseRadix('11111111', 2).value).assertEqual(255);
      expect(parseRadix('0o10', 8).value).assertEqual(8);
    });

    it('rejects_digits_outside_base', 0, () => {
      const octal: boolean = parseRadix('8', 8).invalid;
      expect(octal).assertTrue();
      expect(parseRadix('12', 2).invalid).assertTrue();
      expect(parseRadix('G1', 16).invalid).assertTrue();
    });

    it('distinguishes_empty_and_invalid', 0, () => {
      expect(parseRadix('', 10).ok).assertFalse();
      expect(parseRadix('', 10).invalid).assertFalse();
    });

    it('formats_with_prefix', 0, () => {
      expect(toRadix(255, 16)).assertEqual('0xFF');
      expect(toRadix(5, 2)).assertEqual('0b101');
      expect(toRadix(8, 8)).assertEqual('0o10');
      expect(toRadix(-10, 10)).assertEqual('-10');
    });
  });

  describe('units', () => {
    it('converts_length', 0, () => {
      const length: UnitCategory = UNIT_CATEGORIES[0];
      // 索引顺序：mm, cm, m, km, in, ft
      expect(convertValue(length, 2, 1, 1)).assertEqual(100);
      expect(convertValue(length, 1, 2, 100)).assertEqual(1);
      expect(convertValue(length, 3, 2, 1)).assertEqual(1000);
    });

    it('converts_temperature_with_offset', 0, () => {
      const temp: UnitCategory = UNIT_CATEGORIES[2];
      // 索引顺序：℃, ℉, K
      expect(formatResult(convertValue(temp, 0, 1, 0))).assertEqual('32');
      expect(formatResult(convertValue(temp, 0, 1, 100))).assertEqual('212');
      expect(formatResult(convertValue(temp, 0, 2, 0))).assertEqual('273.15');
    });

    it('normalizes_float_noise', 0, () => {
      expect(formatResult(0.1 + 0.2)).assertEqual('0.3');
    });
  });

  describe('datecalc', () => {
    it('counts_days_between', 0, () => {
      expect(daysBetween(new Date(2026, 0, 1), new Date(2026, 0, 31))).assertEqual(30);
      expect(daysBetween(new Date(2026, 0, 31), new Date(2026, 0, 1))).assertEqual(-30);
    });

    it('adds_days_across_month', 0, () => {
      expect(formatDate(addDays(new Date(2026, 0, 31), 1))).assertEqual('2026-02-01');
      expect(formatDate(addDays(new Date(2026, 0, 1), -1))).assertEqual('2025-12-31');
    });

    it('parses_offset', 0, () => {
      expect(parseOffset('7')).assertEqual(7);
      expect(parseOffset('-3')).assertEqual(-3);
    });

    it('rejects_invalid_offset', 0, () => {
      expect(parseOffset('1.5') === null).assertTrue();
      expect(parseOffset('abc') === null).assertTrue();
    });
  });

  describe('percent', () => {
    it('computes_share', 0, () => {
      expect(shareOf(25, 200).value).assertEqual(12.5);
      expect(formatPercent(shareOf(1, 3).value)).assertEqual('33.33');
    });

    it('rejects_zero_divisor', 0, () => {
      expect(shareOf(1, 0).ok).assertFalse();
      expect(changeRate(0, 5).ok).assertFalse();
    });

    it('computes_change_and_discount', 0, () => {
      expect(changeRate(100, 120).value).assertEqual(20);
      expect(changeRate(100, 80).value).assertEqual(-20);
      expect(discountedPrice(200, 80).value).assertEqual(160);
      expect(formatMoney(discountedPrice(200, 80).value)).assertEqual('160.00');
    });
  });

  describe('rmb', () => {
    it('handles_integers', 0, () => {
      expect(toRmbUpper(0).text).assertEqual('零元整');
      expect(toRmbUpper(10).text).assertEqual('壹拾元整');
      expect(toRmbUpper(1000).text).assertEqual('壹仟元整');
      expect(toRmbUpper(1234).text).assertEqual('壹仟贰佰叁拾肆元整');
    });

    it('inserts_zero_between_groups', 0, () => {
      expect(toRmbUpper(10001).text).assertEqual('壹万零壹元整');
      expect(toRmbUpper(100000001).text).assertEqual('壹亿零壹元整');
    });

    it('handles_jiao_and_fen', 0, () => {
      expect(toRmbUpper(1234.56).text).assertEqual('壹仟贰佰叁拾肆元伍角陆分');
      expect(toRmbUpper(0.5).text).assertEqual('伍角');
      expect(toRmbUpper(1.05).text).assertEqual('壹元零伍分');
      expect(toRmbUpper(2).text).assertEqual('贰元整');
    });

    it('rejects_invalid_amount', 0, () => {
      expect(toRmbUpper(-1).ok).assertFalse();
      expect(toRmbUpper(1e13).ok).assertFalse();
    });
  });

  describe('format', () => {
    it('adds_thousands_separator', 0, () => {
      expect(addThousands('1234567')).assertEqual('1,234,567');
      expect(addThousands('-1234.5')).assertEqual('-1,234.5');
      expect(addThousands('99')).assertEqual('99');
    });

    it('applies_decimals_and_grouping', 0, () => {
      expect(formatNumberText('1234.5', 2, true)).assertEqual('1,234.50');
      expect(formatNumberText('1234.5', -1, false)).assertEqual('1234.5');
      expect(formatNumberText('0.30000000000000004', 2, false)).assertEqual('0.30');
    });
  });
}
