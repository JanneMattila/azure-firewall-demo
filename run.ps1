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
    $script::$result = .\deploy.ps1 `
        -Username $username `
        -Password $password `
        -ResourceGroupName $resourceGroupName
} | Format-Table

# Few notes about deployment:
# - Same deployment can be executed in pipeline
#   by Azure AD Service Principal
# - You can deploy this to multiple resources groups
#   - This is extremely handy since deleting also takes time
# - Deployment takes roughly nn minutes
#

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

# TBD:
# https://docs.microsoft.com/en-us/azure/bastion/connect-native-client-windows
az network bastion ssh `
    --name $result.outputs.bastionName `
    --resource-group $resourceGroupName `
    --target-resource-id $result.outputs.virtualMachineResourceId `
    --username $username `
    --auth-type $plainTextPassword
 
# https://docs.microsoft.com/en-us/powershell/module/az.compute/get-azvmruncommand?view=azps-7.0.0
# Get-AzVMRunCommand
curl http://10.1.0.4/
curl http://10.2.0.4/
curl http://10.3.0.4/

##################################
#  ____  _
# |  _ \| | __ _ _   _
# | |_) | |/ _` | | | |
# |  __/| | (_| | |_| |
# |_|   |_|\__,_|\__, |
#                |___/
# with our setup
##################################

# To be added

##################################
#   ____ _
#  / ___| | ___  __ _ _ __
# | |   | |/ _ \/ _` | '_ \
# | |___| |  __/ (_| | | | |
#  \____|_|\___|\__,_|_| |_|
# up demo resources 
##################################

Remove-AzResourceGroup -Name $resourceGroupName -Force
