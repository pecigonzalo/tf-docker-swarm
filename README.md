# Docker Swarm for AWS (Terraform)
This is an open Docker Swarm for AWS deployment based on Terraform and custom supporting images.

### Why?
This is using mostly public code images (Working on a replacement for l4controller) instead of the "hidden" images docker use and the containers can run on non musl libc hosts.  
Docker just released the Docker for AWS as a fire and forget thing, no docs, no anything and while I have no docs yet, the "how it works" is there in the open as the code for everything is on github.


*There is still some cleanup to do and add it to travis, tests, etc. but it works as is.*

### Project Components

##### Terraform:
* [docker-swarm](https://github.com/pecigonzalo/tf-docker-swarm)

*For the VPC and ELB modules, you can BYO as long as it complies with the inputs and outputs. (I use something based on https://github.com/segmentio/stack that will publish soon)*

##### Images:
- **[guide-aws](https://github.com/pecigonzalo/docker-guide-aws)**
This container *guides* the cluster instances through its lifecycle performing maintenance tasks.

- **[meta-aws](https://github.com/pecigonzalo/docker-meta-aws)**
Provides a simple Flask based metadata service, primarely gives Swarm tokens based on the EC2 instance SG.

- **[init-aws](https://github.com/pecigonzalo/docker-init-aws)**
Initializes the EC2 instance, gets AWS info, inits or joins the Swarm, updates DynamoDB entry, etc.

- **[status-aws](https://github.com/pecigonzalo/docker-status-aws)**
Provides a simple Flask based *status* endpoint based on the Docker Engine status.

- **[elb-aws](https://github.com/pecigonzalo/docker-elb-aws)**
Dynamically updates the cluster ELB based on the published services running on the cluster.

*Documentation for each image is found under the image README.md*

## Development
### Initialize

After cloning the repo, please run:
```
pip install pre-commit # If not installed
pre-commit install
```
Add your modules to the modules directory and then run terraform normally
