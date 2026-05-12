# MarkdownLint (PowerShell)

<div align="center">

English &nbsp;&nbsp;|&nbsp;&nbsp; [Chinese Traditional](./Readme(zh-TW).md)

</div>

**MarkdownLint** is a specialized PowerShell module designed to automate formatting correction for Markdown files. It focuses on optimizing the spacing between **CJK (Chinese, Japanese, Korean)** characters and Latin (English) text while strictly preserving Markdown syntax integrity.

## 🚀 Features

* **Precise Spacing Control**: Automatically removes redundant spaces between CJK and English/Numeric characters to maintain professional typesetting.
* **Symbol Standardization**: Converts full-width brackets `（）` and question marks `？` to half-width `()` `?` for technical consistency.
* **Punctuation Optimization**: Refines the placement and spacing of full-width punctuation (e.g., `：`, `，`, `。`) in mixed-language contexts.
* **Syntax Protection**: Implements a robust exclusion mechanism for Markdown markers (Headers `#`, Lists `-`, Blockquotes `>`) to prevent formatting corruption.
* **Advanced LaTeX/Math Support**: Specialized regex patterns for KaTeX block and inline math formatting, including automated tag and alignment correction.

## 📦 Installation & Usage

### Import Module

```powershell
Import-Module ".\Path\To\MarkdownLint\MarkdownLint.psd1"
```

### Direct File Processing

```powershell
Invoke-MarkdownLint -FilePath ".\YourDocument.md"
```

### Pipeline Support (Batch Processing)

```powershell
Get-ChildItem -Path ".\Docs" -Filter "*.md" | Invoke-MarkdownLint
```

## 📝 Formatting Rules

| Category | Description | Before | After |
| :--- | :--- | :--- | :--- |
| **Spacing** | CJK ↔ English | `你好 World` | `你好World` |
| **Spacing** | CJK ↔ CJK | `中 文` | `中文` |
| **Brackets** | Full-width to Half | `說明（一）` | `說明(一)` |
| **Bold** | CJK ↔ Bold Marker | `重點 **說明**` | `重點**說明**` |
| **Punctuation** | Full-width Colon | `定義: Agent` | `定義：Agent` |
| **Slash** | Path/Option | `選項 / Option` | `選項/Option` |
| **Syntax** | **Protected** | `- **List Item**` | `- **List Item**` (Unchanged) |

## ⚠️ Requirements

* **PowerShell**: Version 7.0 or higher is recommended (supports cross-platform).
* **Encoding**: Files are processed and saved in **UTF-8**.
