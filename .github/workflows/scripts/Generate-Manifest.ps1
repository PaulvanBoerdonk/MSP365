# This script generates manifest files for different modules. Update manually when exported functions or static variables change.

Function Generate-Manifest {
    # Run this function each time a new module version is created.
    # Ensure the version folder name matches the moduleversion parameter.
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $false)][Switch]$IncludeMSP365,
        [Parameter(Mandatory = $false)][Switch]$IncludeReporting,
        [Parameter(Mandatory = $false)][Switch]$IncludeSAM
    )

    # Helper function to extract the latest version from a changelog file
    Function Get-LatestVersion ($changelogPath) {
        $lastEntry = Get-Content $changelogPath | Select-Object -Last 1
        $trimmedEntry = $lastEntry.TrimStart('- **')
        $versionParts = $trimmedEntry.Split('*')
        return $versionParts | Select-Object -First 1
    }

    # Define working directory
    $workingDir = "$PSScriptRoot/../modules"

    # Extract versions from changelog files
    $script:MSP365Version = Get-LatestVersion "$workingDir/MSP365/ChangeLog.md"
    $script:ReportingVersion = Get-LatestVersion "$workingDir/MSP365.Reporting/ChangeLog.md"
    $script:SAMVersion = Get-LatestVersion "$workingDir/MSP365.SAM/ChangeLog.md"

    if ($IncludeReporting) {
        # Reporting Module
        $reportingPath = "$workingDir/MSP365.Reporting"
        $reportingParams = @{
            CompatiblePSEditions = "Desktop", "Core"
            FunctionsToExport    = 'Get-M365Users'
            Path                 = "$reportingPath/MSP365.Reporting.psd1"
            Author               = "Paul van Boerdonk"
            Description          = "Functions for Reporting Module"
            IconUri              = 'https://raw.githubusercontent.com/PaulvanBoerdonk/MSP365/master/images/MSP365.png'
            LicenseUri           = 'https://github.com/PaulvanBoerdonk/MSP365/blob/main/LICENSE'
            ModuleVersion        = "$script:ReportingVersion"
            Powershellversion    = "7.1"
            ProjectUri           = 'https://github.com/PaulvanBoerdonk/MSP365'
            RequiredModules      = (
                @{ModuleName = 'PartnerCenter'; ModuleVersion = "3.0.10"; }
            )
            RootModule           = "MSP365.ReportingManifest.psm1"
            ReleaseNotes         = "Dependency module for the Module MSP365. Full ChangeLog contained in bundled ChangeLog.txt"
            Tags                 = 'Reporting'
        }
        New-ModuleManifest @reportingParams
    }

    if ($IncludeSAM) {
        # SAM Module
        $samPath = "$workingDir/MSP365.SAM"
        $samParams = @{
            CompatiblePSEditions = "Desktop", "Core"
            FunctionsToExport    = 'Get-M365Users'
            Path                 = "$samPath/MSP365.SAM.psd1"
            Author               = "Paul van Boerdonk"
            Description          = "Functions for management of SAM"
            IconUri              = 'https://raw.githubusercontent.com/PaulvanBoerdonk/MSP365/master/images/MSP365.png'
            LicenseUri           = 'https://github.com/PaulvanBoerdonk/MSP365/blob/master/LICENSE'
            ModuleVersion        = "$script:SAMVersion"
            Powershellversion    = "7.1"
            ProjectUri           = 'https://github.com/PaulvanBoerdonk/MSP365'
            RequiredModules      = (
                @{ModuleName = 'PartnerCenter'; ModuleVersion = "3.0.10"; }
            )
            RootModule           = "MSP365.SAMManifest.psm1"
            ReleaseNotes         = "Dependency module for the Module MSP365. Full ChangeLog contained in bundled ChangeLog.txt"
            Tags                 = 'SAM'
        }
        New-ModuleManifest @samParams
    }

    if ($IncludeMSP365) {
        # MSP365 Module
        $msp365Path = "$workingDir/MSP365"
        $msp365Params = @{
            CompatiblePSEditions = "Desktop", "Core"
            FunctionsToExport    = 'Get-M365Users'
            Path                 = "$msp365Path/MSP365.psd1"
            Author               = "Paul van Boerdonk"
            Description          = "Functions for MSP365 Module"
            IconUri              = 'https://raw.githubusercontent.com/PaulvanBoerdonk/MSP365/master/images/MSP365.png'
            LicenseUri           = 'https://github.com/PaulvanBoerdonk/MSP365/blob/main/LICENSE'
            ModuleVersion        = "$script:MSP365Version"
            Powershellversion    = "7.1"
            ProjectUri           = 'https://github.com/PaulvanBoerdonk/MSP365'
            RequiredModules      = (
                @{ModuleName = 'PartnerCenter'; ModuleVersion = "3.0.10"; }
            )
            RootModule           = "MSP365Manifest.psm1"
            ReleaseNotes         = "Dependency module for the Module MSP365. Full ChangeLog contained in bundled ChangeLog.txt"
            Tags                 = 'MSP365'
        }
        New-ModuleManifest @msp365Params
    }
}