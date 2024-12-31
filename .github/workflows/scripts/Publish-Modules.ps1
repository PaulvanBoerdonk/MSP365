# This script publishes modules to the PowerShell Gallery if the version in the changelog is greater than the version in the gallery.

Function Publish-Modules {
    param (
        [string]$WorkingDirectory,
        [string]$PSGalleryApiKey
    )

    # Helper function to get the latest version from a changelog file
    Function Get-LatestVersion ($changelogPath) {
        $lastEntry = Get-Content $changelogPath | Select-Object -Last 1
        $trimmedEntry = $lastEntry.TrimStart('- **')
        $versionParts = $trimmedEntry.Split('*')
        return $versionParts | Select-Object -First 1
    }

    # Helper function to publish a module
    Function Publish-ModuleIfNewer ($moduleName, $modulePath) {
        $psGalleryVersion = (Find-Module $moduleName -Repository PSGallery).Version
        $githubVersion = Get-LatestVersion "$modulePath/ChangeLog.md"
        if ([version]$githubVersion -gt [version]$psGalleryVersion) {
            Generate-Manifest -Include$moduleName
            Publish-Module -Path $modulePath -NuGetApiKey $PSGalleryApiKey
            Write-Output "$moduleName published to PSGallery"
        }
        else {
            Write-Output "$moduleName not published"
        }
    }

    # Publish SAM module
    Publish-ModuleIfNewer "MSP365.SAM" "$WorkingDirectory/modules/MSP365.SAM"

    # Publish Reporting module
    Publish-ModuleIfNewer "MSP365.Reporting" "$WorkingDirectory/modules/MSP365.Reporting"

    # Publish MSP365 module
    Start-Sleep -Seconds 30
    $msp365Path = "$WorkingDirectory/modules/MSP365"
    $msp365Version = Get-LatestVersion "$msp365Path/ChangeLog.md"
    $msp365PSGalleryVersion = (Find-Module MSP365 -Repository PSGallery).Version
    if ([version]$msp365Version -gt [version]$msp365PSGalleryVersion) {
        Generate-Manifest -IncludeMSP365
        Copy-Item "$WorkingDirectory/modules/MSP365.Reporting" -Destination "$env:ProgramFiles\WindowsPowerShell\Modules" -Force -Recurse
        Import-Module "$WorkingDirectory/modules/MSP365.Reporting" -Force -Global
        Copy-Item "$WorkingDirectory/modules/MSP365.SAM" -Destination "$env:ProgramFiles\WindowsPowerShell\Modules" -Force -Recurse
        Import-Module "$WorkingDirectory/modules/MSP365.SAM" -Force -Global
        Publish-Module -Path $msp365Path -NuGetApiKey $PSGalleryApiKey
        Write-Output "[+] MSP365 published to PSGallery"
    }
    else {
        Write-Output "[-] MSP365 not published"
    }
}
