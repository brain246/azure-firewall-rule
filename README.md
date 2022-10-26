# Add-AzFirewallRule

## Description

This Powershell module adds-or-updates firewall rules for your current client ip-address to all Azure Synapse Workspaces & SQL Servers located in the provided Resourcegroup.

## Installation

### Dependencies
- Az.Accounts
- Az.Synapse
- Az.Sql

### Elevated[^1] installation for all users

```powershell
Install-Module -Name Add-AzFirewallRule
```

### Installation for the current user only (no admin rights)

```powershell
Install-Module -Name Add-AzFirewallRule -Scope CurrentUser
```

## Usage

```powershell
# Provide specific tenant/subscription
Add-AzFirewallRule -tenantId "myAzureTenantId" -SubscriptionId "myAzureSubscriptionId" -resourceGroupName "myResourceGroup"
# Or use tenant and subscription of your current context
Add-AzFirewallRule -tenantId $((Get-AzContext).Tenant.Id) -SubscriptionId $((Get-AzContext).Subscription.Id) -resourceGroupName "myResourceGroup" 
```

## Pipeline Status

[![.github/workflows/main.yml](https://github.com/brain246/Add-AzFirewallRule/actions/workflows/main.yml/badge.svg)](https://github.com/brain246/Add-AzFirewallRule/actions/workflows/main.yml)

## Resources
[Powershell Gallery](https://www.powershellgallery.com/packages/Add-AzFirewallRule)

[^1]: Needs the Powershell console to be executed als local administrator.
