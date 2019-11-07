#!/bin/bash

echo "purging all objects"
for object in "cluster" "shared_rules" "proxy" "domain" "listener" "route"; do
  for key in $(/opt/mesh/greymatter list $object | jq -r ".[] | .${object}_key"); do
    echo "greymatter delete $object $key"
    /opt/mesh/greymatter delete $object $key
    sleep 1s
  done
done

echo "start edge"
/opt/mesh/edge.sh

echo "done edge"

sleep 10s

echo "start control-api"
/opt/mesh/control-api.sh

echo "done control-api"

# sleep 10s

# echo "start catalog"
# /opt/mesh/catalog.sh

# echo "done catalog"

# sleep 10s

# echo "start dashboard"
# /opt/mesh/dashboard.sh

# echo "done dashboard"

# echo "start data"
# /opt/mesh/data.sh

# echo "done data"

echo "list clusters"

/opt/mesh/greymatter list cluster

/usr/sbin/sshd -D
