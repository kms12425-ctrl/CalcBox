import { describe, it, expect } from '@ohos/hypium';
import { calculateExpression, isLastCharNotDigit } from '../main/ets/utils/expression';

export default function expressionTest() {
  describe('expression', () => {
    it('adds_two_integers', 0, () => {
      expect(calculateExpression('1+2')).assertEqual('3');
    });

    it('multiplies_before_adding', 0, () => {
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

    it('treats_percent_as_hundredth', 0, () => {
      expect(calculateExpression('50%')).assertEqual('0.5');
      expect(calculateExpression('7%')).assertEqual('0.07');
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

    it('rejects_operator_after_operator', 0, () => {
      expect(isLastCharNotDigit('1+')).assertTrue();
    });
  });
}
