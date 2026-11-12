/**
 * 进制转换：解析与格式化。
 *
 * 用正则校验每个字符是否属于目标进制，比 parseInt 更早发现非法输入；
 * 支持前置 0x / 0b / 0o 与正负号，最大支持 2^53-1（Number 的安全整数范围）。
 */

export class RadixResult {
  ok: boolean = false;
  value: number = 0;
  /** 输入非空但不合法时为 true，用于区分「空」与「错」 */
  invalid: boolean = false;
}

const MAX_SAFE: number = 9007199254740991;

const PATTERNS: string[] = [
  '^[01]+$',          // 2
  '^[0-7]+$',         // 8
  '^[0-9]+$',         // 10
  '^[0-9a-fA-F]+$'    // 16
];

/** 把进制映射到校验表下标，只接受 2/8/10/16 */
function patternIndex(base: number): number {
  if (base === 2) {
    return 0;
  }
  if (base === 8) {
    return 1;
  }
  if (base === 10) {
    return 2;
  }
  return 3;
}

/**
 * 解析输入文本。空输入返回 ok=false 且 invalid=false；非法字符返回 invalid=true。
 */
export function parseRadix(text: string, base: number): RadixResult {
  const result: RadixResult = new RadixResult();
  let cleaned: string = text.trim();
  if (cleaned === '') {
    return result;
  }

  let negative: boolean = false;
  if (cleaned.startsWith('-')) {
    negative = true;
    cleaned = cleaned.substring(1);
  } else if (cleaned.startsWith('+')) {
    cleaned = cleaned.substring(1);
  }

  // 去掉与当前进制匹配的前缀
  const lower: string = cleaned.toLowerCase();
  if (base === 16 && lower.startsWith('0x')) {
    cleaned = cleaned.substring(2);
  } else if (base === 2 && lower.startsWith('0b')) {
    cleaned = cleaned.substring(2);
  } else if (base === 8 && lower.startsWith('0o')) {
    cleaned = cleaned.substring(2);
  }

  if (cleaned === '') {
    return result;
  }

  const pattern: RegExp = new RegExp(PATTERNS[patternIndex(base)]);
  if (!pattern.test(cleaned)) {
    result.invalid = true;
    return result;
  }

  const value: number = Number.parseInt(cleaned, base);
  if (!Number.isFinite(value) || value > MAX_SAFE) {
    result.invalid = true;
    return result;
  }

  result.ok = true;
  result.value = negative ? -value : value;
  return result;
}

/**
 * 把数值格式化为指定进制的字符串（含前缀，16 进制大写）。
 */
export function toRadix(value: number, base: number): string {
  if (!Number.isFinite(value)) {
    return '-';
  }
  const negative: boolean = value < 0;
  const abs: number = Math.abs(value);
  const digits: string = abs.toString(base).toUpperCase();
  const sign: string = negative ? '-' : '';
  if (base === 16) {
    return sign + '0x' + digits;
  }
  if (base === 2) {
    return sign + '0b' + digits;
  }
  if (base === 8) {
    return sign + '0o' + digits;
  }
  return sign + digits;
}
