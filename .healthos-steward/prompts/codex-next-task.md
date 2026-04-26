# HealthOS Project Steward - Codex Next Task

Generate next engineering work unit from official execution docs.

Requirements:
- Read execution status, gap register, finalization plan, and matching todo/skills docs.
- Keep Core/GOS/AACI/app boundaries intact.
- Prefer highest-priority READY or scaffold blocker work.
- Output task title, why now, files to read, invariants, expected changes, tests, restrictions, done criteria.
