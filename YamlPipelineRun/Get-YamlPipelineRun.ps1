function Get-YamlPipelineRun (
    [Parameter(Mandatory)]
    [Int]
    $PipelineId,

    [Nullable[Int]]
    $RunId,

    [PSCustomObject]
    $Context = (Get-Context)
)
{
    $uri = "https://dev.azure.com/$($Context.Organization)/$($Context.Project)/_apis/pipelines/$PipelineId/runs/$($RunId)?api-version=$($Context.ApiVersion)"

    Write-Verbose -Message "Performing request on '$uri'."

    $runs = Invoke-RestMethod `
        -Uri $uri `
        -Method "Get" `
        -Headers @{ "Authorization" = "Basic $($Context.Base64PrivateAccessToken)" }

    if ($null -eq $RunId)
    {
        return $runs.Value
    }
    else
    {
        return $runs
    }
}
