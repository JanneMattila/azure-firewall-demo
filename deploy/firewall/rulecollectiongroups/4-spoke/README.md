# Spokes

These are rules specific to individual spoke virtual networks.

You can see mapping of `subscription/resource group/vnet` 
to identifiers used in firewall in [here](spokes.md).

## Spoke001

- UDR: 0.0.0.0 -> Firewall Private IP
- Internet access via firewall
  - `github.com`
  - `bing.com`

## Spoke002

- UDR: 0.0.0.0 -> Firewall Private IP
- Internet access blocked in firewall

## Spoke003

- UDR: Spoke001 address space -> Firewall Private IP
- No access to Spoke002
