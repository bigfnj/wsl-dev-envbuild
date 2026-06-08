#!/usr/bin/env bash
# mcp — MCP server registration for Claude Code, VS Code Copilot, and Cursor.
#
# Installs Node.js dependencies for the devenv MCP server, then registers all
# four servers (devenv, github, playwright, context7) in every agent config
# that is detected on this machine:
#
#   Claude Code : ~/.mcp.json               (mcpServers key)
#   VS Code     : %APPDATA%/Code/User/mcp.json   (servers key, type:stdio)
#   Cursor      : %APPDATA%/Cursor/User/mcp.json (servers key, type:stdio)
#
# VS Code and Cursor configs are only written when the respective Windows
# AppData directories exist. Path resolution is dynamic via cmd.exe + wslpath,
# so this works on any WSL2 machine regardless of Windows username.

mcp_desc() { echo "devenv MCP server — exposes manifest tools to Claude Code, VS Code, Cursor"; }

mcp_install() {
    mcp_install_deps
    mcp_register
}

mcp_install_deps() {
    has pnpm || { log_err "pnpm not installed — run the node group first"; return 1; }
    log_info "installing MCP server node dependencies"
    ( cd "$REPO_ROOT/mcp-server" && pnpm install --frozen-lockfile 2>/dev/null || pnpm install )
    log_ok "MCP server dependencies installed"
}

# Resolve Windows %APPDATA% as a WSL path. Returns empty string if cmd.exe or
# wslpath are unavailable (non-WSL environment).
_mcp_win_appdata() {
    local raw
    raw="$(cmd.exe /c 'echo %APPDATA%' 2>/dev/null | tr -d '\r\n')" || return 0
    [ -n "$raw" ] && wslpath "$raw" 2>/dev/null || true
}

# Write the four servers into a Claude-style config (mcpServers key).
_mcp_write_claude_fmt() {
    local dest="$1" server_path="$2"
    [ -f "$dest" ] || printf '{"mcpServers":{}}\n' > "$dest"
    MCP_JSON="$dest" SERVER_PATH="$server_path" node --input-type=module <<'EOF'
import { readFileSync, writeFileSync } from "fs";
const cfg = JSON.parse(readFileSync(process.env.MCP_JSON, "utf8"));
cfg.mcpServers = cfg.mcpServers ?? {};
cfg.mcpServers.devenv    = { command: "node", args: [process.env.SERVER_PATH] };
cfg.mcpServers.github    = { command: "sh", args: ["-c", "GITHUB_TOKEN=$(gh auth token) npx -y @modelcontextprotocol/server-github"] };
cfg.mcpServers.playwright = { command: "npx", args: ["-y", "@playwright/mcp"] };
cfg.mcpServers.context7  = { command: "npx", args: ["-y", "@upstash/context7-mcp"] };
writeFileSync(process.env.MCP_JSON, JSON.stringify(cfg, null, 2) + "\n");
EOF
}

# Write the four servers into a VS Code / Cursor style config (servers key +
# type:stdio). Used by both VS Code Copilot and Cursor — same format.
_mcp_write_vscode_fmt() {
    local dest="$1" server_path="$2"
    [ -f "$dest" ] || printf '{"servers":{}}\n' > "$dest"
    MCP_JSON="$dest" SERVER_PATH="$server_path" node --input-type=module <<'EOF'
import { readFileSync, writeFileSync } from "fs";
const cfg = JSON.parse(readFileSync(process.env.MCP_JSON, "utf8"));
cfg.servers = cfg.servers ?? {};
cfg.servers.devenv    = { type: "stdio", command: "node", args: [process.env.SERVER_PATH] };
cfg.servers.github    = { type: "stdio", command: "sh", args: ["-c", "GITHUB_TOKEN=$(gh auth token) npx -y @modelcontextprotocol/server-github"] };
cfg.servers.playwright = { type: "stdio", command: "npx", args: ["-y", "@playwright/mcp"] };
cfg.servers.context7  = { type: "stdio", command: "npx", args: ["-y", "@upstash/context7-mcp"] };
writeFileSync(process.env.MCP_JSON, JSON.stringify(cfg, null, 2) + "\n");
EOF
}

mcp_register() {
    local server_path="$REPO_ROOT/mcp-server/index.js"

    # ── Claude Code ───────────────────────────────────────────────────────────
    _mcp_write_claude_fmt "$HOME/.mcp.json" "$server_path"
    log_ok "Claude Code  → ~/.mcp.json"

    # ── VS Code + Cursor (Windows AppData, WSL2 only) ─────────────────────────
    local appdata; appdata="$(_mcp_win_appdata)"
    if [ -z "$appdata" ]; then
        log_info "mcp: not a WSL2 environment or cmd.exe unavailable — skipping VS Code/Cursor"
        log_info "restart Claude Code to load the new MCP tools"
        return 0
    fi

    local vscode_user="$appdata/Code/User"
    if [ -d "$vscode_user" ]; then
        _mcp_write_vscode_fmt "$vscode_user/mcp.json" "$server_path"
        log_ok "VS Code      → $vscode_user/mcp.json"
    else
        log_info "mcp: VS Code user dir not found — skipping ($vscode_user)"
    fi

    local cursor_user="$appdata/Cursor/User"
    if [ -d "$cursor_user" ]; then
        _mcp_write_vscode_fmt "$cursor_user/mcp.json" "$server_path"
        log_ok "Cursor       → $cursor_user/mcp.json"
    else
        log_info "mcp: Cursor not installed — skipping (install Cursor to auto-register)"
    fi

    log_info "restart Claude Code / VS Code / Cursor to load the new MCP tools"
}
