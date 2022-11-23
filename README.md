<!-- BEGIN_TF_DOCS -->
# Terraform AzureRM Lens

- [Purpose](#purpose)
- [Details](#details)
- [Usage](#usage)
- [Gotchas](#gotchas)
- [Inputs](#inputs)
- [Outputs](#outputs)
- [Contributing](#contributing)

## Purpose

Creates the base resources used by all LENS deployments.

## Details
- Creates a KeyVault (KV) and associated RBAC role assignments or (less preferred) access policies
- Creates a Storage Account with a Gen2 Datalake and assigned RBAC roles

## Usage

This module may be used via a module call specifying the following input variables.

```
provider "azurerm" {
  storage_use_azuread = true
}

resource "azurerm_resource_group" "example" {
  name      = "lens-example"
  location  = "eastus2"
}

module "" {
  source   = "<source-path>"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  depends_on = [
    azurerm_resource_group.example
  ]
}
```

## Gotchas
- Recommend LENS be deployed as a landing zone workload into its own Subscription following the [Enterprise Scale Landing Zone Pattern](https://github.com/Azure/Enterprise-Scale)
- Must have "Owner" permission on the LENS Resource Group (or at the Subscription level) to be able to perform RBAC role assignments. Please note that this is NOT overly privileged if following Enterprise Scale Landing Zone pattern.
- If using AzureRM provider < 3.x, be sure to enable `storage_user_azuread` to leverage MSAL authentication.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | The Azure region where the resources will be deployed. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group where modules resources will be deployed. The resource group location will be used for all resources in this module as well. | `string` | n/a | yes |
| <a name="input_datalake"></a> [datalake](#input\_datalake) | Details of Storage Account DataLake to create. Note there are two access models: 'rbac' and 'sas'. RBAC is preferred, but requires the user or service principal who is running Terraform to be assigned at minimum 'Owner' role on the Resource Group where LENS is deployed (Subscription Owner role would work as well as it would be inherited by the Resource Group). | <pre>object({<br>    name                   = string<br>    tier                   = string<br>    replication_type       = string<br>    data_retention_in_days = number<br>    containers             = list(string)<br>    access_model           = string # "rbac" or "sas"<br>    rbac_roles = map(object({<br>      object_id            = string<br>      role_definition_name = string<br>    }))<br>  })</pre> | <pre>{<br>  "access_model": "rbac",<br>  "containers": [<br>    "dropzone",<br>    "raw",<br>    "stage",<br>    "mdw"<br>  ],<br>  "data_retention_in_days": 7,<br>  "name": "lensdatalake",<br>  "rbac_roles": {},<br>  "replication_type": "LRS",<br>  "tier": "Standard"<br>}</pre> | no |
| <a name="input_key_vault"></a> [key\_vault](#input\_key\_vault) | The key vault configuration used for all LENS-related certificate and key storage. Note there are two access models: 'rbac' and 'policy'. RBAC is preferred, but requires the user or service principal who is running Terraform to be assigned at minimum 'Owner' role on the Resource Group where LENS is deployed (Subscription Owner role would work as well as it would be inherited by the Resource Group). | <pre>object({<br>    name         = string<br>    access_model = string # "rbac" or "policy"<br>    access_policies = map(object({<br>      object_id               = string<br>      certificate_permissions = list(string)<br>      key_permissions         = list(string)<br>      secret_permissions      = list(string)<br>    }))<br>    rbac_roles = map(object({<br>      object_id            = string<br>      role_definition_name = string<br>    }))<br>  })</pre> | <pre>{<br>  "access_model": "rbac",<br>  "access_policies": {},<br>  "name": "lens-kv",<br>  "rbac_roles": {}<br>}</pre> | no |
| <a name="input_rbac_propagation_await_time"></a> [rbac\_propagation\_await\_time](#input\_rbac\_propagation\_await\_time) | The time to await for RBAC role assignment propagation. Varies by region! We await RBAC propagation because the AzureRM API returns 200 for role assignments before they've propagated and gives no async way to monitor. | `string` | `"8m"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to set for all resources | `map(string)` | <pre>{<br>  "Application": "analytics",<br>  "Department": "it",<br>  "Team": "analytics"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_datalake"></a> [datalake](#output\_datalake) | Datalake resource |
| <a name="output_key_vault"></a> [key\_vault](#output\_key\_vault) | Key Vault resource |

## Contributing
### Pre-Commit Hooks

Git hook scripts are useful for identifying simple issues before submission to code review. We run our hooks on every commit to automatically point out issues in the Terraform code such as missing parentheses, and to enforce consistent Terraform styling and spacing. By pointing these issues out before code review, this allows a code reviewer to focus on the architecture of a change while not wasting time with trivial style nitpicks.

#### Pre-Commit Installation

Before you can run hooks, you need to have the pre-commit package manager installed.

Using pip:

```
pip install pre-commit
```

Non-administrative installation:

to upgrade: run again, to uninstall: pass uninstall to python
does not work on platforms without symlink support (windows)

```
curl https://pre-commit.com/install-local.py | python -
```

Afterward, `pre-commit --version` should show you what version you're using.

#### Pre-Commit Configuration

The pre-commit config for this repo may be found in `.pre-commit-config.yaml`, the contents of which takes the following form:

Run `pre-commit install` to set up the git hook scripts:

```
$ pre-commit install
pre-commit installed at .git/hooks/pre-commit
```

Now pre-commit will run automatically on git commit
<!-- END_TF_DOCS -->


#### _this README is auto-generated by [terraform-docs](https://terraform-docs.io)_