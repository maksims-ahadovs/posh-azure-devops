function Set-Context (
    [Parameter(Mandatory)]
    [String]
    $Organization,

    [Parameter(Mandatory)]
    [String]
    $Project,

    [Parameter(Mandatory)]
    [String]
    $PrivateAccessToken,

    [String]
    $ApiVersion = "6.0-preview"
)
{
    $variableName = "AzureDevOpsContext"

    $variableValue = [PSCustomObject]@{
        Organization = $Organization
        Project = $Project
        Base64PrivateAccessToken = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(":$PrivateAccessToken"))
        ApiVersion = $ApiVersion
    }

    if ($null -eq $AzureDevOpsContext)
    {
        Write-Verbose -Message "Creating new '$variableName' read-only context variable in the parent scope."

        New-Variable -Name $variableName -Value $variableValue -Scope 1 -Option ReadOnly
    }
    else
    {
        Write-Verbose -Message "Found existing context variable. Updating."

        Set-Variable -Name $variableName -Value $variableValue -Scope 1 -Force
    }
}
