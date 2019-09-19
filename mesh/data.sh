#!/usr/bin/env bash

# Define cluster for sidecar's discovered instances
greymatter create cluster < <(echo '{
  "zone_key": "default-zone",
  "cluster_key": "sidecar-data",
  "name": "sidecar-data",
  "circuit_breakers": {
    "max_connections": 500,
    "max_requests": 500
  }
}')

# Define rule for directing traffic to sidecar cluster
greymatter create shared_rules < <(echo '{
  "zone_key": "default-zone",
  "shared_rules_key": "to-sidecar-data-rule",
  "name": "data",
  "default": {
    "light": [{
      "cluster_key": "sidecar-data",
      "weight": 1
    }]
  }
}')

# Add route #1 from edge to sidecar (no trailing slash)
greymatter create route < <(echo '{
  "zone_key": "default-zone",
  "domain_key": "edge",
  "shared_rules_key": "to-sidecar-data-rule",
  "route_key": "sidecar-data-route",
  "path": "/services/data/1.0",
  "prefix_rewrite": "/services/data/1.0/",
}')

# Add route #2 from edge to sidecar (with trailing slash)
greymatter create route < <(echo '{
  "zone_key": "default-zone",
  "domain_key": "edge",
  "shared_rules_key": "to-sidecar-data-rule"
  "route_key": "sidecar-data-route-slash",
  "path": "/services/data/1.0/",
  "prefix_rewrite": "/",
}')


# Define cluster for a sidecar's service
# Note: Service is at localhost:port (same EC2)
greymatter create cluster < <(echo '{
  "zone_key": "default-zone",
  "cluster_key": "service-data",
  "name": "service",
  "circuit_breakers": {
    "max_connections": 500,
    "max_requests": 500
  },
  "instances": [{
    "host": "localhost",
    "port": 8080
  }]
}')

# Define rule for directing traffic to service cluster
greymatter create shared_rules < <(echo '{
  "zone_key": "default-zone",
  "shared_rules_key": "data-sidecar-to-service-rule",
  "name": "data",
  "default": {
    "light": [{
      "cluster_key": "service-data",
      "weight": 1
    }]
  }
}')

# Define domain for sidecar route to its service
greymatter create domain < <(echo '{
  "zone_key": "default-zone",
  "domain_key": "data",
  "name": "*",
  "port": 9080
}')

# Define listener for downstream requests to sidecar
greymatter create listener < <(echo '{
  "zone_key": "default-zone",
  "listener_key": "data-listener",
  "domain_keys": ["data"],
  "name": "data",
  "ip": "0.0.0.0",
  "port": 9080,
  "protocol": "http_auto"
}')

# Add route from sidecar to service cluster
greymatter create route < <(echo '{
  "zone_key": "default-zone",
  "domain_key": "data",
  "shared_rules_key": "data-sidecar-to-service-rule",
  "route_key": "service-data-route",
  "path": "/",
}')

# Add route from catalog's sidecar to data's sidecar
# Note: This is how to specify intra-mesh communication
greymatter create route < <(echo '{
  "zone_key": "default-zone",
  "domain_key": "catalog",
  "shared_rules_key": "to-sidecar-data-rule",
  "route_key": "catalog-to-data-route",
  "path": "/data/",
  "prefix_rewrite": "/",
}')

# Add entry to Catalog
# todo: Determine strategy for connecting to Catalog
curl -X POST catalog-host:8080/clusters -data '{
  "zoneName": "default-zone",
  "clusterName": "sidecar-data",
  "name": "Grey Matter Data",
  "version": "1.0",
  "owner": "Decipher",
  "capability": "Grey Matter",
  "documentation": "/services/data/1.0/",
  "maxInstances": 1,
  "minInstances": 1,
  "enableInstanceMetrics": true,
  "enableHistoricalMetrics": false,
  "metricsPort": 8081
}'
