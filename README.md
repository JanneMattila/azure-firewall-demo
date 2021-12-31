# Azure Firewall Demo

Azure Firewall demo

### In-Scope

- Quickly deploy Azure Firewall environment
  - ~10 minutes
  - You can deploy multiple ones to separate resource groups
    - `.\deploy.ps1 -ResourceGroupName "rg-azure-firewall-demo1"`
    - `.\deploy.ps1 -ResourceGroupName "rg-azure-firewall-demo2"`
- Learn how to structure firewall rules (and rule collection groups and policies)
- Quickly test your firewall configuration with deployed helper apps
- Provide ideas, how can you split responsibilities of firewall management
  - Centralized team to manage higher level rules e.g., `common`, `vnet` and `on-premises`
  - Enable other people to participate e.g., update `spoke` specific rule
  - Normal development practices apply (pull request, code review, automated deployments, etc.)

### Out-of-Scope

- Separating solution into multiple resource groups
  - As in any normal Enterprise environment

### Infrastructure notes

To optimize costs some resource pricing tier decisions has been made:

- VPN Gateway is `Generation1` and `VpnGw1AZ`
- Estimated cost of demo environment: *nnn* EUR, *nnn* USD per day

## Deployment

```powershell
.\deploy\deploy.ps1
```

## Links

[bicep/docs/examples/301/modules-vwan-to-vnet-s2s-with-fw/](https://github.com/Azure/bicep/tree/main/docs/examples/301/modules-vwan-to-vnet-s2s-with-fw) example templates.

[Azure Firewall DevSecOps in Azure DevOps](https://aidanfinn.com/?p=22525)
is great blog post and was one inspiration to built this demo.

[Strong typing for parameters and outputs](https://github.com/Azure/bicep/issues/4158) would
further improve way how `ruleCollections` are passed on to the `ruleCollectionGroups`.
