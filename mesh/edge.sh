#!/usr/bin/env bash

# Define cluster for edge proxy
greymatter create cluster < <(echo '{
  "zone_key": "default-zone",
  "cluster_key": "edge",
  "name": "edge",
  "circuit_breakers": {
    "max_connections": 500,
    "max_requests": 500
  }
}')

# Define domain for edge routes to sidecars
greymatter create domain < <(echo '{
  "zone_key": "default-zone",
  "domain_key": "edge",
  "name": "greymatter-ecs.development.deciphernow.com",
  "port": 80,
  "ssl_config": {
    "cipher_filter": "EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH",
    "protocols": ["SSLv3", "SSLv2", "TLSv1", "TLSv1.1", "TLSv1.2"],
    "require_client_certs": true,
    "trust_file": "/app/certs/ca.crt",
    "cert_key_pairs": [
        {
            "certificate_path": "/app/certs/wildcard.development.deciphernow.com.crt",
            "key_path": "/app/certs/wildcard.development.deciphernow.com.key"
        }
    ]
  }
}')

# Define listener for downstream requests to edge
greymatter create listener < <(echo '{
  "zone_key": "default-zone",
  "listener_key": "edge-listener",
  "domain_keys": ["edge"],
  "name": "edge",
  "ip": "0.0.0.0",
  "port": 80,
  "protocol": "http_auto"
}')

# Define proxy for GM Control registration
greymatter create proxy < <(echo '{
  "zone_key": "default-zone",
  "proxy_key": "edge-proxy",
  "domain_keys": ["edge"],
  "listener_keys": ["edge-listener"],
  "name": "edge",
  "active_proxy_filters": ["gm.metrics"],
  "proxy_filters": {
    "gm_metrics": {
      "metrics_port": 8081,
      "metrics_host": "0.0.0.0",
      "metrics_dashboard_uri_path": "/metrics",
      "metrics_prometheus_uri_path": "/prometheus",
      "metrics_ring_buffer_size": 4096,
      "prometheus_system_metrics_interval_seconds": 15,
      "metrics_key_function": "none"
    }
  }
}')

# Add entry to Catalog
# todo: Determine strategy for connecting to Catalog
curl -X POST catalog-host:8080/clusters -data '{
  "zoneName": "default-zone",
  "clusterName": "edge",
  "name": "Grey Matter Edge",
  "version": "1.0",
  "owner": "Decipher",
  "capability": "Grey Matter",
  "documentation": "",
  "maxInstances": 1,
  "minInstances": 1,
  "enableInstanceMetrics": true,
  "enableHistoricalMetrics": false,
  "metricsPort": 8081
}'
