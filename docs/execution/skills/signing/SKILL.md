# Skill: Signing

## Overview
Use this skill when failures smell like codesigning issues (launch refusal, missing entitlement, invalid signature, sandbox mismatch).

## Diagnostic Commands
- `codesign -dvvv --entitlements :- <path>`
- `spctl -a -vv <path>`
- `plutil -p <plist>`

## Failure Classes
- Unsigned/Ad hoc.
- Wrong identity.
- Entitlement mismatch.
- Hardened runtime.
- App Sandbox.
