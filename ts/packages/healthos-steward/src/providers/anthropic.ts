import type { StewardModelProvider, StewardModelProviderConfig, StewardModelRequest, StewardModelResponse } from './types.js';
import { baseResponse, hashText, readEnv, redactSecrets, safeErrorMessage } from './utils.js';

export function createAnthropicProvider(config: StewardModelProviderConfig): StewardModelProvider {
  return {
    health() {
      if (!config.enabled) return { providerId: config.id, enabled: false, status: 'disabled', detail: 'provider is disabled' };
      if (!readEnv(config.apiKeyEnv)) return { providerId: config.id, enabled: true, status: 'missingSecret', detail: `missing ${config.apiKeyEnv}` };
      return { providerId: config.id, enabled: true, status: 'ready', detail: 'ready' };
    },
    async invoke(request: StewardModelRequest): Promise<StewardModelResponse> {
      const started = Date.now();
      const base = baseResponse(config, request);
      if (!config.enabled) return { ...base, status: 'disabled', text: '', durationMs: Date.now() - started, outputHash: hashText('') };
      if (request.dryRun) return { ...base, status: 'dryRun', text: '[dry-run] anthropic payload prepared', raw: { endpointMode: config.endpointMode }, durationMs: Date.now() - started, outputHash: hashText('[dry-run]') };
      if (!request.allowNetwork) return { ...base, status: 'providerError', text: '', errorKind: 'networkDenied', errorMessage: 'network calls are disabled for this invocation', durationMs: Date.now() - started, outputHash: hashText('') };
      const apiKey = readEnv(config.apiKeyEnv);
      if (!apiKey) return { ...base, status: 'missingSecret', text: '', errorKind: 'missingSecret', errorMessage: `missing ${config.apiKeyEnv}`, durationMs: Date.now() - started, outputHash: hashText('') };
      if (config.endpointMode !== 'messages') return { ...base, status: 'unsupported', text: '', errorKind: 'unsupported', errorMessage: `anthropic adapter supports only messages; got ${config.endpointMode}`, durationMs: Date.now() - started, outputHash: hashText('') };

      const body: Record<string, unknown> = {
        model: config.model,
        max_tokens: config.maxOutputTokens ?? 2048,
        system: request.systemPrompt,
        messages: [{ role: 'user', content: request.userPrompt }],
      };

      try {
        const response = await fetch(`${config.baseUrl ?? 'https://api.anthropic.com/v1'}/messages`, {
          method: 'POST',
          headers: {
            'content-type': 'application/json',
            'x-api-key': apiKey,
            'anthropic-version': config.anthropicVersion ?? '2023-06-01',
          },
          body: JSON.stringify(body),
          signal: AbortSignal.timeout(config.timeoutMs),
        });
        const raw = await response.json() as Record<string, unknown>;
        if (!response.ok) {
          return { ...base, status: 'providerError', text: '', raw, errorKind: 'httpError', errorMessage: `anthropic error ${response.status}`, durationMs: Date.now() - started, outputHash: hashText(JSON.stringify(raw)) };
        }
        const content = Array.isArray(raw.content) ? raw.content : [];
        const text = content.map((item) => {
          if (!item || typeof item !== 'object') return '';
          const candidate = item as Record<string, unknown>;
          return typeof candidate.text === 'string' ? candidate.text : '';
        }).join('\n').trim();
        return { ...base, status: 'ok', text: redactSecrets(text), raw, durationMs: Date.now() - started, outputHash: hashText(text) };
      } catch (error) {
        return { ...base, status: String(safeErrorMessage(error)).includes('timeout') ? 'timeout' : 'providerError', text: '', errorKind: 'unknown', errorMessage: safeErrorMessage(error), durationMs: Date.now() - started, outputHash: hashText('') };
      }
    },
  };
}
