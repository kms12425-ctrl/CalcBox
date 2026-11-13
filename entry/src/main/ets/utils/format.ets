/**
 * 数字显示格式化：小数位数与千分位。
 *
 * decimals < 0 表示「自动」：去掉浮点尾巴但不固定位数。
 */
export function addThousands(text: string): string {
  const negative: boolean = text.startsWith('-');
  const body: string = negative ? text.substring(1) : text;
  const dot: number = body.indexOf('.');
  const intPart: string = dot >= 0 ? body.substring(0, dot) : body;
  const fracPart: string = dot >= 0 ? body.substring(dot) : '';
  if (intPart.length === 0) {
    return text;
  }
  let out: string = '';
  for (let i = 0; i < intPart.length; i++) {
    const remaining: number = intPart.length - i;
    out += intPart.charAt(i);
    if (remaining > 1 && (remaining - 1) % 3 === 0) {
      out += ',';
    }
  }
  return (negative ? '-' : '') + out + fracPart;
}

/**
 * 按设置格式化一个数字字符串；无法解析时原样返回。
 */
export function formatNumberText(raw: string, decimals: number, thousands: boolean): string {
  const value: number = Number.parseFloat(raw);
  if (!Number.isFinite(value)) {
    return raw;
  }
  let text: string;
  if (decimals >= 0) {
    text = value.toFixed(decimals);
  } else {
    text = Number(value.toFixed(10)).toString();
  }
  if (thousands) {
    text = addThousands(text);
  }
  return text;
}
