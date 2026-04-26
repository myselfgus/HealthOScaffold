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
  assert.match(out, /Generate next engineering task/);
});

test('ask with disabled provider fails correctly', () => {
  let failed = false;
  try {
    execFileSync('node', [cli, 'ask', '--provider', 'openai-default', '--template', 'model-next-task'], { encoding: 'utf8', cwd, stdio: 'pipe' });
  } catch (error) {
    failed = true;
    assert.equal(error.status, 2);
  }
  assert.equal(failed, true);
});

test('ask with dry-run builds payload', () => {
  const localConfig = JSON.parse(readFileSync(`${cwd}/.healthos-steward/providers/providers.example.json`, 'utf8'));
  localConfig.providers[0].enabled = true;
  writeFileSync(`${cwd}/.healthos-steward/providers/providers.local.json`, JSON.stringify(localConfig, null, 2));
  const out = execFileSync('node', [cli, 'ask', '--provider', 'openai-default', '--template', 'model-next-task', '--dry-run'], { encoding: 'utf8', cwd });
  assert.match(out, /dry-run/i);
  unlinkSync(`${cwd}/.healthos-steward/providers/providers.local.json`);
});
