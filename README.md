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
Add-AzFirewallRule -tenantId "myAzureTenantId" -SubscriptionId "myAzureSubscriptionId" -resourceGroupName "myResourceGroup"
```

[^1]: Needs the Powershell console to be executed als local administrator.
