# https://docs.microsoft.com/en-us/azure/governance/resource-graph/samples/starter
Install-Module -Name Az.ResourceGraph

$query = @"
Resources 
| where type =~ 'Microsoft.Network/virtualNetworks' 
| where isnotnull(tags['azfw-mapping']) 
| extend mapping = tags['azfw-mapping']
| project  subscriptionId, resourceGroup, name, mapping, location
| project-rename  Subscription = subscriptionId, ResourceGroup = resourceGroup, Name = name, Mapping = mapping, Location = location
| order by Subscription, ResourceGroup, Name
"@
$query

$spokes = Search-AzGraph -Query $query
$spokes | Format-Table
$spokes | Format-Table -GroupBy "Location"

"# Spokes" > spokes.md
"Generated $(Get-date)" >> spokes.md

"## Spokes by Subscription" >> spokes.md
"``````powershell" >> spokes.md
$spokes | Format-Table -GroupBy "Subscription" >> spokes.md
"``````" >> spokes.md

"## Spokes by Location" >> spokes.md
"``````powershell" >> spokes.md
$spokes | Format-Table -GroupBy "Location" >> spokes.md
"``````" >> spokes.md

