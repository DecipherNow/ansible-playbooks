## Mesh Configuration Image

This folder contains a Dockerfile that builds the image that configures the mesh.  All of the resources in this folder get copied in (other than the `save` directory which is just for reference) and run with the image to confirugre the mesh from within the mesh.

### apt-get installs

* Installs vim because the greymatter cli needs an editor

* Installs openss-server to allow for ssh access into the container when running on Fargate

### .gitignored files

This Dockerfile expects two resources that aren't pushed to github.  The first is `debug_key.pub` which is your personal ssh key which will allow you to ssh into the container (even if it's on Fargate).  The second is `greymatter.linux` which is the linux version of the greymatter cli binary.

### Services Thus Far

So far, the Dockerfile (and the `mesh.sh` script it runs at runtime) only sets up the control-api, edge, dashboard, and catalog services.
