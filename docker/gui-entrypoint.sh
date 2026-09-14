#!/usr/bin/env bash
# Launch the VibeVoice Gradio web UI (persistent service). Same image as the
# batch container; selected via --entrypoint in the GUI template.
set -euo pipefail

cd /workspace/VibeVoice

GUI_PORT="${GUI_PORT:-7860}"
echo "VibeVoice GUI:"
echo "  model = ${MODEL_PATH}"
echo "  port  = ${GUI_PORT}"

# Merge mounted custom voices into the built-in set so they show in the dropdown.
CUSTOM_VOICES_DIR="${CUSTOM_VOICES_DIR:-/app/voices}"
if [ -d "${CUSTOM_VOICES_DIR}" ]; then
  shopt -s nullglob
  custom=( "${CUSTOM_VOICES_DIR}"/*.wav )
  if [ ${#custom[@]} -gt 0 ]; then
    echo "  custom = ${#custom[@]} voice(s)"
    for f in "${custom[@]}"; do echo "    + $(basename "$f")"; cp -f "$f" demo/voices/; done
  fi
  shopt -u nullglob
fi

# gradio_demo.py is patched at build time to bind 0.0.0.0 (LAN) without the
# public --share tunnel. Model stays resident in VRAM while this runs.
exec python demo/gradio_demo.py --model_path "${MODEL_PATH}" --device cuda --port "${GUI_PORT}"
