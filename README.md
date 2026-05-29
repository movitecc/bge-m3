# BGE-M3 Embedding Model

[BAAI/bge-m3](https://huggingface.co/BAAI/bge-m3) — 多语言 Embedding 模型，支持 Dense / Sparse / ColBERT 三种检索方式。

## 仓库内容

本仓库仅包含模型的**配置文件和分词器**（小文件）。大模型权重文件以分卷形式放在 [Releases](https://github.com/movitecc/bge-m3/releases) 中。

### 目录结构

```
bge-m3/
├── config.json                    # 模型配置
├── config_sentence_transformers.json
├── sentence_bert_config.json
├── modules.json                   # 模块配置
├── tokenizer.json                 # 分词器（17MB）
├── tokenizer_config.json
├── special_tokens_map.json
├── sentencepiece.bpe.model        # SentencePiece 模型
├── colbert_linear.pt              # ColBERT 线性层（2.1MB）
├── sparse_linear.pt               # Sparse 线性层
├── 1_Pooling/
│   └── config.json
├── onnx/                          # ONNX 推理配置
│   ├── config.json
│   ├── model.onnx                 # ONNX 模型结构（708KB）
│   ├── tokenizer.json
│   ├── tokenizer_config.json
│   └── special_tokens_map.json
├── download_and_merge.sh          # 下载并合并权重
└── README.md
```

## 使用方式

### 方式一：下载完整模型（推荐）

```bash
# 使用 Hugging Face Hub 直接下载
pip install huggingface-hub
huggingface-cli download BAAI/bge-m3 --local-dir ./bge-m3/
```

### 方式二：从 Release 下载并合并

```bash
# 下载合并脚本
wget https://github.com/movitecc/bge-m3/releases/latest/download/download_and_merge.sh
chmod +x download_and_merge.sh
./download_and_merge.sh
```

合并后的文件：
- `pytorch_model.bin` — PyTorch 权重（2.2GB）
- `onnx/model.onnx_data` — ONNX 权重（2.2GB）
- `onnx/Constant_7_attr__value` — ONNX 常量

### Python 加载示例

```python
from sentence_transformers import SentenceTransformer

model = SentenceTransformer("./bge-m3/")
embeddings = model.encode(["Hello, world!", "你好，世界！"])
print(embeddings.shape)
```

## 链接

- [Hugging Face 模型页](https://huggingface.co/BAAI/bge-m3)
- [BGE 论文](https://arxiv.org/abs/2402.03216)
- [FlagEmbedding 仓库](https://github.com/FlagOpen/FlagEmbedding)
