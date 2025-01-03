function New-MSPPartnerAppSecret {

    Connect-MSPPartner -Scopes "Application.ReadWrite.All"

    $partnerAppName = "MSP365 Partner App"
    
    try { 
        $existingAppsResponse = Invoke-MgGraphRequest -Method GET -Uri "/v1.0/applications?`$filter=displayName eq '$partnerAppName'" -OutputType PSObject
        $existingApps = $existingAppsResponse.value
    }
    catch {
        Write-Host "❌ Failed to get app registration: $_" -ForegroundColor Red
        exit
    }

    if (!$existingApps) {
        Write-Host "❌ No existing app found with the name $partnerAppName, run 'Register-MSPPartnerApp first" -ForegroundColor Red
        exit
    }
    else {
        $AppId = $existingApps.id
    }

    if ($existingApps.Count -gt 1) {
        Write-Host "Multiple app registrations found with the name $partnerAppName, run 'Register-MSPPartnerApp' first to create a new one" -ForegroundColor Red
        exit
    }

    # Remove existing app secret if found
    try {
        $existingAppSecretsResponse = Invoke-MgGraphRequest -Method GET -Uri "/v1.0/applications/$AppId/passwordCredentials" -OutputType PSObject -ErrorAction Stop
        $existingAppSecrets = $existingAppSecretsResponse.value
    }
    catch {
        Write-Host "❌ Failed to get existing app secrets: $($_.Exception)" -ForegroundColor Red
        exit
    }

    if ($existingAppSecrets) {
        # Ask users if they want to remove the existing app secret
        $removeExistingAppSecret = Read-Host "Existing app secret(s) was found. Do you want to remove it? (Y/N)"
        if ($removeExistingAppSecret -ne "Y" -and $removeExistingAppSecret -ne "y") {
            Write-Host "App secret creation cancelled" -ForegroundColor Yellow
            exit
        }
        foreach ($existingAppSecret in $existingAppSecrets) {
            $uri = "/v1.0/applications/$AppId/passwordCredentials/$($existingAppSecret.keyId)"
            Invoke-MgGraphRequest -Method DELETE -Uri $uri
            Write-Host "✅ Existing app secret removed"
        }
    }

    $body = @{
        passwordCredentials = @(
            @{
                displayName = $partnerAppName
            }
        )
    } | ConvertTo-Json
    
    $MSPPartnerAppSecret = (Invoke-MgGraphRequest -Method POST -Uri "/v1.0/applications/$AppId/addPassword" -Body $body -ContentType "application/json" -OutputType PSObject).SecretText

    Write-Host "✅ New app secret created: $MSPPartnerAppSecret" -ForegroundColor Green

    return $MSPPartnerAppSecret
}