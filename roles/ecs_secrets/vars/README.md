Create a `main.yml` file in this folder that looks like the following:

``` yaml
---

greymatter_ro_secret:
  username: "username"
  password: "password"

jwt_secret:
  api_key: "api_key"
  private_key: "private_key"
  redis_pass: "redis_pass"

data_secret:
  jwt_pub: "jwt_pub"
  mongo_pass: "mongo_pass"
  mongo_admin_pass: "mongo_admin_pass"

slo_psql_pass: "psql_pass"

sense_oc_api_token: "oc_api_token"

```
