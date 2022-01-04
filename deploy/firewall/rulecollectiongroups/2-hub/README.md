# Spokes

These are rules specific to individual spoke virtual networks.

You can see mapping of `subscription/resource group/vnet` 
to identifiers used in firewall in [here](spokes.md).

## All spokes

- Internet access via firewall
  - `www.microsoft.com`
    - Denied in spoke003

## Spoke001

- UDR: 0.0.0.0 -> Firewall Private IP
- Internet access via firewall
  - `github.com`
  - `bing.com`
  - `docs.microsoft.com`
- VNet accesses
  - Full access to spoke002
  - Http (port 80) access to spoke003
- On-premises network access

## Spoke002

- UDR: 0.0.0.0 -> Firewall Private IP
- Internet access via firewall
  - `github.com`
- VNet accesses
  - Full access to spoke001
  - No access to spoke003
- No on-premises network access

## Spoke003

- UDR: Spoke001 address space -> Firewall Private IP
- Internet access via firewall
  - `github.com`
- VNet accesses
  - Full access to spoke001
  - No access to spoke002
- No on-premises network access
