# 1. Start from Paddle's *official* genai image from the docs you linked
# This has the correct Python/CUDA environment for the install script.
FROM paddleocr/paddleocr_genai:v1.0

# 2. Install system dependencies (git/curl) and the RunPod SDK
# The base image does not have runpod.
RUN apt-get update && \
    apt-get install -y curl git && \
    rm -rf /var/lib/apt/lists/*

RUN pip install runpod --no-cache-dir

# 3. Install the vLLM dependencies
# This command is *designed* to run inside this *specific* base image.
# It will find the correct pre-compiled wheels.
RUN paddleocr install_genai_server_deps vllm

# 4. Install uvicorn for the server
RUN pip install uvicorn

# 5. Set a working directory
WORKDIR /app

# 6. Copy the handler and the startup script
COPY handler.py .
COPY start.sh .

# 7. Make the startup script executable
RUN chmod +x /app/start.sh

# 8. Set the entrypoint to our custom startup script
CMD ["/app/start.sh"]
