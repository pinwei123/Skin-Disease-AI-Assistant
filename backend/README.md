# Skin Lesion Detection Backend

This backend loads a LoRA fine-tuned version of LLaMA3 8B to assist in skin disease diagnosis.

## 🔗 Model Location

The LoRA weights and tokenizer are hosted on Hugging Face:  
👉 https://huggingface.co/Pluxs/skin_lora_llama3.1_8B

---
### 📁 Output Folder: `lora_model/`

When running the script, a folder named `lora_model/` will be created automatically if it doesn't exist.

This folder stores:
- Downloaded tokenizer
- LoRA adapter weights
- Config files

You **do not need to download manually**.
## 📦 Installation

```bash
pip install transformers peft accelerate
