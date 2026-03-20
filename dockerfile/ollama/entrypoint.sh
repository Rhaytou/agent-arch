#!/bin/sh
# ============================================================
# OLLAMA ENTRYPOINT — starts Ollama and pulls models on boot
# Models defined in OLLAMA_MODELS env var (comma-separated)
# Example: OLLAMA_MODELS=llama3.2:3b,mistral:7b
# ============================================================

# Start Ollama server in background
ollama serve &
OLLAMA_PID=$!

# Wait for Ollama API to be ready
echo "[ollama-entrypoint] Waiting for Ollama to be ready..."
until curl -s http://localhost:11434/api/tags > /dev/null 2>&1; do
  sleep 1
done
echo "[ollama-entrypoint] Ollama is ready."

# Pull each model defined in OLLAMA_MODELS
if [ -n "${OLLAMA_MODELS}" ]; then
  echo "[ollama-entrypoint] Pulling models: ${OLLAMA_MODELS}"
  echo "${OLLAMA_MODELS}" | tr ',' '\n' | while read -r model; do
    model=$(echo "$model" | tr -d '[:space:]')
    if [ -n "$model" ]; then
      echo "[ollama-entrypoint] Pulling model: $model"
      ollama pull "$model"
    fi
  done
  echo "[ollama-entrypoint] All models pulled."
else
  echo "[ollama-entrypoint] No models specified in OLLAMA_MODELS — skipping pull."
fi

# Hand control back to Ollama server process
wait $OLLAMA_PID



