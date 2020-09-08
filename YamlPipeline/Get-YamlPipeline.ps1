function Get-YamlPipeline (
    [Nullable[Int]]
    $PipelineId,

    [PSCustomObject]
    $Context = (Get-Context)
)
{
    $uri = "https://dev.azure.com/$($Context.Organization)/$($Context.Project)/_apis/pipelines/$($PipelineId)?api-version=$($Context.ApiVersion)"

    Write-Verbose -Message "Performing request on '$uri'."

    $pipelines = Invoke-RestMethod `
        -Uri $uri `
        -Method "Get" `
        -Headers @{ "Authorization" = "Basic $($Context.Base64PrivateAccessToken)" }

    if ($null -eq $PipelineId)
    {
        return $pipelines.Value
    }
    else
    {
        return $pipelines
    }
}
