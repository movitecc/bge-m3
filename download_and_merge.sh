#!/bin/bash
# BGE-M3 模型权重下载和合并脚本
# 从 GitHub Release 下载分卷文件并合并为完整权重

set -e

RELEASE_URL="https://github.com/movitecc/bge-m3/releases/latest/download"
TARGET_DIR="${1:-.}"

echo "=== BGE-M3 权重下载合并脚本 ==="
echo "目标目录: $TARGET_DIR"
echo ""

# 下载并合并 pytorch_model
echo "下载 PyTorch 权重分卷..."
for i in $(seq -w 0 22); do
  file="pytorch_model.part_$i"
  echo "  -> $file"
  wget -q --show-progress "$RELEASE_URL/$file" -O "$TARGET_DIR/$file"
done

echo "合并 pytorch_model.bin..."
cat "$TARGET_DIR"/pytorch_model.part_* > "$TARGET_DIR/pytorch_model.bin"
rm -f "$TARGET_DIR"/pytorch_model.part_*
echo "✅ pytorch_model.bin 合并完成 ($(du -h "$TARGET_DIR/pytorch_model.bin" | cut -f1))"
echo ""

# 下载并合并 onnx_data
mkdir -p "$TARGET_DIR/onnx"
echo "下载 ONNX 权重分卷..."
for i in $(seq -w 0 22); do
  file="onnx_data.part_$i"
  echo "  -> $file"
  wget -q --show-progress "$RELEASE_URL/$file" -O "$TARGET_DIR/$file"
done

echo "合并 onnx/model.onnx_data..."
cat "$TARGET_DIR"/onnx_data.part_* > "$TARGET_DIR/onnx/model.onnx_data"
rm -f "$TARGET_DIR"/onnx_data.part_*
echo "✅ onnx/model.onnx_data 合并完成 ($(du -h "$TARGET_DIR/onnx/model.onnx_data" | cut -f1))"
echo ""

# 下载 onnx 常量
echo "下载 ONNX 常量..."
wget -q --show-progress "$RELEASE_URL/onnx_const.whole" -O "$TARGET_DIR/onnx/Constant_7_attr__value"
echo "✅ onnx/Constant_7_attr__value 下载完成"
echo ""

# 下载配置和分词器文件（如果目标目录没有）
echo "检查配置文件..."
for f in config.json tokenizer.json sentencepiece.bpe.model modules.json special_tokens_map.json; do
  if [ ! -f "$TARGET_DIR/$f" ]; then
    echo "  -> 下载 $f"
    wget -q "https://raw.githubusercontent.com/movitecc/bge-m3/main/$f" -O "$TARGET_DIR/$f"
  fi
done

echo ""
echo "=== 全部完成 ==="
echo "模型文件已就绪: $TARGET_DIR"
echo ""
echo "使用示例:"
echo "  from sentence_transformers import SentenceTransformer"
echo "  model = SentenceTransformer('$TARGET_DIR')"
echo "  emb = model.encode(['Hello world', '你好'])"
