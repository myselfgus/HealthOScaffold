import test from 'node:test';
import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { readFileSync, writeFileSync, unlinkSync } from 'node:fs';

const cli = new URL('../dist/cli.js', import.meta.url).pathname;
const cwd = new URL('../../../../', import.meta.url).pathname;

test('status runs', () => {
  const out = execFileSync('node', [cli, 'status'], { encoding: 'utf8', cwd });
  assert.match(out, /github_integration/);
});

test('providers list and check run', () => {
  const listOut = execFileSync('node', [cli, 'providers', 'list'], { encoding: 'utf8', cwd });
  assert.match(listOut, /openai-default/);
  const checkOut = execFileSync('node', [cli, 'providers', 'check'], { encoding: 'utf8', cwd });
  assert.match(checkOut, /providerId/);
});

test('prompt codex-next works without provider', () => {
  const out = execFileSync('node', [cli, 'prompt', 'codex-next'], { encoding: 'utf8', cwd });
  assert.match(out, /HealthOS Project Steward - Codex Next Task/);
});

test('next-task command is deterministic and non-deprecated', () => {
  const out = execFileSync('node', [cli, 'next-task'], { encoding: 'utf8', cwd });
  assert.match(out, /recommended_command/);
  assert.doesNotMatch(out, /Deprecated/);
});

test('agent mode requires provider and network flag', () => {
  let failed = false;
  try {
    execFileSync('node', [cli, 'agent', 'plan-next', '--provider', 'openai-default'], { encoding: 'utf8', cwd, stdio: 'pipe' });
  } catch (error) {
    failed = true;
    assert.equal(error.status, 2);
  }
  assert.equal(failed, true);
});

test('agent dry-run works with explicit provider and allow-network', () => {
  const localConfig = JSON.parse(readFileSync(`${cwd}/.healthos-steward/providers/providers.example.json`, 'utf8'));
  localConfig.providers[0].enabled = true;
  writeFileSync(`${cwd}/.healthos-steward/providers/providers.local.json`, JSON.stringify(localConfig, null, 2));
  const out = execFileSync('node', [cli, 'agent', 'plan-next', '--provider', 'openai-default', '--allow-network', '--dry-run'], { encoding: 'utf8', cwd });
  assert.match(out, /dry-run/i);
  unlinkSync(`${cwd}/.healthos-steward/providers/providers.local.json`);
});

test('agent handoff, generate-codex-prompt, and sync-memory no longer alias to plan-next', () => {
  const localConfig = JSON.parse(readFileSync(`${cwd}/.healthos-steward/providers/providers.example.json`, 'utf8'));
  localConfig.providers[0].enabled = true;
  writeFileSync(`${cwd}/.healthos-steward/providers/providers.local.json`, JSON.stringify(localConfig, null, 2));

  const handoffOut = execFileSync('node', [cli, 'agent', 'handoff', '--provider', 'openai-default', '--allow-network', '--dry-run'], { encoding: 'utf8', cwd });
  const codexOut = execFileSync('node', [cli, 'agent', 'generate-codex-prompt', '--provider', 'openai-default', '--allow-network', '--dry-run'], { encoding: 'utf8', cwd });
  const syncOut = execFileSync('node', [cli, 'agent', 'sync-memory', '--provider', 'openai-default', '--allow-network', '--dry-run'], { encoding: 'utf8', cwd });

  assert.match(handoffOut, /dry-run/i);
  assert.match(codexOut, /dry-run/i);
  assert.match(syncOut, /dry-run/i);
  assert.notEqual(handoffOut, codexOut);
  assert.notEqual(handoffOut, syncOut);
  assert.notEqual(codexOut, syncOut);

  unlinkSync(`${cwd}/.healthos-steward/providers/providers.local.json`);
});
