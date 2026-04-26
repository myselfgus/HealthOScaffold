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

const baseProvider = {
  id: 'openai-default', kind: 'openai', enabled: false, model: 'x', apiKeyEnv: 'OPENAI_API_KEY', endpointMode: 'responses', timeoutMs: 1000,
  dryRunDefault: true, supportsPrReview: true, supportsNextTask: true, supportsHandoff: true, supportsStructuredJson: true, supportsToolUse: false,
};

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

test('unknown provider fails typed error', async () => {
  const root = setup({ version: '0.1.0', providers: [baseProvider] });
  const { createProviderRouter } = await import('../dist/providers/router.js');
  const router = await createProviderRouter(root);
  await assert.rejects(() => router.invoke({ providerId: 'nope', templateId: 'x', systemPrompt: '', userPrompt: '', inputKind: 'freeform', repoContextRefs: [], dryRun: true, allowNetwork: false, allowGitHubWrite: false }), /unknown provider/);
  rmSync(root, { recursive: true, force: true });
});

test('dry-run adapters do not call network', async () => {
  const calls = [];
  global.fetch = async (...args) => {
    calls.push(args);
    throw new Error('should not be called');
  };
  const root = setup({ version: '0.1.0', providers: [
    { ...baseProvider, enabled: true, id: 'openai-default' },
    { ...baseProvider, enabled: true, kind: 'anthropic', id: 'anthropic-default', apiKeyEnv: 'ANTHROPIC_API_KEY', endpointMode: 'messages' },
    { ...baseProvider, enabled: true, kind: 'xai', id: 'xai-default', apiKeyEnv: 'XAI_API_KEY', endpointMode: 'responses' },
  ] });
  const { createProviderRouter } = await import('../dist/providers/router.js');
  const router = await createProviderRouter(root);
  for (const id of ['openai-default','anthropic-default','xai-default']) {
    const res = await router.invoke({ providerId: id, templateId: 't', systemPrompt: 's', userPrompt: 'u', inputKind: 'freeform', repoContextRefs: [], dryRun: true, allowNetwork: false, allowGitHubWrite: false });
    assert.equal(res.status, 'dryRun');
  }
  assert.equal(calls.length, 0);
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
