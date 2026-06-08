#!/usr/bin/env bash
# image — image / media command-line tools (global). Python imaging libraries
# (Pillow, OpenCV, scikit-image) and ML upscalers are PROJECT-LOCAL via uv,
# never global — see docs/architecture.md §4.

image_desc() { echo "imagemagick, ffmpeg, Pillow (ipython-injected)"; }

image_install() {
    apt_install imagemagick ffmpeg
    image_pillow
    image_record_manifest
}

# Pillow is a Python imaging library — not a CLI, so it can't go in ~/tools/bin.
# We inject it into ipython's isolated pipx environment: available in the global
# REPL, properly isolated, and no system-pip pollution. For project image code,
# use `uv add pillow` in the project venv (the canonical approach).
image_pillow() {
    if ! has ipython; then
        log_warn "Pillow: ipython not installed — skipping inject (run python group first)"
        return 0
    fi
    if ipython -c "import PIL" >/dev/null 2>&1; then
        log_skip "Pillow already injected into ipython"
        return 0
    fi
    log_info "injecting Pillow into ipython pipx env"
    pipx inject ipython Pillow
}

image_record_manifest() {
    # ImageMagick 7 ships the `magick` driver; `convert` may exist as legacy compat.
    local im=""
    if has magick; then im=magick; elif has convert; then im=convert; fi
    if [ -n "$im" ]; then
        manifest_add imagemagick "$im" image global apt "$im --version" core "image manipulation/conversion"
    fi
    if has ffmpeg; then manifest_add ffmpeg ffmpeg image global apt "ffmpeg -version" core "audio/video transcoding"; fi
    if ipython -c "import PIL" >/dev/null 2>&1; then
        manifest_add pillow ipython image global pipx-inject "ipython -c 'import PIL; print(PIL.__version__)'" core "Python imaging library; injected into ipython for REPL use — use 'uv add pillow' for project code" "ipython"
    fi
    log_ok "manifest updated — image group"
}
