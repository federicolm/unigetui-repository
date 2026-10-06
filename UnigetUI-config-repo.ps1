# ==============================================================================
# Script di installazione Package Manager e Dipendenze per UniGetUI
# Eseguire in una finestra PowerShell aperta come AMMINISTRATORE
# ==============================================================================

Write-Host "Impostazione della ExecutionPolicy..." -ForegroundColor Cyan
Set-ExecutionPolicy Bypass -Scope Process -Force

# ------------------------------------------------------------------------------
# 1. POWERSHELL 7.x
# ------------------------------------------------------------------------------
Write-Host "`n[1/9] Installazione di PowerShell 7..." -ForegroundColor Yellow
winget install --id Microsoft.PowerShell --source winget --exact --accept-package-agreements --accept-source-agreements

# ------------------------------------------------------------------------------
# 2. .NET TOOL (tramite .NET SDK 8.0)
# ------------------------------------------------------------------------------
Write-Host "`n[2/9] Installazione di .NET SDK..." -ForegroundColor Yellow
winget install --id Microsoft.DotNet.SDK.8 --source winget --exact --accept-package-agreements --accept-source-agreements

# ------------------------------------------------------------------------------
# 3. NPM (tramite Node.js LTS)
# ------------------------------------------------------------------------------
Write-Host "`n[3/9] Installazione di Node.js (npm)..." -ForegroundColor Yellow
winget install --id OpenJS.NodeJS.LTS --source winget --exact --accept-package-agreements --accept-source-agreements

# ------------------------------------------------------------------------------
# 4. CARGO (tramite Rustup)
# ------------------------------------------------------------------------------
Write-Host "`n[4/9] Installazione di Rustup / Cargo..." -ForegroundColor Yellow
winget install --id Rustlang.Rustup --source winget --exact --accept-package-agreements --accept-source-agreements

# ------------------------------------------------------------------------------
# 5. VISUAL STUDIO C++ BUILD TOOLS (Richiesto per Cargo / link.exe)
# ------------------------------------------------------------------------------
Write-Host "`n[5/9] Installazione dei C++ Build Tools per Rust/Cargo..." -ForegroundColor Yellow
winget install --id Microsoft.VisualStudio.2022.BuildTools --override "--passive --wait --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended" --exact --accept-package-agreements --accept-source-agreements

# ------------------------------------------------------------------------------
# 6. CHOCOLATEY
# ------------------------------------------------------------------------------
Write-Host "`n[6/9] Installazione di Chocolatey..." -ForegroundColor Yellow
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    $chocoScript = (New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')
    Invoke-Expression $chocoScript
} else {
    Write-Host "Chocolatey e gia installato." -ForegroundColor Green
}

# ------------------------------------------------------------------------------
# 7. SCOOP
# ------------------------------------------------------------------------------
Write-Host "`n[7/9] Installazione di Scoop..." -ForegroundColor Yellow
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    try {
        Invoke-Expression "& {$(Invoke-RestMethod get.scoop.sh)} -RunAsAdmin"
    } catch {
        Write-Host "Impossibile installare Scoop." -ForegroundColor Red
    }
} else {
    Write-Host "Scoop e gia installato." -ForegroundColor Green
}

# ------------------------------------------------------------------------------
# 8. BUN
# ------------------------------------------------------------------------------
Write-Host "`n[8/9] Installazione di Bun..." -ForegroundColor Yellow
try {
    powershell -Command "Invoke-RestMethod bun.sh/install.ps1 | Invoke-Expression"
} catch {
    Write-Host "Impossibile installare Bun." -ForegroundColor Red
}

# ------------------------------------------------------------------------------
# 9. VCPKG (tramite Git)
# ------------------------------------------------------------------------------
Write-Host "`n[9/9] Configurazione di vcpkg..." -ForegroundColor Yellow

# Assicura il caricamento delle variabili d'ambiente PATH aggiornate
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Verifica ed eventuale installazione di Git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Installazione di Git richiesta per vcpkg..." -ForegroundColor Cyan
    winget install --id Git.Git --source winget --exact --accept-package-agreements --accept-source-agreements
    
    # Ricarica nuovamente il PATH dopo l'installazione
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

# Individua il percorso dell'eseguibile Git
$gitCmd = "git"
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    if (Test-Path "C:\Program Files\Git\cmd\git.exe") {
        $gitCmd = "C:\Program Files\Git\cmd\git.exe"
    }
}

$vcpkgPath = "C:\vcpkg"
if (-not (Test-Path $vcpkgPath)) {
    & $gitCmd clone https://github.com/microsoft/vcpkg.git $vcpkgPath
    Set-Location $vcpkgPath
    .\bootstrap-vcpkg.bat
    [System.Environment]::SetEnvironmentVariable("PATH", $env:PATH + ";$vcpkgPath", [System.EnvironmentVariableTarget]::Machine)
} else {
    Write-Host "vcpkg e gia presente in C:\vcpkg." -ForegroundColor Green
}

Write-Host "`n==============================================================================" -ForegroundColor Green
Write-Host "Installazione completata! " -ForegroundColor Green
Write-Host "IMPORTANTE: Chiudi e riapri UniGetUI (o riavvia il PC) per aggiornare le variabili PATH." -ForegroundColor Cyan
Write-Host "==============================================================================" -ForegroundColor Green
