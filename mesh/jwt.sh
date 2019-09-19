#!/usr/bin/env bash

# Define cluster for sidecar's discovered instances
greymatter create cluster < <(echo '{
  "zone_key": "default-zone",
  "cluster_key": "sidecar-jwt",
  "name": "sidecar-jwt",
  "circuit_breakers": {
    "max_connections": 500,
    "max_requests": 500
  }
}')

# Define rule for directing traffic to sidecar cluster
greymatter create shared_rules < <(echo '{
  "zone_key": "default-zone",
  "shared_rules_key": "to-sidecar-jwt-rule",
  "name": "jwt",
  "default": {
    "light": [{
      "cluster_key": "sidecar-jwt",
      "weight": 1
    }]
  }
}')

# Add route #1 from edge to sidecar (no trailing slash)
greymatter create route < <(echo '{
  "zone_key": "default-zone",
  "domain_key": "edge",
  "shared_rules_key": "to-sidecar-jwt-rule",
  "route_key": "sidecar-jwt-route",
  "path": "/services/jwt/1.0",
  "prefix_rewrite": "/services/jwt/1.0/",
}')

# Add route #2 from edge to sidecar (with trailing slash)
greymatter create route < <(echo '{
  "zone_key": "default-zone",
  "domain_key": "edge",
  "shared_rules_key": "to-sidecar-jwt-rule"
  "route_key": "sidecar-jwt-route-slash",
  "path": "/services/jwt/1.0/",
  "prefix_rewrite": "/",
}')


# Define cluster for a sidecar's service
# Note: Service is at localhost:port (same EC2)
greymatter create cluster < <(echo '{
  "zone_key": "default-zone",
  "cluster_key": "service-jwt",
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
  "shared_rules_key": "jwt-sidecar-to-service-rule",
  "name": "jwt",
  "default": {
    "light": [{
      "cluster_key": "service-jwt",
      "weight": 1
    }]
  }
}')

# Define domain for sidecar route to its service
greymatter create domain < <(echo '{
  "zone_key": "default-zone",
  "domain_key": "jwt",
  "name": "*",
  "port": 9080
}')

# Define listener for downstream requests to sidecar
greymatter create listener < <(echo '{
  "zone_key": "default-zone",
  "listener_key": "jwt-listener",
  "domain_keys": ["jwt"],
  "name": "jwt",
  "ip": "0.0.0.0",
  "port": 9080,
  "protocol": "http_auto"
}')

# Add route from sidecar to service cluster
greymatter create route < <(echo '{
  "zone_key": "default-zone",
  "domain_key": "jwt",
  "shared_rules_key": "jwt-sidecar-to-service-rule",
  "route_key": "service-jwt-route",
  "path": "/",
}')

# Add route from data's sidecar to jwt's sidecar
# Note: This is how to specify intra-mesh communication
greymatter create route < <(echo '{
  "zone_key": "default-zone",
  "domain_key": "data",
  "shared_rules_key": "to-sidecar-jwt-rule",
  "route_key": "data-to-jwt-route",
  "path": "/jwt/",
  "prefix_rewrite": "/",
}')

# Add entry to Catalog
# todo: Determine strategy for connecting to Catalog
curl -X POST catalog-host:8080/clusters -data '{
  "zoneName": "default-zone",
  "clusterName": "sidecar-jwt",
  "name": "Grey Matter JWT Security",
  "version": "1.0",
  "owner": "Decipher",
  "capability": "Grey Matter",
  "documentation": "/services/jwt/1.0/",
  "maxInstances": 1,
  "minInstances": 1,
  "enableInstanceMetrics": true,
  "enableHistoricalMetrics": false,
  "metricsPort": 8081
}'
