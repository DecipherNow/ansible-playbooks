This is a doc of notes having to do with bringing up the base AWS infrastructure for use with Amazon ECS.

This infrastructure is ready to go for the AWS Fargate launch type, and is most of the way ready to go for the EC2 launch type.

### IAM Notes

For simplicity, this infrastructure uses a single, all-purpose IAM role for all ECS related work.  In production it should probably be split up more precisely for different use cases.

The iam role, and associated instance profile, has the following permissions:

1. `arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role`

	This role is necessary for the ecs-agent to start correctly on an ecs optimized instance.

2. `arn:aws:iam::aws:policy/AmazonECS_FullAccess`

	This role is necessary for containers to be able to talk to the ECS console (i.e. to find the cluster).

3. `arn:aws:iam::aws:policy/SecretsManagerReadWrite`
   
   This role is necessary if you use the AWS secrets manager to pass down credentials to tasks.

4. `arn:aws:iam::aws:policy/AmazonEC2FullAccess`

	This role is necessary if you use the EC2 launch type.  Not sure why, but there's errors without it.
	

### VPC Notes

Notice that there's an assertion in the Ansible that the VPC did not change.  This is because generally we don't want to mess with the VPC once it's up the first time.  This assertion section should be commented the first time this code runs.


### Security Group Notes

The ingress security group values dictate from which IP the EC2 instances can be accessed.  If you want to SSH into an instance, your IP needs to be added at port 22.

### AMI

The AMI for the EC2 instances should be an Amazon ECS optimized AMI.  The code finds an ecs-optimized AMI, and sets that as the image ID to be used in the launch configuration.  Theoretically, any of the ecs-optimized AMIs should do the trick, but in reality you want to grab one with the most up to date `ecs-init` installed.  This code doesn't yet grab the most up-to-date AMI.

### Load Balancer and Target Groups

Both an `instance` and `ip` target group is creeated for networking reasons.  The `host` network mode, for instance, only wants the ECS task to be connected to an instance target group, whereas the `awsvpc` network mode needs an ip target group.

### Creating a Key Pair

This is a bit of an awkward piece of yaml.  An ec2 key pair needs to be created and defined in order to be able to create accessible EC2 instances, which is why that block exists.  However, Ansible isn't going to download the newly created key pair for you, so it basically dissapears into the ether if this is the first time its created.  The only way to download the key pair is making it through the AWS console, at which point it's downloadable one time.  The code makes the most sense when you manually create the key pair, download it, and stick its name into the Ansible yaml block.  This way it will not be recreated, but will still be used in the launch configuration.
