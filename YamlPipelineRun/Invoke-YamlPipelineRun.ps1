function Invoke-YamlPipelineRun (
    [Parameter(Mandatory)]
    [Int]
    $PipelineId,

    [Hashtable]
    $YamlTemplateParameters = @{},

    [String]
    $FullBranchReferenceName,

    [Int]
    $TimeoutSeconds = 900,

    [Int]
    $PollingIntervalSeconds = 20,

    [PSCustomObject]
    $Context = (Get-Context)
)
{
    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    $initialRunResult = Start-YamlPipelineRun -PipelineId $PipelineId -YamlTemplateParameters $YamlTemplateParameters -FullBranchReferenceName $FullBranchReferenceName -Context $Context

    Write-Verbose -Message "Pipeline run id is '$($initialRunResult.Id)'."

    for ($timeSlept = 0; $timeSlept -lt $TimeoutSeconds; $timeSlept += $PollingIntervalSeconds)
    {
        $runResult = Get-YamlPipelineRun -PipelineId $PipelineId -RunId $initialRunResult.Id -Context $Context

        Write-Verbose -Message "Pipeline run state is '$($runResult.State)'."

        if ("completed" -eq $runResult.State)
        {
            Write-Verbose -Message "Pipeline run result is '$($runResult.Result)'."

            return $runResult
        }

        Write-Verbose -Message "Pipeline is still running. Waiting '$PollingIntervalSeconds' seconds more."

        Start-Sleep -Seconds $PollingIntervalSeconds
    }

    throw [System.TimeoutException] "The timeout provided has expired and the operation has not been completed."
}
