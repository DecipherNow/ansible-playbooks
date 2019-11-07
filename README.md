## What
This is the repo for the Ansible-based deployment of Grey Matter 2.0 in Amazon ECS.

### Further Explanation

This repository contains playbooks made to deploy the AWS infrastructure and Grey Matter services to the Decipher dev AWS environment. It is recommended to set up `aws-vault`, as described [here](https://github.com/99designs/aws-vault) with your credentials in order to run Ansible smoothly.

There are three Ansible roles defined:
- `ecs-infrastructure` spins up the underlying AWS infrastructure (security groups, IAM roles, VPC, etc)
- `ecs_services` spins up the Grey Matter core services (control, control-api, catalog, etc)

- `ecs_secrets` spins up various necessary secrets into AWS Secrets Manager

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
 aws-vault exec dev -- ansible-playbook services_deployment_?.yaml
 ```

1) You can run the Ansible playbook that just creates secrets with

 ``` console
 aws-vault exec dev -- ansible-playbook secrets.yaml
 ```

Alternatively, you can skip the `aws-vault` part of the command (while we aren't using MFA) if you [export your AWS profile](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html).


### Infrastructure Deployment

This is the most first ansible playbook you should run. It has only two vars to set at the highest level.

If you want to change the `aws_region` you'll be running in, make sure you also change the `ecs_image_id` fact (found in `roles/ecs_infrastructure/tasks/network.yaml`) to an appropriate ami for that region.  There's a nice list of those ami id's [here](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html).

If you want to change the `cluster_name` variable, make sure you also change the name in `roles/ecs_infrastructure/files/cloud-config.yaml` (without these two names matching, your cluster won't be able to find any ec2 instances).

### Secrets Deployment

Go to the README in `roles/ecs_secrets/vars/` to learn how to set up necessary secrets.

### Services Deployment

After running `infrastructure_deployment.yaml` and `secrets.yaml`, AWS should have all the infrastructure in place such that you can find the various arns and names to fill in one of the `services_deployment_X.yaml` files--one will spin up Fargate containers and one will spin up containers in EC2, the infrastructure yaml is set up to allow for either.
