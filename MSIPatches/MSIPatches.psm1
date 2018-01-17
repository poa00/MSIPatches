if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "You need to run this script from an elevated PowerShell prompt!`nPlease start PowerShell as an Administrator..."
    break
}

if ($PSVersionTable.PSEdition -eq 'Core') {
    Write-Warning "This function is not compatible with PowerShell Core as it reiles on the MSI module binaries."
    break
}

# Check MSI module is installed. https://github.com/heaths/psmsi
If ((Get-Command -Module MSI) -eq $null ) {
    Write-Output "The MSI module is not loaded, loading..."
    try {
        Install-Package msi -Provider PowerShellGet -Force -Verbose
    }
    catch {
        Write-Warning $_.exception.message
        break
    }
}

# Get Public and private functions
$Public = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue)
$Private = @(Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue)

# Dot source the files
foreach ($function in @($Public + $Private)) {
    try {
        . $function.Fullname
    }
    catch {
        Write-Error -Message "Failed to import function $($function.Fullname): $_"
    }
}