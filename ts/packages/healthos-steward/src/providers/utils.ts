import { createHash } from 'node:crypto';
import type {
  StewardLLMEndpointMode,
  StewardLLMFailure,
  StewardLLMProviderConfig,
  StewardLLMProviderKind,
  StewardLLMRequest,
  StewardLLMResponse,
  StewardReviewMetadata,
} from './types.js';

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

export function baseResponse(
  config: StewardLLMProviderConfig,
  request: StewardLLMRequest,
): Omit<StewardLLMResponse, 'status' | 'text' | 'durationMs' | 'outputHash'> {
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

/**
 * Map a transport-layer HTTP status code to a typed Steward error kind.
 *
 * 401/403 collapse into `auth` because the operator action (rotate key,
 * grant access) is the same. 408/504 are kept distinct from `timeout`
 * (which we reserve for client-side abort) because they represent a
 * server-acknowledged deadline. 422 is treated as `badRequest` because
 * providers commonly use it for schema rejection.
 */
export function classifyHttpError(status: number): StewardLLMFailure['errorKind'] {
  if (status === 401 || status === 403) return 'auth';
  if (status === 404) return 'notFound';
  if (status === 408) return 'timeout';
  if (status === 429) return 'rateLimited';
  if (status === 422 || (status >= 400 && status < 500)) return 'badRequest';
  if (status >= 500 && status < 600) return 'serverError';
  return 'httpError';
}

/**
 * Map a thrown transport error to a typed Steward error kind.
 *
 * `AbortSignal.timeout` raises a DOMException with `name: 'TimeoutError'`
 * on Node 20+; user-aborted requests raise `AbortError`. Both collapse
 * into `timeout` because they share operator semantics. Pre-response
 * `fetch` failures (DNS, connection refused, TLS) surface as `TypeError`
 * with message "fetch failed" in Node — those are reported as
 * `networkUnavailable` so operators can distinguish "we never reached the
 * provider" from "the provider rejected us".
 */
export function classifyNetworkError(error: unknown): {
  errorKind: StewardLLMFailure['errorKind'];
  isTimeout: boolean;
} {
  const name = (error as { name?: string } | null)?.name;
  if (name === 'TimeoutError' || name === 'AbortError') return { errorKind: 'timeout', isTimeout: true };
  if (error instanceof TypeError) return { errorKind: 'networkUnavailable', isTimeout: false };
  return { errorKind: 'unknown', isTimeout: false };
}

/**
 * Best-effort extraction of a provider-supplied human-readable error message
 * from an HTTP error response body. Returns `undefined` when no message is
 * present; callers should fall back to a generic "<kind> error <status>"
 * label so the response always carries an honest message.
 *
 * Handles the canonical OpenAI/xAI shape `{ error: { message, type, code } }`
 * and the Anthropic shape `{ type: 'error', error: { type, message } }`.
 */
export function extractProviderErrorMessage(raw: unknown): string | undefined {
  if (!raw || typeof raw !== 'object') return undefined;
  const obj = raw as Record<string, unknown>;
  const candidate = obj.error;
  if (candidate && typeof candidate === 'object') {
    const errorObj = candidate as Record<string, unknown>;
    const message = errorObj.message;
    if (typeof message === 'string' && message.trim()) return message.trim();
  }
  if (typeof obj.message === 'string' && obj.message.trim()) return obj.message.trim();
  return undefined;
}

function extractAnthropicMessagesText(raw: unknown): string {
  if (!raw || typeof raw !== 'object') return '';
  const obj = raw as Record<string, unknown>;
  const content = Array.isArray(obj.content) ? obj.content : [];
  const parts: string[] = [];
  for (const block of content) {
    if (!block || typeof block !== 'object') continue;
    const blockObj = block as Record<string, unknown>;
    if (blockObj.type === 'text' && typeof blockObj.text === 'string') {
      parts.push(blockObj.text);
    }
  }
  return parts.join('\n').trim();
}

function extractOpenAIResponsesText(raw: unknown): string {
  if (!raw || typeof raw !== 'object') return '';
  const obj = raw as Record<string, unknown>;
  if (typeof obj.output_text === 'string' && obj.output_text.trim()) {
    return obj.output_text.trim();
  }
  const output = Array.isArray(obj.output) ? obj.output : [];
  const parts: string[] = [];
  for (const item of output) {
    if (!item || typeof item !== 'object') continue;
    const content = (item as Record<string, unknown>).content;
    if (!Array.isArray(content)) continue;
    for (const block of content) {
      if (!block || typeof block !== 'object') continue;
      const blockObj = block as Record<string, unknown>;
      if (blockObj.type === 'output_text' && typeof blockObj.text === 'string') {
        parts.push(blockObj.text);
      }
    }
  }
  return parts.join('\n').trim();
}

function extractChatCompletionsText(raw: unknown): string {
  if (!raw || typeof raw !== 'object') return '';
  const obj = raw as Record<string, unknown>;
  const choices = Array.isArray(obj.choices) ? obj.choices : [];
  const parts: string[] = [];
  for (const choice of choices) {
    if (!choice || typeof choice !== 'object') continue;
    const message = (choice as Record<string, unknown>).message;
    if (!message || typeof message !== 'object') continue;
    const content = (message as Record<string, unknown>).content;
    if (typeof content === 'string') {
      parts.push(content);
      continue;
    }
    if (!Array.isArray(content)) continue;
    for (const part of content) {
      if (!part || typeof part !== 'object') continue;
      const partObj = part as Record<string, unknown>;
      if (typeof partObj.text === 'string') parts.push(partObj.text);
    }
  }
  return parts.join('\n').trim();
}

/**
 * Mode-aware extraction of the assistant text from a provider response.
 *
 * Each branch knows the canonical response shape for its endpoint family
 * and ignores unrelated structural noise (tool_use blocks, function-call
 * blocks, role metadata) so output stays focused on what a human reviewer
 * or downstream consumer actually wants. An empty string return is a
 * meaningful signal — callers must treat it as `payloadEmpty`, never as
 * a successful empty completion.
 */
export function extractLLMText(raw: unknown, mode: StewardLLMEndpointMode): string {
  if (mode === 'messages') return extractAnthropicMessagesText(raw);
  if (mode === 'chatCompletions') return extractChatCompletionsText(raw);
  if (mode === 'responses') return extractOpenAIResponsesText(raw);
  return '';
}

/**
 * Redact common API-key shapes before surfacing provider output to logs or
 * GitHub comments. This is a defense in depth: secrets should never appear
 * in completions in the first place, but the steward keeps the redaction
 * pass to fail closed if a model echoes back its instructions.
 */
export function redactSecrets(text: string): string {
  return text
    .replace(/(sk-[A-Za-z0-9_-]{10,})/g, '[REDACTED]')
    .replace(/(xai-[A-Za-z0-9_-]{10,})/g, '[REDACTED]')
    .replace(/(api[_-]?key\s*[:=]\s*)([^\s,]+)/gi, '$1[REDACTED]')
    .replace(/(Bearer\s+)([A-Za-z0-9._-]{10,})/gi, '$1[REDACTED]');
}

const STEWARD_REVIEW_MARKER = '<!-- healthos-steward review -->';

/**
 * Compose the canonical Steward PR review comment body.
 *
 * Throws on empty body — the steward never posts placeholder text. Adds a
 * persistent HTML marker so future steward runs (or operators searching the
 * PR thread) can identify Steward-authored comments without parsing the
 * markdown header. The footer reasserts non-authority: this is a draft,
 * not approval, not merge, not gate resolution.
 */
export function formatStewardReviewComment(body: string, meta: StewardReviewMetadata): string {
  const trimmed = body.trim();
  if (!trimmed) {
    throw new Error('formatStewardReviewComment refuses empty body — provider output must be present.');
  }
  const header = [
    STEWARD_REVIEW_MARKER,
    '**HealthOS Project Steward — automated review draft**',
    '',
    `- provider: \`${meta.providerKind}/${meta.providerId}\``,
    `- model: \`${meta.model}\``,
    `- generated: \`${meta.generatedAt}\``,
    `- pr ref: \`${meta.prRef}\``,
    `- policy version: invariants \`${meta.invariantPolicyVersion}\`, rubric \`${meta.rubricVersion}\``,
    '',
    '> This is a draft review surfaced by the engineering steward.',
    '> It does not approve, merge, or replace human review.',
    '> Constitutional invariants in `docs/execution/10-invariant-matrix.md` and',
    '> `.healthos-steward/policies/invariant-policy.yaml` remain authoritative.',
    '',
    '---',
    '',
  ].join('\n');
  const footer = [
    '',
    '---',
    '',
    `_Generated by \`@healthos/steward\` review-pr (provider \`${meta.providerKind}\`). Human gate required for any merge or gate resolution._`,
  ].join('\n');
  return `${header}${trimmed}${footer}\n`;
}

export const STEWARD_REVIEW_COMMENT_MARKER = STEWARD_REVIEW_MARKER;

/**
 * Internal helper kept for diagnostic logs and provider kind labels.
 * Not exported as a public API surface; consumers should rely on the
 * structured fields of `StewardLLMResponse` instead.
 */
export function describeProviderKind(kind: StewardLLMProviderKind): string {
  return kind;
}
