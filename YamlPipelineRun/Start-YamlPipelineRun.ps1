function Start-YamlPipelineRun (
    [Parameter(Mandatory)]
    [Int]
    $PipelineId,

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
