# ====== START OF SCRIPT ======
# nstatus.ps1
# A clean, bulletproof ASCII terminal dashboard for your ngrok Jellyfin tunnel.

$ErrorActionPreference = 'SilentlyContinue'
Clear-Host

# Decorative ASCII Header
Write-Host ""
Write-Host " +--------------------------------------------+ " -ForegroundColor Cyan
Write-Host " |            NGROK STATUS DASHBOARD          | " -ForegroundColor Cyan
Write-Host " +--------------------------------------------+ " -ForegroundColor Cyan
Write-Host ""

# 1. Check if the process is actually running
$ngrokProcess = Get-Process -Name 'ngrok' -ErrorAction SilentlyContinue

if ($ngrokProcess) {
    Write-Host "  [+] Background Process: " -NoNewline -ForegroundColor Green
    Write-Host "RUNNING " -NoNewline -ForegroundColor White
    Write-Host "(PID: $($ngrokProcess.Id[0]))" -ForegroundColor DarkGray

    # 2. Query the local Ngrok API for tunnel status
    $response = Invoke-RestMethod -Uri 'http://127.0.0.1:4040/api/tunnels' -Method Get -TimeoutSec 3
    
    if ($response -and $response.tunnels.Count -gt 0) {
        Write-Host "  [+] Tunnel API Status:  " -NoNewline -ForegroundColor Green
        Write-Host "CONNECTED" -ForegroundColor White
        Write-Host ""
        
        Write-Host "  === ACTIVE TUNNELS === " -ForegroundColor Yellow
        Write-Host ""

        foreach ($tunnel in $response.tunnels) {
            Write-Host "  > Name:       " -NoNewline -ForegroundColor DarkCyan
            Write-Host $tunnel.name -ForegroundColor White
            
            Write-Host "  > Public URL: " -NoNewline -ForegroundColor DarkCyan
            Write-Host $tunnel.public_url -ForegroundColor Green
            
            Write-Host "  > Forwarding: " -NoNewline -ForegroundColor DarkCyan
            Write-Host $tunnel.config.addr -ForegroundColor White
            
            Write-Host "  --------------------------------------------" -ForegroundColor DarkGray
        }
    } else {
        Write-Host "  [!] Tunnel API Status:  " -NoNewline -ForegroundColor Yellow
        Write-Host "NO ACTIVE TUNNELS" -ForegroundColor White
        Write-Host "      Ngrok is running, but has not established a connection yet." -ForegroundColor Gray
    }
} else {
    Write-Host "  [X] Background Process: " -NoNewline -ForegroundColor Red
    Write-Host "OFFLINE" -ForegroundColor White
    Write-Host "      Ngrok is not currently running. Did the startup script fire?" -ForegroundColor Gray
}

Write-Host ""
Write-Host " +--------------------------------------------+ " -ForegroundColor Cyan
Write-Host ""
# ====== END OF SCRIPT ======