import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

/**
 * 应用设置：键值存储 + 类型化读写。
 *
 * 与计算历史分开存放；缺省值集中导出，页面直接引用，避免两处不一致。
 */

const STORE_NAME: string = 'app_settings';

/** 昵称，首页问候语使用 */
export const KEY_NICKNAME: string = 'nickname';
/** 三角函数是否按角度制计算 */
export const KEY_ANGLE_DEGREES: string = 'angle_degrees';
/** 结果显示的小数位数，-1 表示自动 */
export const KEY_DECIMALS: string = 'decimals';
/** 结果是否使用千分位 */
export const KEY_THOUSANDS: string = 'thousands';

/** AppStorage 中共享给首页的键名 */
export const STORAGE_NICKNAME: string = 'nickname';

export const DEFAULT_ANGLE_DEGREES: boolean = true;
export const DEFAULT_DECIMALS: number = -1;
export const DEFAULT_THOUSANDS: boolean = false;

/**
 * 读取字符串设置，读取失败时返回默认值。
 */
export function loadSetting(context: common.Context, key: string, defaultValue: string): string {
  try {
    const options: preferences.Options = { name: STORE_NAME };
    const store: preferences.Preferences = preferences.getPreferencesSync(context, options);
    return store.getSync(key, defaultValue) as string;
  } catch (error) {
    return defaultValue;
  }
}

/**
 * 写入字符串设置，持久化失败不打断界面流程。
 */
export function saveSetting(context: common.Context, key: string, value: string): void {
  try {
    const options: preferences.Options = { name: STORE_NAME };
    const store: preferences.Preferences = preferences.getPreferencesSync(context, options);
    store.putSync(key, value);
    store.flush();
  } catch (error) {
    // 忽略持久化异常
  }
}

export function loadBool(context: common.Context, key: string, defaultValue: boolean): boolean {
  return loadSetting(context, key, defaultValue ? '1' : '0') === '1';
}

export function saveBool(context: common.Context, key: string, value: boolean): void {
  saveSetting(context, key, value ? '1' : '0');
}

export function loadNumber(context: common.Context, key: string, defaultValue: number): number {
  const parsed: number = Number.parseInt(loadSetting(context, key, defaultValue.toString()), 10);
  return Number.isNaN(parsed) ? defaultValue : parsed;
}

export function saveNumber(context: common.Context, key: string, value: number): void {
  saveSetting(context, key, value.toString());
}
