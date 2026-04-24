import { createHash } from 'node:crypto';
import { canonicalizeGOS, parseGOSAuthoringYAML } from './canonicalize.js';
import { validateAgainstCompiledSchema, validateAgainstAuthoringSchema } from './schema-validation.js';
import { validateGOS } from './validate.js';
import type { GOSCompilerReport, GOSSourceProvenance } from './types.js';

export const GOS_COMPILER_VERSION = '0.1.0';

export function computeSourceProvenance(source: string, sourceReference?: string): GOSSourceProvenance {
  return {
    source_sha256: createHash('sha256').update(source).digest('hex'),
    source_reference: sourceReference,
  };
}

export async function compileGOSAuthoringSource(source: string, sourceReference?: string) {
  const sourceProvenance = computeSourceProvenance(source, sourceReference);
  const authoring = parseGOSAuthoringYAML(source);

  const authoringSchema = await validateAgainstAuthoringSchema(authoring);
  const { spec, report: baseReport } = canonicalizeGOS(authoring);
  const compiledSchema = await validateAgainstCompiledSchema(spec);
  const crossReference = validateGOS(spec);

  const report: GOSCompilerReport = {
    parse_ok: true,
    structural_ok: authoringSchema.ok && compiledSchema.ok,
    cross_reference_ok: crossReference.ok,
    warnings: baseReport.warnings,
    structural_issues: [...authoringSchema.issues, ...compiledSchema.issues],
    cross_reference_issues: crossReference.issues,
    source_provenance: sourceProvenance,
  };

  return {
    spec,
    report,
    sourceProvenance,
  };
}
