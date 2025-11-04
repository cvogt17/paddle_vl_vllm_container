FROM ccr-2vdh3abv-pub.cnc.bj.baidubce.com/paddlepaddle/paddleocr-genai-vllm-server:latest

RUN apt-get update && \
    apt-get install -y curl && \
    rm -rf /var/lib/apt/lists/*

RUN pip install runpod --no-cache-dir

WORKDIR /app

COPY handler.py .
COPY start.sh .

RUN chmod +x /app/start.sh

CMD ["/app/start.sh"]
