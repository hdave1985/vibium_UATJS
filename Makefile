.PHONY: all build build-go build-js deps clean clean-bin clean-js clean-cache clean-all serve test test-cli test-js test-mcp double-tap help

# Default target
all: build

# Build everything (Go + JS)
build: build-go build-js

# Build clicker binary
build-go: deps
	cd clicker && go build -o bin/clicker ./cmd/clicker

# Build JS client
build-js: deps
	cd clients/javascript && npm run build

# Install npm dependencies (skip if node_modules exists)
deps:
	@if [ ! -d "node_modules" ]; then npm install; fi

# Start the proxy server
serve: build-go
	./clicker/bin/clicker serve

# Run all tests
test: build test-cli test-js test-mcp

# Run CLI tests (tests the clicker binary directly)
# Process tests run separately with --test-concurrency=1 to avoid interference
test-cli: build-go
	@echo "━━━ CLI Tests ━━━"
	node --test tests/cli/navigation.test.js tests/cli/elements.test.js tests/cli/actionability.test.js
	@echo "━━━ CLI Process Tests (sequential) ━━━"
	node --test --test-concurrency=1 tests/cli/process.test.js

# Run JS library tests (sequential to avoid resource exhaustion)
test-js: build
	@echo "━━━ JS Library Tests ━━━"
	node --test --test-concurrency=1 tests/js/async-api.test.js tests/js/sync-api.test.js tests/js/auto-wait.test.js tests/js/headless-headed.test.js
	@echo "━━━ JS Process Tests (sequential) ━━━"
	node --test --test-concurrency=1 tests/js/process.test.js

# Run MCP server tests (sequential - browser sessions)
test-mcp: build-go
	@echo "━━━ MCP Server Tests ━━━"
	node --test --test-concurrency=1 tests/mcp/server.test.js

# Kill zombie Chrome and chromedriver processes
double-tap:
	@echo "Killing zombie processes..."
	@pkill -9 -f 'Chrome for Testing' 2>/dev/null || true
	@pkill -9 -f chromedriver 2>/dev/null || true
	@sleep 1
	@echo "Done."

# Clean clicker binaries
clean-bin:
	rm -rf clicker/bin

# Clean JS dist
clean-js:
	rm -rf clients/javascript/dist

# Clean cached Chrome for Testing
clean-cache:
	rm -rf ~/Library/Caches/vibium/chrome-for-testing
	rm -rf ~/.cache/vibium/chrome-for-testing

# Clean everything (binaries + JS dist + cache)
clean-all: clean-bin clean-js clean-cache

# Alias for clean-bin + clean-js
clean: clean-bin clean-js

# Show available targets
help:
	@echo "Available targets:"
	@echo "  make             - Build everything (default)"
	@echo "  make build-go    - Build clicker binary"
	@echo "  make build-js    - Build JS client"
	@echo "  make deps        - Install npm dependencies"
	@echo "  make serve       - Start proxy server on :9515"
	@echo "  make test        - Run all tests (CLI + JS + MCP)"
	@echo "  make test-cli    - Run CLI tests only"
	@echo "  make test-js     - Run JS library tests only"
	@echo "  make test-mcp    - Run MCP server tests only"
	@echo "  make double-tap  - Kill zombie Chrome/chromedriver processes"
	@echo "  make clean       - Clean binaries and JS dist"
	@echo "  make clean-cache - Clean cached Chrome for Testing"
	@echo "  make clean-all   - Clean everything"
	@echo "  make help        - Show this help"
