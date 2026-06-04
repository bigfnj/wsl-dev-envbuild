#!/usr/bin/env bash
# data — lightweight local data tooling (CLI). Heavy DS/ML libraries (pandas,
# numpy, scikit-learn, pytorch, …) are PROJECT-LOCAL via uv, never global.
# sqlite3 itself lives in the core group.

data_desc() { echo "duckdb CLI, sqlite-utils, csvkit"; }

data_install() {
    data_duckdb
    pipx_install sqlite-utils   # SQLite automation/CLI
    pipx_install csvkit         # csvlook, csvcut, csvstat, in2csv, …
    data_record_manifest
}

# DuckDB CLI — standalone glibc binary from GitHub releases into ~/tools/bin.
# (The pip `duckdb` package is the Python library, not the CLI — different thing.)
data_duckdb() {
    if has duckdb; then
        log_skip "duckdb already installed ($(duckdb --version 2>/dev/null))"
        return 0
    fi
    local url zip
    url="$(curl -fsSL https://api.github.com/repos/duckdb/duckdb/releases/latest 2>/dev/null \
        | jq -r '.assets[] | select(.name=="duckdb_cli-linux-amd64.zip") | .browser_download_url' | head -1)"
    if [ -z "$url" ]; then
        log_warn "duckdb: could not resolve CLI URL — skipping"
        return 0
    fi
    zip="$(mktemp --suffix=.zip)"
    log_info "downloading DuckDB CLI ($(basename "$url"))"
    if curl -fsSL "$url" -o "$zip"; then
        unzip -q -o "$zip" -d "$HOME/tools/bin"
        chmod +x "$HOME/tools/bin/duckdb"
        log_ok "duckdb -> ~/tools/bin/duckdb"
    else
        log_warn "duckdb download failed — skipping"
    fi
    rm -f "$zip"
}

data_record_manifest() {
    if has duckdb;       then manifest_add duckdb       duckdb       data global github-zip "duckdb --version"       core "in-process analytical SQL over CSV/Parquet/JSON"; fi
    if has sqlite-utils; then manifest_add sqlite-utils sqlite-utils data global pipx       "sqlite-utils --version" core "SQLite CLI + automation"; fi
    if has csvlook;      then manifest_add csvkit       csvlook      data global pipx       "csvlook --version"      core "CSV inspection/conversion (csvlook, csvcut, …)"; fi
    log_ok "manifest updated — data group"
}
