# 1. Start from the official, public vLLM image
# This comes with CUDA, PyTorch, and vLLM pre-installed.
FROM vllm/vllm-openai:latest

# 2. Install system dependencies
# We need 'curl' for our health check and 'git' for some python deps
RUN apt-get update && \
    apt-get install -y curl git && \
    rm -rf /var/lib/apt/lists/*

# 3. Install the RunPod SDK and PaddleOCR
# We install "paddleocr[doc-parser]" as you suggested
# We also pin a few libraries that are known to work with vLLM
RUN pip install runpod --no-cache-dir
RUN pip install "paddleocr[doc-parser]" --no-cache-dir

# 4. Install the *specific* dependencies for Paddle's genai_server
# This is the key step you found: `paddleocr install_genai_server_deps vllm`
# We also install 'uvicorn' as the server needs it.
RUN paddleocr install_genai_server_deps vllm
RUN pip install uvicorn

# 5. Set a working directory
WORKDIR /app

# 6. Copy the handler and the startup script
COPY handler.py .
COPY start.sh .

# 7. Make the startup script executable
RUN chmod +x /app/start.sh

# 8. Set the entrypoint to our custom startup script
# This script will launch the vLLM server and then the RunPod handler
CMD ["/app/start.sh"]

