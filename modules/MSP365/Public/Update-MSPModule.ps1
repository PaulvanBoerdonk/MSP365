function Update-MSPModule {
    # Set the parameter types and default values
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [ValidateSet("MSP365", "MSP365.Authentication", "MSP365.Reporting", "MSP365.SAM")]
        [string]$ModuleName,
        [Parameter(Mandatory = $false)][switch]$All
    )

    # Check if -ModuleName and -All are not specified and return if so
    if (-not $ModuleName -and -not $All) {
        Write-Host "Please specify either -All or -ModuleName <ModuleName>"
        return
    }

    # Check if both -All and -ModuleName are specified and return if so
    if ($All -and $ModuleName) {
        Write-Host "Please specify either -All or -ModuleName, not both"
        return
    }

    # Check if -All is specified and update all modules

    # Get all modules that start with MSP365.* and update them
    if ($All -and -not $ModuleName) {
        $modules = Get-Module -ListAvailable | Where-Object { $_.Name -like "MSP365.*" }
        foreach ($module in $modules) {
            $latestVersion = Find-Module -Name $module.Name | Sort-Object -Property Version -Descending | Select-Object -First 1
            if ($latestVersion.Version -gt $module.Version) {
                Write-Host "Updating module $($module.Name) to version $($latestVersion.Version)"
                Update-Module -Name $module.Name -AllowClobber -Scope CurrentUser
            }
            else {
                Write-Host "Module $($module.Name) is already up to date, version: $($module.Version)"
            }
        }

        # Update the main module
        $latestVersion = Find-Module -Name "MSP365" | Sort-Object -Property Version -Descending | Select-Object -First 1

        if ($latestVersion.Version -gt (Get-Module -Name "MSP365" -ListAvailable).Version) {
            Write-Host "Updating module MSP365 to version $($latestVersion.Version)"
            Update-Module -Name "MSP365" -AllowClobber -Scope CurrentUser
        }
        else {
            Write-Host "Module MSP365 is already up to date, version: $($latestVersion.Version)"
        }
        return
    }


    # Check if -ModuleName is specified and update the module
    $module = Get-Module -Name $ModuleName -ListAvailable
    if ($module) {
        $latestVersion = Find-Module -Name $ModuleName | Sort-Object -Property Version -Descending | Select-Object -First 1
        if ($latestVersion.Version -gt $module.Version) {
            Write-Host "Updating module $ModuleName to version $($latestVersion.Version)"
            Update-Module -Name $ModuleName -AllowClobber -Scope CurrentUser
        }
        else {
            Write-Host "Module $ModuleName is already up to date, version: $($module.Version)"
        }
    }
    else {
        Write-Host "Module $ModuleName is not installed"
    }

}