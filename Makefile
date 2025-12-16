.PHONY: build clean clean-bin clean-cache clean-all

# Build clicker binary
build:
	cd clicker && go build -o bin/clicker ./cmd/clicker

# Clean clicker binaries
clean-bin:
	rm -rf clicker/bin

# Clean cached Chrome for Testing
clean-cache:
	rm -rf ~/Library/Caches/vibium/chrome-for-testing
	rm -rf ~/.cache/vibium/chrome-for-testing

# Clean everything (binaries + cache)
clean-all: clean-bin clean-cache

# Alias for clean-bin
clean: clean-bin
