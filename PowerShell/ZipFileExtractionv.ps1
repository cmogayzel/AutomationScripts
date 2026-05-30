# Extract-Zip.ps1
# Extracts a ZIP file using a GUI file picker for source and destination,
# then opens the destination folder when complete.

Add-Type -AssemblyName System.Windows.Forms

# ── Select source ZIP file ──────────────────────────────────────────────────
$openDialog = New-Object System.Windows.Forms.OpenFileDialog
$openDialog.Title  = "Select the ZIP file to extract"
$openDialog.Filter = "ZIP Files (*.zip)|*.zip|All Files (*.*)|*.*"

if ($openDialog.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) {
    Write-Host "No ZIP file selected. Exiting." -ForegroundColor Yellow
    exit
}

$zipPath    = $openDialog.FileName
$zipName    = [System.IO.Path]::GetFileNameWithoutExtension($zipPath)

# ── Select parent destination folder ────────────────────────────────────────
# The extracted contents will land in <selected folder>\<zip name>\
$folderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
$folderDialog.Description         = "Select where to extract '$zipName' (a subfolder named '$zipName' will be created)"
$folderDialog.ShowNewFolderButton = $true

if ($folderDialog.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) {
    Write-Host "No destination folder selected. Exiting." -ForegroundColor Yellow
    exit
}

$destPath = Join-Path $folderDialog.SelectedPath $zipName

# ── Extract ─────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "Source : $zipPath"
Write-Host "Destination : $destPath"
Write-Host ""
Write-Host "Extracting..." -ForegroundColor Cyan

try {
    Expand-Archive -Path $zipPath -DestinationPath $destPath -Force
    Write-Host "Extraction complete!" -ForegroundColor Green
} catch {
    Write-Host "Extraction failed: $_" -ForegroundColor Red
    exit 1
}

# ── Open destination folder ─────────────────────────────────────────────────
Start-Process -FilePath "explorer.exe" -ArgumentList "`"$destPath`""