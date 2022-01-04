# https://docs.microsoft.com/en-us/azure/governance/resource-graph/samples/starter
Install-Module -Name Az.ResourceGraph

# Disable Ansi output
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_ansi_terminals
$PSStyle.OutputRendering = "PlainText"

Set-Location .\deploy\firewall\rulecollectiongroups\5-spoke

$queryTagVNETs = @"
Resources 
| where type =~ 'Microsoft.Network/virtualNetworks' 
| where isnotnull(tags['azfw-mapping']) 
| extend mapping = tags['azfw-mapping']
| project  subscriptionId, resourceGroup, name, mapping, location
| project-rename  Subscription = subscriptionId, ResourceGroup = resourceGroup, Name = name, Mapping = mapping, Location = location
| order by Subscription, ResourceGroup, Name
"@
$queryTagVNETs

$spokes = Search-AzGraph -Query $queryTagVNETs
$spokes | Format-Table
$spokes | Format-Table -GroupBy "Location"

"# Spokes" > spokes.md
"" >> .\spokes.md
"Generated $(Get-date)" >> spokes.md
"" >> .\spokes.md
"## ``azfw-mapping`` tagged spokes by Subscription" >> spokes.md
"" >> .\spokes.md
"``````text" >> spokes.md
$spokes | Format-Table -GroupBy "Subscription" | Out-File -FilePath spokes.md -Append
"``````" >> spokes.md
"" >> .\spokes.md
"## ``azfw-mapping`` tagged spokes by Location" >> spokes.md
"``````text" >> spokes.md
$spokes | Format-Table -GroupBy "Location" >> spokes.md
"``````" >> spokes.md
"" >> .\spokes.md

$hubVnet = Get-AzVirtualNetwork -Name "vnet-hub" -ResourceGroupName "rg-azure-firewall-demo"
$hubVnet.Id
$queryPeeredVNETs = @"
Resources
| where type =~ "microsoft.network/virtualNetworks"
| mv-expand peering=properties.virtualNetworkPeerings
| where peering.properties.remoteVirtualNetwork.id == "$($hubVnet.Id)"
| extend mapping = tags['azfw-mapping']
| project  subscriptionId, resourceGroup, name, mapping, location
| project-rename  Subscription = subscriptionId, ResourceGroup = resourceGroup, Name = name, Mapping = mapping, Location = location
| order by Subscription, ResourceGroup, Name
"@
$queryPeeredVNETs

$allSpokes = Search-AzGraph -Query $queryPeeredVNETs
$allSpokes | Format-Table
$allSpokes | Format-Table -GroupBy "Location"

"" >> .\spokes.md
"## All spokes by Subscription" >> spokes.md
"" >> .\spokes.md
"``````text" >> spokes.md
$allSpokes | Format-Table -GroupBy "Subscription" | Out-File -FilePath spokes.md -Append
"``````" >> spokes.md
"" >> .\spokes.md
"## All spokes by Location" >> spokes.md
"``````text" >> spokes.md
$allSpokes | Format-Table -GroupBy "Location" >> spokes.md
"``````" >> spokes.md
"" >> .\spokes.md
