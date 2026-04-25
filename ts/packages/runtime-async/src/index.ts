import type { AsyncJobDescriptor, AsyncJobHealthSummary, AsyncJobObservabilityEvent, AsyncJobState, SessionWork } from "@healthos/contracts";

declare const process: {
  argv: string[];
};

type JobRunResult =
  | { ok: true; outputRefs: string[] }
  | { ok: false; retryable: boolean; message: string };

export class AsyncRuntime {
  private readonly jobs = new Map<string, AsyncJobDescriptor>();
  private readonly idempotency = new Map<string, string>();
  private readonly events: AsyncJobObservabilityEvent[] = [];

  enqueue(job: AsyncJobDescriptor): AsyncJobDescriptor {
    const existingId = this.idempotency.get(job.idempotencyKey);
    if (existingId) {
      const existing = this.jobs.get(existingId);
      if (existing && existing.state === "completed") {
        this.events.push(this.makeEvent(existing, "job.idempotency_reused"));
        return existing;
      }
      throw new Error(`duplicate idempotency key for active job: ${existingId}`);
    }

    this.jobs.set(job.id, job);
    this.idempotency.set(job.idempotencyKey, job.id);
    this.events.push(this.makeEvent(job, "job.enqueued"));
    return job;
  }

  async runOne(jobId: string, execute: (job: AsyncJobDescriptor, attempt: number) => Promise<JobRunResult>): Promise<AsyncJobDescriptor> {
    const job = this.jobs.get(jobId);
    if (!job) throw new Error(`job not found: ${jobId}`);
    if (job.state !== "pending" && job.state !== "retry_scheduled") {
      throw new Error(`job state not runnable: ${job.state}`);
    }

    const attempt = job.retryCount + 1;
    const started = this.withState(job, "running", { startedAt: new Date().toISOString() });
    this.jobs.set(job.id, started);
    this.events.push(this.makeEvent(started, "job.started"));

    const result = await execute(started, attempt);
    if (result.ok) {
      const completed = this.withState(started, "completed", {
        outputRefs: result.outputRefs,
        completedAt: new Date().toISOString()
      });
      this.jobs.set(completed.id, completed);
      this.events.push(this.makeEvent(completed, "job.completed"));
      return completed;
    }

    const failed = {
      ...started,
      state: "failed" as AsyncJobState,
      retryCount: started.retryCount + 1,
      failedAt: new Date().toISOString()
    };
    this.jobs.set(failed.id, failed);
    this.events.push(this.makeEvent(failed, "job.failed", "internal_failure"));

    const canRetry = failed.idempotent && failed.retryPolicy.automaticRetryAllowed && result.retryable && failed.retryCount <= failed.retryPolicy.maxRetries;
    if (canRetry) {
      const retryScheduled = this.withState(failed, "retry_scheduled");
      this.jobs.set(retryScheduled.id, retryScheduled);
      this.events.push(this.makeEvent(retryScheduled, "job.retry_scheduled", "internal_failure"));
      return retryScheduled;
    }

    const deadLetter = this.withState(failed, "dead_letter");
    this.jobs.set(deadLetter.id, deadLetter);
    this.events.push(this.makeEvent(deadLetter, "job.dead_lettered", "internal_failure"));
    return deadLetter;
  }

  list(state?: AsyncJobState): AsyncJobDescriptor[] {
    return Array.from(this.jobs.values()).filter((job) => (state ? job.state === state : true));
  }

  cancelPending(jobId: string): AsyncJobDescriptor {
    const job = this.jobs.get(jobId);
    if (!job) throw new Error(`job not found: ${jobId}`);
    if (job.state !== "pending" && job.state !== "retry_scheduled") {
      throw new Error(`job cannot be cancelled from state ${job.state}`);
    }
    const cancelled = this.withState(job, "cancelled", { failedAt: new Date().toISOString() });
    this.jobs.set(job.id, cancelled);
    this.events.push(this.makeEvent(cancelled, "job.cancelled", "cancelled"));
    return cancelled;
  }

  healthSummary(): AsyncJobHealthSummary {
    let pending = 0;
    let running = 0;
    let retryScheduled = 0;
    let failed = 0;
    let deadLetter = 0;

    for (const job of this.jobs.values()) {
      if (job.state === "pending") pending += 1;
      else if (job.state === "running" || job.state === "leased") running += 1;
      else if (job.state === "retry_scheduled") retryScheduled += 1;
      else if (job.state === "failed") failed += 1;
      else if (job.state === "dead_letter") deadLetter += 1;
    }

    return { pending, running, retryScheduled, failed, deadLetter };
  }

  eventsLog(): AsyncJobObservabilityEvent[] {
    return [...this.events];
  }

  async handleSessionClosure(session: SessionWork): Promise<void> {
    void session;
  }

  private withState(job: AsyncJobDescriptor, state: AsyncJobState, patch: Partial<AsyncJobDescriptor> = {}): AsyncJobDescriptor {
    return { ...job, ...patch, state };
  }

  private makeEvent(job: AsyncJobDescriptor, kind: AsyncJobObservabilityEvent["kind"], failureKind?: AsyncJobObservabilityEvent["failureKind"]): AsyncJobObservabilityEvent {
    return {
      id: crypto.randomUUID(),
      kind,
      jobId: job.id,
      jobKind: job.kind,
      state: job.state,
      source: job.requestedByActor,
      timestamp: new Date().toISOString(),
      failureKind,
      provenanceRef: job.provenanceRefs.at(-1)
    };
  }
}

if (process.argv[1]?.endsWith("index.js")) {
  const runtime = new AsyncRuntime();
  runtime.enqueue({
    id: crypto.randomUUID(),
    kind: "maintenance",
    requestedByActor: "runtime.async",
    submissionSource: "system",
    lawfulContextRequirement: {
      requireLawfulContext: false,
      requireFinalidade: false,
      requireConsent: false,
      requireHabilitation: false,
      requirePatientContext: false,
      requireServiceContext: false
    },
    dataLayersTouched: ["governance-metadata"],
    inputRefs: [],
    outputRefs: [],
    idempotencyKey: `maintenance-${Date.now()}`,
    priority: "low",
    createdAt: new Date().toISOString(),
    retryCount: 0,
    retryPolicy: { maxRetries: 1, baseDelaySeconds: 5, backoff: "fixed", automaticRetryAllowed: true },
    state: "pending",
    provenanceRefs: [],
    auditRefs: [],
    idempotent: true,
    allowsRemoteProvider: false
  });
}
