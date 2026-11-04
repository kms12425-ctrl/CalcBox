/**
 * 计算器表达式求值。
 *
 * 当前实现基于正则折叠：先把 `50%` 这类写法转成小数，
 * 再循环折叠所有乘除，最后折叠加减，以此近似“先乘除后加减”。
 * 不处理括号。
 */

/**
 * 求值结果。区分三种情况，避免调用方把“还没输完”和“算不出来”混为一谈。
 */
export class EvalResult {
  /** 是否得到了可显示的结果 */
  ok: boolean = false;
  /** 结果文本，ok 为 true 时有效 */
  value: string = '';
  /** 算式尚未输完（末位是运算符），此时不应刷新结果 */
  incomplete: boolean = true;
  /** 计算过程出错，例如除以零 */
  failed: boolean = false;
}

/**
 * 判断算式末位是否可以追加运算符（末位必须是数字或百分号）。
 */
export function isLastCharNotDigit(operate: string): boolean {
  return !(/\d$/.test(operate) || /%$/.test(operate));
}

/**
 * 判断能否再追加一个小数点：同一段数字内不允许出现第二个小数点，
 * 且不能以小数点开头（紧随运算符时也不允许）。
 */
export function canAppendDot(operate: string): boolean {
  const match: RegExpMatchArray | null = operate.match(/[\d.]*$/);
  const tail: string = match ? match[0] : '';
  if (tail === '') {
    return false;
  }
  return tail.indexOf('.') < 0;
}

/**
 * 去除浮点误差后再转成字符串，例如 0.30000000000000004 -> 0.3。
 */
function formatNumber(value: number): string {
  const rounded: number = Number(value.toFixed(10));
  return rounded.toString();
}

/**
 * 求值并返回字符串结果。除零时抛出异常，由 tryEvaluate 统一处理。
 */
export function calculateExpression(operate: string): string {
  operate = operate.replace(/(\d+)%/g, (num) => (parseFloat(num) / 100).toString());

  // Function to handle operations
  const compute = (a: number, b: number, operator: string): number => {
    switch (operator) {
      case '+': return a + b;
      case '-': return a - b;
      case 'x': return a * b;
      case '÷':
        if (b === 0) {
          throw new Error('divide by zero');
        }
        return a / b;
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
      expr = expr.replace(match[0], formatNumber(result));
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
      expr = expr.replace(match[0], formatNumber(result));
    }
    return expr;
  };

  // Process the expression
  let result = handleMulDiv(operate);
  result = handleAddSub(result);

  return result;
}

/**
 * 面向界面的求值入口：区分「未输完」「算不出」「有结果」。
 */
export function tryEvaluate(operate: string): EvalResult {
  const result: EvalResult = new EvalResult();

  // 末尾的小数点不参与求值，例如 "1." 按 "1" 处理
  let expr: string = operate;
  while (expr.length > 0 && expr.endsWith('.')) {
    expr = expr.slice(0, -1);
  }

  if (expr === '' || isLastCharNotDigit(expr)) {
    result.incomplete = true;
    return result;
  }

  result.incomplete = false;
  try {
    const text: string = calculateExpression(expr);
    if (text === '' || text.indexOf('Infinity') >= 0 || text.indexOf('NaN') >= 0) {
      result.failed = true;
      return result;
    }
    result.ok = true;
    result.value = text;
  } catch (error) {
    result.failed = true;
  }
  return result;
}
