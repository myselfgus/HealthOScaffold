import { execFileSync } from 'node:child_process';
import type { StewardLLMProvider, StewardLLMProviderConfig, StewardLLMRequest, StewardLLMResponse } from './types.js';
import { baseResponse, hashText } from './utils.js';

function isAllowed(config: StewardLLMProviderConfig, command: string[]): boolean {
  const allowlist = config.commandAllowlist ?? [];
  return allowlist.some((entry) => entry.length <= command.length && entry.every((item, index) => command[index] === item));
}

export function createLocalCommandProvider(config: StewardLLMProviderConfig): StewardLLMProvider {
  return {
    health() {
      if (!config.enabled) return { providerId: config.id, enabled: false, status: 'disabled', detail: 'provider is disabled' };
      if (!config.command || config.command.length === 0) return { providerId: config.id, enabled: true, status: 'misconfigured', detail: 'missing command' };
      return { providerId: config.id, enabled: true, status: 'ready', detail: 'ready' };
    },
    async invoke(request: StewardLLMRequest): Promise<StewardLLMResponse> {
      const started = Date.now();
      const base = baseResponse(config, request);
      if (!config.enabled) return { ...base, status: 'disabled', text: '', durationMs: Date.now() - started, outputHash: hashText('') };
      const command = config.command ?? [];
      if (!isAllowed(config, command)) {
        return { ...base, status: 'unsupported', text: '', errorKind: 'localCommandDenied', errorMessage: 'local command denied by allowlist', durationMs: Date.now() - started, outputHash: hashText('') };
      }
      if (request.dryRun) {
        return {
          ...base,
          status: 'dryRun',
          text: `[dry-run] local command not executed: ${command.join(' ')}`,
          durationMs: Date.now() - started,
          outputHash: hashText('[dry-run]'),
        };
      }
      const output = execFileSync(command[0], command.slice(1), { encoding: 'utf8' });
      return { ...base, status: 'ok', text: output, raw: { command }, durationMs: Date.now() - started, outputHash: hashText(output) };
    },
  };
}
