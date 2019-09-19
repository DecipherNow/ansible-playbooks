#!/usr/bin/env bash

# Define cluster for sidecar's discovered instances
greymatter create cluster < <(echo '{
  "zone_key": "default-zone",
  "cluster_key": "sidecar-dashboard",
  "name": "sidecar-dashboard",
  "circuit_breakers": {
    "max_connections": 500,
    "max_requests": 500
  }
}')

# Define rule for directing traffic to sidecar cluster
greymatter create shared_rules < <(echo '{
  "zone_key": "default-zone",
  "shared_rules_key": "to-sidecar-dashboard-rule",
  "name": "dashboard",
  "default": {
    "light": [{
      "cluster_key": "sidecar-dashboard",
      "weight": 1
    }]
  }
}')

# Add route #1 from edge to sidecar (no trailing slash)
greymatter create route < <(echo '{
  "zone_key": "default-zone",
  "domain_key": "edge",
  "shared_rules_key": "to-sidecar-dashboard-rule",
  "route_key": "sidecar-dashboard-route",
  "path": "/services/dashboard/latest",
  "prefix_rewrite": "/services/dashboard/latest/",
}')

# Add route #2 from edge to sidecar (with trailing slash)
greymatter create route < <(echo '{
  "zone_key": "default-zone",
  "domain_key": "edge",
  "shared_rules_key": "to-sidecar-dashboard-rule"
  "route_key": "sidecar-dashboard-route-slash",
  "path": "/services/dashboard/latest/",
  "prefix_rewrite": "/",
}')


# Define cluster for a sidecar's service
# Note: Service is at localhost:port (same EC2)
greymatter create cluster < <(echo '{
  "zone_key": "default-zone",
  "cluster_key": "service-dashboard",
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
  "shared_rules_key": "dashboard-sidecar-to-service-rule",
  "name": "dashboard",
  "default": {
    "light": [{
      "cluster_key": "service-dashboard",
      "weight": 1
    }]
  }
}')

# Define domain for sidecar route to its service
greymatter create domain < <(echo '{
  "zone_key": "default-zone",
  "domain_key": "dashboard",
  "name": "*",
  "port": 9080
}')

# Define listener for downstream requests to sidecar
greymatter create listener < <(echo '{
  "zone_key": "default-zone",
  "listener_key": "dashboard-listener",
  "domain_keys": ["dashboard"],
  "name": "dashboard",
  "ip": "0.0.0.0",
  "port": 9080,
  "protocol": "http_auto"
}')

# Add route from sidecar to service cluster
greymatter create route < <(echo '{
  "zone_key": "default-zone",
  "domain_key": "dashboard",
  "shared_rules_key": "dashboard-sidecar-to-service-rule",
  "route_key": "service-dashboard-route",
  "path": "/",
}')

# Add entry to Catalog
# todo: Determine strategy for connecting to Catalog
curl -X POST catalog-host:8080/clusters -data '{
  "zoneName": "default-zone",
  "clusterName": "sidecar-dashboard",
  "name": "Grey Matter Dashboard",
  "version": "latest",
  "owner": "Decipher",
  "capability": "Grey Matter",
  "documentation": "",
  "maxInstances": 1,
  "minInstances": 1,
  "enableInstanceMetrics": true,
  "enableHistoricalMetrics": false,
  "metricsPort": 8081
}'
