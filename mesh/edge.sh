#!/usr/bin/env bash


echo "Define cluster for edge proxy"
/opt/mesh/greymatter create cluster < edge/cluster.json

echo "Define domain for edge routes to sidecars"
/opt/mesh/greymatter create domain < edge/domain.json

echo "Define listener for downstream requests to edge"
/opt/mesh/greymatter create listener < edge/listener.json

echo "Define proxy for GM Control registration"
/opt/mesh/greymatter create proxy < edge/proxy.json
