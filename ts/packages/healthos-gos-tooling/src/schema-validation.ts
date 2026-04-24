import * as Ajv2020Module from 'ajv/dist/2020.js';
import * as addFormatsModule from 'ajv-formats/dist/index.js';
import type { ErrorObject } from 'ajv';
import { readFile } from 'node:fs/promises';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import type { GOSValidationResult } from './types.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const repoRoot = resolve(__dirname, '../../../..');

async function loadSchema(schemaFileName: string): Promise<unknown> {
  const schemaPath = resolve(repoRoot, 'schemas', schemaFileName);
  const contents = await readFile(schemaPath, 'utf8');
  return JSON.parse(contents);
}

type AjvLike = {
  compile: (schema: unknown) => {
    (data: unknown): boolean;
    errors?: ErrorObject[] | null;
  };
};

function buildAjv() {
  const AjvCtor = ((Ajv2020Module as unknown) as { default?: new (options?: Record<string, unknown>) => AjvLike }).default;
  const addFormats = ((addFormatsModule as unknown) as { default?: (instance: AjvLike) => void }).default;
  if (!AjvCtor || !addFormats) {
    throw new Error('Failed to resolve Ajv modules for schema validation.');
  }

  const ajv = new AjvCtor({ allErrors: true, strict: false });
  addFormats(ajv);
  return ajv as AjvLike;
}

function normalizeErrors(errors: ErrorObject[] | null | undefined): GOSValidationResult {
  return {
    ok: !errors || errors.length === 0,
    issues: (errors ?? []).map((error) => ({
      code: 'gos.schema.validation_failed',
      message: error.message ?? 'Schema validation failed.',
      path: error.instancePath || undefined,
    })),
  };
}

export async function validateAgainstCompiledSchema(spec: unknown): Promise<GOSValidationResult> {
  const ajv = buildAjv();
  const schema = await loadSchema('governed-operational-spec.schema.json');
  const validate = ajv.compile(schema);
  validate(spec);
  return normalizeErrors(validate.errors);
}

export async function validateAgainstAuthoringSchema(spec: unknown): Promise<GOSValidationResult> {
  const ajv = buildAjv();
  const schema = await loadSchema('governed-operational-spec-authoring.schema.json');
  const validate = ajv.compile(schema);
  validate(spec);
  return normalizeErrors(validate.errors);
}
