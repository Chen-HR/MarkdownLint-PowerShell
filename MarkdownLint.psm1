function Invoke-MarkdownLint {
    <#
    .SYNOPSIS
        Automated Markdown syntax and formatting correction tool.
        
    .DESCRIPTION
        Directly processes a specified Markdown file to handle spacing between mixed CJK and English text, 
        converts full-width characters to half-width, and corrects punctuation.
        This version targets a specific file path without directory recursion.

    .EXAMPLE
        Invoke-MarkdownLint -FilePath "C:\Docs\README.md"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("Path", "FullName")]
        [string]$FilePath
    )

    process {
        # --- 1. Validation ---
        if (-not (Test-Path -Path $FilePath -PathType Leaf)) {
            Write-Error "File not found or is a directory: $FilePath"
            return
        }

        if ($FilePath -notmatch '\.md$') {
            Write-Warning "File '$FilePath' does not have a .md extension. Skipping."
            return
        }

        # --- 2. Define Character Classes ---
        $cjk           = '[\u4e00-\u9fa5，。！？；：、「」『』（）【】—－]'
        $eng           = '[a-zA-Z0-9]'
        $sym           = '[\(\)\[\]`\$“”"''\+\-\*\/=><_#%]'
        $doubleSym     = '[\*_~\|]{2}'
        $spc           = ' '
        $newline       = '\r*\n'
        $dollarsym     = '\$'
        $doubledollarsym = '\$\$'
        $mathlineend   = '$$$$($1)' + "`n"

        # --- 3. Regex Replacement Logic ---
        $regexMap = [ordered]@{
            # Basic Full-width to Half-width Conversion
            '（' = '('
            '）' = ')'
            '？' = '?'
            
            # Basic CJK Spacing Removal
            "($cjk)$spc*($eng)" = '$1$2'
            "($cjk)$spc*($cjk)" = '$1$2'
            "($eng)$spc*($cjk)" = '$1$2'
            "($cjk)$spc*($sym)$spc*($eng)" = '$1$2$3'
            "($cjk)$spc*($sym)$spc*($cjk)" = '$1$2$3'
            "($eng)$spc*($sym)$spc*($cjk)" = '$1$2$3'
            "($cjk)$spc*($doubleSym)$spc*($eng)" = '$1$2$3'
            "($cjk)$spc*($doubleSym)$spc*($cjk)" = '$1$2$3'
            "($eng)$spc*($doubleSym)$spc*($cjk)" = '$1$2$3'

            # Math
            "([_^])\{([a-zA-Z0-9-+*])\}" = '$1$2'

            ## Inline KaTex
            "  $dollarsym"        = ' $'
            "$dollarsym$spc*([,. ])"  = '$$$1'
            "$dollarsym$spc*($cjk)" = '$$$1'

            ## Bolck KaTex
            ### phase 0
            "$newline$doubledollarsym$spc+" = '
$$$$'

            ### phase 1
            ### phase 1.1
            "$doubledollarsym$newline*$newline*$spc*\((\d+)\)" = '$$$$($1)'
            ### phase 1.2
            "$spc*$doubledollarsym$newline$spc*$newline*$doubledollarsym\((\d+)\)$doubledollarsym$newline*" = $mathlineend
            "[\(\{](\d+)[\)\}]$doubledollarsym$spc*$newline" = $mathlineend
            ### phase 1.3
            "$spc*\\tag$doubledollarsym\((\d+)\)$newline" = $mathlineend
            "$spc*\\quad$doubledollarsym\((\d+)\)$newline" = $mathlineend
            "$spc*\\$doubledollarsym\((\d+)\)$newline" = $mathlineend
            "$spc*$doubledollarsym\((\d+)\)$newline" = $mathlineend

            ### phase 2
            "$spc*$doubledollarsym$newline$spc*$newline$doubledollarsym$spc*=" = '\\\\='

            ### phase 3
            "``````html$newline$doubledollarsym" = '$$$$'
            "$spc*$doubledollarsym\((\d+)\)$newline``````$newline" = $mathlineend

            ### phase 4
            "$spc+$doubledollarsym$newline" = '$$$$
'

            # Format the image format of the Marker
            "!\[\]\(_page_(\d+)_Picture_(\d+)\.jpeg\)$newline$newline\**Fig. (\d+).\**" = '![fig$3](_page_$1_Picture_$2.jpeg)
Fig. $3.'
            "!\[\]\(_page_(\d+)_Figure_(\d+)\.jpeg\)$newline$newline\**Fig. (\d+).\**" = '![fig$3](_page_$1_Figure_$2.jpeg)
Fig. $3.'
            "!\[\]\(_page_(\d+)_Picture_(\d+)\.jpeg\)$newline$newline!\[fig(\d+)\]\(_page_(\d+)_Picture_(\d+)\.jpeg\)" = '![fig$3](_page_$1_Picture_$2.jpeg)
![fig$3](_page_$4_Picture_$5.jpeg)'
            "!\[\]\(_page_(\d+)_Figure_(\d+)\.jpeg\)$newline$newline!\[fig(\d+)\]\(_page_(\d+)_Figure_(\d+)\.jpeg\)" = '![fig$3](_page_$1_Figure_$2.jpeg)
![fig$3](_page_$4_Figure_$5.jpeg)'
        }

        # --- 4. File Processing ---
        try {
            $absPath = (Resolve-Path -Path $FilePath).Path
            $content = [System.IO.File]::ReadAllText($absPath, [System.Text.Encoding]::UTF8)
            
            foreach ($pattern in $regexMap.Keys) {
                $content = [regex]::Replace($content, $pattern, $regexMap[$pattern])
            }
            
            [System.IO.File]::WriteAllText($absPath, $content, [System.Text.Encoding]::UTF8)
            Write-Host "Successfully processed: $absPath" -ForegroundColor Green
        }
        catch {
            Write-Error "Failed to process $FilePath : $($_.Exception.Message)"
        }
    }
}

Export-ModuleMember -Function Invoke-MarkdownLint