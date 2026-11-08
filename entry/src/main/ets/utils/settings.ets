import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

/**
 * 应用设置的键值存取。
 * 与计算历史分开存放，避免两类数据互相覆盖。
 */

const STORE_NAME: string = 'app_settings';

/** 昵称 */
export const KEY_NICKNAME: string = 'nickname';
/** 字号偏好：S / M / L */
export const KEY_FONT_SCALE: string = 'font_scale';

/** AppStorage 中共享给首页的键名 */
export const STORAGE_NICKNAME: string = 'nickname';

function openStore(context: common.Context): preferences.Preferences {
  const options: preferences.Options = { name: STORE_NAME };
  return preferences.getPreferencesSync(context, options);
}

/**
 * 读取字符串设置，读取失败时返回默认值。
 */
export function loadSetting(context: common.Context, key: string, defaultValue: string): string {
  try {
    const store: preferences.Preferences = openStore(context);
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
    const store: preferences.Preferences = openStore(context);
    store.putSync(key, value);
    store.flush();
  } catch (error) {
    // 忽略持久化异常
  }
}
