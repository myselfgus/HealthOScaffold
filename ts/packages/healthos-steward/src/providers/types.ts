export type StewardModelProviderKind =
  | 'openai'
  | 'anthropic'
  | 'xai'
  | 'codex-cli'
  | 'claude-code-cli'
  | 'local-command'
  | 'disabled';

export type StewardProviderEndpointMode = 'responses' | 'chatCompletions' | 'messages' | 'localCommand';
export type StewardInputKind = 'nextTask' | 'prReview' | 'handoff' | 'architectureReview' | 'freeform';
export type StewardModelStatus = 'ok' | 'dryRun' | 'disabled' | 'missingSecret' | 'providerError' | 'timeout' | 'unsupported';

export type StewardProviderCapability = {
  supportsPrReview: boolean;
  supportsNextTask: boolean;
  supportsHandoff: boolean;
  supportsStructuredJson: boolean;
  supportsToolUse: boolean;
};

export type StewardProviderHealth = {
  providerId: string;
  enabled: boolean;
  status: 'ready' | 'disabled' | 'missingSecret' | 'misconfigured';
  detail: string;
};

export type StewardModelProviderConfig = {
  id: string;
  kind: StewardModelProviderKind;
  enabled: boolean;
  model: string;
  apiKeyEnv?: string;
  baseUrl?: string;
  endpointMode: StewardProviderEndpointMode;
  timeoutMs: number;
  maxOutputTokens?: number;
  temperature?: number;
  dryRunDefault: boolean;
  supportsPrReview: boolean;
  supportsNextTask: boolean;
  supportsHandoff: boolean;
  supportsStructuredJson: boolean;
  supportsToolUse: boolean;
  notes?: string;
  anthropicVersion?: string;
  command?: string[];
  commandAllowlist?: string[][];
  metadata?: Record<string, string | number | boolean>;
};

export type StewardModelRequest = {
  providerId: string;
  templateId: string;
  systemPrompt: string;
  userPrompt: string;
  inputKind: StewardInputKind;
  repoContextRefs: string[];
  dryRun: boolean;
  allowNetwork: boolean;
  allowGitHubWrite: boolean;
  metadata?: Record<string, string | number | boolean>;
};

export type StewardModelFailure = {
  errorKind: 'networkDenied' | 'httpError' | 'missingSecret' | 'providerDisabled' | 'misconfigured' | 'timeout' | 'unsupported' | 'localCommandDenied' | 'unknown';
  errorMessage: string;
};

export type StewardModelResponse = {
  providerId: string;
  model: string;
  status: StewardModelStatus;
  text: string;
  raw?: unknown;
  inputHash: string;
  outputHash: string;
  durationMs: number;
  errorKind?: StewardModelFailure['errorKind'];
  errorMessage?: string;
  postedToGitHub: boolean;
};

export type StewardModelProvider = {
  invoke: (request: StewardModelRequest) => Promise<StewardModelResponse>;
  health: () => StewardProviderHealth;
};

export type StewardModelRouter = {
  listProviders: () => StewardModelProviderConfig[];
  checkProviders: () => StewardProviderHealth[];
  explainProvider: (providerId: string) => StewardModelProviderConfig;
  invoke: (request: StewardModelRequest) => Promise<StewardModelResponse>;
};

export type StewardModelInvocationLog = {
  timestamp: string;
  command: string;
  providerId: string;
  providerKind: StewardModelProviderKind;
  model: string;
  templateId: string;
  inputHash: string;
  outputHash: string;
  status: StewardModelStatus;
  errorKind?: string;
  durationMs: number;
  dryRun: boolean;
  postedToGitHub: boolean;
  repoRef: string;
  prNumber?: number;
};

export type ProviderConfigFile = {
  version: string;
  providers: StewardModelProviderConfig[];
};
