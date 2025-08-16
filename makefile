.PHONY: clean pull pre_commit build_runner env start detect_branch_duplicate_code integration_test fvm_clean fvm_pre_commit fvm_build_runner fvm_env fvm_start fvm_detect_branch_duplicate_code fvm_integration_test 

help: ## Show commands that can be use by make
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "  %-30s %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "Run 'make [target] --help' to get more information about a specific target."

changes_pull:
	@echo "Pulling latest changes"
	git pull

## Default commands
build_runner: ## Shortcut for build_runner
	@echo "Generating files with build_runner"
	dart run build_runner build --delete-conflicting-outputs

start_web: ## Start App in dev mode
	flutter run -d chrome --web-port=8080

clean: ## Cleaning environment
	@echo "Cleaning up..."
	flutter clean

start_env: ## Starting flutter app with the specified .env config. Use: make start_env env=<envName>, where envName == .env.<envName>. This will OVERWRITE your .env file
ifeq (,$(wildcard ./.env.${env}))
	$(error Config .env.${env} does not exist!)
else
	@cp .env.${env} .env
	@echo .env is overwritten with .env.${env}
	flutter run
endif

pull: changes_pull deps_get build_runner ## Pulling latest changes with dependencies

deps_get: ## Get dependencies 
	@echo "Getting dependencies"
	flutter pub get
	flutter pub outdated --no-show-all

pre_commit: ## Format code & Analyze & Run tests
	dart format . && flutter analyze && flutter test