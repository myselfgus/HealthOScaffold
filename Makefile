bootstrap:
	bash ./scripts/bootstrap-local.sh

tree:
	find . -maxdepth 4 -type f | sort

swift-build:
	cd swift && swift build

swift-test:
	cd swift && swift test

smoke-cli:
	cd swift && swift run HealthOSCLI

smoke-scribe:
	cd swift && swift run HealthOSScribeApp --smoke-test

smoke-sortio:
	cd swift && swift run HealthOSSortioApp --smoke-test

smoke-cloudclinic:
	cd swift && swift run HealthOSCloudClinicApp --smoke-test

swift-smoke: smoke-cli smoke-scribe smoke-sortio smoke-cloudclinic

ts-build:
	cd ts && npm install && npm run build

ts-test:
	cd ts && npm test --if-present --workspaces

python-check:
	cd python && python -m compileall .

python-compile: python-check

validate-docs:
	bash ./scripts/check-docs.sh

validate-schemas:
	bash ./scripts/validate-schemas.sh

validate-contracts:
	bash ./scripts/check-contract-drift.sh

validate-all:
	bash ./scripts/validate-local.sh

sql-print:
	cat sql/migrations/001_init.sql
