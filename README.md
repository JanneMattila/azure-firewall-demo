# Azure Firewall Demo

Azure Firewall demo enables you quickly deploy following environment:

![Azure Firewall Demo architecture](https://user-images.githubusercontent.com/2357647/148061479-7626496e-4bbe-4974-ad36-c3df54fb1eda.png)

### In-Scope of demo

- Quickly deploy Azure Firewall environment
  - Initial deployment ~30-40 minutes and incremental deployments ~15-20 minutes 
  - You can deploy multiple ones to separate resource groups
    - `.\deploy.ps1 -ResourceGroupName "rg-azure-firewall-demo1"`
    - `.\deploy.ps1 -ResourceGroupName "rg-azure-firewall-demo2"`
- Learn how to structure firewall rules (and rule collection groups and policies)
- Quickly test your firewall configuration with deployed helper apps
- Provide ideas, how can you split responsibilities of firewall management
  - Centralized team to manage higher level rules e.g., `Common`, `VNET` and `On-premises`
  - Enable other people to participate e.g., update `Spoke-specific` rules
  - Normal development practices apply (pull request, code review, automated deployments, etc.)
    - Configuration is stored in git and deployed using service principal
    - End users don't need to have `Contributor` access to actual Azure Firewall resource

### Out-of-Scope

- Separating solution into multiple resource groups
  - As in any normal Enterprise environment
- On-premises connectivity deployment

### Infrastructure notes

To optimize costs some resource pricing tier decisions has been made:

- VPN Gateway is `Generation1` and `VpnGw1AZ`
- Jumpbox Ubuntu VM `Standard_B2s`
- Estimated cost of demo environment: `< 20 EUR, < 20 USD per work day`

### Implementation walk through

Azure infrastructure resources have been divided into following feature folders:

```
.
├───firewall
│   └───rulecollectiongroups
│       ├───1-common
│       ├───2-hub
│       ├───3-vnet
│       ├───4-on-premises
│       └───5-spoke
└───infrastructure
    ├───hub
    └───spoke
```

`infrastructure` folder contains deployment of virtual networks, subnets, virtual network peering,
route tables, network security groups and sample test workload.

`firewall` folder contains deployment of Azure firewall. 

`rulecollectiongroups` folder contains split of different firewall rules so that they would
be easier to manage:

- `1-common` contains common critical rules, such as Windows Update etc.
- `2-hub` contains all `hub` specific rules
- `3-vnet` contains `vnet-to-vnet` and `vnet-to-internet` rules 
- `4-on-premises` contains rules specific to on-premises network connectivity
- `5-spoke` contains rules that you need to implement as spoke specific

Centralized firewall team would maintain these rules:

- `1-common`
- `2-hub`
- `3-vnet`
- `4-on-premises`

Spoke teams can request firewall team to implement or they can 
implement their required changes under this path:

- `5-spoke`

**Note:** It does not matter who changes the rules, pull request, code review and deployment automation still applies.
No rule maintenance in portal should be done.

**Note:** Spoke subnets have Network Security Groups (NSGs) deployed with `Allow` rule.
You can also change them to test different scenarios.

In order to test firewall setup, all spokes have [webapp-network-tester](https://github.com/JanneMattila/webapp-network-tester) deployed.
It enables you to execute paths of `HTTP GET` or `HTTP POST` requests (and other commands as well).
Example: Post command to `spoke001` to then further post command to `spoke002`.
Using this method you can test if your rules work as expected.

Here is diagram that illustrates the testing flow using `webapp-network-tester` in our demo architecture:

![Request flow in our architecture](https://user-images.githubusercontent.com/2357647/148060299-9fb70956-cf56-46e4-a389-a36ff87b9b13.png)

### Implemented firewall rules

#### All spoke networks

- Internet access via firewall
  - `www.microsoft.com` is allowed
    - Note: This is overridden in spoke003 to be denied

#### Spoke001

- All traffic is routed to firewall
- Internet access via firewall
  - `github.com`
  - `bing.com`
  - `docs.microsoft.com`
- VNet accesses
  - Full access to spoke002
  - Http (port 80) access to spoke003
- On-premises network access

#### Spoke002

- All traffic is routed to firewall
- Internet access via firewall
  - `github.com`
- VNet accesses
  - Full access to spoke001
  - No access to spoke003
- No on-premises network access

#### Spoke003

- Traffic targeted to spoke001 address space is routed to firewall
- Internet access via direct routing to internet
  - `github.com`
- No VNet network accesses
  - No allow firewall rules defined
- No on-premises network access

## Usage

1. Clone this repository to your own machine.
  - If you decide to download this as zip instead, then remember to `Unblock file` before extracting the content. 
    Otherwise you might get `Run only scripts that you trust. While scripts from the internet can be useful,this script can potentially harm your computer. If you trust this script, use the Unblock-File cmdlet to allow the script to run without this warning message` error. See also [Unblock-File](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/unblock-file) for more details.
2. Update Azure `Az` PowerShell module ([instructions](https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-7.0.0))
3. Install [Bicep](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/install#azure-powershell)
4. Open [run.ps1](run.ps1) to walk through steps to deploy this demo environment
  - Execute different script steps one-by-one (hint: use [shift-enter](https://github.com/JanneMattila/some-questions-and-some-answers/blob/master/q%26a/vs_code.md#automation-tip-shift-enter))

## Try it yourself

Here are few tasks that you can try yourself:

#### Deploy new spoke network

<details>
<summary>Hint to get you started...</summary>

Open `infrastructure/deploy.bicep` and look for `spokes` array and
see how it's used.

</details>

#### Allow access to `www.linkedin.com` from `spoke001`

<details>
<summary>Hint to get you started...</summary>

Open `firewall/3-vnet/deploy.bicep` and look for `Allow-VNET-To-Internet-Application-Rules`
rule collection. It already contains rule for `github.com` as example.

</details>

#### Find firewall logs

- ACI communicating with `wwww.bing.com` running inside `spoke001` vnet

<details>
<summary>Hint to get you started...</summary>

Use IP address of ACI `10.1.0.4` and then target address in your `AzureDiagnostics` query.

</details>

<details>
<summary>Solution</summary>

Here is example query:

```sql
AzureDiagnostics 
| where Category <> "AzureFirewallDnsProxy"
| where OperationName == "AzureFirewallApplicationRuleLog"
| where msg_s contains "www.bing.com:443." and msg_s contains "10.1.0.4"
| project TimeGenerated, msg_s
```

</details>


## Improvement ideas

- Look up (at least some) network IP ranges e.g., spoke vnet address spaces 
  and pass them to firewall deployment as parameters
  - You wouldn't need to use hardcoded IP addresses

## Links

[bicep/docs/examples/301/modules-vwan-to-vnet-s2s-with-fw/](https://github.com/Azure/bicep/tree/main/docs/examples/301/modules-vwan-to-vnet-s2s-with-fw) example templates.

[Azure Firewall DevSecOps in Azure DevOps](https://aidanfinn.com/?p=22525)
is great blog post and was one inspiration to built this demo.

[Strong typing for parameters and outputs](https://github.com/Azure/bicep/issues/4158) would
further improve way how `ruleCollections` are passed on to the `ruleCollectionGroups`.

[Virtual network traffic routing](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-udr-overview)
