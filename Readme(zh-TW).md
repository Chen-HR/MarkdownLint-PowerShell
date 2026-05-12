# MarkdownLint (PowerShell)

<div align="center">

[English](./Readme.md) &nbsp;&nbsp;|&nbsp;&nbsp; Chinese Traditional

</div>

**MarkdownLint**是一款專為PowerShell設計的自動化格式修正工具。其核心目標在於精準優化**CJK(中、日、韓)** 字元與拉丁字元(英文/數字)之間的間距，同時嚴格保護Markdown語法結構不被破壞。

## 🚀 功能特性

* **精準間距管理**：自動移除CJK字元與英文字母/數字間冗餘的空格，確保符合專業排版標準。
* **符號標準化**：將全形括號 `()` 與問號 `?` 轉換為半形 `()` `?`，提升技術文件的統一性。
* **標點符號優化**：校正全形標點(如 `：`、`，`、`。`)在混合語境下的位置與間距。
* **語法結構保護**：嚴格排除Markdown標記(如標題 `#`、清單 `-`、引用 `>`)的格式變動，防止排版毀損。
* **KaTeX/數學公式支援**：針對KaTeX區塊與行內公式提供專屬的正則表達式優化，包含自動對齊與標記修正。

## 📦 安裝與使用

### 匯入模組

```powershell
Import-Module ".\Path\To\MarkdownLint\MarkdownLint.psd1"
```

### 處理特定檔案

```powershell
Invoke-MarkdownLint -FilePath ".\YourDocument.md"
```

### 批次處理(透過Pipeline)

```powershell
Get-ChildItem -Path ".\Docs" -Filter "*.md" | Invoke-MarkdownLint
```

## 📝 格式化規則範例

| 類別 | 描述 | 修正前 | 修正後 |
| :--- | :--- | :--- | :--- |
| **間距** | CJK ↔ 英文 | `你好World` | `你好World` |
| **間距** | CJK ↔ CJK | `中文` | `中文` |
| **括號** | 全形轉半形 | `說明(一)` | `說明(一)` |
| **粗體** | CJK ↔ 粗體標記 | `重點**說明**` | `重點**說明**` |
| **標點** | 全形冒號校正 | `定義: Agent` | `定義：Agent` |
| **斜線** | 路徑/選項優化 | `選項/Option` | `選項/Option` |
| **語法** | **語法保護區** | `- **List Item**` | `- **List Item**` (保持不變) |

## ⚠️ 系統需求

* **PowerShell**：建議使用7.0或更高版本(支援跨平台)。
* **編碼**：檔案將以**UTF-8**編碼進行處理並儲存。
