##################################
#     _           _____
#    / \    ____ |  ___|_      __
#   / _ \  |_  / | |_  \ \ /\ / /
#  / ___ \  / /  |  _|  \ V  V /
# /_/   \_\/___| |_|     \_/\_/
# demo script
##################################

# Remember to update you Azure Az PowerShell module!
# https://learn.microsoft.com/en-us/powershell/azure/install-azure-powershell?view=azps-12.3.0
Update-Module Az

# Remember to install Bicep!
# https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/install#azure-powershell
bicep --version # 0.30.3 or newer

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
$location = "swedencentral"

# Run deployment in single command
$global:result = .\deploy.ps1 -Username $username -Password $password -ResourceGroupName $resourceGroupName -Location $location

# Run deployment using multi-line command to print the deployment duration (you need to execute all lines)
Measure-Command -Expression {
    $global:result = .\deploy.ps1 `
        -Username $username `
        -Password $password `
        -ResourceGroupName $resourceGroupName `
        -Location $location
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

# Connect to a VM using Bastion and the native client on your Windows computer
# https://learn.microsoft.com/en-us/azure/bastion/connect-native-client-windows
az login -o none
az extension add --upgrade --yes --name bastion
az extension add --upgrade --yes --name ssh
az network bastion ssh `
    --name $bastion `
    --resource-group $resourceGroupName `
    --target-resource-id $virtualMachineResourceId `
    --username $username `
    --auth-type password

# Now you can execute commands from our jumpbox
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
curl -X POST --data "$BODY" "$spoke1/api/commands" # OK (via firewall)
curl -X POST --data "$BODY" "$spoke2/api/commands" # Deny
curl -X POST --data "$BODY" "$spoke3/api/commands" # OK (due to routing)

BODY=$(echo "HTTP GET \"https://www.microsoft.com\"")
curl -X POST --data "$BODY" "$spoke1/api/commands" # OK (via firewall)
curl -X POST --data "$BODY" "$spoke2/api/commands" # OK (via firewall)
curl -X POST --data "$BODY" "$spoke3/api/commands" # OK (due to routing)

BODY=$(echo "HTTP GET \"https://www.bing.com\"")
curl -X POST --data "$BODY" "$spoke1/api/commands" # OK (via firewall)
curl -X POST --data "$BODY" "$spoke2/api/commands" # Deny
curl -X POST --data "$BODY" "$spoke3/api/commands" # OK (due to routing)

BODY=$(echo "HTTP GET \"https://learn.microsoft.com\"")
curl -X POST --data "$BODY" "$spoke1/api/commands" # OK (via firewall)
curl -X POST --data "$BODY" "$spoke2/api/commands" # Deny
curl -X POST --data "$BODY" "$spoke3/api/commands" # OK (due to routing)

BODY=$(echo "HTTP GET \"https://myip.jannemattila.com\"")
curl -X POST --data "$BODY" "$spoke1/api/commands" # OK (via firewall)
curl -X POST --data "$BODY" "$spoke2/api/commands" # Deny
curl -X POST --data "$BODY" "$spoke3/api/commands" # OK (due to routing)
# Question: What IP addresses you got as responses and why?

# Test outbound vnet-to-vnet using http on port 80
# Spoke001 -> Spoke002 and Spoke001 -> Spoke003 - Both OK
curl -X POST --data  "HTTP GET \"$spoke2\"" "$spoke1/api/commands" # OK
curl -X POST --data  "HTTP GET \"$spoke3\"" "$spoke1/api/commands" # OK

# Spoke002 -> Spoke001 OK but, Spoke003 is denied by firewall
curl -X POST --data  "HTTP GET \"$spoke1\"" "$spoke2/api/commands" # OK
curl -X POST --data  "HTTP GET \"$spoke3\"" "$spoke2/api/commands" # Deny

# Spoke003 -> Spoke001 is denied by firewall
curl -X POST --data  "HTTP GET \"$spoke1\"" "$spoke3/api/commands" # Deny
# Spoke003 -> Spoke002 timeouts, because there is no route and you cannot reach the target server
curl -X POST --data  "HTTP GET \"$spoke2\"" "$spoke3/api/commands" # Timeout

# Exit ssh (our jumpbox)
exit

# https://learn.microsoft.com/en-us/powershell/module/az.compute/get-azvmruncommand?view=azps-7.0.0
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
