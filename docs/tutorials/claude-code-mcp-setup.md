# Setting Up Vibium MCP in Claude Code

This tutorial covers how to manage MCP (Model Context Protocol) servers in Claude Code, specifically for Vibium browser automation.

## Prerequisites

- Claude Code CLI installed (`npm install -g @anthropic-ai/claude-code`)
- Vibium installed (`npm install vibium`) or clicker binary built locally

## List Installed MCP Servers

To see all currently configured MCP servers:

```bash
claude mcp list
```

Example output:
```
vibium: clicker mcp
filesystem: npx -y @anthropic-ai/mcp-filesystem /path/to/dir
```

If no MCP servers are configured, the output will be empty.

## Add Vibium MCP

### Option 1: Using npx (Recommended)

After Vibium is published to npm:

```bash
claude mcp add vibium -- npx -y vibium
```

### Option 2: Using Local Binary

If you built clicker locally:

```bash
claude mcp add vibium -- /path/to/clicker mcp
```

For example, from the vibium repo root:

```bash
claude mcp add vibium -- ./clicker/bin/clicker mcp
```

### Option 2b: With Screenshot Saving

To enable saving screenshots to disk, add the `--screenshot-dir` flag:

```bash
claude mcp add vibium -- ./clicker/bin/clicker mcp --screenshot-dir ./screenshots
```

Without this flag, screenshots are returned as base64 inline only (no file saving).

### Option 3: Using Absolute Path

```bash
claude mcp add vibium -- $HOME/Projects/vibium/clicker/bin/clicker mcp
```

### Verify Installation

After adding, verify it appears in the list:

```bash
claude mcp list
```

You should see:
```
vibium: /path/to/clicker mcp
```

## Remove Vibium MCP

To remove the Vibium MCP server:

```bash
claude mcp remove vibium
```

Verify removal:

```bash
claude mcp list
```

Vibium should no longer appear in the output.

## Testing the Integration

Once added, start a new Claude Code session and ask Claude to use browser automation:

```
> Take a screenshot of https://example.com
```

Claude will use the Vibium MCP tools:
1. `browser_launch` - Start a headless browser
2. `browser_navigate` - Go to the URL
3. `browser_screenshot` - Capture the page
4. `browser_quit` - Close the browser

## Available MCP Tools

| Tool | Description |
|------|-------------|
| `browser_launch` | Start a browser session (headless by default) |
| `browser_navigate` | Navigate to a URL |
| `browser_click` | Click an element by CSS selector |
| `browser_type` | Type text into an element |
| `browser_screenshot` | Capture a screenshot (optionally save to file with `--screenshot-dir`) |
| `browser_find` | Find element info (tag, text, bounding box) |
| `browser_quit` | Close the browser session |

## Troubleshooting

### MCP server not responding

Check that the clicker binary exists and is executable:

```bash
./clicker/bin/clicker mcp --help
```

### Browser fails to launch

Ensure Chrome for Testing is installed:

```bash
./clicker/bin/clicker install
```

### View MCP server logs

Run clicker directly to see any error output. You can test the full flow by sending JSON-RPC messages to stdin:

**Initialize the connection:**
```bash
echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"capabilities":{}}}' | ./clicker/bin/clicker mcp
```

Expected response:
```json
{"jsonrpc":"2.0","id":1,"result":{"protocolVersion":"2024-11-05","capabilities":{"tools":{}},"serverInfo":{"name":"vibium","version":"0.1.0"}}}
```

**Test a full browser session (headed):**

Create a test script to send multiple commands:

```bash
cat << 'EOF' | ./clicker/bin/clicker mcp
{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"capabilities":{}}}
{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"browser_launch","arguments":{"headless":false}}}
{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"browser_navigate","arguments":{"url":"https://example.com"}}}
{"jsonrpc":"2.0","id":4,"method":"tools/call","params":{"name":"browser_quit","arguments":{}}}
EOF
```

Expected output (one JSON response per line):
```json
{"jsonrpc":"2.0","id":1,"result":{"protocolVersion":"2024-11-05","capabilities":{"tools":{}},"serverInfo":{"name":"vibium","version":"0.1.0"}}}
{"jsonrpc":"2.0","id":2,"result":{"content":[{"type":"text","text":"Browser launched (headless: false)"}]}}
{"jsonrpc":"2.0","id":3,"result":{"content":[{"type":"text","text":"Navigated to https://example.com/"}]}}
{"jsonrpc":"2.0","id":4,"result":{"content":[{"type":"text","text":"Browser session closed"}]}}
```

**Individual commands for reference:**

| Action | JSON-RPC Message |
|--------|------------------|
| Initialize | `{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"capabilities":{}}}` |
| Launch (headed) | `{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"browser_launch","arguments":{"headless":false}}}` |
| Navigate | `{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"browser_navigate","arguments":{"url":"https://example.com"}}}` |
| Screenshot | `{"jsonrpc":"2.0","id":4,"method":"tools/call","params":{"name":"browser_screenshot","arguments":{}}}` |
| Screenshot (to file) | `{"jsonrpc":"2.0","id":4,"method":"tools/call","params":{"name":"browser_screenshot","arguments":{"filename":"page.png"}}}` |
| Quit | `{"jsonrpc":"2.0","id":5,"method":"tools/call","params":{"name":"browser_quit","arguments":{}}}` |
