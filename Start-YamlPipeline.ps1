function Start-YamlPipeline (
    [Parameter(Mandatory)]
    [Int]
    $PipelineId,

    [Hashtable]
    $YamlTemplateParameters = @{},

    [String]
    $FullBranchReferenceName,

    [PSCustomObject]
    $Context = $AzureDevOpsContext
)
{
    $branchReference = if (-not [String]::IsNullOrWhiteSpace($FullBranchReferenceName)) { $FullBranchReferenceName } else { "refs/heads/master" }

    $convertedTemplateParameters = ConvertTo-Json $YamlTemplateParameters

    $requestBody = @"
{
    "resources": {
        "repositories": {
            "self": {
                "refName": "$branchReference"
            }
        }
    },
    "templateParameters": $convertedTemplateParameters
}
"@

    $uri = "https://dev.azure.com/$($Context.Organization)/$($Context.Project)/_apis/pipelines/$PipelineId/runs?api-version=$($Context.ApiVersion)"

    Write-Verbose -Message "Performing request on '$uri'."

    $run = Invoke-RestMethod `
        -Uri $uri `
        -Body $requestBody `
        -ContentType "application/json" `
        -Method "Post" `
        -Headers @{ "Authorization" = "Basic $($Context.Base64PrivateAccessToken)" }

    return $run
}