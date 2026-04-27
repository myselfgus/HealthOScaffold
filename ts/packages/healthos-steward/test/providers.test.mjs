import test from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync, writeFileSync, mkdirSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';

function setup(config) {
  const root = mkdtempSync(join(tmpdir(), 'steward-test-'));
  mkdirSync(join(root, '.healthos-steward/providers'), { recursive: true });
  writeFileSync(join(root, '.healthos-steward/providers/providers.example.json'), JSON.stringify(config, null, 2));
  return root;
}

function freshFetchTracker() {
  const calls = [];
  const reset = () => { calls.length = 0; };
  return { calls, reset };
}

const baseProvider = {
  id: 'openai-default', kind: 'openai', enabled: false, model: 'x', apiKeyEnv: 'OPENAI_API_KEY', endpointMode: 'responses', timeoutMs: 1000,
  dryRunDefault: true, supportsPrReview: true, supportsNextTask: true, supportsHandoff: true, supportsStructuredJson: true, supportsToolUse: false,
};

const anthropicProvider = { ...baseProvider, id: 'anthropic-default', kind: 'anthropic', apiKeyEnv: 'ANTHROPIC_API_KEY', endpointMode: 'messages' };
const xaiResponsesProvider = { ...baseProvider, id: 'xai-default', kind: 'xai', apiKeyEnv: 'XAI_API_KEY', endpointMode: 'responses' };
const xaiChatProvider = { ...baseProvider, id: 'xai-chat', kind: 'xai', apiKeyEnv: 'XAI_API_KEY', endpointMode: 'chatCompletions' };

test('providers.example.json parseable and disabled listed', async () => {
  const root = setup({ version: '0.1.0', providers: [baseProvider] });
  const { createProviderRouter } = await import('../dist/providers/router.js');
  const router = await createProviderRouter(root);
  assert.equal(router.listProviders()[0].enabled, false);
  rmSync(root, { recursive: true, force: true });
});

test('enabled provider without env returns missingSecret', async () => {
  const root = setup({ version: '0.1.0', providers: [{ ...baseProvider, enabled: true }] });
  delete process.env.OPENAI_API_KEY;
  const { createProviderRouter } = await import('../dist/providers/router.js');
  const router = await createProviderRouter(root);
  const health = router.checkProviders()[0];
  assert.equal(health.status, 'missingSecret');
  rmSync(root, { recursive: true, force: true });
});

test('unknown provider id throws typed error', async () => {
  const root = setup({ version: '0.1.0', providers: [baseProvider] });
  const { createProviderRouter } = await import('../dist/providers/router.js');
  const router = await createProviderRouter(root);
  await assert.rejects(
    () => router.invoke({ providerId: 'nope', templateId: 'x', systemPrompt: '', userPrompt: '', inputKind: 'freeform', repoContextRefs: [], dryRun: true, allowNetwork: false, allowGitHubWrite: false }),
    /unknown provider/,
  );
  rmSync(root, { recursive: true, force: true });
});

test('dry-run path does not call network for any provider kind', async () => {
  const tracker = freshFetchTracker();
  global.fetch = async (...args) => { tracker.calls.push(args); throw new Error('should not be called'); };
  const root = setup({ version: '0.1.0', providers: [
    { ...baseProvider, enabled: true },
    { ...anthropicProvider, enabled: true },
    { ...xaiResponsesProvider, enabled: true },
  ] });
  const { createProviderRouter } = await import('../dist/providers/router.js');
  const router = await createProviderRouter(root);
  for (const id of ['openai-default','anthropic-default','xai-default']) {
    const res = await router.invoke({ providerId: id, templateId: 't', systemPrompt: 's', userPrompt: 'u', inputKind: 'freeform', repoContextRefs: [], dryRun: true, allowNetwork: false, allowGitHubWrite: false });
    assert.equal(res.status, 'dryRun');
  }
  assert.equal(tracker.calls.length, 0);
  rmSync(root, { recursive: true, force: true });
});

test('network denied without --allow-network surfaces typed networkDenied', async () => {
  const root = setup({ version: '0.1.0', providers: [{ ...baseProvider, enabled: true }] });
  process.env.OPENAI_API_KEY = 'sk-test-openai';
  const { createProviderRouter } = await import('../dist/providers/router.js');
  const router = await createProviderRouter(root);
  const response = await router.invoke({ providerId: 'openai-default', templateId: 't', systemPrompt: 's', userPrompt: 'u', inputKind: 'freeform', repoContextRefs: [], dryRun: false, allowNetwork: false, allowGitHubWrite: false });
  assert.equal(response.status, 'providerError');
  assert.equal(response.errorKind, 'networkDenied');
  rmSync(root, { recursive: true, force: true });
});

test('local-command dry-run does not execute', async () => {
  const root = setup({ version: '0.1.0', providers: [{ ...baseProvider, enabled: true, id: 'local-default', kind: 'local-command', endpointMode: 'localCommand', command: ['echo', 'hello'], commandAllowlist: [['echo']] }] });
  const { createProviderRouter } = await import('../dist/providers/router.js');
  const router = await createProviderRouter(root);
  const response = await router.invoke({ providerId: 'local-default', templateId: 't', systemPrompt: '', userPrompt: '', inputKind: 'freeform', repoContextRefs: [], dryRun: true, allowNetwork: false, allowGitHubWrite: false });
  assert.equal(response.status, 'dryRun');
  rmSync(root, { recursive: true, force: true });
});

test('openai responses payload extraction parses output_text shortcut', async () => {
  const root = setup({ version: '0.1.0', providers: [{ ...baseProvider, enabled: true }] });
  process.env.OPENAI_API_KEY = 'sk-test-openai';
  global.fetch = async () => ({ ok: true, status: 200, json: async () => ({ output_text: 'openai ok' }) });
  const { createProviderRouter } = await import('../dist/providers/router.js');
  const router = await createProviderRouter(root);
  const response = await router.invoke({ providerId: 'openai-default', templateId: 't', systemPrompt: 's', userPrompt: 'u', inputKind: 'freeform', repoContextRefs: [], dryRun: false, allowNetwork: true, allowGitHubWrite: false });
  assert.equal(response.status, 'ok');
  assert.equal(response.text, 'openai ok');
  rmSync(root, { recursive: true, force: true });
});

test('openai responses payload extraction walks output[].content[] when shortcut absent', async () => {
  const root = setup({ version: '0.1.0', providers: [{ ...baseProvider, enabled: true }] });
  process.env.OPENAI_API_KEY = 'sk-test-openai';
  global.fetch = async () => ({
    ok: true,
    status: 200,
    json: async () => ({
      output: [
        { type: 'message', content: [{ type: 'output_text', text: 'first chunk' }, { type: 'reasoning', text: 'should be ignored' }] },
        { type: 'message', content: [{ type: 'output_text', text: 'second chunk' }] },
      ],
    }),
  });
  const { createProviderRouter } = await import('../dist/providers/router.js');
  const router = await createProviderRouter(root);
  const response = await router.invoke({ providerId: 'openai-default', templateId: 't', systemPrompt: 's', userPrompt: 'u', inputKind: 'freeform', repoContextRefs: [], dryRun: false, allowNetwork: true, allowGitHubWrite: false });
  assert.equal(response.status, 'ok');
  assert.equal(response.text, 'first chunk\nsecond chunk');
  rmSync(root, { recursive: true, force: true });
});

test('anthropic messages payload extraction filters non-text content blocks', async () => {
  const root = setup({ version: '0.1.0', providers: [{ ...anthropicProvider, enabled: true }] });
  process.env.ANTHROPIC_API_KEY = 'anthropic-test-key';
  global.fetch = async () => ({
    ok: true,
    status: 200,
    json: async () => ({
      content: [
        { type: 'tool_use', id: 'tool_1', name: 'inspect', input: {} },
        { type: 'text', text: 'anthropic ok' },
        { type: 'text', text: 'second segment' },
      ],
    }),
  });
  const { createProviderRouter } = await import('../dist/providers/router.js');
  const router = await createProviderRouter(root);
  const response = await router.invoke({ providerId: 'anthropic-default', templateId: 't', systemPrompt: 's', userPrompt: 'u', inputKind: 'freeform', repoContextRefs: [], dryRun: false, allowNetwork: true, allowGitHubWrite: false });
  assert.equal(response.status, 'ok');
  assert.equal(response.text, 'anthropic ok\nsecond segment');
  rmSync(root, { recursive: true, force: true });
});

test('xai chat completions payload extraction parses message.content', async () => {
  const root = setup({ version: '0.1.0', providers: [{ ...xaiChatProvider, enabled: true }] });
  process.env.XAI_API_KEY = 'xai-test-key';
  global.fetch = async () => ({ ok: true, status: 200, json: async () => ({ choices: [{ message: { content: 'xai ok' } }] }) });
  const { createProviderRouter } = await import('../dist/providers/router.js');
  const router = await createProviderRouter(root);
  const response = await router.invoke({ providerId: 'xai-chat', templateId: 't', systemPrompt: 's', userPrompt: 'u', inputKind: 'freeform', repoContextRefs: [], dryRun: false, allowNetwork: true, allowGitHubWrite: false });
  assert.equal(response.status, 'ok');
  assert.equal(response.text, 'xai ok');
  rmSync(root, { recursive: true, force: true });
});

test('http 401 maps to errorKind auth and surfaces provider message', async () => {
  const root = setup({ version: '0.1.0', providers: [{ ...baseProvider, enabled: true }] });
  process.env.OPENAI_API_KEY = 'sk-test-openai';
  global.fetch = async () => ({ ok: false, status: 401, json: async () => ({ error: { message: 'Invalid API key', type: 'authentication_error' } }) });
  const { createProviderRouter } = await import('../dist/providers/router.js');
  const router = await createProviderRouter(root);
  const response = await router.invoke({ providerId: 'openai-default', templateId: 't', systemPrompt: 's', userPrompt: 'u', inputKind: 'freeform', repoContextRefs: [], dryRun: false, allowNetwork: true, allowGitHubWrite: false });
  assert.equal(response.status, 'providerError');
  assert.equal(response.errorKind, 'auth');
  assert.equal(response.errorMessage, 'Invalid API key');
  rmSync(root, { recursive: true, force: true });
});

test('http 403 maps to errorKind auth', async () => {
  const root = setup({ version: '0.1.0', providers: [{ ...baseProvider, enabled: true }] });
  process.env.OPENAI_API_KEY = 'sk-test-openai';
  global.fetch = async () => ({ ok: false, status: 403, json: async () => ({ error: { message: 'forbidden' } }) });
  const { createProviderRouter } = await import('../dist/providers/router.js');
  const router = await createProviderRouter(root);
  const response = await router.invoke({ providerId: 'openai-default', templateId: 't', systemPrompt: 's', userPrompt: 'u', inputKind: 'freeform', repoContextRefs: [], dryRun: false, allowNetwork: true, allowGitHubWrite: false });
  assert.equal(response.errorKind, 'auth');
  rmSync(root, { recursive: true, force: true });
});

test('http 404 maps to errorKind notFound', async () => {
  const root = setup({ version: '0.1.0', providers: [{ ...baseProvider, enabled: true }] });
  process.env.OPENAI_API_KEY = 'sk-test-openai';
  global.fetch = async () => ({ ok: false, status: 404, json: async () => ({ error: { message: 'model not found' } }) });
  const { createProviderRouter } = await import('../dist/providers/router.js');
  const router = await createProviderRouter(root);
  const response = await router.invoke({ providerId: 'openai-default', templateId: 't', systemPrompt: 's', userPrompt: 'u', inputKind: 'freeform', repoContextRefs: [], dryRun: false, allowNetwork: true, allowGitHubWrite: false });
  assert.equal(response.errorKind, 'notFound');
  rmSync(root, { recursive: true, force: true });
});

test('http 429 maps to errorKind rateLimited', async () => {
  const root = setup({ version: '0.1.0', providers: [{ ...anthropicProvider, enabled: true }] });
  process.env.ANTHROPIC_API_KEY = 'anthropic-test-key';
  global.fetch = async () => ({ ok: false, status: 429, json: async () => ({ type: 'error', error: { type: 'rate_limit_error', message: 'rate limit exceeded' } }) });
  const { createProviderRouter } = await import('../dist/providers/router.js');
  const router = await createProviderRouter(root);
  const response = await router.invoke({ providerId: 'anthropic-default', templateId: 't', systemPrompt: 's', userPrompt: 'u', inputKind: 'freeform', repoContextRefs: [], dryRun: false, allowNetwork: true, allowGitHubWrite: false });
  assert.equal(response.errorKind, 'rateLimited');
  assert.equal(response.errorMessage, 'rate limit exceeded');
  rmSync(root, { recursive: true, force: true });
});

test('http 500/502/503 map to errorKind serverError', async () => {
  const root = setup({ version: '0.1.0', providers: [{ ...xaiChatProvider, enabled: true }] });
  process.env.XAI_API_KEY = 'xai-test-key';
  for (const status of [500, 502, 503]) {
    global.fetch = async () => ({ ok: false, status, json: async () => ({}) });
    const { createProviderRouter } = await import('../dist/providers/router.js');
    const router = await createProviderRouter(root);
    const response = await router.invoke({ providerId: 'xai-chat', templateId: 't', systemPrompt: 's', userPrompt: 'u', inputKind: 'freeform', repoContextRefs: [], dryRun: false, allowNetwork: true, allowGitHubWrite: false });
    assert.equal(response.errorKind, 'serverError', `expected serverError for status ${status}`);
    assert.equal(response.errorMessage, `xai error ${status}`);
  }
  rmSync(root, { recursive: true, force: true });
});

test('http 422 maps to errorKind badRequest', async () => {
  const root = setup({ version: '0.1.0', providers: [{ ...baseProvider, enabled: true }] });
  process.env.OPENAI_API_KEY = 'sk-test-openai';
  global.fetch = async () => ({ ok: false, status: 422, json: async () => ({ error: { message: 'invalid params' } }) });
  const { createProviderRouter } = await import('../dist/providers/router.js');
  const router = await createProviderRouter(root);
  const response = await router.invoke({ providerId: 'openai-default', templateId: 't', systemPrompt: 's', userPrompt: 'u', inputKind: 'freeform', repoContextRefs: [], dryRun: false, allowNetwork: true, allowGitHubWrite: false });
  assert.equal(response.errorKind, 'badRequest');
  rmSync(root, { recursive: true, force: true });
});

test('200 with no extractable text maps to errorKind payloadEmpty', async () => {
  const root = setup({ version: '0.1.0', providers: [{ ...baseProvider, enabled: true }] });
  process.env.OPENAI_API_KEY = 'sk-test-openai';
  global.fetch = async () => ({ ok: true, status: 200, json: async () => ({ output: [] }) });
  const { createProviderRouter } = await import('../dist/providers/router.js');
  const router = await createProviderRouter(root);
  const response = await router.invoke({ providerId: 'openai-default', templateId: 't', systemPrompt: 's', userPrompt: 'u', inputKind: 'freeform', repoContextRefs: [], dryRun: false, allowNetwork: true, allowGitHubWrite: false });
  assert.equal(response.status, 'providerError');
  assert.equal(response.errorKind, 'payloadEmpty');
  assert.equal(response.text, '');
  rmSync(root, { recursive: true, force: true });
});

test('anthropic with only tool_use blocks maps to payloadEmpty (no text content)', async () => {
  const root = setup({ version: '0.1.0', providers: [{ ...anthropicProvider, enabled: true }] });
  process.env.ANTHROPIC_API_KEY = 'anthropic-test-key';
  global.fetch = async () => ({ ok: true, status: 200, json: async () => ({ content: [{ type: 'tool_use', id: 't1', name: 'x', input: {} }] }) });
  const { createProviderRouter } = await import('../dist/providers/router.js');
  const router = await createProviderRouter(root);
  const response = await router.invoke({ providerId: 'anthropic-default', templateId: 't', systemPrompt: 's', userPrompt: 'u', inputKind: 'freeform', repoContextRefs: [], dryRun: false, allowNetwork: true, allowGitHubWrite: false });
  assert.equal(response.errorKind, 'payloadEmpty');
  rmSync(root, { recursive: true, force: true });
});

test('json parse failure maps to errorKind parseError', async () => {
  const root = setup({ version: '0.1.0', providers: [{ ...baseProvider, enabled: true }] });
  process.env.OPENAI_API_KEY = 'sk-test-openai';
  global.fetch = async () => ({ ok: true, status: 200, json: async () => { throw new SyntaxError('Unexpected token N in JSON at position 0'); } });
  const { createProviderRouter } = await import('../dist/providers/router.js');
  const router = await createProviderRouter(root);
  const response = await router.invoke({ providerId: 'openai-default', templateId: 't', systemPrompt: 's', userPrompt: 'u', inputKind: 'freeform', repoContextRefs: [], dryRun: false, allowNetwork: true, allowGitHubWrite: false });
  assert.equal(response.status, 'providerError');
  assert.equal(response.errorKind, 'parseError');
  rmSync(root, { recursive: true, force: true });
});

test('TypeError fetch failure maps to errorKind networkUnavailable', async () => {
  const root = setup({ version: '0.1.0', providers: [{ ...baseProvider, enabled: true }] });
  process.env.OPENAI_API_KEY = 'sk-test-openai';
  global.fetch = async () => { throw new TypeError('fetch failed'); };
  const { createProviderRouter } = await import('../dist/providers/router.js');
  const router = await createProviderRouter(root);
  const response = await router.invoke({ providerId: 'openai-default', templateId: 't', systemPrompt: 's', userPrompt: 'u', inputKind: 'freeform', repoContextRefs: [], dryRun: false, allowNetwork: true, allowGitHubWrite: false });
  assert.equal(response.status, 'providerError');
  assert.equal(response.errorKind, 'networkUnavailable');
  rmSync(root, { recursive: true, force: true });
});

test('AbortError surfaces as status timeout with errorKind timeout', async () => {
  const root = setup({ version: '0.1.0', providers: [{ ...baseProvider, enabled: true }] });
  process.env.OPENAI_API_KEY = 'sk-test-openai';
  global.fetch = async () => { const error = new Error('aborted'); error.name = 'AbortError'; throw error; };
  const { createProviderRouter } = await import('../dist/providers/router.js');
  const router = await createProviderRouter(root);
  const response = await router.invoke({ providerId: 'openai-default', templateId: 't', systemPrompt: 's', userPrompt: 'u', inputKind: 'freeform', repoContextRefs: [], dryRun: false, allowNetwork: true, allowGitHubWrite: false });
  assert.equal(response.status, 'timeout');
  assert.equal(response.errorKind, 'timeout');
  rmSync(root, { recursive: true, force: true });
});

test('TimeoutError (DOMException name) surfaces as status timeout', async () => {
  const root = setup({ version: '0.1.0', providers: [{ ...baseProvider, enabled: true }] });
  process.env.OPENAI_API_KEY = 'sk-test-openai';
  global.fetch = async () => { const error = new Error('signal timed out'); error.name = 'TimeoutError'; throw error; };
  const { createProviderRouter } = await import('../dist/providers/router.js');
  const router = await createProviderRouter(root);
  const response = await router.invoke({ providerId: 'openai-default', templateId: 't', systemPrompt: 's', userPrompt: 'u', inputKind: 'freeform', repoContextRefs: [], dryRun: false, allowNetwork: true, allowGitHubWrite: false });
  assert.equal(response.status, 'timeout');
  assert.equal(response.errorKind, 'timeout');
  rmSync(root, { recursive: true, force: true });
});

test('formatStewardReviewComment refuses empty body', async () => {
  const { formatStewardReviewComment } = await import('../dist/providers/utils.js');
  assert.throws(() => formatStewardReviewComment('', {
    providerId: 'openai-default', providerKind: 'openai', model: 'gpt-x', generatedAt: '2026-04-27T00:00:00Z',
    prRef: '#1 example', invariantPolicyVersion: '0.1.0', rubricVersion: '0.1.0',
  }), /refuses empty body/);
  assert.throws(() => formatStewardReviewComment('   \n\t  ', {
    providerId: 'openai-default', providerKind: 'openai', model: 'gpt-x', generatedAt: '2026-04-27T00:00:00Z',
    prRef: '#1 example', invariantPolicyVersion: '0.1.0', rubricVersion: '0.1.0',
  }), /refuses empty body/);
});

test('formatStewardReviewComment carries marker, header metadata, and footer', async () => {
  const { formatStewardReviewComment, STEWARD_REVIEW_COMMENT_MARKER } = await import('../dist/providers/utils.js');
  const body = formatStewardReviewComment('Reviewer notes here.', {
    providerId: 'anthropic-default', providerKind: 'anthropic', model: 'claude-x',
    generatedAt: '2026-04-27T12:34:56Z', prRef: '#42 sample title',
    invariantPolicyVersion: '0.1.0', rubricVersion: '0.1.0',
  });
  assert.match(body, new RegExp(STEWARD_REVIEW_COMMENT_MARKER));
  assert.match(body, /provider: `anthropic\/anthropic-default`/);
  assert.match(body, /model: `claude-x`/);
  assert.match(body, /generated: `2026-04-27T12:34:56Z`/);
  assert.match(body, /pr ref: `#42 sample title`/);
  assert.match(body, /invariants `0.1.0`, rubric `0.1.0`/);
  assert.match(body, /Reviewer notes here\./);
  assert.match(body, /Human gate required for any merge or gate resolution/);
  assert.match(body, /does not approve, merge, or replace human review/);
});

test('classifyHttpError covers documented HTTP categories', async () => {
  const { classifyHttpError } = await import('../dist/providers/utils.js');
  assert.equal(classifyHttpError(401), 'auth');
  assert.equal(classifyHttpError(403), 'auth');
  assert.equal(classifyHttpError(404), 'notFound');
  assert.equal(classifyHttpError(408), 'timeout');
  assert.equal(classifyHttpError(422), 'badRequest');
  assert.equal(classifyHttpError(429), 'rateLimited');
  assert.equal(classifyHttpError(400), 'badRequest');
  assert.equal(classifyHttpError(499), 'badRequest');
  assert.equal(classifyHttpError(500), 'serverError');
  assert.equal(classifyHttpError(503), 'serverError');
  assert.equal(classifyHttpError(599), 'serverError');
  assert.equal(classifyHttpError(600), 'httpError');
});

test('classifyNetworkError distinguishes timeout vs networkUnavailable vs unknown', async () => {
  const { classifyNetworkError } = await import('../dist/providers/utils.js');
  const timeout = classifyNetworkError(Object.assign(new Error('t'), { name: 'TimeoutError' }));
  assert.equal(timeout.errorKind, 'timeout');
  assert.equal(timeout.isTimeout, true);
  const aborted = classifyNetworkError(Object.assign(new Error('a'), { name: 'AbortError' }));
  assert.equal(aborted.errorKind, 'timeout');
  assert.equal(aborted.isTimeout, true);
  const network = classifyNetworkError(new TypeError('fetch failed'));
  assert.equal(network.errorKind, 'networkUnavailable');
  assert.equal(network.isTimeout, false);
  const other = classifyNetworkError(new Error('something else'));
  assert.equal(other.errorKind, 'unknown');
  assert.equal(other.isTimeout, false);
});

test('extractProviderErrorMessage handles openai/xai shape and anthropic shape', async () => {
  const { extractProviderErrorMessage } = await import('../dist/providers/utils.js');
  assert.equal(extractProviderErrorMessage({ error: { message: 'bad request' } }), 'bad request');
  assert.equal(extractProviderErrorMessage({ type: 'error', error: { type: 'rate_limit', message: 'too many' } }), 'too many');
  assert.equal(extractProviderErrorMessage({ message: 'top-level' }), 'top-level');
  assert.equal(extractProviderErrorMessage({}), undefined);
  assert.equal(extractProviderErrorMessage(null), undefined);
});
