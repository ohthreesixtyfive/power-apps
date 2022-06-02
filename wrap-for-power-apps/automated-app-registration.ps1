###########################################################
###              install required modules               ###
###########################################################

#microsoft graph
Install-Module Microsoft.Graph -Scope CurrentUser

#microsoft power apps administration
Install-Module -Name Microsoft.PowerApps.Administration.PowerShell -Scope CurrentUser


###########################################################
###         install wrap feature in environment         ###
###########################################################

<# !-- TODO

[Retrieve application name in environment] Get Environment Application Package: https://docs.microsoft.com/en-us/rest/api/power-platform/appmanagement/applications/get-environment-application-package

[Check if already installed] Get Application Package Install Status: https://docs.microsoft.com/en-us/rest/api/power-platform/appmanagement/applications/get-application-package-install-status

[Install if not already installed] Install Application Package: https://docs.microsoft.com/en-us/rest/api/power-platform/appmanagement/applications/install-application-package

TODO --! #>


###########################################################
###       generate key and retrieve signature hash      ###
###########################################################

Write-Host "Initializing variables..." -ForegroundColor "Cyan"

#request input for key alias
$keyAlias = Read-Host "Provide an alias for the key (eg: 'hellowrap')"

#request input for keystore path
$keystorePath = Read-Host "Provide an path/name for the keystore (eg: 'hellowrap.keystore')"

#request input for key password
$keyPassword = Read-Host "Provide a password for the key (eg: 'hellopassword')"

#request inputs for key distinguished name
$keyDistinguishedNameAttributes = [ordered]@{
    cn= Read-Host "Key owner common name (eg: 'Nate Flightless') [Optional]"
    ou= Read-Host "Key organizational unit (eg: 'Operations') [Optional]"
    o= Read-Host "Key organization (eg: 'Contoso') [Optional]"
    l= Read-Host "Key locality (eg: 'Redmond') [Optional]"
    st= Read-Host "Key state code (eg: 'WA') [Optional]"
    c= Read-Host "Key country code (eg: 'US') [Optional]"
}

#for each non-blank distinguished name attribute
ForEach ($keyDistinguishedNameAttribute in $keyDistinguishedNameAttributes.getEnumerator().where({$_.Value -ne ""})) {
    #append attribute to distinguished name string
    $keyDistinguishedName += "$($keyDistinguishedNameAttribute.Key)=$($keyDistinguishedNameAttribute.Value),"
}

#trim trailing comma on key distinguished name string
$keyDistinguishedName = $keyDistinguishedName.Substring(0,$keyDistinguishedName.Length-1)

Write-Host "Generating key..." -ForegroundColor "Yellow"

#generate key/keystore file
keytool -genkey -alias $keyAlias -keystore $keystorePath -keypass $keyPassword -storepass $keyPassword -keyalg RSA -keysize 2048 -validity 10000 -storetype PKCS12 -dname $keyDistinguishedName -noprompt 2>out-null
Write-Host "Key generated successfully" -ForegroundColor "Green"


Write-Host "Retrieving SHA-1 key fingerprint..." -ForegroundColor "Yellow"

#retrieve generated key
$signature = keytool -list -v -alias $keyAlias -keystore $keystorePath -storepass $keyPassword

#extract SHA1 fingerprint
$signatureSHA1 = ($signature | Where{$_ -match "SHA1: "}).Replace("SHA1: ", "") -replace "\W"

Write-Host "Converting to base64..." -ForegroundColor "Yellow"

#convert all hex-digit pairs in the signatureSHA1 fingerprint to an array of bytes
$bytes = [byte[]] -split ($signatureSHA1 -replace '..', '0x$& ')

#get the base64 encoding of the signatureSHA1 fingerprint
$signatureHash = [System.Convert]::ToBase64String($bytes)

Write-Host "Generated signature hash: $signatureHash"


###########################################################
###           create app registration in azure          ###
###########################################################

#request signature hash if it is empty
if ($signatureHash = "") {
    $signatureHash = Read-Host "Signature hash from the previously generated key"
}

$azureTenantId = Read-Host "Provide the tenant id to create the app registration in (eg: 'c6a1edf9-0185-4d26-a408-d3662176a19f')"
$androidAppPackageName = Read-Host "Provide an app package name (eg: 'com.wrap.hello')"
$androidAppDisplayName= Read-Host "Provide an app display name (eg: 'Hello Wrap')"

#initialize redirect uri
$redirectUri = @{
    redirectUris = @(
        "msauth://$androidAppPackageName/$signatureHash"
    )
}

#initialize required api permissions
$requiredResourceAccess = @(
    @{
        resourceAppId = "00000007-0000-0000-c000-000000000000" <# Dynamics CRM #>
        resourceAccess = @(
        @{
            Id = "78ce3f0f-a1ce-49c2-8cde-64b5c0896db4" <# Dynamics CRM => user_impersonation #>
            Type = "Scope"
        })
    }
    @{
        resourceAppId = "fe053c5f-3692-4f14-aef2-ee34fc081cae" <# Azure API Connections #>
        resourceAccess = @(
        @{
            Id = "6c3012bf-22c1-4bb5-959b-dff738314144" <# Azure API Connections => Runtime.All #>
            Type = "Scope"
        })
    }
    @{
        resourceAppId = "475226c6-020e-4fb2-8a90-7a972cbfc1d4" <# PowerAppsService #>
        resourceAccess = @(
        @{
            Id = "0eb56b90-a7b5-43b5-9402-8137a8083e90" <# PowerAppsService => User #>
            Type = "Scope"
        })
    }
)


Write-Host "Requesting login to establish connection to Microsoft Graph..." -ForegroundColor "Cyan"

#establish connection to microsoft graph
Connect-MgGraph -TenantId $azureTenantId -Scopes "Application.ReadWrite.All"

Write-Host "Registering new application..." -ForegroundColor Yellow
#register the application in azure
$appRegistration = New-MgApplication -DisplayName $androidAppDisplayName -SignInAudience "AzureADMyOrg" -PublicClient $redirectUri -RequiredResourceAccess $requiredResourceAccess

Write-Host ("New App Registration Id: " + $appRegistration.appId)
Write-Host ("Display Name: " + $appRegistration.displayName)
Write-Host ("Redirect Uri: " + $redirectUri)
Write-Host ("Application Url: https://portal.azure.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Overview/appId/" + $appRegistration.appId)


###########################################################
###         enable application in power platform        ###
###########################################################

Write-Host "Requesting login to establish connection to Power Platform Admin Center..." -ForegroundColor "Cyan"
Write-Host "Enabling new application..." -ForegroundColor Yellow

Add-AdminAllowedThirdPartyApps -ApplicationId $appRegistration.appId
