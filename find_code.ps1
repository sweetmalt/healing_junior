#!/usr/bin/env pwsh
# 从对话日志中提取包含关键代码的行

$dialogFile = "dialog\2026-06-04.jsonl"
$content = Get-Content $dialogFile -Raw -Encoding UTF8

# 查找包含关键模式的大块内容
$patterns = @(
    "currentCards",
    "selectedCardIndex",
    "drawnCardSets",
    "fanDisplayCards",
    "flyStartPositions",
    "CardohPhase.viewing"
)

Write-Host "Searching for key patterns in dialog..."
foreach ($p in $patterns) {
    $count = ([regex]::Matches($content, $p)).Count
    Write-Host "  $p : $count"
}

# 查找写入文件的位置
Write-Host "`nSearching for write_file operations..."

# 用 .NET JSON 解析来提取
Add-Type -AssemblyName System.Web

# 找到包含 card_oh.dart 和 write_file 的行
$lines = Get-Content $dialogFile -Encoding UTF8
$writeLines = @()
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match 'card_oh\.dart' -and $lines[$i] -match 'write_file') {
        $writeLines += $i + 1
    }
}

Write-Host "Found $($writeLines.Count) lines with write_file to card_oh.dart"

# 提取edit_file操作的old_text和new_text
Write-Host "`nExtracting edit operations..."

$edits = @()
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match 'edit_file' -and $lines[$i] -match 'card_oh') {
        $edits += $i + 1
    }
}

Write-Host "Found $($edits.Count) edit operations"

# 提取old_text内容用于分析
Write-Host "`nExtracting first 5 old_text patterns..."
$count = 0
for ($i = 0; $i -lt $lines.Count -and $count -lt 5; $i++) {
    if ($lines[$i] -match 'old_text' -and $lines[$i] -match 'card_oh') {
        $json = $lines[$i] | ConvertFrom-Json
        foreach ($item in $json.content) {
            if ($item.type -eq 'tool_use' -and $item.name -eq 'edit_file') {
                $oldText = $item.input.old_text
                $newText = $item.input.new_text
                Write-Host "`n--- Edit at line $($i+1) ---"
                Write-Host "Old ($($oldText.Length) chars): $($oldText.Substring(0, [Math]::Min(150, $oldText.Length)))"
                Write-Host "New ($($newText.Length) chars): $($newText.Substring(0, [Math]::Min(150, $newText.Length)))"
                $count++
            }
        }
    }
}
