#!/bin/bash
set -e

# 1. Start the PaddleOCR-VL vLLM Server in the background
echo "Starting PaddleOCR-VL vLLM Server in the background..."
paddleocr genai_server \
    --model_name PaddleOCR-VL-0.9B \
    --host 127.0.0.1 \
    --port 8118 \
    --backend vllm &

# 2. Wait for the vLLM server to be ready
echo "Waiting for vLLM server to launch on port 8118..."

# We poll the server's port until it responds, indicating it's ready
while ! curl -s http://127.0.0.1:8118 > /dev/null; do
    echo "Server not yet ready. Waiting 2 seconds..."
    sleep 2
done

echo "vLLM Server is up and running."

# 3. Start the RunPod handler in the foreground
# 'exec' replaces the shell process with the Python process
echo "Starting RunPod handler..."
exec python -u handler.py
