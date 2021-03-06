$ErrorActionPreference = "SilentlyContinue"

# LOGGING INITIALISATION
$logSource = "OneDrive Per-Machine Deployment"
if (![System.Diagnostics.EventLog]::SourceExists($logSource)){
        new-eventlog -LogName Application -Source $logSource
}

# END LOGGING

# CONFIGURATION VARIABLES

# Specify the location of the OneDriveSetup.exe
$installationSource = "\\YOUR-SMB-SERVER\group-policy\onedrive\latest\"
$destinationPath = "C:\Program Files (x86)\Microsoft OneDrive"
$installedVersion = (Get-Command "$destinationPath\OneDrive.exe").FileVersionInfo.FileVersion

try{
    $ErrorActionPreference = "Stop"
    $targetVersion = (Get-Command "$installationSource\OneDriveSetup.exe").FileVersionInfo.FileVersion
} catch{
    write-eventlog -LogName Application -Source $logSource -EntryType Error -EventId 900 -Message "Unable to determine target OneDrive version - check network connectivity or existence of deployment files."
    Exit
}

$ErrorActionPreference = "SilentlyContinue"

# END CONFIGURATION

if ($targetVersion -ne $installedVersion){
    write-eventlog -LogName Application -Source $logSource -EntryType Information -EventId 1 -Message "Microsoft OneDrive not installed or out of date. Installed version: $installedVersion; target version: $targetVersion. Installation starting..."

    if (Test-Path ($destinationPath)){
        Remove-Item $destinationPath -recurse
        write-eventlog -LogName Application -Source $logSource -EntryType Information -EventId 2 -Message "Existing OneDrive installation removed"
    }

    & "$installationSource\OneDriveSetup.exe" /allusers

    write-eventlog -LogName Application -Source $logSource -EntryType Information -EventId 5 -Message "OneDrive installation complete"
} 