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
        $doubleSym     = '[\*_~\|]{2}'
        # ExcludePrefix: Negative Lookbehind used to ensure the character is NOT a Markdown List/Header/Quote marker
        # Logic: Current character must NOT be preceded by #, +, -, *, >, or whitespace at the start of a line
        # $excludePrefix = '[^#\+\-\*>\s]'
        # Spc: Single space
        $spc           = ' '
        $spcsym        = '[\n\t ]'
        $newline       = '\r*\n'
        $mathlineend   = '$$$$($1)
'
        # --- 2. Regex Replacement Logic (Ordered Map ensures execution sequence) ---
        $regexMap = [ordered]@{
            # Basic Full-width to Half-width Conversion
            '（' = '('
            '）' = ')'
            '？' = '?'
            
            # Basic CJK Spacing Removal
            "($cjk)$spcsym($eng)" = '$1$2'
            "($cjk)$spcsym($cjk)" = '$1$2'
            "($eng)$spcsym($cjk)" = '$1$2'
            "($cjk)$spc*($sym)$spc*($eng)" = '$1$2$3'
            "($cjk)$spc*($sym)$spc*($cjk)" = '$1$2$3'
            "($eng)$spc*($sym)$spc*($cjk)" = '$1$2$3'
            "($cjk)$spc*($doubleSym)$spc*($eng)" = '$1$2$3'
            "($cjk)$spc*($doubleSym)$spc*($cjk)" = '$1$2$3'
            "($eng)$spc*($doubleSym)$spc*($cjk)" = '$1$2$3'

            # Math
            "  \$"        = ' $'
            "\$ ([,. ])"  = '$$$1'
            "\$\$\r*\n *\r*\n\$\$=" = '\\\\='
            "``````html\r*\n\$\$" = '$$$$'
            "\$\$\r*\n$spc*\((\d+)\)" = '$$$$($1)'
            "[\(\{](\d+)[\)\}]\$\$\r*\n" = $mathlineend
            "$spc*\\tag\$\$\((\d+)\)\r*\n" = $mathlineend
            "$spc*\\quad\$\$\((\d+)\)\r*\n" = $mathlineend
            "$spc*\\\$\$\((\d+)\)\r*\n" = $mathlineend
            "$spc*\$\$\((\d+)\)\r*\n" = $mathlineend
            "$spc*\$\$\((\d+)\)\r*\n``````\r*\n" = $mathlineend
            "$spc*\$\$\r*\n *\r*\n\$\$\$\$\((\d+)\)" = $mathlineend
            "([_^])\{([a-zA-Z0-9-+*])\}" = '$1$2'

            "!\[\]\(_page_(\d+)_Picture_(\d+)\.jpeg\)\r*\n\r*\n\**Fig. (\d+).\**" = '![fig$3](_page_$1_Picture_$2.jpeg)
Fig. $3.'
            "!\[\]\(_page_(\d+)_Figure_(\d+)\.jpeg\)\r*\n\r*\n\**Fig. (\d+).\**" = '![fig$3](_page_$1_Figure_$2.jpeg)
Fig. $3.'
            "!\[\]\(_page_(\d+)_Picture_(\d+)\.jpeg\)\r*\n\r*\n!\[fig(\d+)\]\(_page_(\d+)_Picture_(\d+)\.jpeg\)" = '![fig$3](_page_$1_Picture_$2.jpeg)
![fig$3](_page_$4_Picture_$5.jpeg)'
            "!\[\]\(_page_(\d+)_Figure_(\d+)\.jpeg\)\r*\n\r*\n!\[fig(\d+)\]\(_page_(\d+)_Figure_(\d+)\.jpeg\)" = '![fig$3](_page_$1_Figure_$2.jpeg)
![fig$3](_page_$4_Figure_$5.jpeg)'
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