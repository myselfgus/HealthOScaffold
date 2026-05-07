import { validateConstructionSystem } from "../lib/construction-system-validator.js";

export function runValidateConstructionSystem(): number {
  const checks = validateConstructionSystem();
  for (const check of checks) {
    console.log(`${check.result}: ${check.name} — ${check.detail}`);
  }
  return checks.some((check) => check.result === "FAIL") ? 1 : 0;
}
