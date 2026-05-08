import test from "node:test";
import assert from "node:assert/strict";
import {
  handleGeneratePrompt,
  handleListSettlements,
  handleValidateSettlement,
} from "../dist/handlers.js";
import { FORGE_MCP_TOOL_NAMES } from "../dist/tools.js";

const expectedTools = [
  "steward_next_task",
  "steward_scan_status",
  "steward_get_handoff",
  "steward_list_territories",
  "steward_inspect_territory",
  "steward_list_settlers",
  "steward_list_settlements",
  "steward_validate_settlement",
  "steward_generate_prompt",
  "steward_build_memory",
];

test("Forge MCP exports the documented 10 repository-maintenance tools", () => {
  assert.deepEqual([...FORGE_MCP_TOOL_NAMES].sort(), [...expectedTools].sort());
});

test("list settlements returns callable file IDs plus canonical IDs", () => {
  const result = handleListSettlements();
  assert.equal(result.isError, undefined);
  const payload = JSON.parse(result.content);
  const completed = payload.completed.find(
    (settlement) => settlement.id === "st-012-settler-profile-registry"
  );
  assert.ok(completed);
  assert.equal(
    completed.canonicalId,
    "SETTLEMENT-20260504-settler-profile-registry"
  );
  assert.match(completed.path, /st-012-settler-profile-registry\.md$/);
});

test("validate settlement resolves both file ID and canonical ID", () => {
  for (const id of [
    "st-012-settler-profile-registry",
    "SETTLEMENT-20260504-settler-profile-registry",
  ]) {
    const result = handleValidateSettlement(id);
    assert.equal(result.isError, undefined);
    const payload = JSON.parse(result.content);
    assert.equal(payload.id, "st-012-settler-profile-registry");
    assert.equal(
      payload.canonicalId,
      "SETTLEMENT-20260504-settler-profile-registry"
    );
    assert.equal(payload.hasFail, false);
    assert.match(payload.summary, /PASS/);
  }
});

test("generate prompt resolves both file ID and canonical ID", () => {
  for (const id of [
    "st-012-settler-profile-registry",
    "SETTLEMENT-20260504-settler-profile-registry",
  ]) {
    const result = handleGeneratePrompt(id, { writeOutput: false });
    assert.equal(result.isError, undefined);
    const payload = JSON.parse(result.content);
    assert.equal(payload.id, "st-012-settler-profile-registry");
    assert.equal(
      payload.canonicalId,
      "SETTLEMENT-20260504-settler-profile-registry"
    );
    assert.equal(
      payload.outputPath,
      ".healthos-steward/prompts/generated/st-012-settler-profile-registry.md"
    );
    assert.ok(payload.sectionsCount >= 16);
    assert.equal(payload.wroteOutput, false);
  }
});
