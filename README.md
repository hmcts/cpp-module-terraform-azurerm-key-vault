# cpp-module-terraform-azurerm-key-vault

Terraform module for provisioning an [Azure Key Vault](https://learn.microsoft.com/en-us/azure/key-vault/general/overview).

## Example

```hcl
module "key_vault" {
  source = "git@github.com:hmcts/cpp-module-terraform-azurerm-key-vault.git?ref=v1.0.0"

  # ... see variables.tf for the full list of inputs
}
```

## Versioning

This module uses [Semantic Versioning](https://semver.org/#summary) (`MAJOR.MINOR.PATCH`),
published as Git tags of the form `vMAJOR.MINOR.PATCH` (for example `v1.0.0`).

| Segment | Increments when | Action for consumers |
|---------|-----------------|----------------------|
| MAJOR   | A backwards-incompatible change is made (renamed/removed inputs or outputs, or behaviour that forces resource replacement). | Review before upgrading; may need state changes. |
| MINOR   | New backwards-compatible functionality is added (e.g. a new optional input). | Safe to adopt. |
| PATCH   | A backwards-compatible bug fix or maintenance change is made. | Safe to adopt. |

Always pin the `?ref=` in your `source` to a released tag (e.g. `?ref=v1.0.0`)
rather than `main`, so that upgrades are deliberate.

### How releases are produced

Release automation lives in
[`.github/workflows/release.yaml`](.github/workflows/release.yaml) and uses only
the GitHub CLI (`gh`) — there are no third-party action dependencies.

- **Every merge to `main`** runs the workflow, which calculates the next version
  from the latest tag (a **patch** bump by default), creates or updates a **draft**
  GitHub Release, and prepends the change to [`CHANGELOG.md`](./CHANGELOG.md).
- **Minor or major bumps** are deliberate: run the **Release** workflow from the
  Actions tab (`workflow_dispatch`) and choose `minor` (new backwards-compatible
  input/output) or `major` (breaking change) as the bump type.
- A maintainer **publishes** the draft release, which creates the immutable
  `vX.Y.Z` Git tag that consumers pin to.

<!-- BEGIN_TF_DOCS -->


## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.72.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.5.1 |

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault.key-vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_key_vault_access_policy.access_policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_key_vault_secret.keys](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_private_endpoint.endpoint-vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [random_password.passwd](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [azurerm_private_dns_zone.dns_kv](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/private_dns_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application"></a> [application](#input\_application) | Application to which the s3 bucket relates | `string` | `""` | no |
| <a name="input_attribute"></a> [attribute](#input\_attribute) | An attribute of the s3 bucket that makes it unique | `string` | `""` | no |
| <a name="input_certificate_permissions"></a> [certificate\_permissions](#input\_certificate\_permissions) | n/a | `list(string)` | `[]` | no |
| <a name="input_costcode"></a> [costcode](#input\_costcode) | Name of theDWP PRJ number (obtained from the project portfolio in TechNow) | `string` | `""` | no |
| <a name="input_enable_data_lookup"></a> [enable\_data\_lookup](#input\_enable\_data\_lookup) | n/a | `bool` | `true` | no |
| <a name="input_enabled_for_deployment"></a> [enabled\_for\_deployment](#input\_enabled\_for\_deployment) | n/a | `bool` | `true` | no |
| <a name="input_enabled_for_disk_encryption"></a> [enabled\_for\_disk\_encryption](#input\_enabled\_for\_disk\_encryption) | n/a | `bool` | `true` | no |
| <a name="input_enabled_for_template_deployment"></a> [enabled\_for\_template\_deployment](#input\_enabled\_for\_template\_deployment) | n/a | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment into which resource is deployed | `string` | `""` | no |
| <a name="input_key-vault-name"></a> [key-vault-name](#input\_key-vault-name) | n/a | `string` | `""` | no |
| <a name="input_key_permissions"></a> [key\_permissions](#input\_key\_permissions) | n/a | `list(string)` | `[]` | no |
| <a name="input_location"></a> [location](#input\_location) | n/a | `string` | `"uksouth"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace, which could be an organization name or abbreviation, e.g. 'eg' or 'cp' | `string` | `""` | no |
| <a name="input_network_acls"></a> [network\_acls](#input\_network\_acls) | Network rules to apply to key vault. | <pre>object({<br>    bypass                     = string<br>    default_action             = string<br>    ip_rules                   = list(string)<br>    virtual_network_subnet_ids = list(string)<br>  })</pre> | `null` | no |
| <a name="input_object_id"></a> [object\_id](#input\_object\_id) | n/a | `string` | `""` | no |
| <a name="input_owner"></a> [owner](#input\_owner) | Name of the project or sqaud within the PDU which manages the resource. May be a persons name or email also | `string` | `""` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | n/a | `bool` | `true` | no |
| <a name="input_purge_protection_enabled"></a> [purge\_protection\_enabled](#input\_purge\_protection\_enabled) | n/a | `bool` | `true` | no |
| <a name="input_random_password_length"></a> [random\_password\_length](#input\_random\_password\_length) | The desired length of random password created by this module | `number` | `32` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | n/a | `string` | `""` | no |
| <a name="input_secret_permissions"></a> [secret\_permissions](#input\_secret\_permissions) | n/a | `list(string)` | `[]` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | A map of secrets for the Key Vault. | `map(string)` | `{}` | no |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | n/a | `string` | `""` | no |
| <a name="input_soft_delete_retention_days"></a> [soft\_delete\_retention\_days](#input\_soft\_delete\_retention\_days) | n/a | `number` | `1` | no |
| <a name="input_subnet_kv"></a> [subnet\_kv](#input\_subnet\_kv) | Subnet for key vault | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | n/a | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_key_vault_id"></a> [key\_vault\_id](#output\_key\_vault\_id) | The ID of the Key Vault. |
| <a name="output_key_vault_name"></a> [key\_vault\_name](#output\_key\_vault\_name) | Name of key vault created. |
| <a name="output_key_vault_uri"></a> [key\_vault\_uri](#output\_key\_vault\_uri) | The URI of the Key Vault, used for performing operations on keys and secrets. |
<!-- END_TF_DOCS -->

## Contributing

We use pre-commit hooks for validating the terraform format and maintaining the documentation automatically.
Install it with:

```shell
$ brew install pre-commit terraform-docs
$ pre-commit install
```

If you add a new hook make sure to run it against all files:
```shell
$ pre-commit run --all-files
```
