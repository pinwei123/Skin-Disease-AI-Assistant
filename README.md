# Skin Disease AI Assistant

A hybrid mobile–backend solution designed to support skin-disease assessment using lightweight computer vision and an optimized large language model. The system performs on-device inference for image classification and provides interactive medical dialogue through an LLM-powered backend.

---

## 🎯 Purpose

Skin conditions often appear visually similar, making early identification difficult. This project aims to provide a private, fast, and accessible tool by offering:

* Local image-based condition prediction
* A privacy-preserving workflow with no external data upload
* A conversational interface for medical Q&A driven by a fine-tuned LLM

---

## 🌟 Key Capabilities

| Component               | Summary                                                                    |
| ----------------------- | -------------------------------------------------------------------------- |
| 📱 On-Device Prediction | MobileNetV2 TFLite model for local skin-disease recognition                |
| 💬 LLM-Powered Chat     | LoRA-fine-tuned LLaMA providing medical question-answering                 |
| 🔒 Data Privacy         | Entire inference pipeline stays offline, user data never leaves the device |

---

## 🧩 Model Overview

### Image Classification

* Model: MobileNetV2 (converted to TFLite)
* Designed for real-time inference on mobile hardware
* Trained on dermatology datasets
* Optimized for speed and reduced memory footprint

### Language Model

* Base Model: LLaMA3
* Fine-tuned via LoRA using the Unsloth pipeline
* Custom configurations and tokenizer located in `lora_model/` (excluded from Git)

---

## 📱 System Demo

<p align="center">
  <img src="Demo.png" alt="Skin Disease AI Assistant Demo" width="800"/>
</p>

---

## 🔍 Workflow Overview

1. **User captures or selects a skin-image**
2. **Mobile app performs local inference using a TFLite classifier**

   * Runs fully offline
   * Produces instant predictions
3. **Prediction is forwarded to the backend**
4. **Backend queries a fine-tuned LLaMA model**

   * Generates explanations
   * Offers symptom insights
   * Suggests possible next steps

This design ensures low-latency inference, strong privacy guarantees, and rich medical Q&A capabilities.
