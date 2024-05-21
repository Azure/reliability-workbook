# How to use

## Example

- Deploy only Redis Cache

```
terraform plan -out tfplan -target azurerm_resource_group.example  -target azurerm_redis_cache.non_zone_redundant
```
