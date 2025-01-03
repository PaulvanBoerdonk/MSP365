function Connect-MSPPartner {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Scopes
    )
    try {
        Write-Host "Sign in using the Partner tenant credentials..." -ForegroundColor Yellow
        $null = Connect-MgGraph -Scopes $Scopes -NoWelcome
        Write-Host "✅ Succesfully connected to Microsoft Graph API"
        
    }
    catch {
        Write-Host "❌ Failed to connect to Microsoft Graph: $_" -ForegroundColor Red
        exit
    }
    return 
}