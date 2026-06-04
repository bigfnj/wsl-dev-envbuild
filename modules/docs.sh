#!/usr/bin/env bash
# docs — document conversion + markdown quality. pandoc (apt) for broad
# cross-project document conversion; markdownlint-cli (npm, user prefix) so
# agents and humans can lint docs before committing.

docs_desc() { echo "pandoc, markdownlint-cli"; }

docs_install() {
    apt_install pandoc
    npm_global markdownlint-cli markdownlint
    docs_record_manifest
}

docs_record_manifest() {
    if has pandoc;       then manifest_add pandoc           pandoc       docs global apt      "pandoc --version"       core "universal document converter"; fi
    if has markdownlint; then manifest_add markdownlint-cli markdownlint docs global npm-user "markdownlint --version" core "markdown linter for docs"; fi
    log_ok "manifest updated — docs group"
}
