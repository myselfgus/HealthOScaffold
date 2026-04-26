import { createHash } from 'node:crypto';
import type { StewardLLMFailure, StewardLLMProviderConfig, StewardLLMRequest, StewardLLMResponse } from './types.js';

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

export function classifyHttpError(status: number): StewardLLMFailure['errorKind'] {
  if (status === 400 || status === 422) return 'badRequest';
  if (status === 429) return 'rateLimited';
  return 'httpError';
}

function extractFromUnknown(value: unknown): string[] {
  if (typeof value === 'string') return [value];
  if (Array.isArray(value)) return value.flatMap(extractFromUnknown);
  if (!value || typeof value !== 'object') return [];
  const obj = value as Record<string, unknown>;
  const direct = [obj.output_text, obj.text, obj.content]
    .flatMap(extractFromUnknown)
    .filter(Boolean);
  const outputs = [obj.output, obj.choices, obj.message, obj.messages].flatMap(extractFromUnknown);
  return [...direct, ...outputs];
}

export function extractLLMText(raw: unknown, mode?: string): string {
  if (!raw || typeof raw !== 'object') return '';
  const obj = raw as Record<string, unknown>;

  if (typeof obj.output_text === 'string' && obj.output_text.trim()) return obj.output_text.trim();

  if (mode === 'chatCompletions') {
    const choices = Array.isArray(obj.choices) ? obj.choices : [];
    const text = choices.map((choice) => {
      if (!choice || typeof choice !== 'object') return '';
      const message = (choice as Record<string, unknown>).message;
      if (!message || typeof message !== 'object') return '';
      const content = (message as Record<string, unknown>).content;
      return typeof content === 'string' ? content : extractFromUnknown(content).join('\n');
    }).filter(Boolean).join('\n').trim();
    if (text) return text;
  }

  return extractFromUnknown(raw).join('\n').trim();
}

export function redactSecrets(text: string): string {
  return text
    .replace(/(sk-[A-Za-z0-9_-]{10,})/g, '[REDACTED]')
    .replace(/(xai-[A-Za-z0-9_-]{10,})/g, '[REDACTED]')
    .replace(/(api[_-]?key\s*[:=]\s*)([^\s,]+)/gi, '$1[REDACTED]')
    .replace(/(Bearer\s+)([A-Za-z0-9._-]{10,})/gi, '$1[REDACTED]');
}
