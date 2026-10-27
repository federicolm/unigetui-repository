# ==============================================================================
# Script di installazione Package Manager e Dipendenze per UniGetUI
# Eseguire in una finestra PowerShell aperta come AMMINISTRATORE
# ==============================================================================

Write-Host "Impostazione della ExecutionPolicy..." -ForegroundColor Cyan
Set-ExecutionPolicy Bypass -Scope Process -Force

# ------------------------------------------------------------------------------
# 1. POWERSHELL 7.x
# ------------------------------------------------------------------------------
Write-Host "`n[1/10] Installazione di PowerShell 7..." -ForegroundColor Yellow
winget install --id Microsoft.PowerShell --source winget --exact --accept-package-agreements --accept-source-agreements

# ------------------------------------------------------------------------------
# 2. .NET TOOL (tramite .NET SDK 8.0)
# ------------------------------------------------------------------------------
Write-Host "`n[2/10] Installazione di .NET SDK..." -ForegroundColor Yellow
winget install --id Microsoft.DotNet.SDK.8 --source winget --exact --accept-package-agreements --accept-source-agreements

# ------------------------------------------------------------------------------
# 3. NPM (tramite Node.js LTS)
# ------------------------------------------------------------------------------
Write-Host "`n[3/10] Installazione di Node.js (npm)..." -ForegroundColor Yellow
winget install --id OpenJS.NodeJS.LTS --source winget --exact --accept-package-agreements --accept-source-agreements

# ------------------------------------------------------------------------------
# 4. CARGO (tramite Rustup)
# ------------------------------------------------------------------------------
Write-Host "`n[4/10] Installazione di Rustup / Cargo..." -ForegroundColor Yellow
winget install --id Rustlang.Rustup --source winget --exact --accept-package-agreements --accept-source-agreements

# ------------------------------------------------------------------------------
# 5. VISUAL STUDIO C++ BUILD TOOLS (Richiesto per Cargo / link.exe)
# ------------------------------------------------------------------------------
Write-Host "`n[5/10] Installazione dei C++ Build Tools per Rust/Cargo..." -ForegroundColor Yellow
winget install --id Microsoft.VisualStudio.2022.BuildTools --override "--passive --wait --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended" --exact --accept-package-agreements --accept-source-agreements

# ------------------------------------------------------------------------------
# 6. CHOCOLATEY
# ------------------------------------------------------------------------------
Write-Host "`n[6/10] Installazione di Chocolatey..." -ForegroundColor Yellow
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
Write-Host "`n[7/10] Installazione di Scoop..." -ForegroundColor Yellow
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
Write-Host "`n[8/10] Installazione di Bun..." -ForegroundColor Yellow
try {
    powershell -Command "Invoke-RestMethod bun.sh/install.ps1 | Invoke-Expression"
} catch {
    Write-Host "Impossibile installare Bun." -ForegroundColor Red
}

# ------------------------------------------------------------------------------
# 9. VCPKG (tramite Git)
# ------------------------------------------------------------------------------
Write-Host "`n[9/10] Configurazione di vcpkg..." -ForegroundColor Yellow

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

# ------------------------------------------------------------------------------
# 10. PYTHON & CONFIGURAZIONE PIP PER UNIGETUI
# ------------------------------------------------------------------------------
Write-Host "`n[10/10] Ricerca e installazione dell'ultima versione stabile di Python e configurazione Pip..." -ForegroundColor Yellow

# Rileva dinamicamente l'ID dell'ultima versione stabile di Python disponibile su winget
try {
    $wingetResult = winget search --id Python.Python --source winget --accept-source-agreements
    $pythonLine = $wingetResult | Where-Object { $_ -match "Python\.Python\.\d+" } | Select-Object -First 1
    if ($pythonLine) {
        $pythonWingetId = $pythonLine.Split() | Where-Object { $_ -match "Python\.Python\.\d+" }
    } else {
        $pythonWingetId = "Python.Python.3.12" # Fallback di sicurezza
    }
} catch {
    $pythonWingetId = "Python.Python.3.12"
}

Write-Host "Versione Python rilevata da winget: $pythonWingetId" -ForegroundColor Cyan

# Controlla se Python è installato, altrimenti lo installa con i parametri globali per il PATH
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "Installazione di $pythonWingetId tramite winget..." -ForegroundColor Cyan
    winget install --id $pythonWingetId --source winget --exact --accept-package-agreements --accept-source-agreements --override "/quiet InstallAllUsers=1 PrependPath=1 Include_test=0"
}

# Aggiorna le variabili d'ambiente nella sessione corrente
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Individua l'eseguibile di Python nei percorsi standard o usa il comando diretto
if (Test-Path "C:\Program Files\Python312\python.exe") {
    $pythonExec = "C:\Program Files\Python312\python.exe"
} elseif (Test-Path "$env:ProgramFiles\Python Software Foundation\Python312\python.exe") {
    $pythonExec = "$env:ProgramFiles\Python Software Foundation\Python312\python.exe"
} else {
    $pythonExec = "python"
}

Write-Host "Configurazione del gestore Pip e delle dipendenze per UniGetUI..." -ForegroundColor Cyan

try {
    # Installa o aggiorna la dipendenza richiesta da UniGetUI
    & $pythonExec -m pip install --upgrade --user parse-pip-search
    
    # Aggiunge la cartella Scripts di Python al PATH utente se non è già presente
    $PythonUserBase = [System.Environment]::GetFolderPath('ApplicationData') + "\Python"
    $PythonScriptsPaths = Get-ChildItem -Path "$PythonUserBase\Python*" -Recurse -Filter "Scripts" -Directory -ErrorAction SilentlyContinue
    
    foreach ($targetScriptPath in $PythonScriptsPaths) {
        $UserPath = [Environment]::GetEnvironmentVariable("PATH", "User")
        if ($UserPath -notlike "*$($targetScriptPath.FullName)*") {
            [Environment]::SetEnvironmentVariable("PATH", "$UserPath;$($targetScriptPath.FullName)", "User")
            Write-Host "Aggiunta la cartella Scripts di Python al PATH utente: $($targetScriptPath.FullName)" -ForegroundColor Green
        }
    }
} catch {
    Write-Warning "Impossibile completare la configurazione automatica di Pip in questa sessione. Verrà applicata al prossimo avvio."
}

# Pulizia della cache di configurazione di UniGetUI se rileva dipendenze corrotte
$UniGetUIDependencyJson = "$env:LOCALAPPDATA\UniGetUI\Configuration\DependencyManagement.json"
if (Test-Path $UniGetUIDependencyJson) {
    try {
        $jsonContent = Get-Content $UniGetUIDependencyJson -Raw | ConvertFrom-Json
        if ($jsonContent.PSObject.Properties.Name -contains "parse-pip-search") {
            $jsonContent.PSObject.Properties.Remove("parse-pip-search")
            $jsonContent | ConvertTo-Json -Depth 10 | Set-Content $UniGetUIDependencyJson
            Write-Host "Cache delle dipendenze di UniGetUI pulita con successo." -ForegroundColor Green
        }
    } catch {
        # Ignora se il file è bloccato
    }
}

Write-Host "`n==============================================================================" -ForegroundColor Green
Write-Host "Installazione completata! " -ForegroundColor Green
Write-Host "IMPORTANTE: Chiudi e riapri UniGetUI (o riavvia il PC) per aggiornare le variabili PATH." -ForegroundColor Cyan
Write-Host "==============================================================================" -ForegroundColor Green
