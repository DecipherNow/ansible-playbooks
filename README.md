## What
This is the repo for the Ansible-based deployment of Grey Matter 2.0 in Amazon ECS.

### Further Explanation

This repository contains playbooks made to deploy the AWS infrastructure and Grey Matter services to the Decipher dev AWS environment. It is recommended to set up `aws-vault`, as described [here](https://github.com/99designs/aws-vault) with your credentials in order to run Ansible smoothly.

There are two Ansible roles defined:
- `ecs-infrastructure` spins up the underlying AWS infrastructure (security groups, IAM roles, VPC, etc)
- `ecs_services` spins up the Grey Matter core services (control, control-api, catalog, etc)

### Launch Types

**AWS Fargate**

This deployment currently uses AWS Fargate for managing the underlying AWS infrastructure that supports Amazon ECS.

Each Ansible playbook that uses AWS Fargate should specify `launch_type: FARGATE` and values for its `cpu`, `memory`, and `region` fields.

Also, the task definition's corresponding ECS Service should specify `launch_type: FARGATE`, a `region` value, and `network_configuration` similar to the following:
```
network_configuration:
  assign_public_ip: true
  security_groups:
  - "sg-058ff37fcba82d64e"
  subnets:
  - "subnet-0e06fb4f956d9f5f8"
```

**Amazon EC2**

If not using AWS Fargate, AWS infrastructure must be provisioned using configured EC2 instances and a VPC.

## How

Assuming you have `aws-vault` correctly configured for the Decipher dev environment and named the profile `dev`...

 1) You can run the Ansible playbook that just creates AWS infrastructure with

 ``` console
 aws-vault exec dev -- ansible-playbook infrastructure_deployment.yml
 ```

1) You can run the Ansible playbook that just creates services with

 ``` console
 aws-vault exec dev -- ansible-playbook services_deployment.yml
 ```

