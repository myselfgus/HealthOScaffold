# Phase 3 Prompt — Xcode Agent stream design specifications

**Version**: 1.0 | **Date**: 2026-04-28 | **Plan source**: `docs/execution/20-documental-todos-work-plan.md`

---

## IDENTITY AND MISSION

You are a governance-preserving documentation agent working inside the **HealthOScaffold** repository — the construction repository for **HealthOS**. Your mission is to write **three design specification documents** for unimplemented Xcode Agent streams:

- **Stream C** (XA-004): Tool runtime contracts — typed capabilities the runtime can invoke
- **Stream D**: Model backend layer contract — how a model backend subordinates to the runtime
- **Stream F**: Xcode context envelope — how Xcode context is bridged into runtime requests

These are architecture design specs. You are writing specifications that a future code-writing agent will use to implement the actual TypeScript code. You are not writing the code yourself. You are not modifying any `.ts`, `.swift`, `.py`, or `.sql` files.

**Prerequisite**: Phase 2 (`codex/phase-2-architecture-proposals`) must be merged before Phase 3 begins.

---

## ABSOLUTE INVARIANTS — NEVER VIOLATE

1. **HealthOS is the platform.** HealthOScaffold is the historical repository name.
2. **No production-readiness claim.** No spec may imply any stream is implemented or production-ready.
3. **No provider-centric architecture reintroduction.** Stream D must not bring back the old provider-centric `healthos-steward` pattern. The runtime owns orchestration; the backend is subordinate.
4. **Xcode Intelligence is not HealthOS Core.** Stream F's envelope is input to the Steward runtime — not to the HealthOS clinical runtime. Apple controls the Xcode Intelligence surface.
5. **No clinical content in tool/backend/envelope specs.** No direct identifiers, patient data, or clinical session content in any stream spec.
6. **Fail-closed always.** Every tool invocation, backend call, and context envelope operation must define what happens on failure — and the answer must be fail-closed.
7. **Tracking is mandatory.** After each task, update `docs/execution/02-status-and-tracking.md` and `docs/execution/18-healthos-xcode-agent-task-tracker.md` in the same work unit.
8. **Specs must be implementable.** Each specification must be precise enough that a TypeScript developer can implement it without asking clarifying questions. If a field type is ambiguous, define it explicitly.

---

## BRANCH SETUP (do this first)

```bash
git checkout main
git pull origin main
git checkout -b codex/phase-3-xcode-agent-streams
```

---

## MANDATORY PRE-READING ORDER

Read every file below before writing. Do not skip.

```
1.  docs/execution/20-documental-todos-work-plan.md              ← tasks 7–9 in the master plan
2.  docs/execution/01-agent-operating-protocol.md                ← operating rules
3.  docs/execution/18-healthos-xcode-agent-task-tracker.md       ← Streams C, D, F definitions + working rules
4.  docs/execution/17-healthos-xcode-agent-migration-plan.md     ← WS-2, WS-3 objectives
5.  docs/architecture/45-healthos-xcode-agent.md                 ← target arch (READ IN FULL)
6.  docs/architecture/46-apple-sovereignty-architecture.md       ← Apple boundary doc (for Stream F)
7.  docs/architecture/44-project-steward-agent.md                ← Steward doc (context for Stream D)
8.  docs/execution/02-status-and-tracking.md                     ← current status (top 80 lines)
9.  ts/packages/healthos-steward/src/runtime/types.ts            ← current runtime types baseline
10. ts/packages/healthos-steward/README.md                       ← package baseline description
```

After reading, confirm:
- `docs/architecture/45-healthos-xcode-agent.md` exists → YES/NO
- `docs/architecture/46-apple-sovereignty-architecture.md` exists → YES/NO
- `ts/packages/healthos-steward/src/runtime/types.ts` exists → YES/NO

If any file is missing, read what is available and note the gap explicitly.

Also note: the working rules in `docs/execution/18-healthos-xcode-agent-task-tracker.md` include:
> "do not reintroduce provider-centric architecture into the package"

This constraint governs every design decision you make in Phase 3.

---

## CURRENT IMPLEMENTATION BASELINE (memorize before writing)

The current `ts/packages/healthos-steward/` baseline (from XA-002) contains:
- `src/runtime/types.ts` — runtime request/response and session types
- `src/runtime/session-store.ts` — file-backed session store
- `src/runtime/runtime.ts` — minimal runtime request handler
- `src/steward.ts` — CLI entry points (status, runtime, session)
- `src/index.ts` — package exports
- `src/cli.ts` — CLI surface

**What is NOT implemented** (your specs target these gaps):
- Tool runtime (Stream C)
- Model backend layer (Stream D)
- Conversational CLI loop (Stream E — out of scope for Phase 3)
- Xcode surface bridge (Stream F)

Your specs must extend the existing types surface, not replace it.

---

## TASK 7 OF 9 (PHASE 3 TASK 1 OF 3) — Stream C / XA-004: Tool runtime contracts

**Source**: `docs/execution/18-healthos-xcode-agent-task-tracker.md` → Stream C, XA-004
**Target file**: `docs/architecture/45-healthos-xcode-agent.md` (add new section)
**Supporting update**: `docs/execution/18-healthos-xcode-agent-task-tracker.md` (mark Stream C design-complete)

### What you are specifying

A "tool" in the Steward runtime is a typed capability that the runtime can invoke on behalf of a session. When a user asks Steward to "find where X is defined" or "run the tests", the runtime dispatches to a tool. Tools are discrete, typed, and independently fail-closeable — a failed tool invocation does not crash the session.

The tool runtime is the layer that manages tool discovery, dispatch, capability declaration, and failure handling. You are defining its contract — not its implementation.

### What to add to `docs/architecture/45-healthos-xcode-agent.md`

Find a logical insertion point in the document. Add a new `## Tool runtime contracts` section.

The section must contain:

#### 1. Tool contract definition

A tool is defined by three parts: a capability declaration, an invocation interface, and a result type.

**ToolCapability** — what a tool can do (declared at registration time, before invocation):

```typescript
interface ToolCapability {
  id: string;                // unique tool identifier, e.g. "file.read"
  category: ToolCategory;   // see categories below
  description: string;      // one-sentence description of what this tool does
  xcodeAware: boolean;      // true if this tool uses Xcode-specific context
  requiresActiveFile: boolean; // true if this tool requires an active file in context
  supportsGlob: boolean;    // true if this tool accepts glob patterns as input
}

type ToolCategory =
  | "file"        // read, write, list, glob
  | "search"      // grep, symbol search, reference search
  | "build"       // build project, get build log, get build errors
  | "test"        // run tests, get test results
  | "repository"  // git status, git diff, read tracked file
  | "xcode"       // Xcode-specific: diagnostics, navigator, current file
```

**ToolInvocation** — the input to a tool invocation:

```typescript
interface ToolInvocation {
  toolId: string;         // must match a registered ToolCapability.id
  sessionId: string;      // must match an active session
  params: Record<string, unknown>; // tool-specific parameters (typed per-tool below)
  dryRun: boolean;        // when true, return what would happen without doing it
}
```

**ToolResult** — the output of a tool invocation:

```typescript
interface ToolResult {
  toolId: string;
  sessionId: string;
  status: "ok" | "error" | "unavailable" | "denied";
  payload: unknown;       // tool-specific output; present only when status === "ok"
  errorCode?: string;     // present when status !== "ok"
  errorMessage?: string;  // human-readable; must not contain clinical data or secrets
  durationMs: number;
}
```

**Status semantics**:
```
ok          — tool invocation succeeded; payload is present
error       — tool invocation failed at runtime (process error, timeout, I/O failure)
unavailable — tool is not available in this environment (Xcode not open, no project loaded)
denied      — tool invocation was refused by policy (not implemented yet; reserved)
```

#### 2. Tool categories with per-tool parameter types

For each category, define the tools and their parameter types precisely enough to implement.

**Category: file**

```typescript
// file.read
type FileReadParams = { path: string; offset?: number; limit?: number };
type FileReadResult = { content: string; totalLines: number; path: string };

// file.list
type FileListParams = { directory: string; glob?: string };
type FileListResult = { paths: string[]; count: number };

// file.glob
type FileGlobParams = { pattern: string; basePath?: string };
type FileGlobResult = { matches: string[]; count: number };
```

**Category: search**

```typescript
// search.grep
type GrepParams = { pattern: string; path?: string; glob?: string; caseSensitive?: boolean };
type GrepResult = { matches: Array<{ file: string; line: number; content: string }>; count: number };

// search.symbol
type SymbolSearchParams = { name: string; kind?: "function" | "type" | "variable" | "class" };
type SymbolSearchResult = { symbols: Array<{ name: string; file: string; line: number; kind: string }>; count: number };
```

**Category: build**

```typescript
// build.run
type BuildParams = { target?: string; configuration?: "Debug" | "Release" };
type BuildResult = { success: boolean; errorCount: number; warningCount: number; logSnippet?: string };

// build.getLog
type BuildLogParams = { lines?: number };
type BuildLogResult = { log: string; lineCount: number };

// build.getErrors
type BuildErrorsParams = {};
type BuildErrorsResult = { errors: Array<{ file: string; line: number; column: number; message: string }>; count: number };
```

**Category: test**

```typescript
// test.runAll
type TestRunAllParams = { target?: string };
type TestRunAllResult = { passed: number; failed: number; skipped: number; duration_ms: number };

// test.runSome
type TestRunSomeParams = { testNames: string[]; target?: string };
type TestRunSomeResult = { results: Array<{ name: string; status: "passed" | "failed" | "skipped"; duration_ms: number }> };

// test.getResults
type TestResultsParams = {};
type TestResultsResult = { lastRun?: { passed: number; failed: number; skipped: number; timestamp: string } };
```

**Category: repository**

```typescript
// repository.gitStatus
type GitStatusParams = {};
type GitStatusResult = { branch: string; modified: string[]; staged: string[]; untracked: string[] };

// repository.gitDiff
type GitDiffParams = { staged?: boolean; path?: string };
type GitDiffResult = { diff: string; filesChanged: number };
```

**Category: xcode**

```typescript
// xcode.getActiveFile
type XcodeActiveFileParams = {};
type XcodeActiveFileResult = { path: string; language: string; lineCount: number } | null;

// xcode.getDiagnostics
type XcodeDiagnosticsParams = { filePath?: string };
type XcodeDiagnosticsResult = { diagnostics: Array<{ severity: "error" | "warning"; message: string; file: string; line: number; column: number }>; count: number };
```

#### 3. Tool runtime interface

The tool runtime is the module that manages registration and dispatch:

```typescript
interface ToolRuntime {
  register(capability: ToolCapability, handler: ToolHandler): void;
  invoke(invocation: ToolInvocation): Promise<ToolResult>;
  getCapabilities(): ToolCapability[];
  isAvailable(toolId: string): boolean;
}

type ToolHandler = (params: Record<string, unknown>, context: ToolContext) => Promise<ToolResult>;

interface ToolContext {
  sessionId: string;
  dryRun: boolean;
  xcodeContext?: XcodeContext; // available only for xcodeAware tools; defined in Stream F spec
}
```

#### 4. Fail-closed rules for tools

```
1. If a tool's handler throws, the runtime MUST catch it and return
   { status: "error", errorCode: "handler.exception" } — never propagate unhandled exceptions.

2. If a tool is invoked with an unrecognized toolId, the runtime returns
   { status: "unavailable", errorCode: "tool.not_registered" }.

3. If xcodeAware is true and no Xcode context is available, the runtime returns
   { status: "unavailable", errorCode: "xcode.context.unavailable" }.

4. Tool results must never contain secrets, tokens, credentials, or clinical payloads.

5. dry_run: true must never execute a write operation or build process. It must return
   { status: "ok", payload: { wouldDo: string } } describing the action without taking it.

6. Tool invocations must time out. Define a per-category default timeout:
   - file: 5 000 ms
   - search: 10 000 ms
   - build: 120 000 ms
   - test: 300 000 ms
   - repository: 10 000 ms
   - xcode: 5 000 ms
   On timeout: { status: "error", errorCode: "tool.timeout" }.
```

#### 5. Maturity note

```
**Maturity**: This tool runtime specification is doctrine-only. No tool runtime implementation
exists in ts/packages/healthos-steward/ as of this writing. This specification is the design
contract for XA-004. Implementation is a separate future work unit. No production-readiness
claim is made.
```

### After completing Task 7

Update `docs/execution/18-healthos-xcode-agent-task-tracker.md`:
- Change Stream C status from `TODO` to `design-complete`.
- Add note: "Design spec added to docs/architecture/45-healthos-xcode-agent.md ## Tool runtime contracts"

**Definition of done**: Each of the 6 tool categories has parameter types, result types, and at least one tool definition. The ToolRuntime interface, ToolCapability, ToolInvocation, ToolResult types are fully specified. All 6 fail-closed rules are documented.

---

## TASK 8 OF 9 (PHASE 3 TASK 2 OF 3) — Stream D: Model backend layer contract

**Source**: `docs/execution/18-healthos-xcode-agent-task-tracker.md` → Stream D
**Target file**: `docs/architecture/45-healthos-xcode-agent.md` (add new section)
**Supporting update**: `docs/execution/18-healthos-xcode-agent-task-tracker.md` (mark Stream D design-complete)

### The critical constraint

The previous `healthos-steward` package was removed and reset precisely because it built provider invocation as the primary architectural path. The new baseline deliberately removes provider orchestration as the entry point.

Stream D's contract must make the runtime sovereign and the model backend subordinate. The backend:
- does NOT decide what to do
- does NOT manage sessions
- does NOT select tools
- ONLY handles model invocation when the runtime calls it

If your spec ever reads like "the backend is the orchestrator that calls the runtime", you have violated this constraint. The runtime calls the backend. Not the other way around.

### What to add to `docs/architecture/45-healthos-xcode-agent.md`

Add a new `## Model backend contract` section.

The section must contain:

#### 1. Architectural position statement

```
The model backend is a subordinate component of the Steward runtime.
It handles model invocation only. It does not manage sessions, select tools,
enforce policy, or drive the conversation loop.

The runtime calls the backend. The backend returns a completion.
The runtime decides what to do with the completion.

This separation exists because the previous provider-centric architecture
conflated model invocation with runtime orchestration — creating a system
where the model was driving repository decisions. The new architecture
prevents this by making the backend a pure I/O surface.
```

#### 2. Backend capability declaration

Before invocation, a backend must declare its capabilities:

```typescript
interface BackendCapability {
  id: string;                      // unique backend identifier, e.g. "anthropic-claude-sonnet"
  provider: string;                // provider name: "anthropic" | "openai" | "xai" | "local"
  modelId: string;                 // model identifier as accepted by the provider API
  supportsStreaming: boolean;      // true if the backend can stream responses
  supportsToolUse: boolean;        // true if the backend can invoke tools natively
  contextWindowTokens: number;     // maximum context window in tokens
  maxOutputTokens: number;         // maximum output tokens per completion
  requiresNetwork: boolean;        // true if this backend requires external network access
  offline: boolean;                // true if this backend works without internet
}
```

#### 3. Backend invocation contract

The runtime invokes the backend with a structured request:

```typescript
interface BackendRequest {
  backendId: string;          // must match a registered BackendCapability.id
  sessionId: string;          // the calling session
  messages: BackendMessage[]; // conversation history to send to the model
  tools?: BackendToolSpec[];  // optional tool specs to expose to the model
  maxTokens?: number;         // override maxOutputTokens for this call
  dryRun: boolean;            // when true, return what would be sent without calling
  allowNetwork: boolean;      // explicit caller consent to use network; backends with
                               // requiresNetwork: true must refuse if false
}

interface BackendMessage {
  role: "user" | "assistant" | "system";
  content: string;    // text only; no direct identifiers; no clinical payloads
}

interface BackendToolSpec {
  name: string;
  description: string;
  inputSchema: Record<string, unknown>; // JSON Schema for tool parameters
}
```

#### 4. Backend response contract

```typescript
interface BackendResponse {
  backendId: string;
  sessionId: string;
  status: "ok" | "error" | "unavailable" | "denied";
  completion?: BackendCompletion;  // present only when status === "ok"
  errorCode?: string;
  errorMessage?: string;           // human-readable; no secrets; no clinical data
  inputTokens?: number;            // usage, if available
  outputTokens?: number;
  durationMs: number;
}

interface BackendCompletion {
  content: string;          // assistant text; validated non-empty on "ok"
  toolCalls?: BackendToolCall[]; // present only if the model invoked a tool
  stopReason: "end_turn" | "max_tokens" | "tool_use" | "stop_sequence";
}

interface BackendToolCall {
  id: string;
  toolName: string;
  inputParams: Record<string, unknown>;
}
```

**Status semantics**:
```
ok          — model returned a non-empty completion
error       — model call failed (network error, timeout, API error, empty response)
unavailable — backend not registered or requiresNetwork: true but allowNetwork: false
denied      — model refused the request (content policy, safety filter)
```

#### 5. Backend runtime interface

```typescript
interface ModelBackendRuntime {
  register(capability: BackendCapability, handler: BackendHandler): void;
  invoke(request: BackendRequest): Promise<BackendResponse>;
  getCapabilities(): BackendCapability[];
  isAvailable(backendId: string): boolean;
}

type BackendHandler = (request: BackendRequest) => Promise<BackendResponse>;
```

#### 6. Fail-closed rules for backends

```
1. requiresNetwork: true + allowNetwork: false = status "unavailable", errorCode "network.not_allowed".
   The backend must never attempt a network call without explicit caller consent.

2. If the model returns an empty response, the backend returns
   { status: "error", errorCode: "backend.empty_response" }.
   It must not return status "ok" with empty content.

3. On HTTP 429 (rate limited): { status: "error", errorCode: "backend.rate_limited" }.

4. On HTTP 401/403 (auth): { status: "error", errorCode: "backend.auth_failed" }.

5. On timeout: { status: "error", errorCode: "backend.timeout" }.

6. BackendMessage.content must not contain direct identifiers, patient data,
   or clinical session content before being sent to any backend.

7. BackendResponse.errorMessage must not contain API keys, tokens, or credentials.

8. dry_run: true must never make a network request. It must return a description
   of what would be sent: { status: "ok", completion: { content: "[dry-run: would invoke <model>]" } }.

9. The backend must never drive the conversation loop. It returns a completion
   and that is the end of its responsibility. What happens next is the runtime's decision.
```

#### 7. Network gating note

```
Network-requiring backends must only be invoked when the runtime has received
explicit allowNetwork: true from the caller. This prevents accidental data
exfiltration in offline or air-gapped environments.

For repository-maintenance operations (validate, scan, next-task), the
runtime should prefer offline-capable backends or deterministic operations
over network-requiring model invocations.
```

#### 8. Maturity note

```
**Maturity**: This model backend contract is doctrine-only. No backend implementation
exists in ts/packages/healthos-steward/ as of this writing beyond the basic
runtime request/response baseline. This specification is the design contract
for Stream D. Implementation requires a separate work unit. No production-readiness
claim is made. No live provider integration is implemented.
```

### After completing Task 8

Update `docs/execution/18-healthos-xcode-agent-task-tracker.md`:
- Change Stream D status from `TODO` to `design-complete`.
- Add note: "Design spec added to docs/architecture/45-healthos-xcode-agent.md ## Model backend contract"

**Definition of done**: BackendCapability, BackendRequest, BackendResponse, BackendCompletion, BackendToolCall, ModelBackendRuntime interfaces are fully typed. All 9 fail-closed rules are documented. Network gating rule is explicit.

---

## TASK 9 OF 9 (PHASE 3 TASK 3 OF 3) — Stream F: Xcode context envelope

**Source**: `docs/execution/18-healthos-xcode-agent-task-tracker.md` → Stream F
**Target file**: `docs/architecture/45-healthos-xcode-agent.md` (add new section)
**Supporting update**: `docs/execution/18-healthos-xcode-agent-task-tracker.md` (mark Stream F design-complete)

### What you are specifying

When Steward runs inside Xcode, it can access context about what the developer is currently looking at: the active file, selected text, compiler diagnostics, build state. This context can be included in runtime requests to make Steward's responses relevant to the current Xcode state.

The Xcode context envelope is the typed container for this context. It is:
- Input to the Steward runtime (not to the HealthOS clinical runtime)
- A MCP-transportable JSON structure
- Subject to strict privacy invariants (no patient data, no clinical session content, no direct identifiers)

The key architectural boundary from `docs/architecture/46-apple-sovereignty-architecture.md`:
- Apple controls the Xcode Intelligence surface
- HealthOS contributes instructions and `healthos-mcp` operations
- The envelope flows from Xcode → healthos-mcp → Steward runtime
- The envelope does not flow into the HealthOS clinical runtime or Core law surface

### What to add to `docs/architecture/45-healthos-xcode-agent.md`

Add a new `## Xcode context envelope` section.

The section must contain:

#### 1. Boundary declaration

```
The Xcode context envelope is input to the Steward runtime only.
It does not enter the HealthOS clinical runtime, Core law surface, or any
governance-critical path.

Xcode Intelligence is not HealthOS Core. Apple controls the Xcode
Intelligence surface. HealthOS contributes instructions and healthos-mcp
operations. The Steward runtime uses the envelope to provide relevant
responses to the developer — it does not use it to make clinical decisions.
```

#### 2. XcodeContext type

```typescript
interface XcodeContext {
  // Required fields — must always be present when Xcode context is available
  projectRoot: string;          // absolute path to the project root directory
  projectName: string;          // Xcode project or workspace name (no path separators)
  capturedAt: string;           // ISO 8601 timestamp when context was captured

  // Optional fields — present only when relevant
  activeFile?: XcodeActiveFile;
  selection?: XcodeSelection;
  diagnostics?: XcodeDiagnostic[];
  buildState?: XcodeBuildState;
  targetName?: string;          // active build target name
  schemeName?: string;          // active scheme name
}

interface XcodeActiveFile {
  path: string;           // absolute path (must be within projectRoot)
  relativePath: string;   // path relative to projectRoot
  language: string;       // "swift" | "objc" | "typescript" | "json" | "markdown" | "other"
  lineCount: number;
  cursorLine?: number;    // 1-indexed; present when cursor position is known
  cursorColumn?: number;  // 1-indexed
}

interface XcodeSelection {
  startLine: number;     // 1-indexed
  startColumn: number;   // 1-indexed
  endLine: number;
  endColumn: number;
  text: string;          // selected text; must comply with privacy invariants below
  filePath: string;      // absolute path of file containing selection
}

interface XcodeDiagnostic {
  severity: "error" | "warning" | "note";
  message: string;          // compiler message; must comply with privacy invariants
  filePath: string;         // absolute path
  line: number;             // 1-indexed
  column: number;           // 1-indexed
  fixItHint?: string;       // optional fix-it suggestion from compiler
}

type XcodeBuildState =
  | { status: "passing"; lastBuilt: string }   // ISO 8601 timestamp
  | { status: "failing"; errorCount: number; warningCount: number; lastAttempted: string }
  | { status: "building"; startedAt: string }
  | { status: "unknown" };
```

#### 3. Privacy invariants (mandatory — non-negotiable)

```
PRIVACY INVARIANTS FOR XcodeContext

1. NO PATIENT DATA: XcodeContext fields must never contain patient names, IDs,
   dates of birth, medical record numbers, or any other direct or indirect patient identifier.

2. NO CLINICAL CONTENT: XcodeContext.selection.text and XcodeContext.diagnostics[].message
   must never contain clinical session content, medical notes, diagnostic codes, or
   treatment information.

3. PATH SCRUBBING: File paths must be relative to projectRoot in all contexts where
   the path is transmitted to a model backend. Absolute paths may be used internally
   but must not expose user home directory structure or system-level paths to the model.

4. DIAGNOSTIC SCRUBBING: Diagnostic messages are compiler output — they reflect
   code structure, not clinical content. Before including diagnostics in a backend request,
   validate that no diagnostic message contains recognizable identifier patterns.

5. SELECTION VALIDATION: Before including XcodeSelection.text in any backend request,
   validate that the selected content is code or documentation, not clinical data
   accidentally opened in Xcode.

6. CONTEXT SIZE LIMITS: A single XcodeContext must not exceed 50 000 characters
   when serialized to JSON. Large selections must be truncated to a safe size.

Violations of these invariants must cause the runtime to reject the context and
return an error rather than silently transmit potentially sensitive data.
```

#### 4. Context collection interface

The bridge module that reads Xcode state and produces an XcodeContext:

```typescript
interface XcodeContextCollector {
  collect(): Promise<XcodeContext | null>;
  // Returns null if Xcode is not available or no project is open.
  // Never throws — returns null on any failure.
  isAvailable(): boolean;
}
```

#### 5. How context is attached to runtime requests

When a user sends a message to Steward in Xcode mode, the runtime:
1. Calls `XcodeContextCollector.collect()`
2. If context is available, attaches it to the RuntimeRequest as:
   ```typescript
   interface RuntimeRequest {
     // existing fields from current runtime types
     message: string;
     sessionId: string;
     // added for Xcode mode:
     xcodeContext?: XcodeContext;
   }
   ```
3. The context is available to tool dispatch (tools with `xcodeAware: true` receive it via `ToolContext`)
4. The context is NOT automatically sent to the model backend — the runtime decides which parts to include in `BackendMessage.content`, subject to privacy invariants

#### 6. MCP transport note

When `healthos-mcp` is implemented, the XcodeContext will be serialized to JSON and passed as an MCP tool call parameter. The JSON representation must:
- Use `camelCase` field names
- Omit `null` or `undefined` fields
- Respect the 50 000 character size limit
- Be a valid JSON value that can round-trip through MCP transport

#### 7. Failure modes

```
1. If XcodeContextCollector.collect() fails (Xcode not open, no project):
   → runtime proceeds without context; xcodeContext field is absent from RuntimeRequest.

2. If context violates a privacy invariant:
   → runtime rejects the context; logs a warning (no clinical data in log);
   → runtime proceeds without context rather than transmitting potentially sensitive data.

3. If context exceeds size limit:
   → truncate selection text to fit within limit; emit a note in the context indicating truncation.

4. If active file path escapes projectRoot:
   → reject the context; this indicates a potential directory traversal; log as security event.
```

#### 8. Maturity note

```
**Maturity**: This Xcode context envelope specification is doctrine-only. No context
collector or Xcode bridge is implemented in ts/packages/healthos-steward/ as of this
writing. This specification is the design contract for Stream F. Implementation requires
a separate work unit and MCP transport support (WS-2). No production-readiness claim is made.
```

### After completing Task 9

Update `docs/execution/18-healthos-xcode-agent-task-tracker.md`:
- Change Stream F status from `TODO` to `design-complete`.
- Add note: "Design spec added to docs/architecture/45-healthos-xcode-agent.md ## Xcode context envelope"

**Definition of done**: XcodeContext, XcodeActiveFile, XcodeSelection, XcodeDiagnostic, XcodeBuildState, XcodeContextCollector interfaces are fully typed. All 6 privacy invariants are listed. All 4 failure modes are defined.

---

## TRACKING UPDATE (after all three tasks)

Add an entry to `docs/execution/02-status-and-tracking.md` at the top of "Completed recently":

```markdown
## PHASE-3-XCODE-AGENT-STREAMS — Xcode Agent stream design specifications (2026-04-28)

Objective: write Stream C, D, F design specification sections per
docs/execution/20-documental-todos-work-plan.md Phase 3.

Files touched:
- docs/architecture/45-healthos-xcode-agent.md (3 new sections added)
- docs/execution/18-healthos-xcode-agent-task-tracker.md
- docs/execution/02-status-and-tracking.md

Invariants involved:
- no provider-centric architecture reintroduced (Stream D)
- Xcode Intelligence is not HealthOS Core (Stream F)
- all specs are fail-closed
- no clinical payloads in tool/backend/envelope specs

Validation:
- make validate-docs PASS

Done criteria:
- Stream C: design-complete in 18-healthos-xcode-agent-task-tracker.md
- Stream D: design-complete in 18-healthos-xcode-agent-task-tracker.md
- Stream F: design-complete in 18-healthos-xcode-agent-task-tracker.md
```

---

## GIT WORKFLOW

### Three commits — one per task

```bash
# After Task 7 (Stream C):
git add docs/architecture/45-healthos-xcode-agent.md \
        docs/execution/18-healthos-xcode-agent-task-tracker.md
git commit -m "docs(xcode): Stream C — tool runtime contracts design spec

Adds ## Tool runtime contracts section to 45-healthos-xcode-agent.md.
Defines ToolCapability, ToolInvocation, ToolResult, ToolRuntime interfaces.
Specifies 6 tool categories (file, search, build, test, repository, xcode)
with per-tool parameter and result types. Documents 6 fail-closed rules.
Stream C marked design-complete in 18-healthos-xcode-agent-task-tracker.md.

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"

# After Task 8 (Stream D):
git add docs/architecture/45-healthos-xcode-agent.md \
        docs/execution/18-healthos-xcode-agent-task-tracker.md
git commit -m "docs(xcode): Stream D — model backend layer contract design spec

Adds ## Model backend contract section to 45-healthos-xcode-agent.md.
Defines BackendCapability, BackendRequest, BackendResponse, BackendCompletion,
BackendToolCall, ModelBackendRuntime interfaces.
Establishes runtime-sovereign / backend-subordinate architecture.
Documents 9 fail-closed rules and network gating requirement.
Stream D marked design-complete in 18-healthos-xcode-agent-task-tracker.md.

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"

# After Task 9 (Stream F) + tracking update:
git add docs/architecture/45-healthos-xcode-agent.md \
        docs/execution/18-healthos-xcode-agent-task-tracker.md \
        docs/execution/02-status-and-tracking.md
git commit -m "docs(xcode): Stream F — Xcode context envelope design spec

Adds ## Xcode context envelope section to 45-healthos-xcode-agent.md.
Defines XcodeContext, XcodeActiveFile, XcodeSelection, XcodeDiagnostic,
XcodeBuildState, XcodeContextCollector interfaces.
Documents 6 privacy invariants, 4 failure modes, MCP transport note.
Stream F marked design-complete in 18-healthos-xcode-agent-task-tracker.md.

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

### Push and PR

```bash
git push -u origin codex/phase-3-xcode-agent-streams

gh pr create \
  --title "docs: Phase 3 — Xcode Agent stream design specifications (Streams C, D, F)" \
  --body "## Summary
- Stream C (XA-004): Tool runtime contracts — 6 tool categories, 13 typed tool specs, ToolRuntime interface
- Stream D: Model backend layer contract — runtime-sovereign architecture, 5 typed interfaces, 9 fail-closed rules
- Stream F: Xcode context envelope — 5 typed interfaces, 6 privacy invariants, 4 failure modes

## Changes by stream

### Stream C — Tool runtime contracts
New section: ## Tool runtime contracts in docs/architecture/45-healthos-xcode-agent.md
- ToolCapability, ToolInvocation, ToolResult interfaces
- 6 tool categories with per-tool param/result types (file, search, build, test, repository, xcode)
- ToolRuntime interface
- 6 fail-closed rules with per-category timeout defaults

### Stream D — Model backend layer contract
New section: ## Model backend contract in docs/architecture/45-healthos-xcode-agent.md
- Architectural position statement: runtime is sovereign, backend is subordinate
- BackendCapability, BackendRequest, BackendMessage, BackendToolSpec interfaces
- BackendResponse, BackendCompletion, BackendToolCall interfaces
- ModelBackendRuntime interface
- 9 fail-closed rules
- Network gating: requiresNetwork + allowNetwork explicit consent model

### Stream F — Xcode context envelope
New section: ## Xcode context envelope in docs/architecture/45-healthos-xcode-agent.md
- Boundary declaration: envelope is input to Steward runtime only, not HealthOS clinical runtime
- XcodeContext, XcodeActiveFile, XcodeSelection, XcodeDiagnostic, XcodeBuildState types
- XcodeContextCollector interface
- 6 privacy invariants (no patient data, no clinical content, path scrubbing, diagnostic scrubbing, selection validation, size limits)
- RuntimeRequest extension for xcodeContext
- MCP transport note
- 4 failure modes

## Invariants
- No provider-centric architecture reintroduction (Stream D)
- Xcode Intelligence is not HealthOS Core (Stream F)
- All specs are fail-closed
- No clinical payloads in any spec
- No production-readiness claims

## Test plan
- [ ] make validate-docs passes
- [ ] 45-healthos-xcode-agent.md has all 3 new sections
- [ ] Stream C: ToolCapability/ToolInvocation/ToolResult/ToolRuntime fully typed; 6 categories; 6 fail-closed rules
- [ ] Stream D: BackendCapability/BackendRequest/BackendResponse/ModelBackendRuntime fully typed; 9 fail-closed rules; network gating explicit
- [ ] Stream F: XcodeContext and sub-types fully typed; 6 privacy invariants; 4 failure modes
- [ ] Stream C, D, F marked design-complete in 18-healthos-xcode-agent-task-tracker.md

🤖 Generated with Claude Code" \
  --base main
```

---

## PHASE 3 DEFINITION OF DONE

Phase 3 is complete when ALL of the following are true:

- [ ] `docs/architecture/45-healthos-xcode-agent.md` contains `## Tool runtime contracts` with all type definitions, 6 categories, and 6 fail-closed rules
- [ ] `docs/architecture/45-healthos-xcode-agent.md` contains `## Model backend contract` with architectural position statement, all type definitions, and 9 fail-closed rules
- [ ] `docs/architecture/45-healthos-xcode-agent.md` contains `## Xcode context envelope` with all type definitions, 6 privacy invariants, 4 failure modes, and MCP transport note
- [ ] Stream C marked `design-complete` in `docs/execution/18-healthos-xcode-agent-task-tracker.md`
- [ ] Stream D marked `design-complete` in `docs/execution/18-healthos-xcode-agent-task-tracker.md`
- [ ] Stream F marked `design-complete` in `docs/execution/18-healthos-xcode-agent-task-tracker.md`
- [ ] `docs/execution/02-status-and-tracking.md` has PHASE-3-XCODE-AGENT-STREAMS entry
- [ ] `make validate-docs` passes
- [ ] Three separate commits on branch `codex/phase-3-xcode-agent-streams`
- [ ] Branch pushed to remote
- [ ] PR created targeting main

**If any item above is not met, the phase is not complete.**

---

## FULL DOCUMENTARY PLAN COMPLETION CHECK

When Phase 3 is done, verify that the full documentary plan (`docs/execution/20-documental-todos-work-plan.md`) is now complete:

| Task | Status |
|------|--------|
| ST-006 Territory records | DONE (Phase 1) |
| ST-002 Settler profiles | DONE (Phase 1) |
| ST-003 Settlement schema | DONE (Phase 1) |
| CL-006 Error envelope | DONE (Phase 2) |
| OPS-003 Incident command set | DONE (Phase 2) |
| ST-004 healthos-mcp operations | DONE (Phase 2) |
| Stream C tool contracts | DONE (Phase 3) |
| Stream D backend contract | DONE (Phase 3) |
| Stream F Xcode envelope | DONE (Phase 3) |

If all 9 tasks are DONE, update `docs/execution/20-documental-todos-work-plan.md` status line from:
```
This work plan is: **READY — not started**.
Tasks completed: 0 of 9.
```
to:
```
This work plan is: **COMPLETE**.
Tasks completed: 9 of 9.
Last completed: <date>.
```
