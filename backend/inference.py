from unsloth import FastLanguageModel
from transformers import TextStreamer
import fire
from flask import Flask, request, jsonify
from flask_cors import CORS
def create_app():
        
    max_seq_length = 2048 # Choose any! We auto support RoPE Scaling internally!
    dtype = None # None for auto detection. Float16 for Tesla T4, V100, Bfloat16 for Ampere+
    load_in_4bit = True # Use 4bit quantization to reduce memory usage. Can be False.
    model, tokenizer = FastLanguageModel.from_pretrained(
            model_name = "lora_model", # YOUR MODEL YOU USED FOR TRAINING
            max_seq_length = max_seq_length,
            dtype = dtype,
            load_in_4bit = load_in_4bit,
        )
    FastLanguageModel.for_inference(model)
    app = Flask(__name__)
    CORS(app)
    @app.route("/inference", methods=["POST"])
    def inference():
        print("recived")
        data = request.json
        print("data: ",data)
        user_input = data.get("message", "")
        if not user_input:
            return jsonify({"error": "No message found"}), 400
        messages = [
            {"role": "system", "content": "Always answer with Chinese. Please respond most briefly."},
            {"role": "user", "content": user_input},
        ]
        
        # Enable native 2x faster inference

        # messages = [
        #     {"from": "human", "value": "What dietary advice should I follow if I have eczema?"},
        # ]
        inputs = tokenizer.apply_chat_template(
            messages,
            tokenize = True,
            add_generation_prompt = True, # Must add for generation
            return_tensors = "pt",
        ).to("cuda")
        # text_streamer = TextStreamer(tokenizer)

        generated_tokens = model.generate(input_ids = inputs, max_new_tokens = 256, use_cache = True)
        generated_text = tokenizer.decode(generated_tokens[0], skip_special_tokens=True)
        print(f"Full Generated Text: {generated_text}\n")

        # Extract the last part of the assistant's reply
        # Split by 'assistant' keyword and take the last segment
        if "assistant" in generated_text:
            last_reply = generated_text.split("assistant")[-1].strip()
        else:
            last_reply = generated_text.strip()  # Fallback if 'assistant' keyword is not found

        print(f"Extracted Reply: {last_reply}\n")

        # Return the extracted reply as JSON
        return jsonify({"reply": last_reply})

    return app

def main(
):
    """
    這個函式使用同樣的參數來初始化 Llama，然後啟動 Flask API。
    """
    app = create_app()
    app.run(host="localhost", port=4000, debug=False)


if __name__ == "__main__":
    fire.Fire(main)
        
# max_seq_length = 2048 # Choose any! We auto support RoPE Scaling internally!
# dtype = None # None for auto detection. Float16 for Tesla T4, V100, Bfloat16 for Ampere+
# load_in_4bit = True # Use 4bit quantization to reduce memory usage. Can be False.
# model, tokenizer = FastLanguageModel.from_pretrained(
#             model_name = "lora_model", # YOUR MODEL YOU USED FOR TRAINING
#             max_seq_length = max_seq_length,
#             dtype = dtype,
#             load_in_4bit = load_in_4bit,
#         )
# FastLanguageModel.for_inference(model)
# # Enable native 2x faster inference

# messages = [
#     {"from": "human", "value": "What dietary advice should I follow if I have eczema?"},
# ]
# inputs = tokenizer.apply_chat_template(
#     messages,
#     tokenize = True,
#     add_generation_prompt = True, # Must add for generation
#     return_tensors = "pt",
# ).to("cuda")
# text_streamer = TextStreamer(tokenizer)
# _ = model.generate(input_ids = inputs, streamer = text_streamer, max_new_tokens = 128, use_cache = True)
# print(f"Assistant: {text_streamer}\n")