#!/usr/bin/env bash

# Define cluster for sidecar's discovered instances
greymatter create cluster < <(echo '{
  "zone_key": "default-zone",
  "cluster_key": "sidecar-sense",
  "name": "sidecar-sense",
  "circuit_breakers": {
    "max_connections": 500,
    "max_requests": 500
  }
}')

# Define rule for directing traffic to sidecar cluster
greymatter create shared_rules < <(echo '{
  "zone_key": "default-zone",
  "shared_rules_key": "to-sidecar-sense-rule",
  "name": "sense",
  "default": {
    "light": [{
      "cluster_key": "sidecar-sense",
      "weight": 1
    }]
  }
}')

# Add route #1 from edge to sidecar (no trailing slash)
greymatter create route < <(echo '{
  "zone_key": "default-zone",
  "domain_key": "edge",
  "shared_rules_key": "to-sidecar-sense-rule",
  "route_key": "sidecar-sense-route",
  "path": "/services/sense/1.0",
  "prefix_rewrite": "/services/sense/1.0/",
}')

# Add route #2 from edge to sidecar (with trailing slash)
greymatter create route < <(echo '{
  "zone_key": "default-zone",
  "domain_key": "edge",
  "shared_rules_key": "to-sidecar-sense-rule"
  "route_key": "sidecar-sense-route-slash",
  "path": "/services/sense/1.0/",
  "prefix_rewrite": "/",
}')


# Define cluster for a sidecar's service
# Note: Service is at localhost:port (same EC2)
greymatter create cluster < <(echo '{
  "zone_key": "default-zone",
  "cluster_key": "service-sense",
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
  "shared_rules_key": "sense-sidecar-to-service-rule",
  "name": "sense",
  "default": {
    "light": [{
      "cluster_key": "service-sense",
      "weight": 1
    }]
  }
}')

# Define domain for sidecar route to its service
greymatter create domain < <(echo '{
  "zone_key": "default-zone",
  "domain_key": "sense",
  "name": "*",
  "port": 9080
}')

# Define listener for downstream requests to sidecar
greymatter create listener < <(echo '{
  "zone_key": "default-zone",
  "listener_key": "sense-listener",
  "domain_keys": ["sense"],
  "name": "sense",
  "ip": "0.0.0.0",
  "port": 9080,
  "protocol": "http_auto"
}')

# Add route from sidecar to service cluster
greymatter create route < <(echo '{
  "zone_key": "default-zone",
  "domain_key": "sense",
  "shared_rules_key": "sense-sidecar-to-service-rule",
  "route_key": "service-sense-route",
  "path": "/",
}')
