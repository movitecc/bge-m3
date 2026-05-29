#!/bin/bash
# BGE-M3 模型权重下载和合并脚本
# 从 GitHub Release 下载分卷文件并合并为完整权重

set -e

RELEASE_URL="https://github.com/movitecc/bge-m3/releases/latest/download"
TARGET_DIR="${1:-.}"

echo "=== BGE-M3 权重下载合并脚本 ==="
echo "目标目录: $TARGET_DIR"
echo ""

merge_volume() {
    local prefix="$1"
    local output="$2"
    local parts_file="${prefix}.parts.txt"

    echo "下载分卷: $prefix ..."
    cat "$parts_file" | while read -r part; do
        echo "  -> $part"
        wget -q --show-progress "$RELEASE_URL/$part" -O "$TARGET_DIR/$part"
    done

    echo "合并: $output ..."
    cat "$TARGET_DIR"/"${prefix}".part_* > "$TARGET_DIR/$output"

    # 清理分卷文件
    rm -f "$TARGET_DIR"/"${prefix}".part_*
    rm -f "$TARGET_DIR/$parts_file"

    echo "✅ $output 合并完成 ($(du -h "$TARGET_DIR/$output" | cut -f1))"
    echo ""
}

# 下载分卷列表
echo "下载分卷清单..."
wget -q "$RELEASE_URL/pytorch_model.parts.txt" -O "$TARGET_DIR/pytorch_model.parts.txt"
wget -q "$RELEASE_URL/onnx_data.parts.txt" -O "$TARGET_DIR/onnx_data.parts.txt"
wget -q "$RELEASE_URL/onnx_const.parts.txt" -O "$TARGET_DIR/onnx_const.parts.txt" || true
echo ""

# 合并 PyTorch 权重
merge_volume "pytorch_model" "pytorch_model.bin"

# 合并 ONNX 权重
mkdir -p "$TARGET_DIR/onnx"
merge_volume "onnx_data" "onnx/model.onnx_data"

# 合并 ONNX 常量（如果有）
if [ -f "$TARGET_DIR/onnx_const.parts.txt" ]; then
    merge_volume "onnx_const" "onnx/Constant_7_attr__value"
fi

echo "=== 全部完成 ==="
echo "模型文件已合并到: $TARGET_DIR"
echo "配置和分词器文件请从仓库主分支获取"
