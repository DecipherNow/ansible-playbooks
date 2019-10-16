#!/usr/bin/env bash

echo "Define cluster for sidecar's discovered instances"
/opt/mesh/greymatter create cluster < data/cluster-instance.json

echo "Define rule for directing traffic to sidecar cluster"
/opt/mesh/greymatter create shared_rules < data/shared-rules-sidecar.json

echo "Add route 1 from edge to sidecar (no trailing slash)"
/opt/mesh/greymatter create route < data/route-sidecar.json

echo "Add route 2 from edge to sidecar (with trailing slash)"
/opt/mesh/greymatter create route < data/route-slash.json

echo "Define cluster for a sidecars service"
# Note: Service is at localhost:port (same EC2)
/opt/mesh/greymatter create cluster < data/cluster-service.json

echo "Define rule for directing traffic to service cluster"
/opt/mesh/greymatter create shared_rules < data/shared-rules-service.json

echo "Define domain for sidecar route to its service"
/opt/mesh/greymatter create domain < data/domain.json

echo "Define listener for downstream requests to sidecar"
/opt/mesh/greymatter create listener < data/listener.json

echo "Add route from sidecar to service cluster"
/opt/mesh/greymatter create route < data/route-service.json

echo "Add route from catalogs sidecar to datas sidecar"
# Note: This is how to specify intra-mesh communication
/opt/mesh/greymatter create route < data/route-catalog-to-data.json
