# ================================
# Script: Cleanup & Optimization
# Autor: Marcio (gh05tb0y) Soares 😎
# ATENÇÃO: LIBERAR EXECUÇÃO DO SCRIPT PROVISÓRIAMENTE: SetExecution Policy Unrestricted
# ================================

# Verifica se está rodando como admin
If (-not ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {

    Write-Host "Execute este script como Administrador." -ForegroundColor Red
    Exit
}

$LogFile = "$env:SystemDrive\cleanup-log-$(Get-Date -Format 'yyyyMMdd-HHmm').log"

Function Write-Log {
    param ([string]$Message)
    $Message | Tee-Object -FilePath $LogFile -Append
}

Write-Log "=== Início da limpeza: $(Get-Date) ==="

# -------------------------------
# Limpeza de pastas temporárias
# -------------------------------
$TempPaths = @(
    "$env:TEMP\*",
    "$env:SystemRoot\Temp\*"
)

foreach ($Path in $TempPaths) {
    Write-Log "Limpando: $Path"
    Remove-Item -Path $Path -Recurse -Force -ErrorAction SilentlyContinue
}

# -------------------------------
# Limpeza do Windows Update Cache
# -------------------------------
Write-Log "Limpando cache do Windows Update"
Stop-Service wuauserv -Force -ErrorAction SilentlyContinue
Remove-Item "$env:SystemRoot\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
Start-Service wuauserv -ErrorAction SilentlyContinue

# -------------------------------
# Limpeza DNS Cache
# -------------------------------
Write-Log "Limpando cache DNS"
ipconfig /flushdns | Out-Null

# -------------------------------
# Limpeza da Lixeira
# -------------------------------
Write-Log "Esvaziando lixeira"
Clear-RecycleBin -Force -ErrorAction SilentlyContinue

# -------------------------------
# Limpeza de cache de navegadores
# -------------------------------
$BrowserCaches = @(
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache\*",
    "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache\*"
)

foreach ($Cache in $BrowserCaches) {
    Write-Log "Limpando cache: $Cache"
    Remove-Item -Path $Cache -Recurse -Force -ErrorAction SilentlyContinue
}

# -------------------------------
# Otimização básica de disco
# -------------------------------
Write-Log "Executando otimização de disco"
Optimize-Volume -DriveLetter C -ReTrim -ErrorAction SilentlyContinue

# -------------------------------
# Verificação de integridade (opcional)
# -------------------------------
Write-Log "Executando verificação SFC"
sfc /scannow | Out-Null

Write-Log "=== Limpeza finalizada: $(Get-Date) ==="
Write-Host "Limpeza concluída com sucesso. Log em: $LogFile" -ForegroundColor Green
