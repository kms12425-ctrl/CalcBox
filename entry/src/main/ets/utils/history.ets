import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

/**
 * 一条计算历史。
 */
export class HistoryEntry {
  expr: string = '';
  result: string = '';

  constructor(expr: string, result: string) {
    this.expr = expr;
    this.result = result;
  }
}

/** 历史最多保留的条数 */
export const MAX_HISTORY: number = 20;

const STORE_NAME: string = 'calc_history';
const RECORDS_KEY: string = 'records';

function openStore(context: common.Context): preferences.Preferences {
  const options: preferences.Options = { name: STORE_NAME };
  return preferences.getPreferencesSync(context, options);
}

/**
 * 读取历史记录。读取失败或数据损坏时返回空数组，不影响主流程。
 */
export function loadHistory(context: common.Context): HistoryEntry[] {
  try {
    const store: preferences.Preferences = openStore(context);
    const raw: string = store.getSync(RECORDS_KEY, '') as string;
    if (raw === '') {
      return [];
    }
    const parsed: HistoryEntry[] = JSON.parse(raw) as HistoryEntry[];
    return parsed;
  } catch (error) {
    return [];
  }
}

/**
 * 覆盖写入历史记录，超出上限由调用方裁剪。
 */
export function saveHistory(context: common.Context, entries: HistoryEntry[]): void {
  try {
    const store: preferences.Preferences = openStore(context);
    store.putSync(RECORDS_KEY, JSON.stringify(entries));
    store.flush();
  } catch (error) {
    // 持久化失败不应打断计算
  }
}
