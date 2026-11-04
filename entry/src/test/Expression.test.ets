import { describe, it, expect } from '@ohos/hypium';
import { calculateExpression, canAppendDot, isLastCharNotDigit, tryEvaluate } from '../main/ets/utils/expression';

export default function expressionTest() {
  describe('expression', () => {
    it('adds_two_integers', 0, () => {
      expect(calculateExpression('1+2')).assertEqual('3');
    });

    it('multiplies_before_adding', 0, () => {
      expect(calculateExpression('1+2x3')).assertEqual('7');
      expect(calculateExpression('12+3x4')).assertEqual('24');
    });

    it('folds_repeated_division', 0, () => {
      expect(calculateExpression('100÷4÷5')).assertEqual('5');
    });

    it('folds_repeated_subtraction', 0, () => {
      expect(calculateExpression('10-2-3')).assertEqual('5');
    });

    it('handles_decimals', 0, () => {
      expect(calculateExpression('2.5+2.5')).assertEqual('5');
    });

    it('groups_with_parentheses', 0, () => {
      expect(calculateExpression('(1+2)x3')).assertEqual('9');
      expect(calculateExpression('2x(3+4)')).assertEqual('14');
      expect(calculateExpression('((1+2))')).assertEqual('3');
    });

    it('supports_unary_minus', 0, () => {
      expect(calculateExpression('-(2+3)')).assertEqual('-5');
      expect(calculateExpression('5x-2')).assertEqual('-10');
    });

    it('treats_percent_as_hundredth', 0, () => {
      expect(calculateExpression('50%')).assertEqual('0.5');
      expect(calculateExpression('7%')).assertEqual('0.07');
    });

    it('applies_percent_to_left_operand', 0, () => {
      expect(calculateExpression('200+10%')).assertEqual('220');
      expect(calculateExpression('200-10%')).assertEqual('180');
      expect(calculateExpression('10%x50')).assertEqual('5');
    });

    it('returns_empty_for_empty_input', 0, () => {
      expect(calculateExpression('')).assertEqual('');
    });

    it('rejects_operator_after_empty', 0, () => {
      expect(isLastCharNotDigit('')).assertTrue();
    });

    it('allows_operator_after_digit', 0, () => {
      expect(isLastCharNotDigit('1')).assertFalse();
    });

    it('allows_operator_after_percent', 0, () => {
      expect(isLastCharNotDigit('50%')).assertFalse();
    });

    it('allows_operator_after_closing_paren', 0, () => {
      expect(isLastCharNotDigit('(1+2)')).assertFalse();
    });

    it('rejects_operator_after_operator', 0, () => {
      expect(isLastCharNotDigit('1+')).assertTrue();
    });

    it('formats_floating_point_noise', 0, () => {
      expect(calculateExpression('0.1+0.2')).assertEqual('0.3');
      expect(tryEvaluate('0.1+0.2').value).assertEqual('0.3');
    });

    it('reports_incomplete_expression', 0, () => {
      const pending = tryEvaluate('1+');
      expect(pending.ok).assertFalse();
      expect(pending.incomplete).assertTrue();
      expect(pending.failed).assertFalse();
    });

    it('reports_unclosed_parenthesis_as_incomplete', 0, () => {
      const pending = tryEvaluate('(1+2');
      expect(pending.ok).assertFalse();
      expect(pending.incomplete).assertTrue();
      expect(pending.failed).assertFalse();
    });

    it('reports_divide_by_zero', 0, () => {
      const failed = tryEvaluate('5÷0');
      expect(failed.ok).assertFalse();
      expect(failed.incomplete).assertFalse();
      expect(failed.failed).assertTrue();
      expect(tryEvaluate('(1+1)÷(2-2)').failed).assertTrue();
    });

    it('reports_unexpected_closing_paren', 0, () => {
      expect(tryEvaluate('1+)').failed).assertTrue();
    });

    it('evaluates_trailing_dot_as_integer', 0, () => {
      expect(tryEvaluate('1.').value).assertEqual('1');
      expect(tryEvaluate('1.').ok).assertTrue();
    });

    it('allows_dot_only_within_one_number', 0, () => {
      expect(canAppendDot('1')).assertTrue();
      expect(canAppendDot('1.5')).assertFalse();
      expect(canAppendDot('1+2')).assertTrue();
      expect(canAppendDot('')).assertFalse();
      expect(canAppendDot('1+')).assertFalse();
    });
  });
}
