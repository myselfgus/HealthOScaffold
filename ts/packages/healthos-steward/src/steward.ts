import { access, mkdir, readFile, writeFile } from 'node:fs/promises';
import { constants } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { execSync } from 'node:child_process';

export const REQUIRED_DOCS = [
  'README.md',
  'AGENTS.md',
  'CLAUDE.md',
  'docs/execution/02-status-and-tracking.md',
  'docs/execution/06-scaffold-coverage-matrix.md',
  'docs/execution/10-invariant-matrix.md',
  'docs/execution/11-current-maturity-map.md',
  'docs/execution/12-next-agent-handoff.md',
  'docs/execution/13-scaffold-release-candidate-criteria.md',
  'docs/execution/14-final-gap-register.md',
  'docs/execution/15-scaffold-finalization-plan.md',
  'docs/execution/todo/',
  'docs/execution/skills/',
] as const;

export const REQUIRED_INVARIANTS = [
  'HealthOS is the full platform; AACI is one runtime inside HealthOS.',
  'GOS is an operational layer subordinate to Core law.',
  'Apps are interfaces and never constitutional law engines.',
  'Scribe/Sortio/CloudClinic do not access storage directly.',
  'Human gate is mandatory for regulatory effects and final artifacts.',
  'Draft is never final document; finalization requires approved gate.',
  'Consent/habilitation/finality/lawfulContext/storage/provenance/audit remain in Core.',
  'Direct identifiers and reidentification mapping are sensitive layers.',
  'Provider output is not a clinical act; GOS/network/user-agent are not authorization.',
  'No fictitious clinical examples; no production-ready claims; no fake integrations.',
] as const;

type ValidationRecord = {
  timestamp: string;
  command: string;
  exitCode: number;
  status: 'pass' | 'fail';
};

type GitHubIntegrationStatus = {
  available: boolean;
  authenticated: boolean;
  mode: 'gh-cli' | 'unavailable';
};

type PRDetails = {
  number: number;
  title: string;
  url: string;
  mergeStateStatus?: string;
  reviewDecision?: string;
  comments?: unknown[];
  reviews?: unknown[];
  statusCheckRollup?: unknown[];
};

function repoRoot(): string {
  return resolve(dirname(fileURLToPath(import.meta.url)), '..', '..', '..', '..');
}

function stewardRoot(root: string): string {
  return resolve(root, '.healthos-steward');
}

async function exists(path: string): Promise<boolean> {
  try {
    await access(path, constants.F_OK);
    return true;
  } catch {
    return false;
  }
}

async function readJson<T>(path: string): Promise<T> {
  const raw = await readFile(path, 'utf8');
  return JSON.parse(raw) as T;
}

async function writeJson(path: string, value: unknown): Promise<void> {
  await mkdir(dirname(path), { recursive: true });
  await writeFile(path, JSON.stringify(value, null, 2) + '\n', 'utf8');
}

function parseArgs(args: string[]): Record<string, string | boolean> {
  const parsed: Record<string, string | boolean> = {};
  for (let i = 0; i < args.length; i += 1) {
    const arg = args[i];
    if (arg.startsWith('--')) {
      const key = arg.slice(2);
      const next = args[i + 1];
      if (!next || next.startsWith('--')) {
        parsed[key] = true;
      } else {
        parsed[key] = next;
        i += 1;
      }
    }
  }
  return parsed;
}

async function loadNextGap(root: string): Promise<string> {
  const gapFile = resolve(root, 'docs/execution/14-final-gap-register.md');
  const content = await readFile(gapFile, 'utf8');
  const lines = content.split('\n').filter((line) => line.includes('| GAP-'));
  const blocker = lines.find((line) => line.includes('| scaffold blocker |'));
  return blocker ?? lines[0] ?? 'No gap rows found.';
}

function markdownNextTask(gapLine: string): string {
  const cols = gapLine.split('|').map((part) => part.trim()).filter(Boolean);
  return [
    'task title: Close highest-priority documented gap',
    `why now: Derived from gap register row: ${cols.slice(0, 4).join(' / ')}`,
    'files to read: docs/execution/02-status-and-tracking.md; docs/execution/14-final-gap-register.md; docs/execution/15-scaffold-finalization-plan.md; matching docs/execution/todo/*.md and docs/execution/skills/*.md',
    `invariants: ${REQUIRED_INVARIANTS.join(' | ')}`,
    'expected changes: docs + contracts/tests for the selected gap only; no architectural law migration.',
    'tests to run: make validate-all; make ts-build; make ts-test',
    'restrictions: no fake integrations, no production claims, no secrets in memory.',
    'done criteria: gap status updated in tracking/todo with validation evidence.',
  ].join('\n');
}

async function checkDocs(root: string): Promise<{ ok: string[]; missing: string[] }> {
  const ok: string[] = [];
  const missing: string[] = [];
  for (const rel of REQUIRED_DOCS) {
    const full = resolve(root, rel);
    if (await exists(full)) {
      ok.push(rel);
    } else {
      missing.push(rel);
    }
  }
  return { ok, missing };
}

async function readProjectState(root: string): Promise<Record<string, unknown>> {
  const stateFile = resolve(stewardRoot(root), 'memory/project-state.json');
  return readJson<Record<string, unknown>>(stateFile);
}

async function appendValidation(root: string, record: ValidationRecord): Promise<void> {
  const file = resolve(stewardRoot(root), 'memory/validation-history.json');
  const existing = (await exists(file)) ? await readJson<ValidationRecord[]>(file) : [];
  existing.push(record);
  await writeJson(file, existing.slice(-50));
}

function gitSummary(root: string): { branch: string; head: string } {
  const branch = execSync('git rev-parse --abbrev-ref HEAD', { cwd: root, encoding: 'utf8' }).trim();
  const head = execSync('git rev-parse --short HEAD', { cwd: root, encoding: 'utf8' }).trim();
  return { branch, head };
}

function runGh(root: string, args: string[]): string {
  return execSync(`gh ${args.map((item) => `'${item.replace(/'/g, "'\\''")}'`).join(' ')}`, {
    cwd: root,
    encoding: 'utf8',
    stdio: ['ignore', 'pipe', 'pipe'],
  });
}

function githubIntegrationStatus(root: string): GitHubIntegrationStatus {
  try {
    execSync('gh --version', { cwd: root, stdio: 'ignore' });
  } catch {
    return { available: false, authenticated: false, mode: 'unavailable' };
  }

  try {
    execSync('gh auth status', { cwd: root, stdio: 'ignore' });
    return { available: true, authenticated: true, mode: 'gh-cli' };
  } catch {
    return { available: true, authenticated: false, mode: 'gh-cli' };
  }
}

function parseJsonSafe<T>(raw: string): T {
  return JSON.parse(raw) as T;
}

function requireGithubReady(root: string): GitHubIntegrationStatus {
  const status = githubIntegrationStatus(root);
  if (!status.available) {
    throw new Error('GitHub integration unavailable: gh CLI is not installed.');
  }
  if (!status.authenticated) {
    throw new Error('GitHub integration unavailable: gh CLI is not authenticated (run gh auth login).');
  }
  return status;
}

function getRepoSlug(root: string): string {
  const remote = execSync('git remote get-url origin', { cwd: root, encoding: 'utf8' }).trim();
  const match = remote.match(/github\.com[:/](.+?)(?:\.git)?$/);
  if (!match) {
    throw new Error(`Unable to infer GitHub repo slug from origin: ${remote}`);
  }
  return match[1];
}

function loadPRDetails(root: string, prNumber: string, repo: string): PRDetails {
  const viewRaw = runGh(root, [
    'pr',
    'view',
    prNumber,
    '--repo',
    repo,
    '--json',
    'number,title,url,mergeStateStatus,reviewDecision,comments,reviews,statusCheckRollup',
  ]);
  return parseJsonSafe<PRDetails>(viewRaw);
}

function loadIssueComments(root: string, prNumber: string, repo: string): unknown[] {
  const raw = runGh(root, ['api', `repos/${repo}/issues/${prNumber}/comments`]);
  return parseJsonSafe<unknown[]>(raw);
}

function loadReviewComments(root: string, prNumber: string, repo: string): unknown[] {
  const raw = runGh(root, ['api', `repos/${repo}/pulls/${prNumber}/comments`]);
  return parseJsonSafe<unknown[]>(raw);
}

function buildPRReviewReport(pr: PRDetails, issueComments: unknown[], reviewComments: unknown[]): string {
  const checks = Array.isArray(pr.statusCheckRollup) ? pr.statusCheckRollup.length : 0;
  const inlineComments = reviewComments.length;
  const issueLevelComments = issueComments.length;

  const checklist = [
    '- [ ] PR moved law into app surface?',
    '- [ ] PR moved law into GOS?',
    '- [ ] PR moved law into AACI?',
    '- [ ] PR allows gate bypass?',
    '- [ ] PR exposes raw CPF?',
    '- [ ] PR exposes reidentification mapping?',
    '- [ ] PR invents fictitious clinical data/examples?',
    '- [ ] PR claims false maturity/production readiness?',
    '- [ ] PR updated docs/execution/02-status-and-tracking.md and relevant TODO?',
    '- [ ] PR updated tests/contracts together when required?',
    '- [ ] PR executed validation harness (make validate-all)?',
    '- [ ] PR kept Swift/TS/schema/SQL contracts synchronized when changed?',
  ].join('\n');

  return [
    '# PR Review Scaffold (GitHub integrated)',
    `PR: #${pr.number} ${pr.title}`,
    `URL: ${pr.url}`,
    `mergeStateStatus: ${pr.mergeStateStatus ?? 'unknown'}`,
    `reviewDecision: ${pr.reviewDecision ?? 'unknown'}`,
    `status checks found: ${checks}`,
    `issue comments found: ${issueLevelComments}`,
    `inline review comments found: ${inlineComments}`,
    '',
    '## Mandatory checklist',
    checklist,
  ].join('\n');
}

export async function runStewardCLI(argv: string[]): Promise<number> {
  const [command, maybeSubcommand, ...rest] = argv;
  const root = repoRoot();
  const steward = stewardRoot(root);
  const subcommand = maybeSubcommand && !maybeSubcommand.startsWith('--') ? maybeSubcommand : undefined;
  const parsed = parseArgs(maybeSubcommand && maybeSubcommand.startsWith('--') ? [maybeSubcommand, ...rest] : rest);

  if (!command || command === 'help') {
    console.log('Usage: healthos-steward <status|scan|next-task|validate|review-pr|comment-pr|comment-issue|memory|prompt|handoff> ...');
    return 0;
  }

  if (command === 'status') {
    const docs = await checkDocs(root);
    const state = await readProjectState(root);
    const git = gitSummary(root);
    console.log(JSON.stringify({ git, docs, memory_state: state, github_integration: githubIntegrationStatus(root) }, null, 2));
    return 0;
  }

  if (command === 'scan') {
    const docs = await checkDocs(root);
    console.log(JSON.stringify({ required_docs_ok: docs.ok.length, missing_docs: docs.missing }, null, 2));
    return docs.missing.length === 0 ? 0 : 2;
  }

  if (command === 'next-task') {
    const gapLine = await loadNextGap(root);
    console.log(markdownNextTask(gapLine));
    return 0;
  }

  if (command === 'validate') {
    const dryRun = parsed['dry-run'] === true;
    const validationCommand = 'make validate-all';
    if (dryRun) {
      console.log(`dry-run: ${validationCommand}`);
      return 0;
    }

    try {
      execSync(validationCommand, { cwd: root, stdio: 'inherit' });
      await appendValidation(root, { timestamp: new Date().toISOString(), command: validationCommand, exitCode: 0, status: 'pass' });
      return 0;
    } catch {
      await appendValidation(root, { timestamp: new Date().toISOString(), command: validationCommand, exitCode: 1, status: 'fail' });
      return 1;
    }
  }

  if (command === 'review-pr') {
    const pr = String(parsed.pr ?? '');
    if (!pr) {
      console.error('Missing required flag: --pr <number>');
      return 2;
    }

    try {
      requireGithubReady(root);
      const repo = String(parsed.repo ?? getRepoSlug(root));
      const prDetails = loadPRDetails(root, pr, repo);
      const issueComments = loadIssueComments(root, pr, repo);
      const reviewComments = loadReviewComments(root, pr, repo);
      console.log(buildPRReviewReport(prDetails, issueComments, reviewComments));
      return 0;
    } catch (error) {
      console.error(String(error instanceof Error ? error.message : error));
      return 2;
    }
  }

  if (command === 'comment-pr') {
    const pr = String(parsed.pr ?? '');
    const body = String(parsed.body ?? '');
    if (!pr || !body) {
      console.error('Usage: healthos-steward comment-pr --pr <number> --body "..."');
      return 2;
    }

    try {
      requireGithubReady(root);
      const repo = String(parsed.repo ?? getRepoSlug(root));
      runGh(root, ['pr', 'comment', pr, '--repo', repo, '--body', body]);
      console.log(JSON.stringify({ commented: true, target: 'pr', pr, repo }, null, 2));
      return 0;
    } catch (error) {
      console.error(String(error instanceof Error ? error.message : error));
      return 2;
    }
  }

  if (command === 'comment-issue') {
    const issue = String(parsed.issue ?? '');
    const body = String(parsed.body ?? '');
    if (!issue || !body) {
      console.error('Usage: healthos-steward comment-issue --issue <number> --body "..."');
      return 2;
    }

    try {
      requireGithubReady(root);
      const repo = String(parsed.repo ?? getRepoSlug(root));
      runGh(root, ['issue', 'comment', issue, '--repo', repo, '--body', body]);
      console.log(JSON.stringify({ commented: true, target: 'issue', issue, repo }, null, 2));
      return 0;
    } catch (error) {
      console.error(String(error instanceof Error ? error.message : error));
      return 2;
    }
  }

  if (command === 'memory' && subcommand === 'show') {
    const file = String(parsed.file ?? 'project-state.json');
    const full = resolve(steward, 'memory', file);
    console.log(await readFile(full, 'utf8'));
    return 0;
  }

  if (command === 'memory' && subcommand === 'update') {
    const file = String(parsed.file ?? 'project-state.json');
    const payload = String(parsed.json ?? '{}');
    const full = resolve(steward, 'memory', file);
    const current = (await exists(full)) ? await readJson<Record<string, unknown>>(full) : {};
    const next = { ...current, ...JSON.parse(payload), updated_at: new Date().toISOString() };
    await writeJson(full, next);
    console.log(JSON.stringify({ updated: file }, null, 2));
    return 0;
  }

  if (command === 'prompt' && subcommand === 'codex-next') {
    const state = await readProjectState(root);
    const gapLine = await loadNextGap(root);
    const prompt = [
      '# HealthOS Project Steward generated prompt',
      `state summary: ${JSON.stringify(state)}`,
      `recommended task:\n${markdownNextTask(gapLine)}`,
      `required reading: ${REQUIRED_DOCS.join(', ')}`,
      `invariants: ${REQUIRED_INVARIANTS.join(' | ')}`,
      'deliverables: update docs/execution tracking + relevant todo + tests',
      'tests: make validate-all; make ts-build; make ts-test',
      'absolute restrictions: no clinical agent behavior, no fake integrations, no secrets.',
    ].join('\n\n');
    console.log(prompt);
    return 0;
  }

  if (command === 'handoff') {
    const gapLine = await loadNextGap(root);
    const historyFile = resolve(steward, 'memory/validation-history.json');
    const history = (await exists(historyFile)) ? await readJson<ValidationRecord[]>(historyFile) : [];
    const latestValidation = history[history.length - 1] ?? null;
    const body = [
      '# Next agent handoff (Project Steward)',
      `Generated at: ${new Date().toISOString()}`,
      'State: controlled implementation / scaffold hardening.',
      `Last validation: ${latestValidation ? `${latestValidation.status} (${latestValidation.command}) at ${latestValidation.timestamp}` : 'none recorded'}`,
      `Next probable task: ${gapLine}`,
      'Risks: doc drift, invariant drift, unsynchronized TODO/tracking.',
      'Validation commands: make validate-all; make ts-build; make ts-test',
      'Instruction: consult docs/execution/12-next-agent-handoff.md before coding and keep official docs as source of truth.',
    ].join('\n\n');
    const out = resolve(steward, 'memory/next-agent-handoff.md');
    await writeFile(out, body + '\n', 'utf8');
    console.log(out);
    return 0;
  }

  console.error(`Unknown command: ${[command, subcommand].filter(Boolean).join(' ')}`);
  return 1;
}
