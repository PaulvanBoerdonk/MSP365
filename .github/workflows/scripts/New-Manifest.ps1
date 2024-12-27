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

    $step = Get-Content "$workingdirectory/modules/MSP365.Reporting/ChangeLog.md" | Select-Object -Last 1; $step2 = $step.trimstart('* **'); $step3 = ($step2).split('*'); $script:ReportingGithubVersion = $step3 | Select-Object -First 1
    $step = Get-Content "$workingdirectory/modules/MSP365.SAM/ChangeLog.md" | Select-Object -Last 1; $step2 = $step.trimstart('* **'); $step3 = ($step2).split('*'); $script:SAMGithubVersion = $step3 | Select-Object -First 1
 
    if ($MSP365) {
        ##Create Manifests
        #MSP365
        $savepath = "$workingdirectory\modules\MSP365"
        #Old iconurl. Maybe bad now if profile image has changed. 'https://avatars2.githubusercontent.com/u/53202926?s=460&v=4'
        $Params = @{
            CompatiblePSEditions = "Desktop", "Core"
            FunctionsToExport    = 'Get-All', 'Get-Info', 'Get-Full', 'Start-Application', 'Get-ModuleAliases', 'Invoke-Show'
            Path                 = "$savepath\MSP365.psd1"
            Author               = "Paul van Boerdonk"
            Description          = "Master module for a collection of modules. These modules are varied in their tasks. The overall purpose of them being to provide a powerfull Toolset to improve IT Admin workflows."
            IconUri              = 'https://raw.githubusercontent.com/TheTaylorLee/MSP365/master/images/toolboxShell2.png'
            LicenseUri           = 'https://github.com/TheTaylorLee/MSP365/blob/master/LICENSE.txt'
            ModuleVersion        = "$script:MSP365GithubVersion"
            Powershellversion    = "5.1"
            ProjectUri           = 'https://github.com/TheTaylorLee/MSP365'
            RequiredModules      = (
                @{ModuleName = 'MSP365.Reporting'; ModuleVersion = $script:ReportingGithubVersion; },
                @{ModuleName = 'MSP365.SAM'; ModuleVersion = $script:SAMGithubVersion; }
            )
            RootModule           = "MSP365Manifest.psm1"
            ReleaseNotes         = "The release notes can be found in the ChangeLog.md file at the scriptroot path."
            Tags                 = '365', 'Active', 'Reporting', 'Automate', 'Application', 'Crescendo', 'Directory', 'Exchange', 'FileManagement', 'Fortinet', 'FortiGate', 'FortiOS', 'GraphAPI', 'Iperf', 'MSGraph', 'Network', 'Networking', 'NetworkScan', 'Office', 'Office365', 'OpenSSH', 'PC', 'PCSetup', 'Print', 'Printer', 'Remoting', 'Robocopy', 'Setup', 'SSH', 'vmware', 'Windows'
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
            IconUri              = 'https://raw.githubusercontent.com/TheTaylorLee/MSP365/master/images/toolboxShell2.png'
            LicenseUri           = 'https://github.com/PaulvanBoerdonk/MSP365/blob/main/LICENSE'
            ModuleVersion        = "$script:ReportingGithubVersion"
            Powershellversion    = "5.1"
            ProjectUri           = 'https://github.com/TheTaylorLee/MSP365/'
            RequiredModules      = (
                @{ ModuleName = "ImportExcel" ; ModuleVersion = "7.0.1" }
            )
            RootModule           = "MSP365.ReportingManifest.psm1"
            ReleaseNotes         = "Dependency module for the Module MSP365. Full ChangeLog contained in bundled ChangeLog.txt"
            Tags                 = 'Active', 'Reporting', 'Directory', 'Groups', 'Users'
        }

        New-ModuleManifest @Params
    }

    if ($SAM) {
        #SAM
        $savepath = "$workingdirectory\modules\MSP365.SAM"
        $Params = @{
            CompatiblePSEditions = "Desktop", "Core"
            FunctionsToExport    = 'Add-LocalAdmin', 'Disable-Firewall', 'Disable-PasswordPeek', 'Disable-ShakeToMinimize', 'Disable-Standby', 'Dismount-ProfileRegistry', 'Enable-Firewall', 'Enable-RSATFeatures', 'Get-Applications', 'Get-ChocoOutdated', 'Get-IntroPCS', 'Get-Management', 'Get-PCInfo', 'Get-PrintBackup', 'Get-Printers', 'Get-PrintManagement', 'Get-SAM', 'Install-Chocolatey', 'Install-ChocoPackages', 'Invoke-ChocoUpgrade', 'Invoke-PrinterServerRenew', 'Join-Domain', 'Mount-ProfileRegistry', 'Remove-PrintQueue', 'Remove-Shortcuts', 'Remove-StoreApps', 'Remove-Tiles', 'Restart-Endpoint', 'Get-ChocoInstalls', 'Set-UAC', 'Uninstall-Application', 'Get-PowerShell7', 'Reset-EndpointPassword', 'Repair-DomainJoin', 'Disable-Cortana', 'Get-MonitorSizes', 'Get-RebootEvents', 'Get-RemoteDesktopLogins', 'Get-LocalLogonHistory'
            Path                 = "$savepath\MSP365.SAM.psd1"
            Author               = "Paul van Boerdonk"
            Description          = "Functions for management of endpoints"
            IconUri              = 'https://raw.githubusercontent.com/TheTaylorLee/MSP365/master/images/toolboxShell2.png'
            LicenseUri           = 'https://github.com/TheTaylorLee/MSP365/blob/master/LICENSE.txt'
            ModuleVersion        = "$script:SAMGithubVersion"
            Powershellversion    = "5.1"
            ProjectUri           = 'https://github.com/TheTaylorLee/MSP365/'
            RequiredModules      = (
                @{ ModuleName = "ImportExcel" ; ModuleVersion = "7.0.1" },
                @{ ModuleName = "PSEventViewer" ; ModuleVersion = "1.0.17" }
            )
            RootModule           = "MSP365.SAMManifest.psm1"
            ReleaseNotes         = "Dependency module for the Module MSP365. Full ChangeLog contained in bundled ChangeLog.txt"
            Tags                 = 'Chocolatey', 'PC', 'PCSetup', 'Print', 'Printer', 'Setup', 'UAC', 'Windows'
        }

        New-ModuleManifest @Params
    }
}