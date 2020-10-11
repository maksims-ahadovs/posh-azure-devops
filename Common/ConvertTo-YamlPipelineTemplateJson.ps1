function ConvertTo-YamlPipelineTemplateJson (
    [Parameter(Mandatory)]
    [String]
    $YamlTemplate
)
{
    $escapedBackslashesTemplate = $YamlTemplate -replace "\\", "\\"
    $escapedQuotesTemplate = $escapedBackslashesTemplate -replace "`"", "\`""
    $escapedNewLinesTemplate = $escapedQuotesTemplate -replace [Environment]::NewLine, "\n"

    return $escapedNewLinesTemplate
}
