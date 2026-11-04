/**
 * 计算器表达式求值。
 *
 * 当前实现基于正则折叠：先把 `50%` 这类写法转成小数，
 * 再循环折叠所有乘除，最后折叠加减，以此近似“先乘除后加减”。
 * 不处理括号，也不校验表达式是否完整。
 */

/**
 * 判断算式末位是否可以追加运算符（末位必须是数字或百分号）。
 */
export function isLastCharNotDigit(operate: string): boolean {
  return !(/\d$/.test(operate) || /%$/.test(operate));
}

/**
 * 求值并返回字符串结果，无法求值时原样返回算式。
 */
export function calculateExpression(operate: string): string {
  operate = operate.replace(/(\d+)%/g, (num) => (parseFloat(num) / 100).toString());

  // Function to handle operations
  const compute = (a: number, b: number, operator: string): number => {
    switch (operator) {
      case '+': return a + b;
      case '-': return a - b;
      case 'x': return a * b;
      case '÷': return a / b;
      default: throw new Error('Invalid operator');
    }
  };

  // Handle multiplication and division first
  const handleMulDiv = (expr: string): string => {
    const regex = /(-?\d+(\.\d+)?)([x÷])(-?\d+(\.\d+)?)/;
    let match : RegExpExecArray | null;
    while ((match = regex.exec(expr)) !== null) {
      const left = parseFloat(match[1]);
      const operator = match[3];
      const right = parseFloat(match[4]);
      const result = compute(left, right, operator);
      expr = expr.replace(match[0], result.toString());
    }
    return expr;
  };

  // Handle addition and subtraction
  const handleAddSub = (expr: string): string => {
    const regex = /(-?\d+(\.\d+)?)([+\-])(-?\d+(\.\d+)?)/;
    let match : RegExpExecArray | null;
    while ((match = regex.exec(expr)) !== null) {
      const left = parseFloat(match[1]);
      const operator = match[3];
      const right = parseFloat(match[4]);
      const result = compute(left, right, operator);
      expr = expr.replace(match[0], result.toString());
    }
    return expr;
  };

  // Process the expression
  let result = handleMulDiv(operate);
  result = handleAddSub(result);

  return result;
}
