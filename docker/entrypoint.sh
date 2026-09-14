#!/usr/bin/env bash
# One-shot VibeVoice generation. All settings come from env vars (Unraid template fields).
set -euo pipefail

cd /workspace/VibeVoice

echo "VibeVoice run:"
echo "  model   = ${MODEL_PATH}"
echo "  input   = ${INPUT_TXT}"
echo "  speakers= ${SPEAKER_NAMES}"
echo "  output  = ${OUTPUT_DIR}"
echo "  cfg     = ${CFG_SCALE}"

if [ ! -f "${INPUT_TXT}" ]; then
  echo "ERROR: input script not found at ${INPUT_TXT}" >&2
  echo "Put your 'Speaker 1:'-formatted .txt in the mapped input folder." >&2
  exit 1
fi

mkdir -p "${OUTPUT_DIR}"

# SPEAKER_NAMES is intentionally unquoted so it splits into separate args (nargs='+').
exec python demo/inference_from_file.py \
  --model_path "${MODEL_PATH}" \
  --txt_path "${INPUT_TXT}" \
  --speaker_names ${SPEAKER_NAMES} \
  --output_dir "${OUTPUT_DIR}" \
  --cfg_scale "${CFG_SCALE}"
