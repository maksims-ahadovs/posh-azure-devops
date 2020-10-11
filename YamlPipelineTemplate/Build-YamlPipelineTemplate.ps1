function Build-YamlPipelineTemplate (
    [Parameter(Mandatory)]
    [Int]
    $PipelineId,

    [Parameter(Mandatory)]
    [String]
    $YamlTemplate,

    [Hashtable]
    $YamlTemplateParameters = @{},

    [String]
    $FullBranchReferenceName,

    [PSCustomObject]
    $Context = (Get-Context)
)
{
    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    $branchReference = if (-not [String]::IsNullOrWhiteSpace($FullBranchReferenceName)) { $FullBranchReferenceName } else { "refs/heads/master" }

    $convertedTemplateParameters = ConvertTo-YamlPipelineParameterJson -YamlTemplateParameters $YamlTemplateParameters

    $convertedTemplate = ConvertTo-YamlPipelineTemplateJson -YamlTemplate $YamlTemplate

    $requestBody = @"
{
    "resources": {
        "repositories": {
            "self": {
                "refName": "$branchReference"
            }
        }
    },
    "templateParameters": $convertedTemplateParameters,
    "previewRun": true,
    "yamlOverride": "$convertedTemplate"
}
"@

    Write-Debug -Message "Request's body is $requestBody"

    $uri = "https://dev.azure.com/$($Context.Organization)/$($Context.Project)/_apis/pipelines/$PipelineId/runs?api-version=$($Context.ApiVersion)"

    Write-Verbose -Message "Performing request on '$uri'."

    $result = Invoke-RestMethod `
        -Uri $uri `
        -Body $requestBody `
        -ContentType "application/json" `
        -Method "Post" `
        -Headers @{ "Authorization" = "Basic $($Context.Base64PrivateAccessToken)" }

    return $result
}
