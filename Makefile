bootstrap:
	bash ./scripts/bootstrap-local.sh

tree:
	find . -maxdepth 4 -type f | sort

swift-build:
	cd HealthOS && swift build

swift-test:
	cd HealthOS && swift test

stage-package-check:
	bash ./scripts/check-stage-packages.sh

smoke-cli:
	cd HealthOS && swift run HealthOSCLI

smoke-scribe:
	cd HealthOS/Tier4-Stages-Cast/Scribe && swift run Scribe --smoke-test

smoke-veridia:
	cd HealthOS/Tier4-Stages-Cast/Veridia && swift run Veridia --smoke-test

smoke-cloudclinic:
	cd HealthOS/Tier4-Stages-Cast/CloudClinic && swift run CloudClinic --smoke-test

swift-smoke: smoke-cli stage-package-check smoke-scribe smoke-veridia smoke-cloudclinic

ts-build:
	cd HealthOS/Constructor/ts && npm install && npm run build

ts-test:
	cd HealthOS/Constructor/ts && npm test --if-present --workspaces

python-check:
	cd HealthOS/Support/python && python -m compileall .

python-compile: python-check

validate-docs:
	bash ./scripts/check-docs.sh

validate-schemas:
	bash ./scripts/validate-schemas.sh

validate-contracts:
	bash ./scripts/check-contract-drift.sh

validate-construction-system:
	cd HealthOS/Constructor/ts && npm run build --workspace @healthos/steward && node agent-infra/healthos-steward/dist/cli.js validate-construction-system

validate-all:
	bash ./scripts/validate-local.sh

sql-print:
	cat HealthOS/Tier1-Mestral-Core/SQL/migrations/001_init.sql
