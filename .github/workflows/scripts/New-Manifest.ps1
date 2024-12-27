#This is used by a workflow to generate manifest files. Only needs to be updated manually when exported functions or other static variables need changing. Otherwise can be left as is.

Function New-Manifest {
    #Must Be run each time a new module version is created.
    #Version folder name must be the same as the moduleversion parameter
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $false)][Switch]$MSP365,
        [Parameter(Mandatory = $false)][Switch]$Reporting,
        [Parameter(Mandatory = $false)][Switch]$SAM
    )


    $step = Get-Content "$workingdirectory/modules/MSP365/ChangeLog.md" | Select-Object -Last 1; $step2 = $step.trimstart('- **'); $step3 = ($step2).split('*'); $script:MSP365GithubVersion = $step3 | Select-Object -First 1
    $step = Get-Content "$workingdirectory/modules/MSP365.Reporting/ChangeLog.md" | Select-Object -Last 1; $step2 = $step.trimstart('- **'); $step3 = ($step2).split('*'); $script:ReportingGithubVersion = $step3 | Select-Object -First 1
    $step = Get-Content "$workingdirectory/modules/MSP365.SAM/ChangeLog.md" | Select-Object -Last 1; $step2 = $step.trimstart('- **'); $step3 = ($step2).split('*'); $script:SAMGithubVersion = $step3 | Select-Object -First 1
 
    if ($MSP365) {
        ##Create Manifests
        #MSP365
        $savepath = "$workingdirectory\modules\MSP365"

        $Params = @{
            CompatiblePSEditions = "Desktop", "Core"
            FunctionsToExport    = 'Get-All', 'Get-Info', 'Get-Full', 'Start-Application', 'Get-ModuleAliases', 'Invoke-Show'
            Path                 = "$savepath\MSP365.psd1"
            Author               = "Paul van Boerdonk"
            Description          = "Module that installs all other modules and provides a central point for all functions"
            IconUri              = 'https://raw.githubusercontent.com/PaulvanBoerdonk/MSP365/master/images/MSP365.png'
            LicenseUri           = 'https://github.com/PaulvanBoerdonk/MSP365/blob/master/LICENSE.txt'
            ModuleVersion        = "$script:MSP365GithubVersion"
            Powershellversion    = "7.1"
            ProjectUri           = 'https://github.com/PaulvanBoerdonk/MSP365'
            RequiredModules      = (
                @{ModuleName = 'MSP365.Reporting'; ModuleVersion = $script:ReportingGithubVersion; },
                @{ModuleName = 'MSP365.SAM'; ModuleVersion = $script:SAMGithubVersion; }
            )
            RootModule           = "MSP365Manifest.psm1"
            ReleaseNotes         = "The release notes can be found in the ChangeLog.md file at the scriptroot path."
            Tags                 = '365', 'Reporting', 'Automate', 'Application', 'MSGraph', 'SAM'
        }

        New-ModuleManifest @Params
    }

    if ($Reporting) {
        #Reporting
        $savepath = "$workingdirectory\modules\MSP365.Reporting"
        $Params = @{
            CompatiblePSEditions = "Desktop", "Core"
            FunctionsToExport    = 'Get-M365Users'
            Path                 = "$savepath\MSP365.Reporting.psd1"
            Author               = "Paul van Boerdonk"
            Description          = "Functions for Reporting Module"
            IconUri              = 'https://raw.githubusercontent.com/PaulvanBoerdonk/MSP365/master/images/MSP365.png'
            LicenseUri           = 'https://github.com/PaulvanBoerdonk/MSP365/blob/main/LICENSE'
            ModuleVersion        = "$script:ReportingGithubVersion"
            Powershellversion    = "7.1"
            ProjectUri           = 'https://github.com/PaulvanBoerdonk/MSP365'
            RequiredModules      = (
                @{ModuleName = 'PartnerCenter'; ModuleVersion = "3.0.10"; }
            )
            RootModule           = "MSP365.ReportingManifest.psm1"
            ReleaseNotes         = "Dependency module for the Module MSP365. Full ChangeLog contained in bundled ChangeLog.txt"
            Tags                 = 'Reporting'
        }

        New-ModuleManifest @Params
    }

    if ($SAM) {
        #SAM
        $savepath = "$workingdirectory\modules\MSP365.SAM"
        $Params = @{
            CompatiblePSEditions = "Desktop", "Core"
            FunctionsToExport    = 'Get-M365Users'
            Path                 = "$savepath\MSP365.SAM.psd1"
            Author               = "Paul van Boerdonk"
            Description          = "Functions for management of SAM"
            IconUri              = 'https://raw.githubusercontent.com/PaulvanBoerdonk/MSP365/master/images/MSP365.png'
            LicenseUri           = 'https://github.com/PaulvanBoerdonk/MSP365/blob/master/LICENSE'
            ModuleVersion        = "$script:SAMGithubVersion"
            Powershellversion    = "7.1"
            ProjectUri           = 'https://github.com/PaulvanBoerdonk/MSP365'
            RequiredModules      = (
                @{ModuleName = 'PartnerCenter'; ModuleVersion = "3.0.10"; }
            )
            RootModule           = "MSP365.SAMManifest.psm1"
            ReleaseNotes         = "Dependency module for the Module MSP365. Full ChangeLog contained in bundled ChangeLog.txt"
            Tags                 = 'SAM'
        }

        New-ModuleManifest @Params
    }
}