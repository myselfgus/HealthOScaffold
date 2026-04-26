export type StewardLLMProviderKind =
  | 'openai'
  | 'anthropic'
  | 'xai'
  | 'disabled'
  | 'local-command';

export type StewardLLMEndpointMode = 'responses' | 'chatCompletions' | 'messages' | 'localCommand';
export type StewardInputKind = 'nextTask' | 'prReview' | 'handoff' | 'architectureReview' | 'freeform' | 'diffReview' | 'memorySync';
export type StewardLLMStatus = 'ok' | 'dryRun' | 'disabled' | 'missingSecret' | 'providerError' | 'timeout' | 'unsupported';

export type StewardLLMProviderCapability = {
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

export type StewardLLMProviderConfig = {
  id: string;
  kind: StewardLLMProviderKind;
  enabled: boolean;
  model: string;
  apiKeyEnv?: string;
  baseUrl?: string;
  endpointMode: StewardLLMEndpointMode;
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

export type StewardLLMRequest = {
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

export type StewardLLMFailure = {
  errorKind: 'networkDenied' | 'httpError' | 'missingSecret' | 'providerDisabled' | 'misconfigured' | 'timeout' | 'unsupported' | 'localCommandDenied' | 'unknown';
  errorMessage: string;
};

export type StewardLLMResponse = {
  providerId: string;
  model: string;
  status: StewardLLMStatus;
  text: string;
  raw?: unknown;
  inputHash: string;
  outputHash: string;
  durationMs: number;
  errorKind?: StewardLLMFailure['errorKind'];
  errorMessage?: string;
  postedToGitHub: boolean;
};

export type StewardLLMProvider = {
  invoke: (request: StewardLLMRequest) => Promise<StewardLLMResponse>;
  health: () => StewardProviderHealth;
};

export type StewardLLMRouter = {
  listProviders: () => StewardLLMProviderConfig[];
  checkProviders: () => StewardProviderHealth[];
  explainProvider: (providerId: string) => StewardLLMProviderConfig;
  invoke: (request: StewardLLMRequest) => Promise<StewardLLMResponse>;
};

export type StewardLLMInvocationLog = {
  timestamp: string;
  command: string;
  providerId: string;
  providerKind: StewardLLMProviderKind;
  model: string;
  templateId: string;
  inputHash: string;
  outputHash: string;
  status: StewardLLMStatus;
  errorKind?: string;
  durationMs: number;
  dryRun: boolean;
  postedToGitHub: boolean;
  repoRef: string;
  prNumber?: number;
};

export type ProviderConfigFile = {
  version: string;
  providers: StewardLLMProviderConfig[];
};
