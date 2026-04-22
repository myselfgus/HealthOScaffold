bootstrap:
	bash ./scripts/bootstrap-local.sh

tree:
	find . -maxdepth 4 -type f | sort

swift-build:
	cd swift && swift build

ts-build:
	cd ts && npm install && npm run build

sql-print:
	cat sql/migrations/001_init.sql
