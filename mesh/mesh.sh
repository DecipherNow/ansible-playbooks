#!/bin/bash

/opt/mesh/edge.sh

echo "done edge"

sleep 10s

/opt/mesh/control-api.sh

echo "done control-api"

sleep 10s

/opt/mesh/catalog.sh

echo "done catalog"

sleep 10s

/opt/mesh/dashboard.sh

echo "done dashboard"

echo "list clusters"

/opt/mesh/greymatter list cluster

echo "list domains"

/opt/mesh/greymatter list domain

echo "list listeners"

/opt/mesh/greymatter list listener

/usr/sbin/sshd -D
