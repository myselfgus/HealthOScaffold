import { mkdir, appendFile } from 'node:fs/promises';
import { dirname } from 'node:path';
import type { StewardLLMInvocationLog } from './types.js';

export async function appendInvocationLog(path: string, row: StewardLLMInvocationLog): Promise<void> {
  await mkdir(dirname(path), { recursive: true });
  await appendFile(path, JSON.stringify(row) + '\n', 'utf8');
}
