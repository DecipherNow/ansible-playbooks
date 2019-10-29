## An Overview of ECS

Within a single ECS cluster (ours is called `greymatter-ecs-cluster`), there are multiple ECS services.

Each ECS service is a logical grouping of any number of ECS task-definition revisions.  

A single service can run multiple instances of a single task definition.  You can optionally connect a service to a load balancer, which is what we did for Grey Matter Control and Grey Matter Control API services to allow them to connect to each other dynamically.  The load balancer can load balance betwen multiple task definitions within a service, but more importantly it gives us a way to dynamically access the IP(s) associated with a task.

Each time a task restarts, it gets a new IP.  This is a result of using AWS Fargate over having a series of EC2 instances across which our tasks would run.  Fargate is instance-free, and essentially makes it such that each task is its own "container" with its own IP.

