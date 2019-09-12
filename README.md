## What
This is the repo for the ansible-based deployment of GreyMatter 2.0 in Amazon ECS.

#### Further Explanation

The playbooks were made to deploy the AWS infrastructure and GreyMatter services to the Decipher dev AWS environment.  It is recommended to set up `aws-vault`, as described [here](https://github.com/99designs/aws-vault) with your credentials in order to run the ansible smoothly.

There are three playbooks and two roles thus far.  `full-deployment.yml` works with both roles and will spin up both the underlying AWS infrastructure (security groups, roles, vpc, etc) via the `ecs-infrastructure` role and the actual GreyMatter services (control, control api, catalog, etc) via the `ecs_services` role.

#### Status

**Services**

* control
* control api
* catalog

**Infrastructure**

The infrastructure already exists in AWS, but I'm currently moving it over from terraform to ansible.


## How

Assuming you have `aws-vault` correctly configured for the Decipher dev environment and named the profile `dev`...

1) You can run the ansible playbook that just creates services with

 ``` console
 aws-vault exec dev -- ansible-playbook services_deployment.yml
 ```
 
 2) You can run the ansible playbook that just creates AWS infrastructure  with

 ``` console
 aws-vault exec dev -- ansible-playbook infrastructure_deployment.yml
 ```
 
 3) You can run the ansible playbook that creates the whole shebang (a->z, vpc->services) with
 ``` console
 aws-vault exec dev -- ansible-playbook full_deployment.yml
 ```

