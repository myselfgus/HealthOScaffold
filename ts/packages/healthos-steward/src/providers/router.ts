import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { createOpenAIProvider } from './openai.js';
import { createAnthropicProvider } from './anthropic.js';
import { createXAIProvider } from './xai.js';
import { createLocalCommandProvider } from './local-command.js';
import type { ProviderConfigFile, StewardModelProvider, StewardModelProviderConfig, StewardModelRequest, StewardModelResponse, StewardModelRouter } from './types.js';

function providerFactory(config: StewardModelProviderConfig): StewardModelProvider {
  if (config.kind === 'openai') return createOpenAIProvider(config);
  if (config.kind === 'anthropic') return createAnthropicProvider(config);
  if (config.kind === 'xai') return createXAIProvider(config);
  if (config.kind === 'local-command' || config.kind === 'codex-cli' || config.kind === 'claude-code-cli') return createLocalCommandProvider(config);
  return createLocalCommandProvider({ ...config, command: ['echo', 'provider disabled'], commandAllowlist: [['echo']] });
}

export async function loadProviderConfigs(repoRoot: string): Promise<StewardModelProviderConfig[]> {
  const localPath = resolve(repoRoot, '.healthos-steward/providers/providers.local.json');
  const examplePath = resolve(repoRoot, '.healthos-steward/providers/providers.example.json');
  const primaryPath = await readFile(localPath, 'utf8').then(() => localPath).catch(() => examplePath);
  const parsed = JSON.parse(await readFile(primaryPath, 'utf8')) as ProviderConfigFile;
  return parsed.providers;
}

export async function createProviderRouter(repoRoot: string): Promise<StewardModelRouter> {
  const configs = await loadProviderConfigs(repoRoot);
  const map = new Map<string, { config: StewardModelProviderConfig; provider: StewardModelProvider }>();
  for (const config of configs) map.set(config.id, { config, provider: providerFactory(config) });

  return {
    listProviders() {
      return configs;
    },
    checkProviders() {
      return configs.map((config) => map.get(config.id)?.provider.health() ?? {
        providerId: config.id,
        enabled: false,
        status: 'misconfigured',
        detail: 'provider not initialized',
      });
    },
    explainProvider(providerId: string) {
      const entry = map.get(providerId);
      if (!entry) throw new Error(`unknown provider: ${providerId}`);
      return entry.config;
    },
    async invoke(request: StewardModelRequest): Promise<StewardModelResponse> {
      const entry = map.get(request.providerId);
      if (!entry) {
        throw new Error(`unknown provider: ${request.providerId}`);
      }
      return entry.provider.invoke(request);
    },
  };
}
