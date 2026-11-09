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

    it('evaluates_trig_in_degrees', 0, () => {
      expect(calculateExpression('sin(30)', true)).assertEqual('0.5');
      expect(calculateExpression('cos(60)', true)).assertEqual('0.5');
      expect(calculateExpression('tan(45)', true)).assertEqual('1');
    });

    it('evaluates_trig_in_radians', 0, () => {
      expect(calculateExpression('sin(π÷2)', false)).assertEqual('1');
      expect(calculateExpression('cos(0)', false)).assertEqual('1');
    });

    it('evaluates_logarithms', 0, () => {
      expect(calculateExpression('ln(1)', false)).assertEqual('0');
      expect(calculateExpression('log(100)', false)).assertEqual('2');
    });

    it('evaluates_square_root', 0, () => {
      expect(calculateExpression('√9', false)).assertEqual('3');
      expect(calculateExpression('√(9+7)', false)).assertEqual('4');
    });

    it('evaluates_pi', 0, () => {
      expect(calculateExpression('π', false)).assertEqual('3.1415926536');
    });

    it('supports_implicit_multiplication', 0, () => {
      expect(calculateExpression('2π', false)).assertEqual('6.2831853072');
      expect(calculateExpression('2(3+4)', false)).assertEqual('14');
      expect(calculateExpression('2sin(30)', true)).assertEqual('1');
    });

    it('reports_function_domain_errors', 0, () => {
      expect(tryEvaluate('ln(0)', false).failed).assertTrue();
      expect(tryEvaluate('√-4', false).failed).assertTrue();
      // tan(90°) 溢出，按不可计算处理
      expect(tryEvaluate('tan(90)', true).failed).assertTrue();
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

    it('allows_operator_after_closing_paren_and_pi', 0, () => {
      expect(isLastCharNotDigit('(1+2)')).assertFalse();
      expect(isLastCharNotDigit('π')).assertFalse();
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
