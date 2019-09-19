#!/usr/bin/env bash

# Define cluster for sidecar's discovered instances
greymatter create cluster < <(echo '{
  "zone_key": "default-zone",
  "cluster_key": "sidecar-slo",
  "name": "sidecar-slo",
  "circuit_breakers": {
    "max_connections": 500,
    "max_requests": 500
  }
}')

# Define rule for directing traffic to sidecar cluster
greymatter create shared_rules < <(echo '{
  "zone_key": "default-zone",
  "shared_rules_key": "to-sidecar-slo-rule",
  "name": "slo",
  "default": {
    "light": [{
      "cluster_key": "sidecar-slo",
      "weight": 1
    }]
  }
}')

# Add route #1 from edge to sidecar (no trailing slash)
greymatter create route < <(echo '{
  "zone_key": "default-zone",
  "domain_key": "edge",
  "shared_rules_key": "to-sidecar-slo-rule",
  "route_key": "sidecar-slo-route",
  "path": "/services/slo/1.0",
  "prefix_rewrite": "/services/slo/1.0/",
}')

# Add route #2 from edge to sidecar (with trailing slash)
greymatter create route < <(echo '{
  "zone_key": "default-zone",
  "domain_key": "edge",
  "shared_rules_key": "to-sidecar-slo-rule"
  "route_key": "sidecar-slo-route-slash",
  "path": "/services/slo/1.0/",
  "prefix_rewrite": "/",
}')


# Define cluster for a sidecar's service
# Note: Service is at localhost:port (same EC2)
greymatter create cluster < <(echo '{
  "zone_key": "default-zone",
  "cluster_key": "service-slo",
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
  "shared_rules_key": "slo-sidecar-to-service-rule",
  "name": "slo",
  "default": {
    "light": [{
      "cluster_key": "service-slo",
      "weight": 1
    }]
  }
}')

# Define domain for sidecar route to its service
greymatter create domain < <(echo '{
  "zone_key": "default-zone",
  "domain_key": "slo",
  "name": "*",
  "port": 9080
}')

# Define listener for downstream requests to sidecar
greymatter create listener < <(echo '{
  "zone_key": "default-zone",
  "listener_key": "slo-listener",
  "domain_keys": ["slo"],
  "name": "slo",
  "ip": "0.0.0.0",
  "port": 9080,
  "protocol": "http_auto"
}')

# Add route from sidecar to service cluster
greymatter create route < <(echo '{
  "zone_key": "default-zone",
  "domain_key": "slo",
  "shared_rules_key": "slo-sidecar-to-service-rule",
  "route_key": "service-slo-route",
  "path": "/",
}')