function Invoke-MarkdownLint {
    <#
    .SYNOPSIS
        Automated Markdown syntax and formatting correction tool (Final Version).
        
    .DESCRIPTION
        Automatically handles spacing between mixed CJK and English text, converts full-width characters to half-width, and corrects punctuation positioning.
        Specifically optimized for CJK (Chinese/Japanese/Korean) languages while strictly preserving Markdown syntax structure.

    .EXAMPLE
        Invoke-MarkdownLint -Path "C:\Docs" -Recurse
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string]$Path = ".",

        [Parameter()]
        [switch]$Recurse
    )

    process {
        $searchPath = Join-Path $Path "*.md"
        $targetFiles = Get-ChildItem -Path $searchPath -Recurse:$Recurse

        # --- 1. Define Character Classes ---
        # CJK: Unified Ideographs + Common Full-width Punctuation
        $cjk           = '[\u4e00-\u9fa5，。！？；：、「」『』（）【】—－]'
        # Eng: Alphanumeric characters
        $eng           = '[a-zA-Z0-9]'
        # Sym: General Symbols (Math, Brackets, Quotes, etc.)
        $sym           = '[\(\)\[\]`\$“”"''\+\-\*\/=><_#%]'
        # DoubleSym: Specific for Bold and Italic markers (** or __)
        $doubleSym     = '[\*_~]{2}'
        # ExcludePrefix: Negative Lookbehind used to ensure the character is NOT a Markdown List/Header/Quote marker
        # Logic: Current character must NOT be preceded by #, +, -, *, >, or whitespace at the start of a line
        $excludePrefix = '[^#\+\-\*>\s]'
        # Spc: Single space
        $spc           = ' '

        # --- 2. Regex Replacement Logic (Ordered Map ensures execution sequence) ---
        $regexMap = [ordered]@{
            # A. Basic Full-width to Half-width Conversion
            '（' = '('
            '）' = ')'
            '？' = '?'
            
            # B. Basic CJK-English Spacing Removal (includes newline/tab removal for compact paragraphs)
            "($cjk)[\n\t ]($eng)"  = '$1$2'
            "($cjk)[\n\t ]($cjk)"  = '$1$2'
            "($eng)[\n\t ]($cjk)"  = '$1$2'
            
            # C. Symbol Spacing Removal (Protecting Markdown Syntax)
            # Example: "Var = 1" -> "Var=1" (Tightens symbols based on requirements)
            # Excludes list symbols (e.g., "- -") from being merged
            "(?<=$excludePrefix)($sym)$spc($sym)"  = '$1$2'

            # D. Bold/Italic (** or __) Special Handling
            # 1. CJK followed by Bold (Remove space): "Chinese **Bold**" -> "Chinese**Bold**"
            "($cjk)$spc($doubleSym)" = '$1$2'
            # 2. Bold followed by Space (Fix): "**Bold** " (Removes trailing space or space connecting to next word)
            "($cjk)($doubleSym)$spc" = '$1$2'
            # 3. Space followed by Bold followed by CJK (Remove space): " **Chinese" -> "**Chinese"
            # Must exclude list start (e.g., "- **")
            "(?<=$excludePrefix)$spc($doubleSym)($cjk)" = '$1$2'
            # 4. Bold followed by CJK (Remove space): "**Bold** Chinese" -> "**Bold**Chinese"
            "($doubleSym)$spc($cjk)" = '$1$2'
            
            # E. General Symbols mixed with CJK
            # 1. CJK followed by Symbol: "Chinese (" -> "Chinese("
            "($cjk)$spc($sym)" = '$1$2'
            # 2. Symbol followed by CJK: ") Chinese" -> ")Chinese"
            # Also excludes Markdown list symbols
            "(?<=$excludePrefix)($sym)$spc($cjk)" = '$1$2'
            
            # F. Slash / Path Handling
            # "/ Chinese" -> "/Chinese" (Fixes path or option separators)
            "\/$spc($cjk)" = '/$1'
        }

        # --- 3. File Processing (Encoding Safe) ---
        foreach ($file in $targetFiles) {
            try {
                # Use .NET class to read, ensuring UTF-8 without file locking
                $content = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
                
                # Execute Regex replacements in order
                foreach ($pattern in $regexMap.Keys) {
                    $content = [regex]::Replace($content, $pattern, $regexMap[$pattern])
                }
                
                # Write back to file
                [System.IO.File]::WriteAllText($file.FullName, $content, [System.Text.Encoding]::UTF8)
                Write-Host "Processed: $($file.Name)" -ForegroundColor Green
            }
            catch {
                Write-Error "Failed to process $($file.FullName): $($_.Exception.Message)"
            }
        }
    }
}

Export-ModuleMember -Function Invoke-MarkdownLint