function ConvertTo-YamlPipelineParameterJson (
    [Parameter(Mandatory)]
    [Hashtable]
    $YamlTemplateParameters
)
{
    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    $convertedTemplateParameters = @{}

    foreach ($parameter in $YamlTemplateParameters.GetEnumerator())
    {
        if ($parameter.Value -is [String])
        {
            $convertedTemplateParameters[$parameter.Key] = $parameter.Value
        }
        else
        {
            $convertedTemplateParameters[$parameter.Key] = ConvertTo-Json -InputObject $parameter.Value -Compress
        }
    }

    $jsonTemplateParameters = ConvertTo-Json $convertedTemplateParameters

    return $jsonTemplateParameters
}
