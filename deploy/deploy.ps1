Param (
    [Parameter(HelpMessage = "Deployment target resource group")] 
    [string] $ResourceGroupName = "rg-azure-firewall-demo",

    [Parameter(HelpMessage = "Deployment target resource group location")] 
    [string] $Location = "North Europe",

    [Parameter(HelpMessage = "Management VM username")] 
    [string] $Username = "jumpboxuser",

    [Parameter(HelpMessage = "Management VM password")] 
    [securestring] $Password,

    [string] $Template = "$PSScriptRoot\main.bicep",
    [string] $TemplateParameters = "$PSScriptRoot\azuredeploy.parameters.json"
)

$ErrorActionPreference = "Stop"

$date = (Get-Date).ToString("yyyy-MM-dd-HH-mm-ss")
$deploymentName = "Local-$date"

if ([string]::IsNullOrEmpty($env:RELEASE_DEFINITIONNAME)) {
    Write-Host (@"
Not executing inside Azure DevOps Release Management.
Make sure you have done "Login-AzAccount" and
"Select-AzSubscription -SubscriptionName name"
so that script continues to work correctly for you.
"@)
}
else {
    $deploymentName = $env:RELEASE_RELEASENAME
}

# Target deployment resource group
if ($null -eq (Get-AzResourceGroup -Name $ResourceGroupName -Location $Location -ErrorAction SilentlyContinue)) {
    Write-Warning "Resource group '$ResourceGroupName' doesn't exist and it will be created."
    New-AzResourceGroup -Name $ResourceGroupName -Location $Location -Verbose
}

# Additional parameters that we pass to the template deployment
$additionalParameters = New-Object -TypeName hashtable
$additionalParameters['username'] = $Username
$additionalParameters['password'] = $Password

$result = New-AzResourceGroupDeployment `
    -DeploymentName $deploymentName `
    -ResourceGroupName $ResourceGroupName `
    -TemplateFile $Template `
    -TemplateParameterFile $TemplateParameters `
    @additionalParameters `
    -Mode Complete -Force `
    -Verbose

$result
