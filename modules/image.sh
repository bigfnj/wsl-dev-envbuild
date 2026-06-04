#!/usr/bin/env bash
# image — image / media command-line tools (global). Python imaging libraries
# (Pillow, OpenCV, scikit-image) and ML upscalers are PROJECT-LOCAL via uv,
# never global — see docs/architecture.md §4.

image_desc() { echo "imagemagick, ffmpeg"; }

image_install() {
    apt_install imagemagick ffmpeg
    image_record_manifest
}

image_record_manifest() {
    # ImageMagick 7 ships the `magick` driver; `convert` may exist as legacy compat.
    local im=""
    if has magick; then im=magick; elif has convert; then im=convert; fi
    if [ -n "$im" ]; then
        manifest_add imagemagick "$im" image global apt "$im --version" core "image manipulation/conversion"
    fi
    if has ffmpeg; then manifest_add ffmpeg ffmpeg image global apt "ffmpeg -version" core "audio/video transcoding"; fi
    log_ok "manifest updated — image group"
}
