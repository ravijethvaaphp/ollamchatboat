
#!/bin/bash
set -e

# Start Ollama
ollama serve &
OLLAMA_PID=$!

# Wait for Ollama
until curl -s http://localhost:11434/api/tags >/dev/null; do
    sleep 2
done

# Download model
ollama pull llama3.2

# Start FastAPI
uvicorn main:app --host 0.0.0.0 --port ${PORT:-8000} &
FASTAPI_PID=$!

# Keep both processes alive
wait -n $OLLAMA_PID $FASTAPI_PID
