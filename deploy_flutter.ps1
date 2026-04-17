##############################################################################
# Caresoko Flutter Web - Deployment Script
# Builds Flutter web then deploys to app.caresoko.com via SFTP + PHP runner
##############################################################################

$SERVER_HOST  = "p3plzcpnl505057.prod.phx3.secureserver.net"
$SERVER_USER  = "it67y1462n52"
$SERVER_PASS  = 'FD67a8!yNKt1'
$LIVE_URL     = "https://app.caresoko.com"
$REMOTE_HOME  = "/home/it67y1462n52"
$REMOTE_DOC   = "$REMOTE_HOME/public_html/app.caresoko.com"
$LOCAL_SRC    = "C:\Users\Administrator\Desktop\caresoko\caresoko"
$FLUTTER_BUILD= "$LOCAL_SRC\build\web"

$SECRET       = "csoko_flutter_" + (Get-Random -Min 10000 -Max 99999)
$RUNNER_NAME  = "_caresoko_flutter_deploy.php"
$TEMPLATE     = Join-Path $LOCAL_SRC "deploy_flutter_runner_template.php"
$MAX_MB       = 40   # max MB per zip chunk

##############################################################################
function Write-Step($n, $msg) { Write-Host "`n[$n] $msg" -ForegroundColor Cyan }
function Write-OK($msg)        { Write-Host "    OK   $msg" -ForegroundColor Green }
function Write-Warn($msg)      { Write-Host "    WARN $msg" -ForegroundColor Yellow }
function Write-Err($msg)       { Write-Host "    ERR  $msg" -ForegroundColor Red }

##############################################################################
# 0. Posh-SSH
##############################################################################
Write-Step "0" "Checking Posh-SSH..."
if (-not (Get-Module -ListAvailable -Name Posh-SSH)) {
    Write-Host "    Installing Posh-SSH..." -ForegroundColor Yellow
    Install-Module -Name Posh-SSH -Scope CurrentUser -Force -SkipPublisherCheck
}
Import-Module Posh-SSH -ErrorAction Stop
Write-OK "Posh-SSH ready"

$secPass = ConvertTo-SecureString $SERVER_PASS -AsPlainText -Force
$cred    = New-Object System.Management.Automation.PSCredential($SERVER_USER, $secPass)

##############################################################################
# 1. Flutter build
##############################################################################
Write-Step "1" "Building Flutter web (release, canvaskit)..."
Push-Location $LOCAL_SRC
flutter build web --release
if ($LASTEXITCODE -ne 0) {
    Write-Err "Flutter build failed - aborting"
    Pop-Location; exit 1
}
Pop-Location
Write-OK "Flutter build complete"

##############################################################################
# 2. Chunk the build/web output into <= $MAX_MB MB zips
##############################################################################
Write-Step "2" "Chunking build/web into <=$MAX_MB MB zips..."
if (-not (Test-Path $FLUTTER_BUILD)) {
    Write-Err "Build output not found: $FLUTTER_BUILD"
    exit 1
}

# Collect all files
$allFiles = Get-ChildItem -Path $FLUTTER_BUILD -Recurse -File
Write-Host "    Total files: $($allFiles.Count)" -ForegroundColor White

# Clean up old chunks
Get-Item "$env:TEMP\caresoko_flutter_*.zip" -ErrorAction SilentlyContinue | Remove-Item -Force

$chunkIdx   = 1
$chunkFiles = [System.Collections.ArrayList]@()
$chunkBytes = 0
$maxBytes   = $MAX_MB * 1MB
$zipPaths   = [System.Collections.ArrayList]@()

function Flush-Chunk {
    param([int]$idx, [array]$files)
    if ($files.Count -eq 0) { return }
    $z = "$env:TEMP\caresoko_flutter_{0:D3}.zip" -f $idx
    Write-Host "    Chunk $idx - $($files.Count) files..." -ForegroundColor White
    Compress-Archive -Path $files -DestinationPath $z -Force
    $mb = [math]::Round((Get-Item $z).Length / 1MB, 1)
    Write-Host "    -> $z ($mb MB)" -ForegroundColor DarkGray
    return $z
}

foreach ($f in $allFiles) {
    if (($chunkBytes + $f.Length) -gt $maxBytes -and $chunkFiles.Count -gt 0) {
        $z = Flush-Chunk -idx $chunkIdx -files @($chunkFiles)
        [void]$zipPaths.Add($z)
        $chunkIdx++
        $chunkFiles.Clear()
        $chunkBytes = 0
    }
    [void]$chunkFiles.Add($f.FullName)
    $chunkBytes += $f.Length
}
if ($chunkFiles.Count -gt 0) {
    $z = Flush-Chunk -idx $chunkIdx -files @($chunkFiles)
    [void]$zipPaths.Add($z)
}

Write-OK "$($zipPaths.Count) chunk(s) created"

##############################################################################
# 3. Build runner from template
##############################################################################
Write-Step "3" "Building PHP runner from template..."
if (-not (Test-Path $TEMPLATE)) {
    Write-Err "Template not found: $TEMPLATE"
    exit 1
}
$runnerContent = Get-Content -Path $TEMPLATE -Raw
$runnerContent  = $runnerContent -replace '%%SECRET%%', $SECRET
$runnerLocal    = "$env:TEMP\$RUNNER_NAME"
[System.IO.File]::WriteAllText($runnerLocal, $runnerContent, [System.Text.Encoding]::UTF8)
Write-OK "Runner ready"

##############################################################################
# 4. SFTP upload
##############################################################################
$totalUp = $zipPaths.Count + 1
Write-Step "4" "Uploading $totalUp files via SFTP..."
$sftp = New-SFTPSession -ComputerName $SERVER_HOST -Credential $cred -AcceptKey -Force -ErrorAction Stop
$sid  = $sftp.SessionId
Write-OK "SFTP connected (session $sid)"

foreach ($f in $zipPaths) {
    $name = Split-Path $f -Leaf
    $mb   = [math]::Round((Get-Item $f).Length / 1MB, 1)
    Write-Host "    -> $name  (${mb} MB)" -ForegroundColor White
    Set-SFTPItem -SessionId $sid -Path $f -Destination $REMOTE_HOME -Force -ErrorAction Stop
    Write-OK "$name uploaded"
}
Write-Host "    -> $RUNNER_NAME" -ForegroundColor White
Set-SFTPItem -SessionId $sid -Path $runnerLocal -Destination $REMOTE_DOC -Force -ErrorAction Stop
Write-OK "Runner uploaded"

Remove-SFTPSession -SessionId $sid 2>$null | Out-Null
foreach ($f in $zipPaths) { Remove-Item $f -Force -ErrorAction SilentlyContinue }
Remove-Item $runnerLocal -Force -ErrorAction SilentlyContinue
Write-OK "All files uploaded"

##############################################################################
# 5. Trigger runner
##############################################################################
Write-Step "5" "Triggering deployment runner..."
$runnerUrl = "$LIVE_URL/$RUNNER_NAME`?s=$SECRET"
Write-Host "    $runnerUrl" -ForegroundColor DarkGray
Write-Host "    Waiting for server (~30-90s)..." -ForegroundColor DarkYellow

try {
    $resp = Invoke-WebRequest -Uri $runnerUrl -TimeoutSec 300 -UseBasicParsing
    $text = $resp.Content `
        -replace '<[^>]+>','' `
        -replace '&amp;','&' `
        -replace '&mdash;','-' `
        -replace '&rsaquo;','>' `
        -replace '&#10003;','[OK]' `
        -replace '&gt;','>' -replace '&lt;','<' `
        -replace '\r',''-replace '\n{3,}',"`n`n"
    Write-Host $text -ForegroundColor Gray
    if ($text -match 'FLUTTER WEB DEPLOYMENT COMPLETE') {
        Write-OK "Server confirmed: FLUTTER WEB DEPLOYMENT COMPLETE"
    } else {
        Write-Warn "Check output above for errors"
    }
} catch {
    Write-Warn "HTTP trigger error: $_"
    Write-Host "    Open manually: $runnerUrl" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "==========================================================" -ForegroundColor Green
Write-Host "  DONE  ->  https://app.caresoko.com"                       -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
