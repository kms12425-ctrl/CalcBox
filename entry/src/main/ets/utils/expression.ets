/**
 * 计算器表达式求值。
 *
 * 递归下降解析，文法如下：
 *
 *   expression := term (('+' | '-') term)*
 *   term       := factor (('x' | '÷') factor)*
 *   factor     := ('+' | '-')? (number | '(' expression ')') ('%')?
 *
 * 百分号按计算器惯例解释：作为加减的右操作数时取左侧的百分比，
 * 例如 `200+10%` = 220；其余位置按除以 100 处理，例如 `50%` = 0.5。
 */

/**
 * 求值结果。区分三种情况，避免调用方把“还没输完”和“算不出来”混为一谈。
 */
export class EvalResult {
  /** 是否得到了可显示的结果 */
  ok: boolean = false;
  /** 结果文本，ok 为 true 时有效 */
  value: string = '';
  /** 算式尚未输完（末位是运算符或括号未闭合），此时不应刷新结果 */
  incomplete: boolean = true;
  /** 计算过程出错，例如除以零、括号不匹配、非法字符 */
  failed: boolean = false;
}

/**
 * 判断算式末位是否可以追加运算符：末位必须是数字、百分号或右括号。
 */
export function isLastCharNotDigit(operate: string): boolean {
  return !(/[\d%)]$/.test(operate));
}

/**
 * 判断能否再追加一个小数点：同一段数字内不允许出现第二个小数点，
 * 且不能以小数点开头（紧随运算符或括号时也不允许）。
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

function countChar(text: string, target: string): number {
  let count: number = 0;
  for (let i = 0; i < text.length; i++) {
    if (text.charAt(i) === target) {
      count++;
    }
  }
  return count;
}

/**
 * 解析中间值：pct 表示这个操作数带了百分号，需由上层决定如何解释。
 */
class PVal {
  v: number = 0;
  pct: boolean = false;

  constructor(v: number, pct: boolean) {
    this.v = v;
    this.pct = pct;
  }
}

class Parser {
  private expr: string;
  private pos: number = 0;

  constructor(expr: string) {
    this.expr = expr;
  }

  parse(): number {
    const result: PVal = this.parseExpression();
    const value: number = result.pct ? result.v / 100 : result.v;
    this.skipSpaces();
    if (this.pos < this.expr.length) {
      throw new Error('unexpected trailing characters');
    }
    return value;
  }

  private parseExpression(): PVal {
    let left: PVal = this.parseTerm();
    while (true) {
      this.skipSpaces();
      const op: string = this.peek();
      if (op !== '+' && op !== '-') {
        break;
      }
      this.pos++;
      const right: PVal = this.parseTerm();
      // 右操作数带百分号时取左侧的百分比：200+10% = 200 + 200*10%
      const delta: number = right.pct ? left.v * right.v / 100 : right.v;
      const next: number = op === '+' ? left.v + delta : left.v - delta;
      left = new PVal(next, false);
    }
    return left;
  }

  private parseTerm(): PVal {
    const first: PVal = this.parseFactor();
    let acc: number = first.pct ? first.v / 100 : first.v;
    let hasOperator: boolean = false;
    while (true) {
      this.skipSpaces();
      const op: string = this.peek();
      if (op !== 'x' && op !== '÷') {
        break;
      }
      this.pos++;
      const right: PVal = this.parseFactor();
      const rv: number = right.pct ? right.v / 100 : right.v;
      if (op === 'x') {
        acc = acc * rv;
      } else {
        if (rv === 0) {
          throw new Error('divide by zero');
        }
        acc = acc / rv;
      }
      hasOperator = true;
    }
    if (!hasOperator) {
      return first;
    }
    return new PVal(acc, false);
  }

  private parseFactor(): PVal {
    this.skipSpaces();
    let sign: number = 1;
    const lead: string = this.peek();
    if (lead === '-' || lead === '+') {
      if (lead === '-') {
        sign = -1;
      }
      this.pos++;
      this.skipSpaces();
    }

    const head: string = this.peek();
    let value: number = 0;
    if (head === '(') {
      this.pos++;
      const inner: PVal = this.parseExpression();
      this.skipSpaces();
      if (this.peek() !== ')') {
        throw new Error('unbalanced parenthesis');
      }
      this.pos++;
      value = inner.pct ? inner.v / 100 : inner.v;
    } else {
      value = this.parseNumber();
    }

    this.skipSpaces();
    if (this.peek() === '%') {
      this.pos++;
      return new PVal(value * sign, true);
    }
    return new PVal(value * sign, false);
  }

  private parseNumber(): number {
    const start: number = this.pos;
    while (this.pos < this.expr.length) {
      const ch: string = this.expr.charAt(this.pos);
      const isDigit: boolean = ch >= '0' && ch <= '9';
      if (isDigit || ch === '.') {
        this.pos++;
      } else {
        break;
      }
    }
    if (start === this.pos) {
      throw new Error('number expected');
    }
    const text: string = this.expr.substring(start, this.pos);
    const value: number = Number.parseFloat(text);
    if (Number.isNaN(value)) {
      throw new Error('invalid number');
    }
    return value;
  }

  private peek(): string {
    if (this.pos >= this.expr.length) {
      return '';
    }
    return this.expr.charAt(this.pos);
  }

  private skipSpaces(): void {
    while (this.pos < this.expr.length && this.expr.charAt(this.pos) === ' ') {
      this.pos++;
    }
  }
}

/**
 * 求值并返回字符串结果，空算式返回空串；非法算式抛出异常，由 tryEvaluate 统一处理。
 */
export function calculateExpression(operate: string): string {
  if (operate === '') {
    return '';
  }
  const parser: Parser = new Parser(operate);
  return formatNumber(parser.parse());
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

  // 括号没配平说明算式还没输完
  if (countChar(expr, '(') > countChar(expr, ')')) {
    result.incomplete = true;
    return result;
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
