import preferences from '@ohos.data.preferences';
import { common } from '@kit.AbilityKit';

export interface GameRecord {
  winner: string;
  playerScore: number;
  computerScore: number;
  timestamp: number;
}

const STORE_NAME = 'game_history';
const HISTORY_KEY = 'history';
const MAX_RECORDS = 10;

class GameHistoryStore {
  private context: common.UIAbilityContext;

  constructor(ctx: common.UIAbilityContext) {
    this.context = ctx;
  }

  private async getStore(): Promise<preferences.Preferences> {
    if (!this.context) {
      return Promise.reject(new Error('GameHistoryStore not initialized'));
    }
    return preferences.getPreferences(this.context, STORE_NAME);
  }

  async saveGame(winner: string, playerScore: number, computerScore: number): Promise<void> {
    const store = await this.getStore();
    const raw = await store.get(HISTORY_KEY, '[]') as string;
    const history: GameRecord[] = JSON.parse(raw) as GameRecord[];
    const record: GameRecord = { winner, playerScore, computerScore, timestamp: Date.now() };
    history.unshift(record);
    if (history.length > MAX_RECORDS) {
      history.splice(MAX_RECORDS);
    }
    await store.put(HISTORY_KEY, JSON.stringify(history));
    await store.flush();
  }

  async getHistory(): Promise<GameRecord[]> {
    const store = await this.getStore();
    const raw = await store.get(HISTORY_KEY, '[]') as string;
    return JSON.parse(raw) as GameRecord[];
  }
}

let storeInstance: GameHistoryStore | null = null;

export function initGameHistoryStore(ctx: common.UIAbilityContext): void {
  storeInstance = new GameHistoryStore(ctx);
}

export async function saveGame(winner: string, playerScore: number, computerScore: number): Promise<void> {
  if (!storeInstance) {
    throw new Error('GameHistoryStore not initialized');
  }
  return storeInstance.saveGame(winner, playerScore, computerScore);
}

export async function getHistory(): Promise<GameRecord[]> {
  if (!storeInstance) {
    throw new Error('GameHistoryStore not initialized');
  }
  return storeInstance.getHistory();
}