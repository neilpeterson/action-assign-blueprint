GitHub Action to assign an Azure Blueprint.

For more information on Azure Blueprints, see the [Azure Blueprints documentation](https://docs.microsoft.com/en-us/azure/governance/blueprints/overview?WT.mc_id=blueprintsextension-github-nepeters).

## Azure Authentication

Before using these actions, create an Azure Active Directory Service Principal using the [az ad sp create-for-rbac](https://docs.microsoft.com/en-us/cli/azure/ad/sp?WT.mc_id=blueprintsextension-github-nepeters&view=azure-cli-latest) command.

Next, create three GitHub secrets hold the service principal credentials.

| Secret Name | Value |
|:---|---|
| AZURETENANTID | tenant |
| AZURECLIENTID | appId |
| AZUREPASSWORD | password |


## Assign Blueprint

```
- name: Assign Azure Blueprint
  env:
    AZURETENANTID: ${{ secrets.AZURETENANTID }}
    AZURECLIENTID: ${{ secrets.AZURECLIENTID }}
    AZUREPASSWORD: ${{ secrets.AZUREPASSWORD }}
  uses: neilpeterson/action-assign-blueprint@master
  with:
    AssignmentName: actionBlueprintPublish
    azureManagementGroupName: nepeters-internal
    blueprintName: actionBlueprintPublish
    azureSubscriptionID: 00000000-0000-0000-0000-000000000000
    AssignmentFilePath: ./assign/assign-blueprint.json
```

All configuration parameters:

| Name | Description | Required |
|:---|:---|---|
| scope | Scope at which the blueprint is stored. Valid values are `ManagamentGroup` and `Subscription`. Defaults to `ManagementGroup`. | false |
| azureManagementGroupName | The Azure Management group at which the blueprint is stored. | false |
| azureSubscriptionID | The Azure subscription at which the blueprint is stored and / or where the blueprint will be assigned. | false |
| blueprintName | The blueprint name. | true |
| assignmentName | Name for the assignment. | true |
| assignmentFilePath | The path to a JSON file containing the assignment details and parameter values. | true |
| blueprintVersion | The version of the blueprint to assign. Defaults to `latest`. | false |
| wait | Wait for assignment to complete before moving to the next task. Defaults to `false`. | false |
| timeout | Time in seconds before wait timeout'. Defaults to `240 seconds`. | false |