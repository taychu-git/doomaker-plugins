#!/bin/bash
# DOOMAKER 商品一键导入：import-product.sh <产品文件夹>
# 文件夹内：product.txt（必需）+ demo.gif / photo.jpg（可选，文件名固定）
# 密钥：~/doomaker-import.key（向店主获取）
set -euo pipefail

DIR="${1:?用法: import-product.sh <产品文件夹>}"
KEY_FILE="${DOOMAKER_KEY:-$HOME/doomaker-import.key}"
API="${DOOMAKER_API:-https://doomaker.com}"

[ -f "$DIR/product.txt" ] || { echo "缺 $DIR/product.txt"; exit 1; }
[ -f "${KEY_FILE}" ] || { echo "缺少密钥文件 ${KEY_FILE}（向店主获取）"; exit 1; }
KEY=$(tr -d '[:space:]' < "${KEY_FILE}")

ARGS=(-X POST -H "Authorization: Bearer ${KEY}" -F "product=@$DIR/product.txt")
[ -f "$DIR/demo.gif" ] && ARGS+=(-F "demo=@$DIR/demo.gif;type=image/gif")
[ -f "$DIR/photo.jpg" ] && ARGS+=(-F "photo=@$DIR/photo.jpg;type=image/jpeg")

echo "导入 ${DIR} ..."
curl -s "$API/api/admin/import-key" "${ARGS[@]}"
echo
