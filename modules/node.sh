#!/usr/bin/env bash
# node — JavaScript / TypeScript runtime layer.
#
# Node.js comes from NodeSource (current LTS), not Debian's stale apt package.
# pnpm and tsx are the ONLY global JS tools, installed via npm into a USER
# prefix (~/.local) so there's no sudo and no /usr global-modules pollution —
# their bins land in ~/.local/bin, already on PATH (no third PATH entry).
#
# Everything else — TypeScript, ESLint, Prettier, Vite, frameworks — is
# project-local in node_modules (pnpm). See docs/architecture.md §4.

NODE_MAJOR=22

node_desc() { echo "Node.js (NodeSource LTS), pnpm, tsx"; }

node_install() {
    node_runtime
    node_global_tools
    node_record_manifest
}

# Install Node.js from NodeSource only if absent. Guarded so re-runs never
# re-add the apt repo or reinstall.
node_runtime() {
    if has node; then
        log_skip "node already installed ($(node --version))"
        return 0
    fi
    log_info "adding NodeSource repo (Node ${NODE_MAJOR}.x)"
    curl -fsSL "https://deb.nodesource.com/setup_${NODE_MAJOR}.x" | sudo -E bash -
    apt_install nodejs
}

# Route global npm installs to ~/.local (user-owned), then install pnpm + tsx.
node_global_tools() {
    if [ "$(npm config get prefix)" != "$HOME/.local" ]; then
        npm config set prefix "$HOME/.local"
        log_ok "npm global prefix -> ~/.local (user-owned, no sudo)"
    else
        log_skip "npm global prefix already ~/.local"
    fi
    node_npm_global pnpm   # fast, disk-efficient package manager (preferred)
    node_npm_global tsx    # run .ts files directly, no build step
}

# node_npm_global <pkg> [binary] — install a global npm CLI idempotently.
node_npm_global() {
    local pkg="$1" bin="${2:-$1}"
    if has "$bin"; then
        log_skip "npm -g: $pkg already present ($bin)"
        return 0
    fi
    log_info "npm install -g $pkg"
    npm install -g "$pkg"
}

node_record_manifest() {
    if has node; then manifest_add nodejs node node global nodesource "node --version" core "current LTS via NodeSource apt repo"; fi
    if has npm;  then manifest_add npm   npm  node global nodesource "npm --version"  core "bundled with Node.js"; fi
    if has pnpm; then manifest_add pnpm  pnpm node global npm-user    "pnpm --version" core "preferred package manager (npm -g into ~/.local)"; fi
    if has tsx;  then manifest_add tsx   tsx  node global npm-user    "tsx --version"  core "run TypeScript files directly, no build step"; fi
    log_ok "manifest updated — node group"
}
