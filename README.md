# Azure Firewall Demo

Azure Firewall demo

### In-Scope

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

### Infrastructure notes

To optimize costs some resource pricing tier decisions has been made:

- VPN Gateway is `Generation1` and `VpnGw1AZ`
- Jumpbox Ubuntu VM `Standard_B2s`
- Estimated cost of demo environment: `< 20 EUR, < 20 USD per work day`

## Usage

Open [run.ps1](run.ps1) to walk through steps to deploy this demo environment.


## Links

[bicep/docs/examples/301/modules-vwan-to-vnet-s2s-with-fw/](https://github.com/Azure/bicep/tree/main/docs/examples/301/modules-vwan-to-vnet-s2s-with-fw) example templates.

[Azure Firewall DevSecOps in Azure DevOps](https://aidanfinn.com/?p=22525)
is great blog post and was one inspiration to built this demo.

[Strong typing for parameters and outputs](https://github.com/Azure/bicep/issues/4158) would
further improve way how `ruleCollections` are passed on to the `ruleCollectionGroups`.
