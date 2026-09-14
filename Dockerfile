# VibeVoice 7B TTS image for Unraid (GPU). Built & pushed to GHCR by CI.
# Base already ships torch + CUDA 12.4 + cuDNN9 -> no torch build, no flash-attn compile.
FROM pytorch/pytorch:2.4.1-cuda12.4-cudnn9-runtime

ENV DEBIAN_FRONTEND=noninteractive \
    HF_HOME=/root/.cache/huggingface \
    PYTHONUNBUFFERED=1

# git (pip -e metadata) + ffmpeg (audio encode/decode)
RUN apt-get update && \
    apt-get install -y --no-install-recommends git ffmpeg && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /workspace/VibeVoice
COPY . /workspace/VibeVoice

# Installs transformers==4.51.3, accelerate==1.6.0, etc. flash-attn is NOT pulled;
# on CUDA the script requests flash_attention_2 and auto-falls back to SDPA.
RUN pip install --no-cache-dir -e . && chmod +x docker/entrypoint.sh

# Defaults -> all overridable as editable fields in the Unraid template.
# Speaker 1->Alice (Dana), 2->Carter (Marcus), 3->Frank (Jerry), 4->Maya (Priya).
# The ~18 GB model auto-downloads to the mapped HF cache on first run only.
ENV MODEL_PATH=vibevoice/VibeVoice-7B \
    INPUT_TXT=/app/input/coffee_crisis.txt \
    OUTPUT_DIR=/app/output \
    SPEAKER_NAMES="Alice Carter Frank Maya" \
    CFG_SCALE=1.3

ENTRYPOINT ["/workspace/VibeVoice/docker/entrypoint.sh"]
