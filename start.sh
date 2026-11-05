
#!/bin/bash
set -e

echo "Starting Ollama..."

ollama serve &
OLLAMA_PID=$!

echo "Waiting for Ollama..."

until curl -fsS http://127.0.0.1:11434/api/tags >/dev/null; do
    sleep 2
done

echo "Downloading llama3.2..."

ollama pull llama3.2

echo "Starting FastAPI..."

uvicorn main:app --host 0.0.0.0 --port "${PORT:-8000}"
