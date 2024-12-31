function Invoke-PublishModules {
    $ErrorActionPreference = 'Stop'

    function Publish-IfNewer($moduleName, $modulePath) {
        $psGalleryVersion = (Find-Module $moduleName -Repository PSGallery).version
        $githubVersion = (Get-Content "$modulePath/ChangeLog.md" | Select-Object -Last 1).TrimStart('- **').Split('*')[0]
        
        if ([version]$githubVersion -gt [version]$psGalleryVersion) {
            New-Manifest -$moduleName # Generate each module's manifest files
            Publish-Module -Path $modulePath -NuGetApiKey $env:PS_GALLERY_KEY
            Write-Output "$moduleName published to PSGallery"
        }
        else {
            Write-Output "$moduleName not published"
        }
    }

    $Reporting = Publish-IfNewer "MSP365.Reporting" "$workingdirectory/modules/MSP365.Reporting"
    $SAM = Publish-IfNewer "MSP365.SAM" "$workingdirectory/modules/MSP365.SAM"

    $MSP365PSGallery = (Find-Module MSP365 -Repository PSGallery).version
    $MSP365Github = (Get-Content "$workingdirectory/modules/MSP365/ChangeLog.md" | Select-Object -Last 1).TrimStart('- **').Split('*')[0]
    if ([version]$MSP365Github -gt [version]$MSP365PSGallery) {
        New-Manifest -MSP365 # Generate each module's manifest files
        Copy-Item "$workingdirectory/modules/MSP365.Reporting" -Destination $env:ProgramFiles\WindowsPowerShell\Modules -Force -Recurse
        Import-Module "$workingdirectory/modules/MSP365.Reporting" -Force -Global
        Copy-Item "$workingdirectory/modules/MSP365.SAM" -Destination $env:ProgramFiles\WindowsPowerShell\Modules -Force -Recurse
        Import-Module "$workingdirectory/modules/MSP365.SAM" -Force -Global
        Publish-Module -Path "$workingdirectory/modules/MSP365" -NuGetApiKey $env:PS_GALLERY_KEY
        $MSP365 = Write-Output "MSP365 published to PSGallery"
    }
    else {
        $MSP365 = Write-Output "MSP365 not published"
    }

    $Reporting
    $SAM
    $MSP365
}