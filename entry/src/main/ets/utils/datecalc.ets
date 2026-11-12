/**
 * 日期计算：按「自然日」比较与推算，避免时分秒带来的误差。
 */

/** 归一到当天零点 */
export function startOfDay(value: Date): Date {
  return new Date(value.getFullYear(), value.getMonth(), value.getDate());
}

/**
 * 两个日期相差的天数（自然日）。
 * 结束日期早于起始日期时返回负数。
 */
export function daysBetween(from: Date, to: Date): number {
  const a: number = startOfDay(from).getTime();
  const b: number = startOfDay(to).getTime();
  return Math.round((b - a) / 86400000);
}

/**
 * 在基准日期上推进若干天，负数表示往前推。
 */
export function addDays(base: Date, offset: number): Date {
  const result: Date = startOfDay(base);
  result.setDate(result.getDate() + offset);
  return result;
}

/**
 * 格式化为 yyyy-MM-dd。
 */
export function formatDate(value: Date): string {
  const year: string = value.getFullYear().toString();
  const month: string = (value.getMonth() + 1).toString().padStart(2, '0');
  const day: string = value.getDate().toString().padStart(2, '0');
  return `${year}-${month}-${day}`;
}

/**
 * 解析偏移天数，非法输入返回 null。
 */
export function parseOffset(text: string): number | null {
  const trimmed: string = text.trim();
  if (!/^-?\d+$/.test(trimmed)) {
    return null;
  }
  const value: number = Number.parseInt(trimmed, 10);
  if (!Number.isFinite(value) || Math.abs(value) > 36500) {
    return null;
  }
  return value;
}
