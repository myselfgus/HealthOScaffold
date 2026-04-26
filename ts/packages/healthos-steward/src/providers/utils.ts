import { createHash } from 'node:crypto';
import type { StewardLLMProviderConfig, StewardLLMRequest, StewardLLMResponse } from './types.js';

export function hashText(value: string): string {
  return createHash('sha256').update(value).digest('hex');
}

export function buildInputHash(request: StewardLLMRequest): string {
  return hashText(JSON.stringify({
    providerId: request.providerId,
    templateId: request.templateId,
    inputKind: request.inputKind,
    systemPrompt: request.systemPrompt,
    userPrompt: request.userPrompt,
    repoContextRefs: request.repoContextRefs,
    metadata: request.metadata ?? {},
  }));
}

export function baseResponse(config: StewardLLMProviderConfig, request: StewardLLMRequest): Omit<StewardLLMResponse, 'status' | 'text' | 'durationMs' | 'outputHash'> {
  return {
    providerId: config.id,
    model: config.model,
    inputHash: buildInputHash(request),
    postedToGitHub: false,
  };
}

export function readEnv(name: string | undefined): string | undefined {
  if (!name) return undefined;
  const value = process.env[name];
  return value && value.trim() ? value : undefined;
}

export function safeErrorMessage(error: unknown): string {
  if (error instanceof Error) return error.message;
  return String(error);
}

export function redactSecrets(text: string): string {
  return text
    .replace(/(sk-[A-Za-z0-9_-]{10,})/g, '[REDACTED]')
    .replace(/(xai-[A-Za-z0-9_-]{10,})/g, '[REDACTED]')
    .replace(/(api[_-]?key\s*[:=]\s*)([^\s,]+)/gi, '$1[REDACTED]');
}
