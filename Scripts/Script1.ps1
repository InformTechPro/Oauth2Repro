#retrieve token

$azureSubscriptionId = $env:azureSubscriptionId
        if(([string]::IsNullOrEmpty($env:servicePrincipalId) -eq $false) -and ([string]::IsNullOrEmpty($env:servicePrincipalKey) -eq $true)){
            Write-Host "Workload identity enabled, using workload identity flow"
            $azureAdOauthUrl = "https://login.microsoftonline.com/$($env:idOfAzureTenant)/oauth2/v2.0/token?"
            $azureAdOauthParameters = "scope=https://management.azure.com/.default&client_id=$($env:servicePrincipalId)"
            $azureAdOauthParameters+= "&client_assertion_type=urn:ietf:params:oauth:client-assertion-type:jwt-bearer"
            $azureAdOauthParameters+= "&client_assertion=$($env:idToken)"
            $azureAdOauthParameters+= "&grant_type=client_credentials"

            $censoredParameters = $azureAdOauthParameters.Replace("&client_assertion=$($env:idToken)","&client_assertion=**********")
            Write-Host "Using the following URL to request access token: $azureAdOauthUrl"
            Write-Host "Using the following parameters to request access token: $censoredParameters"

            $azureAdOauthResponse = Invoke-RestMethod `
                -Method Post `
                -Uri "$azureAdOauthUrl" `
                -Body $azureAdOauthParameters `
                -ContentType "application/x-www-form-urlencoded"
            $accessToken = $azureAdOauthResponse.access_token

            Connect-AzAccount `
            -Tenant $env:idOfEpicorAzureTenant `
            -AccessToken $accessToken `
            -AccountId $env:servicePrincipalId

        Set-AzContext `
            -Subscription $azureSubscriptionId `
            -Tenant $env:idOfEpicorAzureTenant