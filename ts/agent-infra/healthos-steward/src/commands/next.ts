import { readAllTrackerTasks } from "../lib/tracker-reader.js";

export function runNext(): number {
  let tasks;
  try {
    tasks = readAllTrackerTasks();
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e);
    process.stderr.write(`Error: ${msg}\n`);
    return 1;
  }

  const nextTodo = tasks.find((task) => task.status === "TODO");
  if (nextTodo) {
    console.log(`Next task: ${nextTodo.id} — ${nextTodo.title}`);
    console.log("Status: TODO");
    return 0;
  }

  const needsReview = tasks.find(
    (task) =>
      task.status === "NEEDS-REVIEW" || task.status === "BLOCKED_AS_WRITTEN"
  );
  if (needsReview) {
    console.log(`No TODO tasks found.`);
    console.log(`Needs review: ${needsReview.id} — ${needsReview.title}`);
    console.log(`Status: ${needsReview.rawStatus || needsReview.status}`);
    return 0;
  }

  console.log("All tracked ST tasks are DONE.");
  return 0;
}
