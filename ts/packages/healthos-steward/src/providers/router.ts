import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { createOpenAIProvider } from './openai.js';
import { createAnthropicProvider } from './anthropic.js';
import { createXAIProvider } from './xai.js';
import { createLocalCommandProvider } from './local-command.js';
import type { ProviderConfigFile, StewardLLMProvider, StewardLLMProviderConfig, StewardLLMRequest, StewardLLMResponse, StewardLLMRouter } from './types.js';

function providerFactory(config: StewardLLMProviderConfig): StewardLLMProvider {
  if (config.kind === 'openai') return createOpenAIProvider(config);
  if (config.kind === 'anthropic') return createAnthropicProvider(config);
  if (config.kind === 'xai') return createXAIProvider(config);
  if (config.kind === 'local-command') return createLocalCommandProvider(config);
  return {
    health() {
      return {
        providerId: config.id,
        enabled: false,
        status: 'disabled',
        detail: 'provider is disabled',
      };
    },
    async invoke(request: StewardLLMRequest): Promise<StewardLLMResponse> {
      void request;
      throw new Error(`provider kind ${config.kind} is not invokable`);
    },
  };
}

export async function loadProviderConfigs(repoRoot: string): Promise<StewardLLMProviderConfig[]> {
  const localPath = resolve(repoRoot, '.healthos-steward/providers/providers.local.json');
  const primaryPath = resolve(repoRoot, '.healthos-steward/providers/providers.json');
  const examplePath = resolve(repoRoot, '.healthos-steward/providers/providers.example.json');
  const configPath = await readFile(localPath, 'utf8')
    .then(() => localPath)
    .catch(() => readFile(primaryPath, 'utf8').then(() => primaryPath).catch(() => examplePath));
  const parsed = JSON.parse(await readFile(configPath, 'utf8')) as ProviderConfigFile;
  return parsed.providers;
}

export async function createProviderRouter(repoRoot: string): Promise<StewardLLMRouter> {
  const configs = await loadProviderConfigs(repoRoot);
  const map = new Map<string, { config: StewardLLMProviderConfig; provider: StewardLLMProvider }>();
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
    async invoke(request: StewardLLMRequest): Promise<StewardLLMResponse> {
      const entry = map.get(request.providerId);
      if (!entry) {
        throw new Error(`unknown provider: ${request.providerId}`);
      }
      return entry.provider.invoke(request);
    },
  };
}
