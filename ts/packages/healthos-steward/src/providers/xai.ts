import type { StewardLLMProvider, StewardLLMProviderConfig, StewardLLMRequest, StewardLLMResponse } from './types.js';
import { baseResponse, classifyHttpError, extractLLMText, hashText, readEnv, redactSecrets, safeErrorMessage } from './utils.js';

export function createXAIProvider(config: StewardLLMProviderConfig): StewardLLMProvider {
  return {
    health() {
      if (!config.enabled) return { providerId: config.id, enabled: false, status: 'disabled', detail: 'provider is disabled' };
      if (!readEnv(config.apiKeyEnv)) return { providerId: config.id, enabled: true, status: 'missingSecret', detail: `missing ${config.apiKeyEnv}` };
      return { providerId: config.id, enabled: true, status: 'ready', detail: 'ready' };
    },
    async invoke(request: StewardLLMRequest): Promise<StewardLLMResponse> {
      const started = Date.now();
      const base = baseResponse(config, request);
      if (!config.enabled && !request.dryRun) return { ...base, status: 'disabled', text: '', errorKind: 'providerDisabled', errorMessage: 'provider is disabled', durationMs: Date.now() - started, outputHash: hashText('') };
      if (request.dryRun) return { ...base, status: 'dryRun', text: `[dry-run] xai payload prepared${config.enabled ? '' : ' (provider disabled; no network call)'}`, raw: { endpointMode: config.endpointMode, enabled: config.enabled }, durationMs: Date.now() - started, outputHash: hashText('[dry-run]') };
      if (!request.allowNetwork) return { ...base, status: 'providerError', text: '', errorKind: 'networkDenied', errorMessage: 'network calls are disabled for this invocation', durationMs: Date.now() - started, outputHash: hashText('') };
      const apiKey = readEnv(config.apiKeyEnv);
      if (!apiKey) return { ...base, status: 'missingSecret', text: '', errorKind: 'missingSecret', errorMessage: `missing ${config.apiKeyEnv}`, durationMs: Date.now() - started, outputHash: hashText('') };

      const baseUrl = config.baseUrl ?? 'https://api.x.ai/v1';
      let path = '/responses';
      let body: Record<string, unknown>;

      if (config.endpointMode === 'responses') {
        body = { model: config.model, input: request.userPrompt, instructions: request.systemPrompt };
        if (config.maxOutputTokens) body.max_output_tokens = config.maxOutputTokens;
      } else if (config.endpointMode === 'chatCompletions') {
        path = '/chat/completions';
        body = {
          model: config.model,
          messages: [
            { role: 'system', content: request.systemPrompt },
            { role: 'user', content: request.userPrompt },
          ],
        };
        if (config.maxOutputTokens) body.max_tokens = config.maxOutputTokens;
      } else {
        return { ...base, status: 'unsupported', text: '', errorKind: 'unsupported', errorMessage: `xai adapter supports responses/chatCompletions; got ${config.endpointMode}`, durationMs: Date.now() - started, outputHash: hashText('') };
      }

      try {
        const response = await fetch(`${baseUrl}${path}`, {
          method: 'POST',
          headers: {
            'content-type': 'application/json',
            authorization: `Bearer ${apiKey}`,
          },
          body: JSON.stringify(body),
          signal: AbortSignal.timeout(config.timeoutMs),
        });
        const raw = await response.json() as Record<string, unknown>;
        if (!response.ok) {
          const errorKind = classifyHttpError(response.status);
          return { ...base, status: 'providerError', text: '', raw, errorKind, errorMessage: `xai error ${response.status}`, durationMs: Date.now() - started, outputHash: hashText(JSON.stringify(raw)) };
        }
        const text = extractLLMText(raw, config.endpointMode);
        return { ...base, status: 'ok', text: redactSecrets(text), raw, durationMs: Date.now() - started, outputHash: hashText(text) };
      } catch (error) {
        return { ...base, status: String(safeErrorMessage(error)).includes('timeout') ? 'timeout' : 'providerError', text: '', errorKind: 'unknown', errorMessage: safeErrorMessage(error), durationMs: Date.now() - started, outputHash: hashText('') };
      }
    },
  };
}
