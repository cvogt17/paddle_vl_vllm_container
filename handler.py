import runpod
from paddleocr import PaddleOCRVL
import os

# 1. Initialize the client to talk to our local vLLM server
# This runs ONCE when the worker starts, after start.sh confirms the server is up.
VL_SERVER_URL = "http://127.0.0.1:8118" # Must match the port in start.sh

try:
    # We use the PaddleOCRVL client, which knows how to talk to the genai_server
    pipeline = PaddleOCRVL(
        vl_rec_backend="vllm-server", 
        vl_rec_server_url=VL_SERVER_URL
    )
    print("PaddleOCRVL client initialized successfully.")
except Exception as e:
    print(f"Fatal: Error initializing PaddleOCRVL client: {e}")
    pipeline = None

def handler(job):
    """
    Process an incoming job from the RunPod queue.
    """
    if not pipeline:
        return {"error": "Pipeline failed to initialize on worker start."}
    
    job_input = job.get('input', {})
    image_url = job_input.get('url')

    if not image_url:
        return {"error": "Missing 'url' in input."}
    
    if not image_url.startswith('http'):
         return {"error": "Invalid input. 'url' must be a valid .png URL."}

    print(f"Processing job for URL: {image_url}")

    try:
        # 2. Run inference by sending the URL to the vLLM server
        # The client returns a list of PaddleOCRVLResult objects
        output = pipeline.predict(image_url)
        
        # 3. Build a comprehensive results list based on the documentation
        results_list = []
        for res in output:
            # res is a PaddleOCRVLResult object
            # We extract all relevant parts as shown in the docs
            result_item = {
                "data": res.data,  # This corresponds to 'prunedResult'
                "markdown": getattr(res, 'markdown', None), # Corresponds to 'markdown'
                "output_image_base64": getattr(res, 'img', None) # Corresponds to 'outputImages' (as 'img' property)
            }
            results_list.append(result_item)
        
        print("Inference successful. Returning all parts.")
        return results_list

    except Exception as e:
        print(f"Error during inference: {e}")
        return {"error": str(e)}

# 4. Start the RunPod serverless worker
# This will wait for jobs from the RunPod API
runpod.serverless.start({"handler": handler})
