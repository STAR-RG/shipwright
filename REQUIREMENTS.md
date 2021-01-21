# Requirements

To use this artifact, the following dependencies are required:

- A working installation of [Docker](https://docs.docker.com/get-docker/)

- Bash

To install Docker please see one of the following resources:

1. [Install Docker for Ubuntu.](https://docs.docker.com/install/linux/docker-ce/ubuntu/)
2. [Install Docker for Mac.](https://docs.docker.com/docker-for-mac/install/)
3. [Install Docker for Windows.](https://docs.docker.com/docker-for-windows/install/)

We recommend running experiments on a `*nix` system but have encapsulated all of the necessary infrastructure via Docker to make it possible (albeit less automatic) to run on any system with a working Docker install. We have only tested on `*nix` systems (CentOS and Debian).

## Disk Space 

**Note:** this repository, freshly cloned, takes about `1.5 GB` of disk space. The corresponding docker image (used by `./shipwright.sh`) uses `3 GB` of space. With data fully extracted, this repository and corresponding artifacts may use up to `20 GB` of space.

Use `docker rmi jjhenkel/shipwright` and `rm -rf ./shipwright` to reclaim the space used by this artifact.
