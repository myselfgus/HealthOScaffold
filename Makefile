bootstrap:
	bash ./scripts/bootstrap-local.sh

tree:
	find . -maxdepth 4 -type f | sort

swift-build:
	cd swift && swift build

swift-test:
	cd swift && swift test

swift-smoke:
	cd swift && swift run HealthOSCLI && swift run HealthOSScribeApp --smoke-test

ts-build:
	cd ts && npm install && npm run build

ts-test:
	cd ts && npm test --if-present --workspaces

python-compile:
	cd python && python -m compileall .

sql-print:
	cat sql/migrations/001_init.sql
