import type { SessionWork } from "\u0040healthos/contracts";

declare const process: {
  argv: string[];
};

export interface AsyncJob {
  id: string;
  kind: "reprocess" | "briefing" | "consolidation" | "evaluation";
  payload: Record<string, unknown>;
}

export class AsyncRuntime {
  async enqueue(job: AsyncJob): Promise<void> {
    console.log("[runtime-async] enqueue", job.kind, job.id);
  }

  async handleSessionClosure(session: SessionWork): Promise<void> {
    console.log("[runtime-async] session closed", session.id);
  }
}

if (process.argv[1]?.endsWith("index.js")) {
  const runtime = new AsyncRuntime();
  void runtime.enqueue({
    id: crypto.randomUUID(),
    kind: "briefing",
    payload: { status: "stub" }
  });
}
