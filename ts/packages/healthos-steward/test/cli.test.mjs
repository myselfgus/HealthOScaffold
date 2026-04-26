import test from 'node:test';
import assert from 'node:assert/strict';
import { resolve } from 'node:path';
import { spawnSync } from 'node:child_process';

const repoRoot = resolve(process.cwd(), '../../..');
const mockDir = resolve(process.cwd(), 'test/mocks');

function runCli(args, extraEnv = {}) {
  const cliPath = resolve(process.cwd(), 'dist/cli.js');
  return spawnSync(process.execPath, [cliPath, ...args], {
    cwd: process.cwd(),
    encoding: 'utf8',
    env: { ...process.env, ...extraEnv },
  });
}

test('status command runs and reports github integration object', () => {
  const result = runCli(['status'], { HEALTHOS_STEWARD_GH_MOCK_DIR: mockDir });
  assert.equal(result.status, 0, result.stderr || result.stdout);
  const payload = JSON.parse(result.stdout);
  assert.equal(payload.github_integration.mode, 'mock');
  assert.equal(payload.github_integration.authenticated, true);
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

test('review-pr reads PR/checks/comments via GitHub integration', () => {
  const result = runCli(['review-pr', '--pr', '123', '--repo', 'myselfgus/HealthOScaffold'], { HEALTHOS_STEWARD_GH_MOCK_DIR: mockDir });
  assert.equal(result.status, 0, result.stderr || result.stdout);
  assert.match(result.stdout, /PR Review Scaffold \(GitHub integrated\)/);
  assert.match(result.stdout, /status checks found: 1/);
  assert.match(result.stdout, /issue comments found: 1/);
  assert.match(result.stdout, /inline review comments found: 1/);
});

test('comment-pr posts PR comment through integration', () => {
  const result = runCli(['comment-pr', '--pr', '123', '--repo', 'myselfgus/HealthOScaffold', '--body', 'LGTM from steward'], { HEALTHOS_STEWARD_GH_MOCK_DIR: mockDir });
  assert.equal(result.status, 0, result.stderr || result.stdout);
  const payload = JSON.parse(result.stdout);
  assert.equal(payload.commented, true);
  assert.equal(payload.target, 'pr');
});

test('comment-issue posts issue comment through integration', () => {
  const result = runCli(['comment-issue', '--issue', '77', '--repo', 'myselfgus/HealthOScaffold', '--body', 'Tracking updated by steward'], { HEALTHOS_STEWARD_GH_MOCK_DIR: mockDir });
  assert.equal(result.status, 0, result.stderr || result.stdout);
  const payload = JSON.parse(result.stdout);
  assert.equal(payload.commented, true);
  assert.equal(payload.target, 'issue');
});

test('memory and policy files are parseable', () => {
  const state = resolve(repoRoot, '.healthos-steward/memory/project-state.json');
  const invariants = resolve(repoRoot, '.healthos-steward/policies/invariant-policy.yaml');
  const out = spawnSync('bash', ['-lc', `node -e "JSON.parse(require('fs').readFileSync('${state}','utf8'));" && test -s '${invariants}'`], { encoding: 'utf8' });
  assert.equal(out.status, 0, out.stderr || out.stdout);
});
