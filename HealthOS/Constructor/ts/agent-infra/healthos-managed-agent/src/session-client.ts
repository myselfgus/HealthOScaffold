// Maturity: implemented seam — requires live Managed Agents API access and a registered
// agent. Construction-system only. No clinical authority. No merge authority.

import Anthropic from "@anthropic-ai/sdk";
import { existsSync, readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const DISCLAIMER = "non-canonical construction-system artifact";
const AGENT_NOT_REGISTERED_ERROR = "ST-023: agent not registered. Run create-agent first.";

const __dirname = dirname(fileURLToPath(import.meta.url));

function findRepoRoot(start: string): string {
  let current = start;
  for (let depth = 0; depth < 12; depth += 1) {
    if (
      existsSync(join(current, "AGENTS.md")) &&
      existsSync(join(current, "HealthOS", "Package.swift"))
    ) {
      return current;
    }
    const parent = dirname(current);
    if (parent === current) break;
    current = parent;
  }
  throw new Error("Unable to locate HealthOS repository root.");
}

const repoRoot = findRepoRoot(__dirname);
const agentStatePath = join(repoRoot, "HealthOS", "Constructor", "Steward", "managed-agent", "agent.json");

export interface WorkflowOptions {
  apiKey?: string;
  authToken?: string;
}

export interface DiscoverResult {
  sessionId: string;
  agentId: string;
  taskSummary: string;
  rawText: string;
  _disclaimer: string;
}

export interface BriefResult {
  sessionId: string;
  agentId: string;
  settlementId: string;
  promptSpec: string;
  rawText: string;
  _disclaimer: string;
}

export interface ValidateResult {
  sessionId: string;
  agentId: string;
  settlementId: string;
  validationReport: string;
  hasFail: boolean;
  rawText: string;
  _disclaimer: string;
}

export interface HandoffResult {
  sessionId: string;
  agentId: string;
  settlementId: string;
  handoffSummary: string;
  rawText: string;
  _disclaimer: string;
}

type AgentState = {
  id?: unknown;
};

type Session = {
  id: string;
};

type TextBlock = {
  type: "text";
  text: string;
};

type ManagedAgentMessage = {
  content: Array<TextBlock | { type: string; [key: string]: unknown }>;
};

type ManagedAgentMessageStream = {
  finalMessage(): Promise<ManagedAgentMessage>;
};

type ManagedAgentSessions = {
  create(params: { agent_id: string }): Promise<Session>;
  messages: {
    stream(params: {
      session_id: string;
      input: Array<{ type: "user"; content: Array<{ type: "text"; text: string }> }>;
    }): ManagedAgentMessageStream;
  };
};

type AnthropicWithManagedAgentSessions = Anthropic & {
  beta: Anthropic["beta"] & {
    sessions: ManagedAgentSessions;
  };
};

function resolveClient(options?: WorkflowOptions): Anthropic {
  const apiKey = options?.apiKey ?? process.env.ANTHROPIC_API_KEY;
  const authToken = options?.authToken ?? process.env.ANTHROPIC_AUTH_TOKEN;

  if (apiKey) {
    return new Anthropic({ apiKey });
  }

  if (authToken) {
    return new Anthropic({ authToken });
  }

  throw new Error(
    "ST-023: no Anthropic auth credential found. Set ANTHROPIC_API_KEY or ANTHROPIC_AUTH_TOKEN."
  );
}

function readAgentId(): string {
  if (!existsSync(agentStatePath)) {
    throw new Error(AGENT_NOT_REGISTERED_ERROR);
  }

  try {
    const state = JSON.parse(readFileSync(agentStatePath, "utf-8")) as AgentState;
    if (typeof state.id !== "string" || state.id.trim().length === 0) {
      throw new Error(AGENT_NOT_REGISTERED_ERROR);
    }
    return state.id;
  } catch (err) {
    if (err instanceof Error && err.message === AGENT_NOT_REGISTERED_ERROR) {
      throw err;
    }
    throw new Error(AGENT_NOT_REGISTERED_ERROR);
  }
}

function textFromMessage(message: ManagedAgentMessage): string {
  return message.content
    .filter((block): block is TextBlock => block.type === "text")
    .map((block) => block.text)
    .join("\n");
}

async function runWorkflow(
  workflowName: "discover" | "brief" | "validate" | "handoff",
  prompt: string,
  options?: WorkflowOptions
): Promise<{ sessionId: string; agentId: string; rawText: string }> {
  const agentId = readAgentId();
  const client = resolveClient(options) as AnthropicWithManagedAgentSessions;
  const session = await client.beta.sessions.create({ agent_id: agentId });
  console.error(`ST-023 [${workflowName}] session ${session.id}`);

  const stream = client.beta.sessions.messages.stream({
    session_id: session.id,
    input: [{ type: "user", content: [{ type: "text", text: prompt }] }],
  });
  const message = await stream.finalMessage();
  const rawText = textFromMessage(message);

  return { sessionId: session.id, agentId, rawText };
}

function errorMessage(err: unknown): string {
  return err instanceof Error ? err.message : String(err);
}

export async function discover(options?: WorkflowOptions): Promise<DiscoverResult> {
  try {
    const prompt =
      "What is the next TODO construction task? Use steward_next_task and steward_scan_status to answer. Return: task ID, description, priority, recommended territory, recommended settler profile.";
    const { sessionId, agentId, rawText } = await runWorkflow("discover", prompt, options);
    return { sessionId, agentId, taskSummary: rawText, rawText, _disclaimer: DISCLAIMER };
  } catch (err) {
    if (err instanceof Error && err.message === AGENT_NOT_REGISTERED_ERROR) throw err;
    throw new Error(`ST-023 [discover]: ${errorMessage(err)}`);
  }
}

export async function brief(
  settlementId: string,
  options?: WorkflowOptions
): Promise<BriefResult> {
  try {
    const prompt = `Generate the full implementation prompt for settlement ${settlementId}. Use steward_generate_prompt. Return the complete PromptSpec.`;
    const { sessionId, agentId, rawText } = await runWorkflow("brief", prompt, options);
    return {
      sessionId,
      agentId,
      settlementId,
      promptSpec: rawText,
      rawText,
      _disclaimer: DISCLAIMER,
    };
  } catch (err) {
    if (err instanceof Error && err.message === AGENT_NOT_REGISTERED_ERROR) throw err;
    throw new Error(`ST-023 [brief]: ${errorMessage(err)}`);
  }
}

export async function validate(
  settlementId: string,
  options?: WorkflowOptions
): Promise<ValidateResult> {
  try {
    const prompt = `Validate settlement ${settlementId}. Use steward_validate_settlement. Return the full ValidationReport including all PASS, FAIL, and UNVERIFIED criteria verbatim.`;
    const { sessionId, agentId, rawText } = await runWorkflow("validate", prompt, options);
    return {
      sessionId,
      agentId,
      settlementId,
      validationReport: rawText,
      hasFail: rawText.includes("FAIL"),
      rawText,
      _disclaimer: DISCLAIMER,
    };
  } catch (err) {
    if (err instanceof Error && err.message === AGENT_NOT_REGISTERED_ERROR) throw err;
    throw new Error(`ST-023 [validate]: ${errorMessage(err)}`);
  }
}

export async function handoff(
  settlementId: string,
  options?: WorkflowOptions
): Promise<HandoffResult> {
  try {
    const prompt = `Settlement ${settlementId} is complete. Use steward_build_memory to refresh derived memory. Then use steward_get_handoff to return the current handoff state. Summarize what was completed and what is next.`;
    const { sessionId, agentId, rawText } = await runWorkflow("handoff", prompt, options);
    return {
      sessionId,
      agentId,
      settlementId,
      handoffSummary: rawText,
      rawText,
      _disclaimer: DISCLAIMER,
    };
  } catch (err) {
    if (err instanceof Error && err.message === AGENT_NOT_REGISTERED_ERROR) throw err;
    throw new Error(`ST-023 [handoff]: ${errorMessage(err)}`);
  }
}
