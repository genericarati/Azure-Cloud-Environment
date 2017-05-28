function New-RandomString {
    $String = $null
    $r = New-Object System.Random
    1..6 | % { $String += [char]$r.next(97,122) }
    $string
}

### Define variables

$SubscriptionName = 'Free Trial'
$Location = 'West US' ### Use "Get-AzureLocation | Where-Object Name -eq 'ResourceGroup' | Format-Table Name, LocationsString -Wrap" in ARM mode to find locations which support Resource Groups
$GroupName = 'chef-lab'
$DeploymentName = 'chef-server-deployment'
$StorageName = 'chefstorage' + (New-RandomString)
$PublicDNSName = 'chef-lab-' + (New-RandomString)
$AdminUsername = 'chef'

### Connect to Azure account

if (Get-AzureRmSubscription){
    Get-AzureRmSubscription -SubscriptionName $SubscriptionName | Select-AzureRmSubscription -Verbose
    }
    else {
    Add-AzureRmAccount
    Get-AzureRmSubscription -SubscriptionName $SubscriptionName | Select-AzureRmSubscription -Verbose
    }

Get-AzureRmResourceGroup -Name $GroupName -ev notPresent -ea 0  ### That's a zero after -ea
If ($notPresent)
{
	New-AzureRmResourceGroup -Name $GroupName -Location $Location -Verbose
}
	
$ResourceGroup = (Get-AzureRmResourceGroup -Name $GroupName).ResourceGroupName

$parameters = @{
    'newStorageAccountName'="$StorageName";
    'adminUsername'="$AdminUsername";
    'dnsNameForPublicIP'="$PublicDNSName"
    }

New-AzureRmResourceGroupDeployment `
    -Name $DeploymentName `
    -ResourceGroupName $ResourceGroup `
    -TemplateFile azuredeploy.json `
    -TemplateParameterObject $parameters `
    -Verbose
