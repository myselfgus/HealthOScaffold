import type { StewardLLMProvider, StewardLLMProviderConfig, StewardLLMRequest, StewardLLMResponse } from './types.js';
import {
  baseResponse,
  classifyHttpError,
  classifyNetworkError,
  extractLLMText,
  extractProviderErrorMessage,
  hashText,
  readEnv,
  redactSecrets,
  safeErrorMessage,
} from './utils.js';

export function createOpenAIProvider(config: StewardLLMProviderConfig): StewardLLMProvider {
  return {
    health() {
      if (!config.enabled) return { providerId: config.id, enabled: false, status: 'disabled', detail: 'provider is disabled' };
      if (!readEnv(config.apiKeyEnv)) return { providerId: config.id, enabled: true, status: 'missingSecret', detail: `missing ${config.apiKeyEnv}` };
      return { providerId: config.id, enabled: true, status: 'ready', detail: 'ready' };
    },
    async invoke(request: StewardLLMRequest): Promise<StewardLLMResponse> {
      const started = Date.now();
      const base = baseResponse(config, request);

      if (!config.enabled && !request.dryRun) {
        return {
          ...base,
          status: 'disabled',
          text: '',
          errorKind: 'providerDisabled',
          errorMessage: 'provider is disabled',
          durationMs: Date.now() - started,
          outputHash: hashText(''),
        };
      }
      if (request.dryRun) {
        return {
          ...base,
          status: 'dryRun',
          text: `[dry-run] openai payload prepared${config.enabled ? '' : ' (provider disabled; no network call)'}`,
          raw: { endpointMode: config.endpointMode, enabled: config.enabled },
          durationMs: Date.now() - started,
          outputHash: hashText('[dry-run]'),
        };
      }
      if (!request.allowNetwork) {
        return {
          ...base,
          status: 'providerError',
          text: '',
          errorKind: 'networkDenied',
          errorMessage: 'network calls are disabled for this invocation',
          durationMs: Date.now() - started,
          outputHash: hashText(''),
        };
      }
      const apiKey = readEnv(config.apiKeyEnv);
      if (!apiKey) {
        return {
          ...base,
          status: 'missingSecret',
          text: '',
          errorKind: 'missingSecret',
          errorMessage: `missing ${config.apiKeyEnv}`,
          durationMs: Date.now() - started,
          outputHash: hashText(''),
        };
      }
      if (config.endpointMode !== 'responses') {
        return {
          ...base,
          status: 'unsupported',
          text: '',
          errorKind: 'unsupported',
          errorMessage: `openai adapter supports only responses; got ${config.endpointMode}`,
          durationMs: Date.now() - started,
          outputHash: hashText(''),
        };
      }

      const body: Record<string, unknown> = {
        model: config.model,
        input: request.userPrompt,
        instructions: request.systemPrompt,
      };
      if (config.maxOutputTokens) body.max_output_tokens = config.maxOutputTokens;
      if (typeof config.temperature === 'number') body.temperature = config.temperature;

      let response: Response;
      try {
        response = await fetch(`${config.baseUrl ?? 'https://api.openai.com/v1'}/responses`, {
          method: 'POST',
          headers: {
            'content-type': 'application/json',
            authorization: `Bearer ${apiKey}`,
          },
          body: JSON.stringify(body),
          signal: AbortSignal.timeout(config.timeoutMs),
        });
      } catch (error) {
        const { errorKind, isTimeout } = classifyNetworkError(error);
        return {
          ...base,
          status: isTimeout ? 'timeout' : 'providerError',
          text: '',
          errorKind,
          errorMessage: safeErrorMessage(error),
          durationMs: Date.now() - started,
          outputHash: hashText(''),
        };
      }

      let raw: unknown;
      try {
        raw = await response.json();
      } catch (parseError) {
        return {
          ...base,
          status: 'providerError',
          text: '',
          errorKind: 'parseError',
          errorMessage: `failed to parse openai response body: ${safeErrorMessage(parseError)}`,
          durationMs: Date.now() - started,
          outputHash: hashText(''),
        };
      }

      if (!response.ok) {
        const errorKind = classifyHttpError(response.status);
        const providerMessage = extractProviderErrorMessage(raw) ?? `openai error ${response.status}`;
        return {
          ...base,
          status: 'providerError',
          text: '',
          raw,
          errorKind,
          errorMessage: providerMessage,
          durationMs: Date.now() - started,
          outputHash: hashText(JSON.stringify(raw)),
        };
      }

      const text = extractLLMText(raw, config.endpointMode);
      if (!text) {
        return {
          ...base,
          status: 'providerError',
          text: '',
          raw,
          errorKind: 'payloadEmpty',
          errorMessage: 'openai returned 200 but no extractable assistant text',
          durationMs: Date.now() - started,
          outputHash: hashText(''),
        };
      }
      return {
        ...base,
        status: 'ok',
        text: redactSecrets(text),
        raw,
        durationMs: Date.now() - started,
        outputHash: hashText(text),
      };
    },
  };
}
