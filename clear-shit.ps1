# Check if directory parameters are provided, and if not, use the current directory
if ($args.Count -eq 0) {
    $TARGET_DIR = "."
} else {
    $TARGET_DIR = $args[0]
}

# Use Get-ChildItem to find and delete .DS_Store files
Get-ChildItem -Path $TARGET_DIR -Recurse -Filter ".DS_Store" -File | Remove-Item -Force

Write-Output "All shits have been deleted."