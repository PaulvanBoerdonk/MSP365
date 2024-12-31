function Invoke-PublishModules {
    $ErrorActionPreference = 'Stop'

    #Reporting
    $ReportingPSGallery = (Find-Module "MSP365.Reporting" -Repository PSGallery).version
    $step = Get-Content "$workingdirectory/modules/MSP365.Reporting/ChangeLog.md" | Select-Object -Last 1; $step2 = $step.trimstart('- **'); $step3 = ($step2).split('*'); $ReportingGithub = $step3 | Select-Object -First 1
    if ([version]$ReportingGithub -gt [version]$ReportingPSGallery ) {
        New-Manifest -Reporting #Generate each modules manifest files
        Publish-Module -Path "$workingdirectory/modules/MSP365.Reporting" -NuGetApiKey $env:PS_GALLERY_KEY
        $Reporting = Write-Output "[+] MSP365.Reporting published to PSGallery"
    }
    else {
        $Reporting = Write-Output "[-] MSP365.Reporting not published"
    }

    #SAM
    $SAMPSGallery = (Find-Module "MSP365.SAM" -Repository PSGallery).version
    $step = Get-Content "$workingdirectory/modules/MSP365.SAM/ChangeLog.md" | Select-Object -Last 1; $step2 = $step.trimstart('- **'); $step3 = ($step2).split('*'); $SAMGithub = $step3 | Select-Object -First 1
    if ([version]$SAMGithub -gt [version]$SAMPSGallery ) {
        New-Manifest -SAM #Generate each modules manifest files
        Publish-Module -Path "$workingdirectory/modules/MSP365.SAM" -NuGetApiKey $env:PS_GALLERY_KEY
        $SAM = Write-Output "[+] MSP365.SAM published to PSGallery"
    }
    else {
        $SAM = Write-Output "[-] MSP365.SAM not published"
    }

    #MSP365
    $MSP365PSGallery = (Find-Module MSP365 -Repository PSGallery).version
    $step = Get-Content "$workingdirectory/modules/MSP365/ChangeLog.md" | Select-Object -Last 1; $step2 = $step.trimstart('- **'); $step3 = ($step2).split('*'); $MSP365Github = $step3 | Select-Object -First 1
    if ([version]$MSP365Github -gt [version]$MSP365PSGallery ) {
        New-Manifest -MSP365 #Generate each modules manifest files
        Copy-Item $workingdirectory/modules/MSP365.Reporting -Destination $env:ProgramFiles\WindowsPowerShell\Modules -Force -Recurse ; Import-Module $workingdirectory/modules/MSP365.Reporting -Force -Global
        Copy-Item $workingdirectory/modules/MSP365.SAM -Destination $env:ProgramFiles\WindowsPowerShell\Modules -Force -Recurse ; Import-Module $workingdirectory/modules/MSP365.SAM -Force -Global
        Publish-Module -Path "$workingdirectory/modules/MSP365" -NuGetApiKey $env:PS_GALLERY_KEY
        $MSP365 = Write-Output "[+] MSP365 published to PSGallery"
    }
    else {
        $MSP365 = Write-Output "[-] MSP365 not published"
    }

    $Reporting
    $SAM
    $MSP365
}