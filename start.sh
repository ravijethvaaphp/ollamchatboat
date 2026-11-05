
#!/bin/bash
set -e

echo "Starting Ollama server..."

ollama serve &
OLLAMA_PID=$!

echo "Waiting for Ollama..."

for i in $(seq 1 60); do
    if curl -fsS http://127.0.0.1:11434/api/tags >/dev/null; then
        echo "Ollama is ready!"
        break
    fi

    if ! kill -0 "$OLLAMA_PID" 2>/dev/null; then
        echo "Ollama process stopped unexpectedly"
        exit 1
    fi

    sleep 2
done

curl -fsS http://127.0.0.1:11434/api/tags >/dev/null || {
    echo "Ollama failed to start"
    exit 1
}

echo "Pulling llama3.2 model..."
ollama pull llama3.2

echo "Starting FastAPI..."

exec uvicorn main:app --host 0.0.0.0 --port "${PORT:-8000}"
