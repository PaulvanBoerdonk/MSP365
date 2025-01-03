function Register-MSPPartnerApp {
    $partnerAppName = "MSP365 Partner App"

    Connect-MSPPartner -Scopes "Application.ReadWrite.All, AppRoleAssignment.ReadWrite.All, Organization.Read.All, RoleManagement.ReadWrite.Directory"
    
    # Remove existing app registration if found

    try {
        $existingAppsResponse = Invoke-MgGraphRequest -Method GET -Uri "/v1.0/applications?`$filter=displayName eq '$partnerAppName'" -OutputType PSObject
        $existingApps = $existingAppsResponse.value
    }
    catch {
        Write-Host "❌ Failed to get existing apps: $_" -ForegroundColor Red
        exit
    }
    
    if ($existingApps) {
        # Ask users if they want to remove the existing app registration
        $removeExistingApp = Read-Host "Existing app registration(s) with the name $partnerAppName was found. Do you want to remove it? (Y/N)"
        if ($removeExistingApp -ne "Y" -and $removeExistingApp -ne "y") {
            Write-Host "Application registration cancelled" -ForegroundColor Yellow
            exit
        }
        foreach ($existingApp in $existingApps) {
            $uri = "https://graph.microsoft.com/v1.0/applications/$($existingApp.Id)"
            Invoke-MgGraphRequest -Method DELETE -Uri $uri
            Write-Host "✅ Existing app $partnerAppName : $($existingApp.Id) removed"
        }    
    }
    else {
        Write-Host "✅ No existing app found with the name $partnerAppName"
    }
    
    # This variable defines the required resource access permissions for the application registration
    # This variable defines the required resource access permissions for the application registration
    $requiredResourceAccess = @{
        resourceAppId  = "00000003-0000-0000-c000-000000000000"
        resourceAccess = @(
            @{
                id   = "7427e0e9-2fba-42fe-b0c0-848c9e6a8182" #offline_access
                type = "Scope"
            },
            @{
                id   = "37f7f235-527c-4136-accd-4a02d197296e" #openid
                type = "Scope"
            },
            @{
                id   = "14dad69e-099b-42c9-810b-d002981feec1" #profile
                type = "Scope"
            }
        )
    },
    @{
        resourceAppId  = "fa3d9a0c-3fb0-42cc-9193-47c7ecd2edbd"
        resourceAccess = @(
            @{
                id   = "1cebfa2a-fb4d-419e-b5f9-839b4383e05a" # Partner Center API User_Impersonation
                type = "Scope"
            }
        )
    }

    # Create the application using the defined variables
    $body = @{
        displayName            = $partnerAppName
        signInAudience         = "AzureADMultipleOrgs"
        requiredResourceAccess = $requiredResourceAccess
        web                    = @{
            redirectUris = @("http://localhost:8400")
        }
    } | ConvertTo-Json -Depth 10

    $app = Invoke-MgGraphRequest -Method POST -Uri 'https://graph.microsoft.com/v1.0/applications' -Body $body

    Write-Host "✅ Application $($partnerAppName) created: $($app.AppId)"
}