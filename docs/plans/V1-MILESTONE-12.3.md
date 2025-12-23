# Milestone 12.3: Main Package with Postinstall

## Overview

Create the main `vibium` npm package that users install. It:
- Re-exports the JS client (browser, browserSync, etc.)
- Lists platform packages as optionalDependencies
- Runs `clicker install` on postinstall to download Chrome
- Provides `npx vibium` entry point for MCP server

## Files to Create

### 1. packages/vibium/package.json

```json
{
  "name": "vibium",
  "version": "0.1.0",
  "description": "Browser automation for AI agents and humans",
  "author": "Jason Huggins <hugs@vibium.com>",
  "license": "Apache-2.0",
  "homepage": "https://vibium.com",
  "repository": {
    "type": "git",
    "url": "git+https://github.com/VibiumDev/vibium.git"
  },
  "bugs": {
    "url": "https://github.com/VibiumDev/vibium/issues"
  },
  "engines": {
    "node": ">=18"
  },
  "main": "./dist/index.js",
  "module": "./dist/index.mjs",
  "types": "./dist/index.d.ts",
  "exports": {
    ".": {
      "types": "./dist/index.d.ts",
      "require": "./dist/index.js",
      "import": "./dist/index.mjs"
    }
  },
  "bin": {
    "vibium": "./bin.js"
  },
  "scripts": {
    "postinstall": "node postinstall.js"
  },
  "files": ["dist", "bin.js", "postinstall.js"],
  "optionalDependencies": {
    "@vibium/linux-x64": "0.1.0",
    "@vibium/linux-arm64": "0.1.0",
    "@vibium/darwin-x64": "0.1.0",
    "@vibium/darwin-arm64": "0.1.0",
    "@vibium/win32-x64": "0.1.0"
  },
  "dependencies": {
    "ws": "^8.18.3"
  }
}
```

### 2. packages/vibium/bin.js

Entry point for `npx vibium` - runs MCP server:

```javascript
#!/usr/bin/env node
// Find clicker binary from platform package and run `clicker mcp`

const { execFileSync } = require('child_process');
const path = require('path');
const os = require('os');

function getClickerPath() {
  const platform = os.platform();
  const arch = os.arch() === 'x64' ? 'x64' : 'arm64';
  const packageName = `@vibium/${platform}-${arch}`;
  const binaryName = platform === 'win32' ? 'clicker.exe' : 'clicker';

  try {
    const packagePath = require.resolve(`${packageName}/package.json`);
    return path.join(path.dirname(packagePath), 'bin', binaryName);
  } catch {
    console.error(`Could not find clicker binary for ${platform}-${arch}`);
    process.exit(1);
  }
}

const clickerPath = getClickerPath();
execFileSync(clickerPath, ['mcp'], { stdio: 'inherit' });
```

### 3. packages/vibium/postinstall.js

Downloads Chrome for Testing on install:

```javascript
#!/usr/bin/env node
// Run clicker install to download Chrome for Testing

if (process.env.VIBIUM_SKIP_BROWSER_DOWNLOAD === '1') {
  console.log('Skipping browser download (VIBIUM_SKIP_BROWSER_DOWNLOAD=1)');
  process.exit(0);
}

const { execFileSync } = require('child_process');
const path = require('path');
const os = require('os');

function getClickerPath() {
  const platform = os.platform();
  const arch = os.arch() === 'x64' ? 'x64' : 'arm64';
  const packageName = `@vibium/${platform}-${arch}`;
  const binaryName = platform === 'win32' ? 'clicker.exe' : 'clicker';

  try {
    const packagePath = require.resolve(`${packageName}/package.json`);
    return path.join(path.dirname(packagePath), 'bin', binaryName);
  } catch {
    // Binary not available for this platform - skip silently
    process.exit(0);
  }
}

try {
  const clickerPath = getClickerPath();
  console.log('Installing Chrome for Testing...');
  execFileSync(clickerPath, ['install'], { stdio: 'inherit' });
} catch (error) {
  console.warn('Warning: Failed to install browser:', error.message);
  // Don't fail the install - user can run manually later
}
```

## Files to Modify

### 1. clients/javascript/src/clicker/binary.ts

Update package name pattern from `@vibium/clicker-*` to `@vibium/*`:

```typescript
// Change this:
const packageName = `@vibium/clicker-${platform}-${arch}`;
// To this:
const packageName = `@vibium/${platform}-${arch}`;
```

### 2. Makefile

Add `package-main` target:

```makefile
# Build main vibium package (copy JS dist)
package-main: build-js
	mkdir -p packages/vibium/dist
	cp -r clients/javascript/dist/* packages/vibium/dist/
```

### 3. Root package.json

Add packages/vibium to workspaces:

```json
{
  "workspaces": [
    "clients/javascript",
    "packages/vibium"
  ]
}
```

## Verification Checkpoint

```bash
# Build and package
make package-main

# Verify dist files copied
ls packages/vibium/dist/

# Verify imports work (from local dist)
node -e "const { browser, browserSync } = require('./packages/vibium/dist'); console.log('OK')"

# Run tests to ensure nothing broken
make test
```

Note: End-to-end testing with `npm pack` and `npx vibium` is covered in Milestone 12.5.
