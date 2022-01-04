##################################
#     _           _____
#    / \    ____ |  ___|_      __
#   / _ \  |_  / | |_  \ \ /\ / /
#  / ___ \  / /  |  _|  \ V  V /
# /_/   \_\/___| |_|     \_/\_/
# demo script
##################################

# Login to Azure
Login-AzAccount

# *Explicitly* select your working context
Select-AzSubscription -Subscription "<YourSubscriptionName>"

# Run deployment
Set-Location .\deploy\
# To understand the demo structure better, see tree of directories
tree
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

# Note: If you get deployment errors, then you can see details in either:
# - Resource Group -> Activity log
# - Resource Group -> Deployments

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
spoke1="http://10.1.0.4"
spoke2="http://10.2.0.4"
spoke3="http://10.3.0.4"
curl $spoke1
# -> <html><body>Hello
curl $spoke2
# -> <html><body>Hello
curl $spoke3
# -> <html><body>Hello

# Test outbound internet accesses
BODY=$(echo "HTTP GET \"https://github.com\"")
curl -X POST --data "$BODY" -H "Content-Type: text/plain" "$spoke1/api/commands"
curl -X POST --data "$BODY" -H "Content-Type: text/plain" "$spoke2/api/commands"
curl -X POST --data "$BODY" -H "Content-Type: text/plain" "$spoke3/api/commands"

# Test outbound vnet-to-vnet
# Spoke001
# -> Spoke002 - OK
BODY=$(echo "HTTP GET \"$spoke2\"")
curl -X POST --data "$BODY" -H "Content-Type: text/plain" "$spoke1/api/commands"
# -> Spoke003 - OK
BODY=$(echo "HTTP GET \"$spoke3\"")
curl -X POST --data "$BODY" -H "Content-Type: text/plain" "$spoke1/api/commands"

# Spoke002
# -> Spoke001 - OK
BODY=$(echo "HTTP GET \"$spoke1\"")
curl -X POST --data "$BODY" -H "Content-Type: text/plain" "$spoke2/api/commands"
# - Spoke003 - Blocked by firewall
BODY=$(echo "HTTP GET \"$spoke3\"")
curl -X POST --data "$BODY" -H "Content-Type: text/plain" "$spoke2/api/commands"

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
