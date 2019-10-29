## An Overview of ECS with EC2 Backing

Within a single ECS cluster (ours is called `greymatter-ecs-cluster`), there are multiple ECS services.

Each ECS service is a logical grouping of any number of ECS task-definition revisions.

Each task is run with bridge networking in order to allow for appropriate discovery of the proxies by the control plane.  It appears that awsvpc and host networking don't quite work, but it's possible they might with a bit of finagling.

Currently, service discovery via the control plane only works with `PROXY_DYNAMIC=false` and `USE_HTTP2=false` configured in the proxies.

Control and Control API talk to each other via load balancers, and via the Control load balancer the various proxies are configured to talk to Control.


