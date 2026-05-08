import test from "node:test";
import assert from "node:assert/strict";
import {
  listResolvedSettlements,
  resolveSettlement,
  readAllTrackerTasks,
  validateConstructionSystem,
  classifyCriterion,
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

test("criterion classifier separates filesystem evidence from command evidence", () => {
  assert.deepEqual(classifyCriterion("../../../README.md exists", process.cwd()), {
    criterion: "../../../README.md exists",
    result: "PASS",
    path: "../../../README.md",
  });

  assert.deepEqual(classifyCriterion("make validate-docs passes", process.cwd()), {
    criterion: "make validate-docs passes",
    result: "UNVERIFIED",
  });

  assert.deepEqual(classifyCriterion("../../../missing/path.md exists", process.cwd()), {
    criterion: "../../../missing/path.md exists",
    result: "FAIL",
    path: "../../../missing/path.md",
  });
});
