function New-Manifest {
    param (
        [Parameter(Mandatory = $false)][Switch]$Authentication,
        [Parameter(Mandatory = $false)][Switch]$MSP365,
        [Parameter(Mandatory = $false)][Switch]$Reporting,
        [Parameter(Mandatory = $false)][Switch]$SAM
    )

    function Get-GithubVersion {
        param (
            [string]$changelogPath
        )
        $lastLine = Get-Content $changelogPath | Select-Object -Last 1
        $trimmedLine = $lastLine.trimstart('- **')
        $versionParts = ($trimmedLine).split('*')
        return $versionParts | Select-Object -First 1
    }
    
    $script:MSP365GithubVersion = Get-GithubVersion "$workingdirectory/modules/MSP365/ChangeLog.md"
    $script:AuthenticationGithubVersion = Get-GithubVersion "$workingdirectory/modules/MSP365.Authentication/ChangeLog.md"
    $script:ReportingGithubVersion = Get-GithubVersion "$workingdirectory/modules/MSP365.Reporting/ChangeLog.md"
    $script:SAMGithubVersion = Get-GithubVersion "$workingdirectory/modules/MSP365.SAM/ChangeLog.md"

    if ($Authentication) {
        $savepath = "$workingdirectory\modules\MSP365.Authentication"
        $Params = @{
            CompatiblePSEditions = "Desktop", "Core"
            FunctionsToExport    = 'Get-MSPAuthenticationContext'
            Path                 = "$savepath\MSP365.Authentication.psd1"
            Author               = "Paul van Boerdonk"
            Description          = "Functions for Authentication Module"
            IconUri              = 'https://raw.githubusercontent.com/PaulvanBoerdonk/MSP365/master/images/MSP365.png'
            LicenseUri           = 'https://github.com/PaulvanBoerdonk/MSP365/blob/main/LICENSE'
            ModuleVersion        = "$script:AuthenticationGithubVersion"
            Powershellversion    = "7.1"
            ProjectUri           = 'https://github.com/PaulvanBoerdonk/MSP365'
            RootModule           = "MSP365.Authentication.psm1"
        }
        New-ModuleManifest @Params
    }

    if ($Reporting) {
        $savepath = "$workingdirectory\modules\MSP365.Reporting"
        $Params = @{
            CompatiblePSEditions = "Desktop", "Core"
            FunctionsToExport    = 'Get-MSPReport'
            Path                 = "$savepath\MSP365.Reporting.psd1"
            Author               = "Paul van Boerdonk"
            Description          = "Functions for Reporting Module"
            IconUri              = 'https://raw.githubusercontent.com/PaulvanBoerdonk/MSP365/master/images/MSP365.png'
            LicenseUri           = 'https://github.com/PaulvanBoerdonk/MSP365/blob/main/LICENSE'
            ModuleVersion        = "$script:ReportingGithubVersion"
            Powershellversion    = "7.1"
            ProjectUri           = 'https://github.com/PaulvanBoerdonk/MSP365'
            RootModule           = "MSP365.Reporting.psm1"
        }
        New-ModuleManifest @Params
    }

    if ($SAM) {
        $savepath = "$workingdirectory\modules\MSP365.SAM"
        $Params = @{
            CompatiblePSEditions = "Desktop", "Core"
            FunctionsToExport    = 'Get-MSPSAMStatus'
            Path                 = "$savepath\MSP365.SAM.psd1"
            Author               = "Paul van Boerdonk"
            Description          = "Functions for SAM Module"
            IconUri              = 'https://raw.githubusercontent.com/PaulvanBoerdonk/MSP365/master/images/MSP365.png'
            LicenseUri           = 'https://github.com/PaulvanBoerdonk/MSP365/blob/main/LICENSE'
            ModuleVersion        = "$script:SAMGithubVersion"
            Powershellversion    = "7.1"
            ProjectUri           = 'https://github.com/PaulvanBoerdonk/MSP365'
            RootModule           = "MSP365.SAM.psm1"
        }
        New-ModuleManifest @Params
    }

    if ($MSP365) {
        $savepath = "$workingdirectory\modules\MSP365"
        $Params = @{
            CompatiblePSEditions = "Desktop", "Core"
            FunctionsToExport    = 'Get-MSPCommand', 'Update-MSPModule'
            Path                 = "$savepath\MSP365.psd1"
            Author               = "Paul van Boerdonk"
            Description          = "Functions for MSP365 Module"
            IconUri              = 'https://raw.githubusercontent.com/PaulvanBoerdonk/MSP365/master/images/MSP365.png'
            LicenseUri           = 'https://github.com/PaulvanBoerdonk/MSP365/blob/main/LICENSE'
            ModuleVersion        = "$script:MSP365GithubVersion"
            Powershellversion    = "7.1"
            ProjectUri           = 'https://github.com/PaulvanBoerdonk/MSP365'
            RequiredModules      = (
                @{ ModuleName = "MSP365.Authentication"; ModuleVersion = $script:AuthenticationGithubVersion; },
                @{ ModuleName = "MSP365.Reporting"; ModuleVersion = $script:ReportingGithubVersion; },
                @{ ModuleName = "MSP365.SAM"; ModuleVersion = $script:SAMGithubVersion; }
            )
            RootModule           = "MSP365.psm1"
        }
        New-ModuleManifest @Params
    }
}

function Publish-Modules {
    $ErrorActionPreference = 'Stop'

    $modules = @(
        @{ Name = "MSP365.Authentication"; Path = "$workingdirectory/modules/MSP365.Authentication"; ManifestSwitch = "-Authentication" },
        @{ Name = "MSP365.Reporting"; Path = "$workingdirectory/modules/MSP365.Reporting"; ManifestSwitch = "-Reporting" },
        @{ Name = "MSP365.SAM"; Path = "$workingdirectory/modules/MSP365.SAM"; ManifestSwitch = "-SAM" },
        @{ Name = "MSP365"; Path = "$workingdirectory/modules/MSP365"; ManifestSwitch = "-MSP365" }
    )

    foreach ($module in $modules) {
        if ($module.ManifestSwitch -eq "-MSP365") {
            Copy-Item $workingdirectory/modules/MSP365.Authentication -Destination $env:ProgramFiles\WindowsPowerShell\Modules -Force -Recurse ; Import-Module $workingdirectory/modules/MSP365.Authentication/MSP365.Authentication.psm1 -Force -Global
            Copy-Item $workingdirectory/modules/MSP365.Reporting -Destination $env:ProgramFiles\WindowsPowerShell\Modules -Force -Recurse ; Import-Module $workingdirectory/modules/MSP365.Reporting/MSP365.Reporting.psm1 -Force -Global
            Copy-Item $workingdirectory/modules/MSP365.SAM -Destination $env:ProgramFiles\WindowsPowerShell\Modules -Force -Recurse ; Import-Module $workingdirectory/modules/MSP365.SAM/MSP365.SAM.psm1 -Force -Global
            Start-Sleep -Seconds 3
        }
        $PSGalleryVersion = (Find-Module $module.Name -Repository PSGallery).version
        $step = Get-Content "$($module.Path)/ChangeLog.md" | Select-Object -Last 1
        $step2 = $step.trimstart('- **')
        $step3 = ($step2).split('*')
        $GithubVersion = $step3 | Select-Object -First 1




        if ([version]$GithubVersion -gt [version]$PSGalleryVersion) {
            Invoke-Expression "New-Manifest $($module.ManifestSwitch)"
            Publish-Module -Path $module.Path -NuGetApiKey $env:PS_GALLERY_KEY
            Write-Output "[+] $($module.Name) published to PSGallery"
        }
        else {
            Write-Output "[-] $($module.Name) not published"
        }
    }
}

