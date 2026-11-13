/**
 * 人民币金额转中文大写。
 *
 * 规则要点：
 * 1. 整数部分按四位分组，组单位依次是 万 / 亿 / 万亿；
 * 2. 组内连续的零只保留一个「零」，整组为零则整组省略；
 * 3. 组与组之间，低位组不足千位时补一个「零」（如 壹亿零壹）；
 * 4. 小数部分按角、分处理，都没有时补「整」。
 */

const DIGITS: string = '零壹贰叁肆伍陆柒捌玖';
const UNITS_WITHIN: string[] = ['', '拾', '佰', '仟'];
const GROUP_UNITS: string[] = ['', '万', '亿', '万亿'];

/** 支持的最大金额（万亿级） */
const MAX_AMOUNT: number = 999999999999.99;

export class RmbResult {
  ok: boolean = false;
  text: string = '';
}

/**
 * 转换整数部分（不含「元」字），0 返回空串。
 */
function convertInteger(value: number): string {
  if (value === 0) {
    return '';
  }
  const digits: string = value.toString();
  const groups: string[] = [];
  let end: number = digits.length;
  while (end > 0) {
    const start: number = Math.max(0, end - 4);
    groups.unshift(digits.substring(start, end));
    end = start;
  }

  let result: string = '';
  for (let i = 0; i < groups.length; i++) {
    const groupText: string = groups[i];
    const groupValue: number = Number.parseInt(groupText, 10);
    const groupUnit: string = GROUP_UNITS[groups.length - 1 - i];
    if (groupValue === 0) {
      continue;
    }
    if (result !== '' && groupValue < 1000) {
      result += '零';
    }
    result += convertGroup(groupText) + groupUnit;
  }
  return result;
}

/**
 * 转换一个四位以内的分组，组内的零只保留一个。
 */
function convertGroup(groupText: string): string {
  let out: string = '';
  let zeroPending: boolean = false;
  for (let i = 0; i < groupText.length; i++) {
    const digit: number = Number.parseInt(groupText.charAt(i), 10);
    const unitIndex: number = groupText.length - 1 - i;
    if (digit === 0) {
      if (out !== '') {
        zeroPending = true;
      }
    } else {
      if (zeroPending) {
        out += '零';
        zeroPending = false;
      }
      out += DIGITS.charAt(digit) + UNITS_WITHIN[unitIndex];
    }
  }
  return out;
}

/**
 * 把金额转成大写。非法输入（负数、超出范围、非数字）返回 ok=false。
 */
export function toRmbUpper(amount: number): RmbResult {
  const result: RmbResult = new RmbResult();
  if (!Number.isFinite(amount) || amount < 0 || amount > MAX_AMOUNT) {
    return result;
  }

  // 先四舍五入到分，避免浮点误差影响角分
  const cents: number = Math.round(amount * 100);
  const integerPart: number = Math.floor(cents / 100);
  const jiao: number = Math.floor(cents % 100 / 10);
  const fen: number = cents % 10;

  let text: string = '';
  if (integerPart > 0) {
    text += convertInteger(integerPart) + '元';
  } else if (jiao === 0 && fen === 0) {
    text = '零元';
  }

  if (jiao === 0 && fen === 0) {
    text += '整';
  } else {
    if (jiao > 0) {
      text += DIGITS.charAt(jiao) + '角';
    }
    if (fen > 0) {
      if (jiao === 0) {
        text += '零';
      }
      text += DIGITS.charAt(fen) + '分';
    }
  }

  result.ok = true;
  result.text = text;
  return result;
}
