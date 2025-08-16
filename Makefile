# Define variables for common commands and directories
FLUTTER_CMD = flutter
BUILD_RUNNER_CMD = $(FLUTTER_CMD) pub run build_runner build --delete-conflicting-outputs

# The default target. Run 'make' to see available commands.
.PHONY: help
help:
	@echo "Welcome to the Surabhi project Makefile!"
	@echo ""
	@echo "Available commands:"
	@echo "  make get              - Install all Flutter project dependencies"
	@echo "  make run              - Run the app on a connected device or emulator"
	@echo "  make build_ios        - Build an iOS release IPA"
	@echo "  make build_android    - Build an Android release APK"
	@echo "  make generate         - Run build_runner to generate files (e.g., json_serializable)"
	@echo "  make clean            - Clean the Flutter project build artifacts"
	@echo "  make format           - Format Dart code"
	@echo "  make analyze          - Analyze Dart code for static errors"
	@echo "  make test             - Run all tests"
	@echo "  make lint             - Run all linters (alias for analyze)"

# Rule to get all pub dependencies
.PHONY: get
get:
	@echo "=> Getting project dependencies..."
	$(FLUTTER_CMD) pub get

# Rule to run the app
.PHONY: run
run: get generate
	@echo "=> Running the application..."
	$(FLUTTER_CMD) run

# Rule to build an iOS release IPA
.PHONY: build_ios
build_ios: get generate
	@echo "=> Building iOS release IPA..."
	$(FLUTTER_CMD) build ipa

# Rule to build an Android release APK
.PHONY: build_android
build_android: get generate
	@echo "=> Building Android release APK..."
	$(FLUTTER_CMD) build apk --release

# Rule to run build_runner for code generation
.PHONY: generate
generate:
	@echo "=> Running code generation (build_runner)..."
	$(BUILD_RUNNER_CMD)

# Rule to clean project build artifacts
.PHONY: clean
clean:
	@echo "=> Cleaning project..."
	$(FLUTTER_CMD) clean

# Rule to format Dart code
.PHONY: format
format:
	@echo "=> Formatting Dart code..."
	dart format lib/

# Rule to analyze Dart code
.PHONY: analyze lint
analyze:
	@echo "=> Analyzing Dart code..."
	$(FLUTTER_CMD) analyze
lint: analyze

# Rule to run all tests
.PHONY: test
test: get
	@echo "=> Running tests..."
	$(FLUTTER_CMD) test
