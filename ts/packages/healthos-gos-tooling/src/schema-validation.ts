import Ajv from 'ajv';
import addFormats from 'ajv-formats';
import { readFile } from 'node:fs/promises';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import type { GOSValidationResult } from './types.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const repoRoot = resolve(__dirname, '../../../../..');

async function loadSchema(schemaFileName: string): Promise<unknown> {
  const schemaPath = resolve(repoRoot, 'schemas', schemaFileName);
  const contents = await readFile(schemaPath, 'utf8');
  return JSON.parse(contents);
}

function buildAjv(): Ajv {
  const ajv = new Ajv({ allErrors: true, strict: false });
  addFormats(ajv);
  return ajv;
}

function normalizeErrors(errors: Ajv['errors']): GOSValidationResult {
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
