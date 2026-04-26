import { access, appendFile, mkdir, readFile, writeFile } from 'node:fs/promises';
import { constants } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { execSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { createProviderRouter } from './providers/router.js';
import { appendInvocationLog } from './providers/invocation-log.js';
import type { StewardLLMInvocationLog, StewardLLMRequest } from './providers/types.js';

export const REQUIRED_DOCS = [
  'README.md', 'AGENTS.md', 'CLAUDE.md', 'docs/execution/02-status-and-tracking.md', 'docs/execution/06-scaffold-coverage-matrix.md',
  'docs/execution/10-invariant-matrix.md', 'docs/execution/11-current-maturity-map.md', 'docs/execution/12-next-agent-handoff.md',
  'docs/execution/13-scaffold-release-candidate-criteria.md', 'docs/execution/14-final-gap-register.md', 'docs/execution/15-scaffold-finalization-plan.md',
] as const;

export const REQUIRED_INVARIANTS = [
  'HealthOS is the full platform; AACI is one runtime inside HealthOS.',
  'GOS is an operational layer subordinate to Core law.',
  'Apps are interfaces and never constitutional law engines.',
  'Project Steward is an engineering orchestration tool, not clinical runtime or law engine.',
] as const;

type ValidationRecord = { timestamp: string; command: string; exitCode: number; status: 'pass' | 'fail' };

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

function gitSummary(root: string): { branch: string; head: string } {
  return {
    branch: execSync('git rev-parse --abbrev-ref HEAD', { cwd: root, encoding: 'utf8' }).trim(),
    head: execSync('git rev-parse --short HEAD', { cwd: root, encoding: 'utf8' }).trim(),
  };
}

function runGh(root: string, args: string[]): string { return execSync(`gh ${args.map((item) => `'${item.replace(/'/g, "'\\''")}'`).join(' ')}`, { cwd: root, encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] }); }
function githubReady(root: string): boolean { try { execSync('gh --version', { cwd: root, stdio: 'ignore' }); execSync('gh auth status', { cwd: root, stdio: 'ignore' }); return true; } catch { return false; } }
function getRepoSlug(root: string): string { const remote = execSync('git remote get-url origin', { cwd: root, encoding: 'utf8' }).trim(); const match = remote.match(/github\.com[:/](.+?)(?:\.git)?$/); if (!match) throw new Error(`Unable to infer GitHub repo slug from origin: ${remote}`); return match[1]; }

function loadPRDetails(root: string, prNumber: string, repo: string): PRDetails { return JSON.parse(runGh(root, ['pr', 'view', prNumber, '--repo', repo, '--json', 'number,title,url,mergeStateStatus,reviewDecision,comments,reviews,statusCheckRollup'])) as PRDetails; }
function loadPRDiff(root: string, prNumber: string, repo: string): string { return runGh(root, ['pr', 'diff', prNumber, '--repo', repo]); }

class StewardCore {
  constructor(private readonly root: string) {}
  async status() {
    return { git: gitSummary(this.root), docs: await this.scan(), memory_state: await readJson(resolve(stewardRoot(this.root), 'memory/project-state.json')), github_integration: { ready: githubReady(this.root) } };
  }
  async scan() {
    const ok: string[] = []; const missing: string[] = [];
    for (const rel of REQUIRED_DOCS) ((await exists(resolve(this.root, rel))) ? ok : missing).push(rel);
    return { ok, missing };
  }
  async validate(dryRun: boolean) {
    const c = 'make validate-all';
    if (dryRun) return { dryRun: c };
    try { execSync(c, { cwd: this.root, stdio: 'inherit' }); await this.appendValidation({ timestamp: new Date().toISOString(), command: c, exitCode: 0, status: 'pass' }); return { ok: true }; }
    catch { await this.appendValidation({ timestamp: new Date().toISOString(), command: c, exitCode: 1, status: 'fail' }); return { ok: false }; }
  }
  async memoryShow(file: string) { return readFile(resolve(stewardRoot(this.root), 'memory', file), 'utf8'); }
  async memoryUpdate(file: string, patch: Record<string, unknown>) {
    const path = resolve(stewardRoot(this.root), 'memory', file);
    const current = (await exists(path)) ? await readJson<Record<string, unknown>>(path) : {};
    await writeJson(path, { ...current, ...patch, updated_at: new Date().toISOString() });
  }
  async promptCodexNext() { return readFile(resolve(this.root, '.healthos-steward/prompts/model-next-task.md'), 'utf8'); }
  private async appendValidation(record: ValidationRecord) {
    const file = resolve(stewardRoot(this.root), 'memory/validation-history.json');
    const existing = (await exists(file)) ? await readJson<ValidationRecord[]>(file) : [];
    existing.push(record);
    await writeJson(file, existing.slice(-50));
  }
}

class StewardAgentRuntime {
  constructor(private readonly root: string) {}
  private async invoke(command: string, request: StewardLLMRequest, prNumber?: number) {
    const router = await createProviderRouter(this.root);
    const providerKind = router.explainProvider(request.providerId).kind;
    const response = await router.invoke(request);
    console.log(response.text || JSON.stringify(response, null, 2));
    const row: StewardLLMInvocationLog = { timestamp: new Date().toISOString(), command, providerId: response.providerId, providerKind, model: response.model, templateId: request.templateId, inputHash: response.inputHash, outputHash: response.outputHash, status: response.status, errorKind: response.errorKind, durationMs: response.durationMs, dryRun: request.dryRun, postedToGitHub: response.postedToGitHub, repoRef: gitSummary(this.root).head, prNumber };
    await appendInvocationLog(resolve(this.root, 'runtime-data/steward/model-invocations.jsonl'), row);
    return response.status === 'ok' || response.status === 'dryRun' ? 0 : 2;
  }
  async planNext(providerId: string, dryRun: boolean, allowNetwork: boolean) {
    const prompt = await readFile(resolve(this.root, '.healthos-steward/prompts/model-next-task.md'), 'utf8');
    return this.invoke('agent plan-next', { providerId, templateId: 'model-next-task', systemPrompt: 'HealthOS steward agent runtime', userPrompt: prompt, inputKind: 'nextTask', repoContextRefs: REQUIRED_DOCS as unknown as string[], dryRun, allowNetwork, allowGitHubWrite: false });
  }
  async architectureReview(providerId: string, dryRun: boolean, allowNetwork: boolean) {
    const prompt = await readFile(resolve(this.root, '.healthos-steward/prompts/model-architecture-review.md'), 'utf8');
    return this.invoke('agent architecture-review', { providerId, templateId: 'model-architecture-review', systemPrompt: 'HealthOS steward architecture reviewer', userPrompt: prompt, inputKind: 'architectureReview', repoContextRefs: ['docs/architecture/44-project-steward-agent.md'], dryRun, allowNetwork, allowGitHubWrite: false });
  }
  async reviewDiff(providerId: string, dryRun: boolean, allowNetwork: boolean) {
    const diff = execSync('git diff -- .', { cwd: this.root, encoding: 'utf8' });
    return this.invoke('agent review-diff', { providerId, templateId: 'model-pr-review', systemPrompt: 'HealthOS steward diff reviewer', userPrompt: diff || 'No local diff.', inputKind: 'diffReview', repoContextRefs: ['docs/execution/10-invariant-matrix.md'], dryRun, allowNetwork, allowGitHubWrite: false });
  }
  async reviewPr(providerId: string, pr: string, repo: string, dryRun: boolean, allowNetwork: boolean, postComment: boolean) {
    if (!githubReady(this.root)) throw new Error('GitHub integration unavailable: gh CLI missing or unauthenticated.');
    const data = loadPRDetails(this.root, pr, repo);
    const payload = `PR #${data.number}: ${data.title}\n${loadPRDiff(this.root, pr, repo).slice(0, 20000)}`;
    const code = await this.invoke('agent review-pr', { providerId, templateId: 'model-pr-review', systemPrompt: 'HealthOS steward PR reviewer', userPrompt: payload, inputKind: 'prReview', repoContextRefs: ['.healthos-steward/policies/invariant-policy.yaml', '.healthos-steward/policies/pr-review-rubric.yaml'], dryRun, allowNetwork, allowGitHubWrite: postComment });
    if (postComment && !dryRun) runGh(this.root, ['pr', 'comment', pr, '--repo', repo, '--body', '# Steward generated review\n\nPosted explicitly with --post-comment.']);
    return code;
  }
}

export async function runStewardCLI(argv: string[]): Promise<number> {
  const [command, maybeSubcommand, ...rest] = argv;
  const root = repoRoot();
  const subcommand = maybeSubcommand && !maybeSubcommand.startsWith('--') ? maybeSubcommand : undefined;
  const parsed = parseArgs(maybeSubcommand && maybeSubcommand.startsWith('--') ? [maybeSubcommand, ...rest] : rest);
  const core = new StewardCore(root);
  const agent = new StewardAgentRuntime(root);
  const router = await createProviderRouter(root);

  if (!command || command === 'help') {
    console.log('Usage: healthos-steward <status|scan|validate|memory|prompt|providers|agent> ...');
    return 0;
  }

  if (command === 'status') { console.log(JSON.stringify({ ...(await core.status()), providers: router.checkProviders() }, null, 2)); return 0; }
  if (command === 'scan') { const docs = await core.scan(); console.log(JSON.stringify({ required_docs_ok: docs.ok.length, missing_docs: docs.missing }, null, 2)); return docs.missing.length ? 2 : 0; }
  if (command === 'next-task') { console.log('Deprecated: use `healthos-steward agent plan-next --provider <id> --allow-network` or `healthos-steward prompt codex-next`.'); return 0; }
  if (command === 'validate') { const out = await core.validate(parsed['dry-run'] === true); if ('dryRun' in out) console.log(`dry-run: ${out.dryRun}`); return out.ok === false ? 1 : 0; }

  if (command === 'providers' && subcommand === 'list') { console.log(JSON.stringify(router.listProviders(), null, 2)); return 0; }
  if (command === 'providers' && subcommand === 'check') { const checks = router.checkProviders(); console.log(JSON.stringify(checks, null, 2)); return checks.some((item) => item.status === 'misconfigured') ? 2 : 0; }
  if (command === 'providers' && subcommand === 'explain') { const providerId = String(parsed.provider ?? ''); if (!providerId) return 2; console.log(JSON.stringify(router.explainProvider(providerId), null, 2)); return 0; }

  if (command === 'prompt' && subcommand === 'codex-next') { console.log(await core.promptCodexNext()); return 0; }
  if (command === 'memory' && subcommand === 'show') { console.log(await core.memoryShow(String(parsed.file ?? 'project-state.json'))); return 0; }
  if (command === 'memory' && subcommand === 'update') { await core.memoryUpdate(String(parsed.file ?? 'project-state.json'), JSON.parse(String(parsed.json ?? '{}'))); return 0; }

  if (command === 'agent') {
    const providerId = String(parsed.provider ?? '');
    if (!providerId) { console.error('Missing --provider <id>'); return 2; }
    if (parsed['allow-network'] !== true) { console.error('Agent runtime requires explicit --allow-network for real invocations.'); return 2; }
    if (subcommand === 'plan-next') return agent.planNext(providerId, parsed['dry-run'] === true, true);
    if (subcommand === 'architecture-review') return agent.architectureReview(providerId, parsed['dry-run'] === true, true);
    if (subcommand === 'review-diff') return agent.reviewDiff(providerId, parsed['dry-run'] === true, true);
    if (subcommand === 'review-pr') {
      const pr = String(parsed.pr ?? ''); if (!pr) return 2;
      return agent.reviewPr(providerId, pr, String(parsed.repo ?? getRepoSlug(root)), parsed['dry-run'] === true, true, parsed['post-comment'] === true);
    }
    if (subcommand === 'handoff' || subcommand === 'generate-codex-prompt' || subcommand === 'sync-memory') {
      return agent.planNext(providerId, parsed['dry-run'] === true, true);
    }
    return 2;
  }

  console.error(`Unknown command: ${[command, subcommand].filter(Boolean).join(' ')}`);
  return 1;
}
