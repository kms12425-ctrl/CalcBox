/**
 * 百分比计算：占比、涨跌幅、折扣价。
 *
 * 统一用 ok 标记是否可计算，避免把 Infinity / NaN 显示到界面上。
 */

export class PercentResult {
  ok: boolean = false;
  value: number = 0;
}

/**
 * A 占 B 的百分比：A / B * 100。B 为 0 时不可计算。
 */
export function shareOf(part: number, total: number): PercentResult {
  const result: PercentResult = new PercentResult();
  if (total === 0) {
    return result;
  }
  result.ok = true;
  result.value = part / total * 100;
  return result;
}

/**
 * 从 A 变化到 B 的幅度：(B - A) / |A| * 100。A 为 0 时不可计算。
 */
export function changeRate(from: number, to: number): PercentResult {
  const result: PercentResult = new PercentResult();
  if (from === 0) {
    return result;
  }
  result.ok = true;
  result.value = (to - from) / Math.abs(from) * 100;
  return result;
}

/**
 * 折扣价：原价 * 折扣百分比 / 100，例如 80 表示八折。
 */
export function discountedPrice(price: number, discountPercent: number): PercentResult {
  const result: PercentResult = new PercentResult();
  if (!Number.isFinite(price) || !Number.isFinite(discountPercent)) {
    return result;
  }
  result.ok = true;
  result.value = price * discountPercent / 100;
  return result;
}

/**
 * 百分比结果格式化：保留两位小数并去掉多余的 0。
 */
export function formatPercent(value: number): string {
  const rounded: number = Number(value.toFixed(2));
  return rounded.toString();
}

/**
 * 金额结果格式化：保留两位小数。
 */
export function formatMoney(value: number): string {
  return value.toFixed(2);
}
