[cmdletbinding()]
param(
    [Parameter(Mandatory=$True)]
    [int64]$flexible_asset_type_id,

    [Parameter(Mandatory=$True)]
    [string]$save_folder
)

$assetData = @()
(Get-ITGlueFlexibleAssetFields -flexible_asset_type_id $flexible_asset_type_id).data.attributes | ForEach-Object {
    $assetDataTemp = [ordered]@{}
    $_.PSObject.Properties | ForEach-Object {
        if($_.Name.GetType().Name -eq 'String' -and $_.Name.Contains('-')) {
            $name = $_.Name.Replace('-','_')
        } else {
            $name = $_.Name
        }


        $assetDataTemp.Add($name, $_.Value)
    }

    $assetDataTemp.Remove('created_at')
    $assetDataTemp.Remove('updated_at')
    $assetDataTemp.Remove('flexible_asset_type_id')
    $assetDataTemp.Remove('decimals')

    $tempBody = @{
        type = 'flexible_asset_fields'
        attributes = $assetDataTemp
    }

    $assetData += $tempBody
}


$orgAsset = (Get-ITGlueFlexibleAssetTypes -id $flexible_asset_type_id).data.attributes
$data = ([ordered]@{
    type = 'flexible_asset_types'
    attributes = @{
        name = $orgAsset.name
        description = $orgAsset.description
        icon = $orgAsset.icon
        enabled = $orgAsset.enabled
    }
    relationships = @{
        flexible_asset_fields = @{
            data = @(
                $assetData
            )
        }
    }
} | ConvertTo-Json -Depth 100) `
    -replace '    '                            , ' ' `
    -replace ': '                              , ' =' `
    -replace ','                               , '' `
    -replace '\['                              , '@(' `
    -replace '\]'                              , ')' `
    -replace '"(\w+)" (=)'                     , '$1 $2' `
    -replace '(\r\n)[ ]+"[\w]+" = null'        , '' `
    -replace '\r\n[ ]+[\w]+ = null'            , '' `
    -replace '(})(\r\n[ ]+)({\r\n[ ]+ type =)' , '$1,$2@$3' `
    -replace 'false'                           , '$false' `
    -replace 'true'                            , '$true' `
    -replace ' = {'                            , ' = @{' `
    -replace '^({)(\r\n)'                      , '$data = @$1$2'`
    -replace '(data = @\(\r\n[ ]+)'            , '$1@' `
    -replace '\r\n[ ]+name_key.+'              , ''

if($save_folder.EndsWith('\')) {
    $save_folder = $save_folder.TrimEnd('\')
}

$data | Out-File -FilePath ("{0}\{1}.ps1" -f $save_folder, $orgAsset.name)