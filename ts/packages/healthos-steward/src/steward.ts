import { access, appendFile, mkdir, readFile, writeFile } from 'node:fs/promises';
import { constants } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { execSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { createProviderRouter } from './providers/router.js';
import { appendInvocationLog } from './providers/invocation-log.js';
import type { StewardModelInvocationLog, StewardModelRequest } from './providers/types.js';
import { hashText } from './providers/utils.js';

export const REQUIRED_DOCS = [
  'README.md','AGENTS.md','CLAUDE.md','docs/execution/02-status-and-tracking.md','docs/execution/06-scaffold-coverage-matrix.md','docs/execution/10-invariant-matrix.md','docs/execution/11-current-maturity-map.md','docs/execution/12-next-agent-handoff.md','docs/execution/13-scaffold-release-candidate-criteria.md','docs/execution/14-final-gap-register.md','docs/execution/15-scaffold-finalization-plan.md','docs/execution/todo/','docs/execution/skills/',
] as const;

export const REQUIRED_INVARIANTS = [
  'HealthOS is the full platform; AACI is one runtime inside HealthOS.','GOS is an operational layer subordinate to Core law.','Apps are interfaces and never constitutional law engines.','Project Steward is an engineering orchestration tool, not clinical runtime or law engine.','Human gate is mandatory for regulatory effects and final artifacts.','No fake integrations, no production-ready claims, and no secrets in repo.',
] as const;

type ValidationRecord = { timestamp: string; command: string; exitCode: number; status: 'pass' | 'fail' };

type GitHubIntegrationStatus = { available: boolean; authenticated: boolean; mode: 'gh-cli' | 'unavailable' };

type PRDetails = { number: number; title: string; url: string; mergeStateStatus?: string; reviewDecision?: string; comments?: unknown[]; reviews?: unknown[]; statusCheckRollup?: unknown[] };

function repoRoot(): string { return resolve(dirname(fileURLToPath(import.meta.url)), '..', '..', '..', '..'); }
function stewardRoot(root: string): string { return resolve(root, '.healthos-steward'); }
async function exists(path: string): Promise<boolean> { try { await access(path, constants.F_OK); return true; } catch { return false; } }
async function readJson<T>(path: string): Promise<T> { return JSON.parse(await readFile(path, 'utf8')) as T; }
async function writeJson(path: string, value: unknown): Promise<void> { await mkdir(dirname(path), { recursive: true }); await writeFile(path, JSON.stringify(value, null, 2) + '\n', 'utf8'); }

function parseArgs(args: string[]): Record<string, string | boolean> {
  const parsed: Record<string, string | boolean> = {};
  for (let i = 0; i < args.length; i += 1) {
    const arg = args[i];
    if (!arg.startsWith('--')) continue;
    const key = arg.slice(2);
    const next = args[i + 1];
    if (!next || next.startsWith('--')) parsed[key] = true;
    else { parsed[key] = next; i += 1; }
  }
  return parsed;
}

async function checkDocs(root: string): Promise<{ ok: string[]; missing: string[] }> {
  const ok: string[] = []; const missing: string[] = [];
  for (const rel of REQUIRED_DOCS) ((await exists(resolve(root, rel))) ? ok : missing).push(rel);
  return { ok, missing };
}

async function readProjectState(root: string): Promise<Record<string, unknown>> { return readJson(resolve(stewardRoot(root), 'memory/project-state.json')); }
async function appendValidation(root: string, record: ValidationRecord): Promise<void> {
  const file = resolve(stewardRoot(root), 'memory/validation-history.json');
  const existing = (await exists(file)) ? await readJson<ValidationRecord[]>(file) : [];
  existing.push(record); await writeJson(file, existing.slice(-50));
}

function gitSummary(root: string): { branch: string; head: string } {
  return {
    branch: execSync('git rev-parse --abbrev-ref HEAD', { cwd: root, encoding: 'utf8' }).trim(),
    head: execSync('git rev-parse --short HEAD', { cwd: root, encoding: 'utf8' }).trim(),
  };
}

function runGh(root: string, args: string[]): string { return execSync(`gh ${args.map((item) => `'${item.replace(/'/g, "'\\''")}'`).join(' ')}`, { cwd: root, encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] }); }
function githubIntegrationStatus(root: string): GitHubIntegrationStatus { try { execSync('gh --version', { cwd: root, stdio: 'ignore' }); } catch { return { available: false, authenticated: false, mode: 'unavailable' }; } try { execSync('gh auth status', { cwd: root, stdio: 'ignore' }); return { available: true, authenticated: true, mode: 'gh-cli' }; } catch { return { available: true, authenticated: false, mode: 'gh-cli' }; } }
function requireGithubReady(root: string): void { const status = githubIntegrationStatus(root); if (!status.available) throw new Error('GitHub integration unavailable: gh CLI is not installed.'); if (!status.authenticated) throw new Error('GitHub integration unavailable: gh CLI is not authenticated (run gh auth login).'); }
function getRepoSlug(root: string): string { const remote = execSync('git remote get-url origin', { cwd: root, encoding: 'utf8' }).trim(); const match = remote.match(/github\.com[:/](.+?)(?:\.git)?$/); if (!match) throw new Error(`Unable to infer GitHub repo slug from origin: ${remote}`); return match[1]; }

function loadPRDetails(root: string, prNumber: string, repo: string): PRDetails { return JSON.parse(runGh(root, ['pr','view',prNumber,'--repo',repo,'--json','number,title,url,mergeStateStatus,reviewDecision,comments,reviews,statusCheckRollup'])) as PRDetails; }
function loadIssueComments(root: string, prNumber: string, repo: string): unknown[] { return JSON.parse(runGh(root, ['api', `repos/${repo}/issues/${prNumber}/comments`])) as unknown[]; }
function loadReviewComments(root: string, prNumber: string, repo: string): unknown[] { return JSON.parse(runGh(root, ['api', `repos/${repo}/pulls/${prNumber}/comments`])) as unknown[]; }
function loadPRDiff(root: string, prNumber: string, repo: string): string { return runGh(root, ['pr', 'diff', prNumber, '--repo', repo]); }

function truncate(text: string, limit: number): { text: string; truncated: boolean } { return text.length > limit ? { text: `${text.slice(0, limit)}\n\n[TRUNCATED by steward]`, truncated: true } : { text, truncated: false }; }

function buildPRReviewPayload(pr: PRDetails, issueComments: unknown[], reviewComments: unknown[], diffText: string, truncationLimit: number): string {
  const truncated = truncate(diffText, truncationLimit);
  return [
    '# HealthOS Steward PR Review Input',
    `PR: #${pr.number} ${pr.title}`,
    `URL: ${pr.url}`,
    `mergeStateStatus: ${pr.mergeStateStatus ?? 'unknown'}`,
    `reviewDecision: ${pr.reviewDecision ?? 'unknown'}`,
    `status checks found: ${Array.isArray(pr.statusCheckRollup) ? pr.statusCheckRollup.length : 0}`,
    `issue comments found: ${issueComments.length}`,
    `inline comments found: ${reviewComments.length}`,
    `diff_truncated: ${String(truncated.truncated)}`,
    'required output sections: summary, blockers, non-blocking issues, tests to request, docs to update, recommendation (approve/comment/request changes), confidence, limitations.',
    'invariant policy source: .healthos-steward/policies/invariant-policy.yaml',
    'rubric source: .healthos-steward/policies/pr-review-rubric.yaml',
    '',
    '## Diff',
    truncated.text,
  ].join('\n');
}

async function loadPromptFile(root: string, file: string): Promise<string> { return readFile(resolve(root, file), 'utf8'); }

async function invokeAndLog(root: string, command: string, request: StewardModelRequest, prNumber?: number, providerKind = 'disabled'): Promise<number> {
  const router = await createProviderRouter(root);
  let response;
  try { response = await router.invoke(request); } catch (error) { console.error(String(error)); return 2; }
  console.log(response.text || JSON.stringify(response, null, 2));
  const row: StewardModelInvocationLog = {
    timestamp: new Date().toISOString(), command, providerId: response.providerId, providerKind: providerKind as StewardModelInvocationLog['providerKind'], model: response.model,
    templateId: request.templateId, inputHash: response.inputHash, outputHash: response.outputHash, status: response.status, errorKind: response.errorKind,
    durationMs: response.durationMs, dryRun: request.dryRun, postedToGitHub: response.postedToGitHub, repoRef: gitSummary(root).head, prNumber,
  };
  await appendInvocationLog(resolve(root, 'runtime-data/steward/model-invocations.jsonl'), row);
  return response.status === 'ok' || response.status === 'dryRun' ? 0 : 2;
}

export async function runStewardCLI(argv: string[]): Promise<number> {
  const [command, maybeSubcommand, ...rest] = argv;
  const root = repoRoot();
  const subcommand = maybeSubcommand && !maybeSubcommand.startsWith('--') ? maybeSubcommand : undefined;
  const parsed = parseArgs(maybeSubcommand && maybeSubcommand.startsWith('--') ? [maybeSubcommand, ...rest] : rest);
  const router = await createProviderRouter(root);

  if (!command || command === 'help') { console.log('Usage: healthos-steward <status|scan|next-task|validate|review-pr|comment-pr|comment-issue|memory|prompt|handoff|providers|ask|delegate> ...'); return 0; }

  if (command === 'status') { console.log(JSON.stringify({ git: gitSummary(root), docs: await checkDocs(root), memory_state: await readProjectState(root), github_integration: githubIntegrationStatus(root), providers: router.checkProviders() }, null, 2)); return 0; }
  if (command === 'scan') { const docs = await checkDocs(root); console.log(JSON.stringify({ required_docs_ok: docs.ok.length, missing_docs: docs.missing }, null, 2)); return docs.missing.length === 0 ? 0 : 2; }
  if (command === 'next-task') { console.log('Use `healthos-steward prompt codex-next` to generate deterministic next task prompt.'); return 0; }
  if (command === 'validate') { const c='make validate-all'; if (parsed['dry-run'] === true) { console.log(`dry-run: ${c}`); return 0; } try { execSync(c, { cwd: root, stdio: 'inherit' }); await appendValidation(root, { timestamp:new Date().toISOString(), command:c, exitCode:0, status:'pass' }); return 0; } catch { await appendValidation(root, { timestamp:new Date().toISOString(), command:c, exitCode:1, status:'fail' }); return 1; } }

  if (command === 'providers' && subcommand === 'list') { console.log(JSON.stringify(router.listProviders(), null, 2)); return 0; }
  if (command === 'providers' && subcommand === 'check') { const checks = router.checkProviders(); console.log(JSON.stringify(checks, null, 2)); return checks.some((item) => item.status === 'misconfigured') ? 2 : 0; }
  if (command === 'providers' && subcommand === 'explain') { const providerId = String(parsed.provider ?? ''); if (!providerId) return 2; console.log(JSON.stringify(router.explainProvider(providerId), null, 2)); return 0; }

  if (command === 'ask') {
    const providerId = String(parsed.provider ?? ''); if (!providerId) { console.error('Missing --provider <id>'); return 2; }
    const template = String(parsed.template ?? 'model-next-task');
    const promptFile = String(parsed['prompt-file'] ?? `.healthos-steward/prompts/${template}.md`);
    const userPrompt = await loadPromptFile(root, promptFile).catch(() => '');
    const request: StewardModelRequest = { providerId, templateId: template, systemPrompt: await loadPromptFile(root, '.healthos-steward/prompts/llm-system.md').catch(() => 'HealthOS steward system prompt'), userPrompt, inputKind: 'freeform', repoContextRefs: REQUIRED_DOCS.slice(0, 6) as unknown as string[], dryRun: parsed['dry-run'] === true, allowNetwork: parsed['allow-network'] === true, allowGitHubWrite: false };
    return invokeAndLog(root, 'ask', request, undefined, router.explainProvider(providerId).kind);
  }

  if (command === 'review-pr') {
    const pr = String(parsed.pr ?? ''); if (!pr) { console.error('Missing required flag: --pr <number>'); return 2; }
    const providerId = String(parsed.provider ?? '');
    try {
      requireGithubReady(root);
      const repo = String(parsed.repo ?? getRepoSlug(root));
      const payload = buildPRReviewPayload(loadPRDetails(root, pr, repo), loadIssueComments(root, pr, repo), loadReviewComments(root, pr, repo), loadPRDiff(root, pr, repo), Number(parsed['diff-limit'] ?? 20000));
      if (!providerId) { console.log(payload); return 0; }
      const request: StewardModelRequest = { providerId, templateId: 'model-pr-review', systemPrompt: await loadPromptFile(root, '.healthos-steward/prompts/llm-system.md').catch(() => ''), userPrompt: payload, inputKind: 'prReview', repoContextRefs: ['docs/execution/10-invariant-matrix.md','.healthos-steward/policies/invariant-policy.yaml','.healthos-steward/policies/pr-review-rubric.yaml'], dryRun: parsed['dry-run'] === true, allowNetwork: parsed['allow-network'] === true, allowGitHubWrite: parsed['post-comment'] === true };
      const exit = await invokeAndLog(root, 'review-pr', request, Number(pr), router.explainProvider(providerId).kind);
      if (parsed['post-comment'] === true && parsed['dry-run'] !== true) {
        const body = '# Steward generated review\n\nPosted explicitly with --post-comment.';
        runGh(root, ['pr', 'comment', pr, '--repo', repo, '--body', body]);
      }
      return exit;
    } catch (error) { console.error(String(error instanceof Error ? error.message : error)); return 2; }
  }

  if (command === 'delegate') {
    const target = String(parsed.target ?? ''); const task = String(parsed.task ?? 'next');
    const providerId = target === 'codex' ? 'codex-cli-default' : target === 'claude' ? 'claude-code-cli-default' : '';
    if (!providerId) return 2;
    const request: StewardModelRequest = { providerId, templateId: 'model-next-task', systemPrompt: await loadPromptFile(root, '.healthos-steward/prompts/llm-system.md').catch(() => ''), userPrompt: `Delegate task=${task} for target=${target}`, inputKind: 'nextTask', repoContextRefs: ['docs/execution/12-next-agent-handoff.md'], dryRun: parsed['dry-run'] !== false, allowNetwork: false, allowGitHubWrite: false };
    return invokeAndLog(root, 'delegate', request, undefined, router.explainProvider(providerId).kind);
  }

  if (command === 'prompt' && subcommand === 'codex-next') {
    const providerId = String(parsed.provider ?? '');
    const prompt = await loadPromptFile(root, '.healthos-steward/prompts/model-next-task.md').catch(() => 'model-next-task template not found');
    if (!providerId) { console.log(prompt); return 0; }
    const request: StewardModelRequest = { providerId, templateId: 'model-next-task', systemPrompt: await loadPromptFile(root, '.healthos-steward/prompts/llm-system.md').catch(() => ''), userPrompt: prompt, inputKind: 'nextTask', repoContextRefs: REQUIRED_DOCS.slice(0, 6) as unknown as string[], dryRun: parsed['dry-run'] === true, allowNetwork: parsed['allow-network'] === true, allowGitHubWrite: false };
    return invokeAndLog(root, 'prompt codex-next', request, undefined, router.explainProvider(providerId).kind);
  }

  if (command === 'memory' && subcommand === 'show') { console.log(await readFile(resolve(stewardRoot(root), 'memory', String(parsed.file ?? 'project-state.json')), 'utf8')); return 0; }
  if (command === 'memory' && subcommand === 'update') { const file = resolve(stewardRoot(root), 'memory', String(parsed.file ?? 'project-state.json')); const current = (await exists(file)) ? await readJson<Record<string, unknown>>(file) : {}; await writeJson(file, { ...current, ...JSON.parse(String(parsed.json ?? '{}')), updated_at: new Date().toISOString() }); return 0; }
  if (command === 'handoff') { const out = resolve(stewardRoot(root), 'memory/next-agent-handoff.md'); await mkdir(dirname(out), { recursive: true }); await appendFile(out, `# Next agent handoff\nGenerated at ${new Date().toISOString()}\n`, 'utf8'); console.log(out); return 0; }

  if (command === 'comment-pr' || command === 'comment-issue') { console.error('Use explicit gh CLI flows outside default steward runbooks.'); return 2; }

  console.error(`Unknown command: ${[command, subcommand].filter(Boolean).join(' ')}`);
  return 1;
}
