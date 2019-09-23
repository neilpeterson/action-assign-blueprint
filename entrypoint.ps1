<#
.DESCRIPTION
    Assign Azure BluePrint

.NOTES
    Intent: Sample to demonstrate Azure BluePrints with Github Actions
#>

$ErrorActionPreference = "Stop"

# Auth
$TenantId = $Env:AZURETENANTID
$ClientId = $Env:AZURECLIENTID
$ClientSecret = $Env:AZUREPASSWORD | ConvertTo-SecureString -AsPlainText -Force

# Location Details
$BlueprintLocation = $Env:INPUT_SCOPE
$BlueprintManagementGroup = $Env:INPUT_AZUREMANAGEMENTGROUPNAME
$BlueprintSubscriptionID = $Env:INPUT_AZURESUBSCRIPTIONID

$BlueprintName = $Env:INPUT_BLUEPRINTNAME
$AssignmentName = $Env:INPUT_ASSIGNMENTNAME
$AssignmentFilePath = $Env:INPUT_ASSIGNMENTFILEPATH
$Wait = $Env:INPUT_WAIT
$Timeout = $Env:INPUT_TIMEOUT
$BlueprintVersion = $Env:INPUT_BLUEPRINTVERSION

# Install Azure PowerShell modules
if (Get-Module -ListAvailable -Name Az.Accounts) {
    Write-Output "Az.Accounts module is allready installed."
 }
 else {
    Find-Module Az.Accounts | Install-Module -Force
 }

 if (Get-Module -ListAvailable -Name Az.Blueprint) {
    Write-Output "Az.Blueprint module is allready installed."
 }
 else {
    Find-Module Az.Blueprint | Install-Module -RequiredVersion 0.2.5 -Force
 }

# Set Blueprint Scope (Subscription / Management Group)
if ($BlueprintLocation -eq 'ManagementGroup') {
    $BlueprintScope = "-ManagementGroupId $BlueprintManagementGroup"
}

if ($BlueprintLocation -eq 'Subscription') {
    $BlueprintScope = "-SubscriptionId $BlueprintSubscriptionID"
}

# Connect to Azure
$creds = New-Object System.Management.Automation.PSCredential ($ClientId, $ClientSecret)
Connect-AzAccount -ServicePrincipal -Tenant $TenantId -Credential $creds -WarningAction silentlyContinue

# Get Blueprint object
if ($BlueprintVersion -eq 'latest') {
    $bluePrintObject = Invoke-Expression "Get-AzBlueprint -Name $BlueprintName $BlueprintScope"
 } else {
    $bluePrintObject = Invoke-Expression "Get-AzBlueprint -Name $BlueprintName $BlueprintScope -Version $BlueprintVersion"
 }

# Add Blueprint ID
$body = Get-Content -Raw -Path $AssignmentFilePath | ConvertFrom-Json
$body.properties.blueprintId = $bluePrintObject.id
$body | ConvertTo-Json -Depth 4 | Out-File -FilePath $AssignmentFilePath -Encoding utf8 -Force

# Create Blueprint assignment
$AssignmentObject = Get-AzBlueprintAssignment -Name $AssignmentName -erroraction 'silentlycontinue'

if ($AssignmentObject) {
    Set-AzBlueprintAssignment -Name $AssignmentName -Blueprint $bluePrintObject -AssignmentFile $AssignmentFilePath -SubscriptionId $BlueprintSubscriptionID
} else {
    New-AzBlueprintAssignment -Name $AssignmentName -Blueprint $bluePrintObject -AssignmentFile $AssignmentFilePath -SubscriptionId $BlueprintSubscriptionID
}

# Wait for assignment to complete
if ($Wait -eq "true") {
    $timeout = new-timespan -Seconds $Timeout
    $sw = [diagnostics.stopwatch]::StartNew()

    while (($sw.elapsed -lt $timeout) -and ($assignemntStatus.ProvisioningState -ne "Succeeded") -and ($assignemntStatus.ProvisioningState -ne "Failed")) {
        $assignemntStatus = Get-AzBlueprintAssignment -Name $AssignmentName -SubscriptionId $BlueprintSubscriptionID
        if ($assignemntStatus.ProvisioningState -eq "failed") {
            Throw "Assignment Failed. See Azure Portal for datails."
            break
        }
    }

    if ($assignemntStatus.ProvisioningState -ne "Succeeded") {
        Write-Warning "Assignment has timed out, activity is exiting."
    }
}