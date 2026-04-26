import { mkdir, appendFile } from 'node:fs/promises';
import { dirname } from 'node:path';
import type { StewardModelInvocationLog } from './types.js';

export async function appendInvocationLog(path: string, row: StewardModelInvocationLog): Promise<void> {
  await mkdir(dirname(path), { recursive: true });
  await appendFile(path, JSON.stringify(row) + '\n', 'utf8');
}
