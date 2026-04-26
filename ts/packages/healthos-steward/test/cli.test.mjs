import test from 'node:test';
import assert from 'node:assert/strict';
import { resolve } from 'node:path';
import { spawnSync } from 'node:child_process';

const repoRoot = resolve(process.cwd(), '../../..');

function runCli(args) {
  const cliPath = resolve(process.cwd(), 'dist/cli.js');
  return spawnSync(process.execPath, [cliPath, ...args], {
    cwd: process.cwd(),
    encoding: 'utf8',
  });
}

test('status command runs and reports github integration not configured', () => {
  const result = runCli(['status']);
  assert.equal(result.status, 0, result.stderr || result.stdout);
  const payload = JSON.parse(result.stdout);
  assert.equal(payload.github_integration, 'not configured');
});

test('next-task command runs with structured sections', () => {
  const result = runCli(['next-task']);
  assert.equal(result.status, 0, result.stderr || result.stdout);
  assert.match(result.stdout, /task title:/);
  assert.match(result.stdout, /done criteria:/);
});

test('prompt codex-next generates markdown output', () => {
  const result = runCli(['prompt', 'codex-next']);
  assert.equal(result.status, 0, result.stderr || result.stdout);
  assert.match(result.stdout, /HealthOS Project Steward generated prompt/);
  assert.match(result.stdout, /absolute restrictions:/);
});

test('validate dry-run does not execute make and succeeds', () => {
  const result = runCli(['validate', '--dry-run']);
  assert.equal(result.status, 0, result.stderr || result.stdout);
  assert.match(result.stdout, /dry-run: make validate-all/);
});

test('memory and policy files are parseable', () => {
  const state = resolve(repoRoot, '.healthos-steward/memory/project-state.json');
  const invariants = resolve(repoRoot, '.healthos-steward/policies/invariant-policy.yaml');
  const out = spawnSync('bash', ['-lc', `node -e "JSON.parse(require('fs').readFileSync('${state}','utf8'));" && test -s '${invariants}'`], { encoding: 'utf8' });
  assert.equal(out.status, 0, out.stderr || out.stdout);
});
