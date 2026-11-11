/**
 * 单位换算的静态数据与换算逻辑。
 *
 * 每个单位用「倍率 + 偏移」描述到基准单位的关系：
 *   base = value * factor + offset
 * 长度/重量/面积用倍率即可（offset = 0），温度需要偏移。
 */

export class UnitDef {
  /** 单位符号，跨语言通用，不需要翻译 */
  symbol: string = '';
  /** 相对基准单位的倍率 */
  factor: number = 1;
  /** 相对基准单位的偏移（温度专用） */
  offset: number = 0;

  constructor(symbol: string, factor: number, offset: number = 0) {
    this.symbol = symbol;
    this.factor = factor;
    this.offset = offset;
  }
}

export class UnitCategory {
  key: string = '';
  /** 分类名的资源键，运行时按当前语言解析 */
  resName: string = '';
  units: UnitDef[] = [];

  constructor(key: string, resName: string, units: UnitDef[]) {
    this.key = key;
    this.resName = resName;
    this.units = units;
  }
}

const LENGTH_UNITS: UnitDef[] = [
  new UnitDef('mm', 0.001),
  new UnitDef('cm', 0.01),
  new UnitDef('m', 1),
  new UnitDef('km', 1000),
  new UnitDef('in', 0.0254),
  new UnitDef('ft', 0.3048)
];

const WEIGHT_UNITS: UnitDef[] = [
  new UnitDef('g', 0.001),
  new UnitDef('kg', 1),
  new UnitDef('t', 1000),
  new UnitDef('lb', 0.45359237),
  new UnitDef('oz', 0.028349523125)
];

/** 温度以摄氏度为基准 */
const TEMPERATURE_UNITS: UnitDef[] = [
  new UnitDef('℃', 1, 0),
  new UnitDef('℉', 5 / 9, -32 * 5 / 9),
  new UnitDef('K', 1, -273.15)
];

const AREA_UNITS: UnitDef[] = [
  new UnitDef('cm²', 0.0001),
  new UnitDef('m²', 1),
  new UnitDef('ha', 10000),
  new UnitDef('km²', 1000000),
  new UnitDef('ft²', 0.09290304)
];

export const UNIT_CATEGORIES: UnitCategory[] = [
  new UnitCategory('length', 'unit_length', LENGTH_UNITS),
  new UnitCategory('weight', 'unit_weight', WEIGHT_UNITS),
  new UnitCategory('temperature', 'unit_temperature', TEMPERATURE_UNITS),
  new UnitCategory('area', 'unit_area', AREA_UNITS)
];

/**
 * 在同一分类内换算：先折算到基准单位，再折算到目标单位。
 */
export function convertValue(category: UnitCategory, fromIndex: number,
                             toIndex: number, value: number): number {
  const from: UnitDef = category.units[fromIndex];
  const to: UnitDef = category.units[toIndex];
  const base: number = value * from.factor + from.offset;
  return (base - to.offset) / to.factor;
}

/**
 * 结果格式化：去掉浮点尾巴，过大或过小时退回科学计数法的可读形式。
 */
export function formatResult(value: number): string {
  if (!Number.isFinite(value)) {
    return '-';
  }
  const rounded: number = Number(value.toFixed(6));
  if (Math.abs(rounded) >= 1e12) {
    return rounded.toExponential(4);
  }
  return rounded.toString();
}
