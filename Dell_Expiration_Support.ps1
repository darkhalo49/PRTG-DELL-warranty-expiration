# ___ ___ _____ ___
#| _ \ _ \_   _/ __|
#|  _/   / | || (_ |
#|_| |_|_\ |_| \___|
#    NETWORK MONITOR
#
#-------------------
# Name             Dell_Expiration_Support.ps1
# Description      This sensor will show the remaining days before a DELL device warranty expires
#
#-------------------
# Requirements
#
# - Needs an API ID and Secret string from Dell TechDirect
#
#-------------------
# Parameters
#
# Only the DELL service tag must be passed to the script in the PRTG sensor configuration settings  
# The service tag is a 7 alphanumeric character code stick on your dell hardware which is used by Dell to access information
# about your device's specific tech specs and warranty
#
#-------------------
# Version History
# 
# Version  Date        Notes
# 0.1      01/07/2020  First draft
# 1.0      09/12/2020  Initial Release
#
# ------------------
# (c) 2020 Maxime DUPUIS
# ------------------

# Script parameters
Param (
    [string]$tag
)

# Check for required parameters
if (-not $tag) {
                return @"
<prtg>
  <error>1</error>
  <text>Required parameter not specified: please provide a dell service tag </text>
</prtg>
"@
}

# Script variables required
$proxy = 'XXXXXXXXXXXXXXXXXXXXXXXX'
$dell_api_id = 'XXXXXXXXXXXXXXXXXXXXXXXX'
$dell_api_secret = 'XXXXXXXXXXXXXXXXXXXXXXXX'
$access_token_endpoint_url = 'https://apigtwb2c.us.dell.com/auth/oauth/v2/token'
$api_url = "https://apigtwb2c.us.dell.com/PROD/sbil/eapi/v5/asset-entitlements"

# Variables for sensor settings
$channel_name = 'Remaining Support Days'
$custom_unit = 'Days'
$limit_min_error = '30'
$limit_min_warning = '75'
$limit_warning_msg = 'Less than 75 days remaining !'
$limit_error_msg = 'Less than 30 days remaining !'

# If your remote probe is behind a proxy
[system.net.webrequest]::defaultwebproxy = new-object system.net.webproxy($proxy)
[system.net.webrequest]::defaultwebproxy.credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
[system.net.webrequest]::defaultwebproxy.BypassProxyOnLocal = $true

# Fix the error message "Invoke-RestMethod : The request was aborted: Could not create SSL/TLS secure channel."
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls, [Net.SecurityProtocolType]::Tls11, [Net.SecurityProtocolType]::Tls12, [Net.SecurityProtocolType]::Ssl3
[Net.ServicePointManager]::SecurityProtocol = "Tls, Tls11, Tls12, Ssl3"

# Get Access Token - expires in 3600 seconds
$requestBody = @{
grant_type = "client_credentials"
client_id = $dell_api_id
client_secret = $dell_api_secret
}
$authResponse = Invoke-RestMethod -Method Post -Uri $access_token_endpoint_url -Body $requestBody -ContentType "application/x-www-form-urlencoded"
$token = $authResponse.access_token

# GET API query 
$headers = @{"Authorization" = "Bearer $token" }
$body = @{
    servicetags = $tag
}
$json = Invoke-RestMethod -URI $api_url -Method GET -contenttype 'Application/json' -Headers $headers -body $body

# Get the warranty expiration date
$endsupport = $json.entitlements.endDate | Sort-Object -Descending | Select-Object -First 1

# Get the current date and time
$today = Get-Date

# Get the time interval between today's date and the warranty expiration date
$timespan = (New-TimeSpan -Start $today -End $endsupport).Days

# Create results table for PRTG EXE/Script Advanced Sensor to process
Write-Host
"<prtg>"
    "<result>"
        "<channel>$channel_name</channel>"
        "<CustomUnit>$custom_unit</CustomUnit>"
        "<mode>Absolute</mode>"
        "<showChart>1</showChart>"
        "<showTable>1</showTable>"
        "<warning>0</warning>"
        "<float>1</float>"
        "<value>$timespan</value>"
        "<LimitMinError>$limit_min_error</LimitMinError>"
        "<LimitMinWarning>$limit_min_warning</LimitMinWarning>"
        "<LimitWarningMsg>$limit_warning_msg</LimitWarningMsg>"
        "<LimitErrorMsg>$limit_error_msg</LimitErrorMsg>"
        "<LimitMode>1</LimitMode>"
     "</result>"
"</prtg>"
