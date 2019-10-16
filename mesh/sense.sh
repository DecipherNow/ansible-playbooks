#!/usr/bin/env bash

echo "Define cluster for sidecar's discovered instances"
/opt/mesh/greymatter create cluster < sense/cluster-instance.json

echo "Define rule for directing traffic to sidecar cluster"
/opt/mesh/greymatter create shared_rules < sense/shared-rules-sidecar.json

echo "Add route #1 from edge to sidecar (no trailing slash)"
/opt/mesh/greymatter create route < sense/route-sidecar.json

echo "Add route #2 from edge to sidecar (with trailing slash)"
/opt/mesh/greymatter create route < sense/route-slash.json

echo "Define cluster for a sidecar's service"
# Note: Service is at localhost:port (same EC2)
/opt/mesh/greymatter create cluster < sense/cluster-service.json

echo "Define rule for directing traffic to service cluster"
/opt/mesh/greymatter create shared_rules < sense/shared-rules-service.json

echo "Define domain for sidecar route to its service"
/opt/mesh/greymatter create domain < sense/domain.json

echo "Define listener for downstream requests to sidecar"
/opt/mesh/greymatter create listener < sense/listener.json

echo "Add route from sidecar to service cluster"
/opt/mesh/greymatter create route < sense/route-service.json
