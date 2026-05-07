import test from "node:test";
import assert from "node:assert/strict";
import {
  listResolvedSettlements,
  resolveSettlement,
  readAllTrackerTasks,
  validateConstructionSystem,
} from "../dist/index.js";

test("settlement registry resolves by fileId and canonicalId", () => {
  const { completed } = listResolvedSettlements();
  const st012 = completed.find(
    (settlement) => settlement.fileId === "st-012-settler-profile-registry"
  );
  assert.ok(st012);
  assert.equal(st012.canonicalId, "SETTLEMENT-20260504-settler-profile-registry");
  assert.ok(resolveSettlement(st012.fileId));
  assert.ok(resolveSettlement(st012.canonicalId));
});

test("tracker parser classifies ST-020 composite status", () => {
  const tasks = readAllTrackerTasks();
  const st020 = tasks.find((task) => task.id === "ST-020");
  assert.ok(st020);
  assert.equal(st020.status, "BLOCKED_AS_WRITTEN");
  assert.match(st020.rawStatus, /NEEDS-REVIEW \/ BLOCKED AS WRITTEN/);
});

test("construction-system validator passes current repository invariants", () => {
  const checks = validateConstructionSystem();
  assert.deepEqual(
    checks.filter((check) => check.result === "FAIL"),
    []
  );
});
