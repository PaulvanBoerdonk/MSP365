Function New-Manifest {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $false)][Switch]$MSP365,
        [Parameter(Mandatory = $false)][Switch]$Reporting,
        [Parameter(Mandatory = $false)][Switch]$SAM
    )

    $modules = @(
        @{ Name = 'MSP365'; Path = 'MSP365'; ParamName = 'MSP365GithubVersion' },
        @{ Name = 'MSP365.Reporting'; Path = 'MSP365.Reporting'; ParamName = 'ReportingGithubVersion' },
        @{ Name = 'MSP365.SAM'; Path = 'MSP365.SAM'; ParamName = 'SAMGithubVersion' }
    )

    foreach ($module in $modules) {
        $lastChangeLogEntry = Get-Content "$workingdirectory/modules/$($module.Path)/ChangeLog.md" | Select-Object -Last 1
        $trimmedEntry = $lastChangeLogEntry.trimstart('- **')
        $entryParts = ($trimmedEntry).split('*')
        Set-Variable -Name $module.ParamName -Value ($entryParts | Select-Object -First 1)
    }

    $manifests = @(
        @{ Switch = $Reporting; Path = 'MSP365.Reporting'; Functions = 'Get-M365Users'; ModuleVersion = $script:ReportingGithubVersion; Tags = 'Reporting' },
        @{ Switch = $SAM; Path = 'MSP365.SAM'; Functions = 'Get-M365Users'; ModuleVersion = $script:SAMGithubVersion; Tags = 'SAM' }
    )

    foreach ($manifest in $manifests) {
        if ($manifest.Switch) {
            $Params = @{
                CompatiblePSEditions = "Desktop", "Core"
                FunctionsToExport    = $manifest.Functions
                Path                 = "$workingdirectory\modules\$($manifest.Path)\$($manifest.Path).psd1"
                Author               = "Paul van Boerdonk"
                Description          = "Functions for $($manifest.Path) Module"
                IconUri              = 'https://raw.githubusercontent.com/PaulvanBoerdonk/MSP365/master/images/MSP365.png'
                LicenseUri           = 'https://github.com/PaulvanBoerdonk/MSP365/blob/main/LICENSE'
                ModuleVersion        = $manifest.ModuleVersion
                Powershellversion    = "7.1"
                ProjectUri           = 'https://github.com/PaulvanBoerdonk/MSP365'
                RequiredModules      = @{ ModuleName = 'PartnerCenter'; ModuleVersion = "3.0.10" }
                RootModule           = "$($manifest.Path)Manifest.psm1"
                ReleaseNotes         = "$($manifest.Path) module for the MSP365 module. Changes can be found in the ChangeLog.md file."
                Tags                 = $manifest.Tags
            }

            New-ModuleManifest @Params
        }
    }

    Start-Sleep -Seconds 60

    if ($MSP365) {
        $Params = @{
            CompatiblePSEditions = "Desktop", "Core"
            FunctionsToExport    = 'Get-All', 'Get-Info', 'Get-Full', 'Start-Application', 'Get-ModuleAliases', 'Invoke-Show'
            Path                 = "$workingdirectory\modules\MSP365\MSP365.psd1"
            Author               = "Paul van Boerdonk"
            Description          = "Module that installs all other modules and provides a central point for all functions"
            IconUri              = 'https://raw.githubusercontent.com/PaulvanBoerdonk/MSP365/master/images/MSP365.png'
            LicenseUri           = 'https://github.com/PaulvanBoerdonk/MSP365/blob/master/LICENSE.txt'
            ModuleVersion        = $script:MSP365GithubVersion
            Powershellversion    = "7.1"
            ProjectUri           = 'https://github.com/PaulvanBoerdonk/MSP365'
            RequiredModules      = (
                @{ ModuleName = 'MSP365.Reporting'; ModuleVersion = $script:ReportingGithubVersion },
                @{ ModuleName = 'MSP365.SAM'; ModuleVersion = $script:SAMGithubVersion }
            )
            RootModule           = "MSP365Manifest.psm1"
            ReleaseNotes         = "The release notes can be found in the ChangeLog.md file at the scriptroot path."
            Tags                 = '365', 'Reporting', 'Automate', 'Application', 'MSGraph', 'SAM'
        }

        New-ModuleManifest @Params
    }
}