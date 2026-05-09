bootstrap:
	bash ./scripts/bootstrap-local.sh

tree:
	find . -maxdepth 4 -type f | sort

swift-build:
	cd HealthOS && swift build

swift-test:
	cd HealthOS && swift test

smoke-cli:
	cd HealthOS && swift run HealthOSCLI

smoke-scribe:
	cd HealthOS && swift run HealthOSScribeStage --smoke-test

smoke-veridia:
	cd HealthOS && swift run HealthOSVeridiaStage --smoke-test

smoke-cloudclinic:
	cd HealthOS && swift run HealthOSCloudClinicStage --smoke-test

swift-smoke: smoke-cli smoke-scribe smoke-veridia smoke-cloudclinic

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
