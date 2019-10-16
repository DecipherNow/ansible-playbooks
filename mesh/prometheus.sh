#!/usr/bin/env bash

echo "Define cluster for sidecar's discovered instances"
/opt/mesh/greymatter create cluster < prometheus/cluster-instance.json

echo "Define rule for directing traffic to sidecar cluster"
/opt/mesh/greymatter create shared_rules < prometheus/shared-rules-sidecar.json

echo "Add route #1 from edge to sidecar (no trailing slash)"
/opt/mesh/greymatter create route < prometheus/route-sidecar.json

echo "Add route #2 from edge to sidecar (with trailing slash)"
/opt/mesh/greymatter create route < prometheus/route-slash.json

echo "Define cluster for a sidecar's service"
# Note: Service is at localhost:port (same EC2)
/opt/mesh/greymatter create cluster < prometheus/cluster-service.json

echo "Define rule for directing traffic to service cluster"
/opt/mesh/greymatter create shared_rules < prometheus/shared-rules-service.json

echo "Define domain for sidecar route to its service"
/opt/mesh/greymatter create domain < prometheus/domain.json

echo "Define listener for downstream requests to sidecar"
/opt/mesh/greymatter create listener < prometheus/listener.json

echo "Add route from sidecar to service cluster"
/opt/mesh/greymatter create route < prometheus/route-service.json
