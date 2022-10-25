<#
    .SYNOPSIS
        Add-or-update firewall rules for your current client ip address to all Azure Synapse Workspaces & SQL Servers in a provided Resourcegroup.

    .DESCRIPTION
        Automatically add-or-updates a provided ip address (or the client's current external ip address) to firewall rules of all Azure Synapse workspaces & SQL servers of the provided resource group.

    .PARAMETER tenantId
        The Azure tenant id in which your resources are located.

    .PARAMETER SubscriptionId
        The Azure subscription id in which your resources are located.

    .PARAMETER resourceGroupName
        The Azure resource group name which contains the Azure Synapse workspace(s) and Azure SQL server(s) that should be processed.

    .PARAMETER firewallRuleName
        The rule name to be added/updated. If no rule name is provided, the hostname of the current client is being used.

    .PARAMETER clientIpAddress
        The ip address (v4) for which the rule should be added/updated.
        If no ip address is provided, the external ip of the current client will be used. For this feature to work the URL https://api.ipify.org must be accessible.

    .DEPENDENCIES
        This module requires the following Az modules: Az.Accounts, Az.Synapse, Az.Sql
        See https://learn.microsoft.com/en-us/powershell/azure for more information.

    .EXAMPLE
        Add-AzFirewallRule -tenantId "xxxxxx-yyyy-zzzz-xxxx-yyyyyyyyy" -subscriptionId "xxxxxx-yyyy-zzzz-xxxx-yyyyyyyyy" -resourceGroupName "myResourceGroupName"
#>

# Exposed main module function
function Add-AzFirewallRule {
    param(
        [Parameter(Mandatory)]
        [string]$tenantId,
        [Parameter(Mandatory)]
        [string]$subscriptionId,
        [Parameter(Mandatory)]
        [string]$resourceGroupName,
        [string]$firewallRuleName,
        [string]$clientIpAddress
    )

    # Check if there is a current Azure session context for the provided tenant and subcription.
    # If no suitable context is available, logout of the current session and interactively login to the correct tenant/subscription.
    $context = Get-AzContext
    if (!$context -or $context.Tenant.Id -ne $tenantId -or $context.Subscription.Id -ne $subscriptionId) {
        Disconnect-AzAccount
        Connect-AzAccount -TenantId $tenantId -SubscriptionId $subscriptionId
    }

    # Check if an ip adress was provided. If no ip was provided use an external service to get the external ip address of the client.
    if (!$clientIpAddress) {
        $clientIpAddress = (Invoke-WebRequest -uri "https://api.ipify.org/").Content
    }

    # Use hostname of the current client, if no ruleName was provided.
    if (!$firewallRuleName) {
        $firewallRuleName = [System.Net.Dns]::GetHostName().ToUpper()
    }

    # ###################################################################
    # Loop all Synapse Workspaces of the provided Resourcegroup
    # ###################################################################
    Get-AzSynapseWorkspace -ResourceGroupName $resourceGroupName | ForEach-Object {
        # Get current Synapse Workspace name
        $workspaceName = $_.Name
        # Get all firewall rules of the current Synapse Workspace
        $synwFirewallRules = Get-AzSynapseFirewallRule -ResourceGroupName $resourceGroupName -WorkspaceName $workspaceName
        # Check if the Firewall Rule already exists
        $synwFirewallRule = $synwFirewallRules | Where-Object { $_.Name.ToUpper() -eq $firewallRuleName }
        if ($synwFirewallRule) {
            # If exists - update the firewall rule
            Write-Host "Updating Firewall Rule $firewallRuleName for Synapse-Workspace $workspaceName..."
            $ret = Update-AzSynapseFirewallRule -ResourceGroupName $resourceGroupName -WorkspaceName $workspaceName -Name $firewallRuleName -StartIpAddress $clientIpAddress -EndIpAddress $clientIpAddress
        } else {
            # If it doesn't exist yet - create the firewall rule
            Write-Host "Adding Firewall Rule $firewallRuleName for Synapse-Workspace $workspaceName..."
            $ret = New-AzSynapseFirewallRule -ResourceGroupName $resourceGroupName -WorkspaceName $workspaceName -Name $firewallRuleName -StartIpAddress $clientIpAddress -EndIpAddress $clientIpAddress
        }
        Write-Host "$workspaceName`: $($ret.StartIpAddress) added successfully to firewall rules."
    }

    # ###################################################################
    # Loop all SQL-Servers of the provided Resourcegroup
    # ##################################################################
    Get-AzSqlServer -ResourceGroupName $resourceGroupName  | ForEach-Object {
        # Get current SQL Server name
        $serverName = $_.ServerName
        # Get all firewall rules of the current SQL-Server
        $sqlServerFirewallRules = Get-AzSqlServerFirewallRule -ResourceGroupName $resourceGroupName -ServerName $serverName
        # Check if the firewall rule already exists
        $sqlServerFirewallRule = $sqlServerFirewallRules | Where-Object { $_.FirewallRuleName -eq $firewallRuleName }
        if ($sqlServerFirewallRule) {
            # If exists - update the firewall rule
            Write-Host "Updating Firewall Rule $firewallRuleName for SQL-Server $serverName..."
            # Using the Name dervied from $sqlServerFirewallRule instead of $firewallRuleName, because the parameter is case-sensitive
            $ret = Set-AzSqlServerFirewallRule -ResourceGroupName $resourceGroupName -ServerName $serverName -FirewallRuleName $($sqlServerFirewallRule.FirewallRuleName) -StartIpAddress $clientIpAddress -EndIpAddress $clientIpAddress
        } else {
            # If it doesn't exist yet - create the firewall rule
            Write-Host "Adding Firewall Rule $firewallRuleName for SQL-Server $serverName..."
            $ret = New-AzSqlServerFirewallRule -ResourceGroupName $resourceGroupName -ServerName $serverName -FirewallRuleName $firewallRuleName -StartIpAddress $clientIpAddress -EndIpAddress $clientIpAddress
        }
        Write-Host "$serverName`: $($ret.StartIpAddress) added successfully to firewall rules."
    }
}
# Export main module function
Export-ModuleMember -Function "Add-AzFirewallRule"
