# MarkdownLint (PowerShell)

![PowerShell](https://img.shields.io/badge/PowerShell-7.0%2B-%235391FE.svg?style=for-the-badge&logo=powershell&logoColor=white)
![Platform](https://img.shields.io/badge/platform-windows%20%7C%20macos%20%7C%20linux-lightgrey.svg?style=for-the-badge)
![License](https://img.shields.io/badge/license-MIT-green.svg?style=for-the-badge)

**MarkdownLint** is a specialized PowerShell module designed to automate formatting correction for Markdown files. It focuses on optimizing the spacing between **CJK (Chinese, Japanese, Korean)** characters and Latin (English) text, while strictly preserving Markdown syntax structure.

---

## 🚀 Features

* **Smart Spacing Removal**: Removes redundant spaces between CJK and English/Numbers.
* **Symbol Standardization**: Converts Full-width brackets `（）` to Half-width `()`.
* **Punctuation Optimization**: Handles spacing around Full-width punctuation (e.g., `：`, `，`, `。`).
* **Syntax Protection**: Strictly excludes Markdown syntax markers (Headers `#`, Lists `-`, Blockquotes `>`) from formatting rules to prevent layout corruption.
* **Complex Formatting Support**: Correctly handles Bold (`**`), Italic (`__`), and Slash (`/`) logic within mixed language sentences.

---

## 📦 Installation

1. Download the `MarkdownLint` folder containing `.psd1` and `.psm1` files.
2. Place the folder into your PowerShell modules path:
   * **Windows**: `C:\Users\<User>\Documents\PowerShell\Modules\`
   * **macOS/Linux**: `~/.local/share/powershell/Modules/`

Alternatively, you can import it manually from any location:

```powershell
Import-Module ".\Path\To\MarkdownLint\MarkdownLint.psd1"

```

---

## 📝 Formatting Rules

| Category | Description | Before | After |
| --- | --- | --- | --- |
| **Spacing** | CJK ↔ English | `你好 World` | `你好World` |
| **Spacing** | CJK ↔ CJK | `中 文` | `中文` |
| **Brackets** | Full-width to Half | `說明（一）` | `說明(一)` |
| **Bold** | CJK + Bold | `重點 **說明**` | `重點**說明**` |
| **Colon** | Full-width Colon | `定義 : Agent` | `定義：Agent` |
| **Slash** | Path/Option | `選項 / Option` | `選項/ Option` |
| **Syntax** | **Protected** | `- **List Item**` | `- **List Item**` (Unchanged) |

---

## ⚠️ Requirements

* **PowerShell**: Version 7.0 or higher is recommended (supports cross-platform).
* **Encoding**: Files are processed and saved in **UTF-8**.

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

---

## 📄 License

This project is licensed under the MIT License.
