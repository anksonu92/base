
# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [1.4.0] - 2022-11-08

### Changed
- Changed terraform version from `">= 0.14.8"` to `~> 1.1`


### Removed 
- Removed `random_integer` resource & provider
- Removed optional `enabled` property and associated `count` properties





## [1.3.0] - 2022-08-02
### Added
- expose `location` variable instead of using data lookup based on `resource_group_name`
- `rbac_propagation_await_time` variable allows you to override the default await time for rbac propagation, which is 8 minutes.

### Changed
- all resource `location` properties now set via `var.location` as the `data.azurerm_resource_group.module.location` lookup was causing unintended resource replacement due to location being unknown
- all `time_sleep` resources now leverage `var.rbac_propagation_await_time` for their `create_duration` property

### Removed
- `data.azurerm_resource_group.module` has been removed

## [1.2.3] - 2022-07-18
### ADDED

### Changed
- Increased  azurerm module constraints from "~>" 2.0 to  “~> 3.9”

- Increase sleep time on datalake & key vault rbac propagation from 5m to 8m to increase consistency of initial deploy.



### Removed
- Removed allow_blob_public_access from the azurerm_storage_account


### Buged
- During the inital deployment  permission propagation timing error & working fine during the next  deployment

## [1.2.1] - 2022-03-29
### Added
- User managed identity for customer managed encryption keys
### Changed
- Increase sleep time on datalake rbac propagation from 2m to 5m to increase consistency of initial deploy
- Configure datalake to use customer managed encryption key with user managed identity instead of system assigned identity to fix error on destroy due to missing `customer_managed_key` block on storage account after initial deploy

## [1.2.0] - 2022-03-15
### Changed
- `datalake` and `key_vault` outputs now output _only_ the needed properties instead of _all_ properties
- Fixed explicit dependencies to allow rbac propagation on datalake before container creation
- Decreased rbac propagation await time on datalake to 2 minutes

## [1.1.0] - 2022-03-14
### Added
- Support for RBAC on Key Vault
- Support for RBAC on Datalake (Storage Account)
- Stubbed out support for (legacy) Key Vault Access Policies
- Initial validation rules for `datalake` and `key_vault` variables
- Key Vault and Storage Account names now append a random string of up to 4 integers to help ensure uniqueness across multiple applies/destroys
- Encrypt Datalake (Storage Account) using a customer-managed key (CMK) stored in KV per best-practice
- Add `time_sleep` blocks to await RBAC role assignment propagation because the API returns 200 before they've propagated
- Implicit RBAC policies on KV and SA to enable the current principal to own the deployment
### Changed
- Change `rg_name` variable to `resource_group_name`
- Change `key_vault` input object and renamed `storage_account` to `datalake` and made object changes
- Updated basic test, renamed `kv` test to `rbac` and updated
### Removed
- Requirement for AzureAD provider within the module

## [1.0.0] - 2022-03-07
### Added
- Initial module
- Added `tests/` directory for unit tests
- Added pre-commit hooks to leverage terraform-docs for documentation (see README)
