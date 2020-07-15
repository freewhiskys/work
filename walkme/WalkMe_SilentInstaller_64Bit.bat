@echo off
echo "Installation Start"

:: Put The files inside a Shared Folder And write the UNC Path
set SourceFile_XPI="%~dp0Walkme_Extension.xpi"
set SourceFile_MSI_32="XXXXX"
set SourceFile_MSI_64="%~dp0Walkme_Extension_x64.msi"

:: ================
:: Install Chrome:
:: =================

echo "Install Chrome Start"

:::: 1. Add chrome extension 
echo "Install CRX"
call :install_extension "chrome" "fckonodhlfjlkndmedanenhgdnbopbmh" "https://clients2.google.com/service/update2/crx"

:::: 2. Configure extension 
echo "Configure CRX"
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome\3rdparty\extensions\fckonodhlfjlkndmedanenhgdnbopbmh\policy" /f /v "wmExtConfig" /t REG_SZ /d {\"u\":\"https://eu-cdn.walkme.com/extension/customers/Stada/default/015c01f0c5aa11e99b03f31fdb7d9716/ext_settings.json\",\"g\":\"015c01f0c5aa11e99b03f31fdb7d9716\",\"env\":\"ProductionEu\",\"ct\":900}
echo "Install Chrome End"

:: ================
:: Install Firefox: 
:: ================
echo "Install Firefox Start"
set FFConfigFile="C:\Program Files\WalkMe\Extension\all-walkme.js"

:::: 1. Copy xpi file locally
if not exist "C:\Program Files\Walkme\" mkdir "C:\Program Files\Walkme\"
xcopy /s/y %SourceFile_XPI% "C:\Program Files\Walkme\"
cd C:\Program Files\Walkme\
ren "Walkme_Extension.xpi" "WalkmeExtension@walkme.com.xpi"

::::2. Copy XPI to Firefox default profile
ECHO "Copying WalkMe Extension to Firefox Default Profile"
for /D %%D in ("%appdata%\Mozilla\Firefox\Profiles\*") do xcopy /y "C:\Program Files\Walkme\WalkmeExtension@walkme.com.xpi" "%%D\Extensions\"

:::: 3. Create ext settings file
if not exist "C:\Program Files\Walkme\Extension" mkdir "C:\Program Files\Walkme\Extension"
echo "Create Settings JSON File"
@echo {"name":"WalkmeExtension@walkme.com","description":"","type":"storage","data":{"wmExtConfig": "{\"u\":\"https://eu-cdn.walkme.com/extension/customers/Stada/default/015c01f0c5aa11e99b03f31fdb7d9716/ext_settings.json\",\"g\":\"015c01f0c5aa11e99b03f31fdb7d9716\",\"env\":\"ProductionEu\",\"ct\":900}"}} >> "C:\Program Files\WalkMe\Extension\WalkmeExtension@walkme.com.json"

:::: 4. Create all-walkme
echo "Create all-walkme JS File"
if not exist %FFConfigFile% @echo pref("extensions.autoDisableScopes",0);pref("extensions.autoDisableScopes",0);pref("extensions.enabledScopes",15); >> %FFConfigFile%

:::: 5. Add managed storage registry key
ECHO "Adding Managed Storage reg key"
reg add "HKEY_LOCAL_MACHINE\Software\Mozilla\ManagedStorage\WalkmeExtension@walkme.com" /f /ve /t REG_SZ /d "C:\Program Files\WalkMe\Extension\WalkmeExtension@walkme.com.json"

:::: 6. Checking for Firefox 64bit:
ECHO "Searching for Firefox 64-bit"
IF EXIST "C:\Program Files\Mozilla Firefox\firefox.exe" (
xcopy /y "C:\Program Files\Walkme\WalkmeExtension@walkme.com.xpi" "C:\Program Files\Mozilla Firefox\distribution\extensions\"
xcopy /y %FFConfigFile% "C:\Program Files\Mozilla Firefox\browser\defaults\preferences\"
) ELSE (
    ECHO "FireFox 64bit Was Not Found On This Computer"
)
ECHO "Deployment Ended"

:::: 7. Checking for Firefox 32bit:
ECHO "Searching for Firefox 32-bit"
IF EXIST "C:\Program Files (x86)\Mozilla Firefox\firefox.exe" (
xcopy /y "C:\Program Files\Walkme\WalkmeExtension@walkme.com.xpi" "C:\Program Files (x86)\Mozilla Firefox\distribution\extensions\"
xcopy /y %FFConfigFile% "C:\Program Files (x86)\Mozilla Firefox\browser\defaults\preferences\"
) ELSE (
    ECHO "FireFox 32bit Was Not Found On This Computer"
)
ECHO "Deployment Ended"

:: Install IE: 
:: ================
echo "Install Internet Explorer Start"

Set _os_bitness=64
IF %PROCESSOR_ARCHITECTURE% == x86 (
  IF NOT DEFINED PROCESSOR_ARCHITEW6432 Set _os_bitness=32
)

IF %_os_bitness% == 64 (
    start /wait msiexec.exe /quiet /i %SourceFile_MSI_64%
	start /wait msiexec.exe /quiet /i "%~dp0WalkmeAllInOneInstaller_x64_chrome_firefox_ie_edge_WithIEAutoUpdate.msi"
)
:: Check to see that 64-bit installer ran without error
if /I %errorlevel% NEQ 0 (
    echo ie extension 64-bit installation failed
) else (
    echo ie extension 64-bit installation was successful 
)

start /wait msiexec.exe /quiet /i %SourceFile_MSI_32%
:: Check to see that 32-bit installer ran without error
if /I %errorlevel% NEQ 0 (
    echo ie extension 32-bit installation failed
) else (
    echo ie extension 32-bit installation was successful 
)

:: Adding Enable Browser Extensions registry key
reg add "HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main" /f /v "Enable Browser Extensions" /t REG_SZ /d yes

:: Adding Flags registry key
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Ext\Settings\{42ED1D51-363B-4BF1-BF36-A2E3B56EDD44}" /f /v "Flags" /t REG_DWORD /d "0x400"

:: Adding extension config settings to registry
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\WalkMe\WalkMeExtension" /f /v "wmExtConfig" /t REG_SZ /d {\"u\":\"https://eu-cdn.walkme.com/extension/customers/Stada/default/015c01f0c5aa11e99b03f31fdb7d9716/ext_settings.json\",\"g\":\"015c01f0c5aa11e99b03f31fdb7d9716\",\"env\":\"ProductionEu\",\"ct\":900}
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\WalkMe\WalkMeExtension" /f /v "wmExtConfig" /t REG_SZ /d {\"u\":\"https://eu-cdn.walkme.com/extension/customers/Stada/default/015c01f0c5aa11e99b03f31fdb7d9716/ext_settings.json\",\"g\":\"015c01f0c5aa11e99b03f31fdb7d9716\",\"env\":\"ProductionEu\",\"ct\":900}


echo "Install Chromium-Edge Start"

:::: 1. Add chromium-edge extension 
echo "Install CRX"
call :install_extension "edge" "llggdlippdhlaakibcfddnepbiphgdka"

:::: 2. Configure extension settings
echo "Configure CRX"
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge\3rdparty\extensions\llggdlippdhlaakibcfddnepbiphgdka\policy" /f /v "wmExtConfig" /t REG_SZ /d {\"u\":\"https://eu-cdn.walkme.com/extension/customers/Stada/default/015c01f0c5aa11e99b03f31fdb7d9716/ext_settings.json\",\"g\":\"015c01f0c5aa11e99b03f31fdb7d9716\",\"env\":\"ProductionEu\",\"ct\":900}

echo "Install Chromium-Edge End"
:: ================

echo "Installation End"


:install_extension
    powershell -command "&{"^
    "$extensionInstallUuid = '%~2';"^
    "$browserName = '%~1';"^
    "$extensionInstallPath = '%~3';"^
    "$extensionInstalled = $FALSE;"^
    ""^
    "$registryPolicyPath = '';"^
    "if ($browserName -eq 'chrome') {"^
    "  $registryPolicyPath = 'Google\Chrome';"^
    "  $extensionInstallValue = $extensionInstallUuid +';'+ $extensionInstallPath;"^
    " "^
    "} elseif ($browserName -eq 'edge') {"^
    "  $registryPolicyPath = 'Microsoft\Edge';"^
    "  $extensionInstallValue = $extensionInstallUuid;"^
    "} else {"^
    "  Write-Output 'Invalid browser name! exiting...';"^
    "  break;"^
    "}"^
    "$extensionForceListPath = \"HKLM:\SOFTWARE\Policies\$registryPolicyPath\ExtensionInstallForcelist\";"^
    ""^
    "if (Test-Path $extensionForceListPath) {"^
    "  $extensionNum = [int]0;"^
    ""^
    "	(Get-ItemProperty $extensionForceListPath).PSObject.Properties | ForEach-Object {"^
    "		if ($_.Value -match $extensionInstallUuid) {"^
    "			$extensionInstalled = $TRUE;"^
    "          break;"^
    "		}"^
    ""^
    "		if ($_.Name -match '^\d+$') {"^
    "		    if ([int]$_.Name -gt [int]$extensionNum) {"^
    "			    $extensionNum = [int]$_.Name;"^
    "			}"^
    "		}"^
    "	};"^
    ""^
    "  if ($extensionInstalled -eq $FALSE) {"^
    "	    $extensionNum = $extensionNum + 1;"^
    ""^
    "	    Get-Item $extensionForceListPath | New-ItemProperty -Name $extensionNum -Value $extensionInstallValue -Force | Out-Null;"^
    "  }"^
    "} else {"^
    "	New-Item $extensionForceListPath -Force | New-ItemProperty -Name 1 -Value $extensionInstallValue -Force | Out-Null;"^
    "}"^
    "}"
EXIT /B 0