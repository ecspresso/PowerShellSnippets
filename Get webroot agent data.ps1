$g = Show-WebrootGSMKey

New-WebrootAccessToken

$headers = @{'Authorization' = ('Bearer {0}' -f (Show-WebrootAccessToken))}

$url = 'https://unityapi.webrootcloudav.com'

$sites = Invoke-RestMethod -URI ($url+"/service/api/console/gsm/$g/sites") -Headers $headers
$data = @()
foreach($site in ($sites.sites | ? Deactivated -eq $false)) {
    $endpoints = Invoke-RestMethod -URI ($url+"/service/api/console/gsm/$g/sites/$($site.SiteId)/endpoints") -Headers $headers
    
    foreach($ep in $endpoints.Endpoints) {
        $data += [PSCustomObject]@{
            SiteName = $site.SiteName
            HostName = $ep.HostName
            LastSeen = $ep.LastSeen
            GroupName = $ep.GroupName
            Deactivated = $ep.Deactivated
        }
    }
}

$data | ft