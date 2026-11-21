---
name: doomaker-import
description: 把本地产品文件夹一键导入/更新到 DOOMAKER 商店（doomaker.com）——文件夹含 product.txt，可选 demo.gif 与 photo.jpg
---

# DOOMAKER 商品导入

把用户准备好的产品文件夹发布到 doomaker.com（新增或更新，按 SKU 判断，重复导入安全）。

## 资源（都在本插件内）

- 导入脚本：本插件 `scripts/import-product.sh`（路径 = 本 skill 基础目录的上一级 `../scripts/import-product.sh`，即插件根下）
- 产品模板：本插件 `assets/_template/product.txt`（用户没有模板时复制给他）

## 前置条件：密钥（首次自动配置）

- 密钥文件 `~/doomaker-import.key` 存在则直接用
- **不存在时**：告诉用户「需要店主发的导入密钥（一串随机字符）」，用户贴出后执行（只需一次，之后永久生效）：
  ```bash
  printf '%s' '<用户贴的密钥>' > ~/doomaker-import.key && chmod 600 ~/doomaker-import.key
  ```
- 用户拿不出密钥就停下——密钥只能向店主 taychu 获取，不要猜、不要编

## 执行步骤

1. **读并校验** `<产品文件夹>/product.txt`：每行 `键: 值`，`#` 是注释。必填：`SKU`、`CATEGORY`（只能是 oled / tft / boards / kits）、`NAME_ZH`、`NAME_EN`。缺了先向用户要。
2. **导入**（优先用插件内脚本）：
   ```bash
   "<插件根>/scripts/import-product.sh" "<产品文件夹>"
   ```
   脚本不可用时退回直连 curl：
   ```bash
   KEY=$(tr -d '[:space:]' < ~/doomaker-import.key)
   curl -s -X POST https://doomaker.com/api/admin/import-key \
     -H "Authorization: Bearer $KEY" \
     -F "product=@<文件夹>/product.txt" \
     -F "demo=@<文件夹>/demo.gif;type=image/gif" \
     -F "photo=@<文件夹>/photo.jpg;type=image/jpeg"
   ```
   （demo.gif / photo.jpg 没有就去掉对应 -F 行；多文件夹逐个执行）
3. **验证**：
   - 返回 `{"ok":true,"slug":"..."}` → `curl -s -o /dev/null -w '%{http_code}' https://doomaker.com/products/<slug>` 应为 200 → 向用户报告商品链接 `https://doomaker.com/products/<slug>`
   - 401 → 密钥问题，让用户找店主
   - 400 → 按返回 error 修 product.txt 后重试
4. **更新已有商品**：改 product.txt 或换图后重新执行即可（SKU 相同即覆盖）。

## 注意

- 全程无需打开网站后台
- product.txt 必须 UTF-8
- 密钥内容不要显示、不要写入任何文件或仓库
