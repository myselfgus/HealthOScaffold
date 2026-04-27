# Skill: Build/Run/Debug

## Overview
Use this skill to set up project-local `script/build_and_run.sh` and wire `.codex/environments/environment.toml` for a standardized build/run workflow.

## Guidelines
- Prefer shell-first workflows (`./script/build_and_run.sh`).
- Default to project-local `.app` bundle staging for GUI apps on macOS.
- Use Xcode-aware MCP only for discovery/logging support, not as the primary workflow.

## Standard Script Actions
1. Stop existing process.
2. Build.
3. Launch/Open bundle.

## Debugging
- Supported flags: `--debug`, `--logs`, `--telemetry`, `--verify`.
