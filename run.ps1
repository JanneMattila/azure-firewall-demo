##################################
#     _           _____
#    / \    ____ |  ___|_      __
#   / _ \  |_  / | |_  \ \ /\ / /
#  / ___ \  / /  |  _|  \ V  V /
# /_/   \_\/___| |_|     \_/\_/
# demo script
##################################

# Run deployment
Set-Location .\deploy\
$username = "jumpboxuser"
$plainTextPassword = (New-Guid).ToString() + (New-Guid).ToString().ToUpper()
$plainTextPassword
$password = ConvertTo-SecureString -String $plainTextPassword -AsPlainText
$resourceGroupName = "rg-azure-firewall-demo"
Measure-Command -Expression { 
    $global:result = .\deploy.ps1 `
        -Username $username `
        -Password $password `
        -ResourceGroupName $resourceGroupName
} | Format-Table

$bastion = $result.Outputs.bastionName.value
$virtualMachineResourceId = $result.Outputs.virtualMachineResourceId.value

$bastion
$virtualMachineResourceId

# Few notes about deployment:
# - Same deployment can be executed in pipeline
#   by Azure AD Service Principal
# - You can deploy this to multiple resources groups
#   - This is extremely handy since deleting also takes time
# - Initial deployment takes roughly 30 minutes
# - Incremental deployments take roughly 15 minutes

###############################
#  ____
# |  _ \  ___ _ __ ___   ___
# | | | |/ _ \ '_ ` _ \ / _ \
# | |_| |  __/ | | | | | (_) |
# |____/ \___|_| |_| |_|\___/
# script
###############################

# 1. Open VM Blade -> Connect -> Bastion
# 2. Use following credentials:
$username
$username | clip
$plainTextPassword
$plainTextPassword | clip

# Connect to a VM using Bastion and the native client on your Windows computer (Preview)
# https://docs.microsoft.com/en-us/azure/bastion/connect-native-client-windows
az login -o none
az extension add --upgrade --yes --name ssh
az network bastion ssh `
    --name $bastion `
    --resource-group $resourceGroupName `
    --target-resource-id $virtualMachineResourceId `
    --username $username `
    --auth-type password

# Now you can execute commands from our jumbox
curl http://10.1.0.4/
# -> <html><body>Hello
curl http://10.2.0.4/
# -> <html><body>Hello
curl http://10.3.0.4/
# -> <html><body>Hello

# Exit ssh (our jumpbox)
exit

# https://docs.microsoft.com/en-us/powershell/module/az.compute/get-azvmruncommand?view=azps-7.0.0
# Get-AzVMRunCommand

##################################
#   ____ _
#  / ___| | ___  __ _ _ __
# | |   | |/ _ \/ _` | '_ \
# | |___| |  __/ (_| | | | |
#  \____|_|\___|\__,_|_| |_|
# up demo resources 
##################################

Remove-AzResourceGroup -Name $resourceGroupName -Force
