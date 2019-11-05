#!/bin/bash

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
