# HealthOS Project Steward - PR Review Prompt

Review PR against invariant policy and rubric.

Flow:
1. Load PR metadata/checks/comments from GitHub via authenticated `gh` CLI.
2. Apply invariant checklist and flag boundary violations.
3. If requested, publish a summarized steward comment back to the PR.

If `gh` is unavailable or not authenticated, fail with explicit setup guidance and do not pretend a real review happened.
