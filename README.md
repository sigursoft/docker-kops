docker-kops
==============

[Docker](https://www.docker.com) image for running [kops](https://github.com/kubernetes/kops), [kubectl](https://github.com/kubernetes/kubectl) and the [Amazon Web Services Command Line Interface](http://aws.amazon.com/cli/).

The versions currently included are *kops 1.11.0*, *kubectl 1.11.6*, *aws-cli 1.16.82* on *Python 2.7.13*.

Background
----------

The `kops` tool is a command line interface that helps you create, destroy, upgrade and maintain production-grade, highly available, Kubernetes clusters.
The `kubectl` is a command line client to deploy and manage applications on Kubernetes.
The `aws` command line tool is a command line interface for [Amazon Web Services](http://aws.amazon.com).

The _docker-kops_ creates a [Docker](https://www.docker.com) image containing all dependencies needed to run `kops`, `kubectl` and `aws`. That way, you can create and manage Kubernetes clusters on `aws` in a [Docker](https://www.docker.com) container without setting dependencies on the host system.

Usage
-----------------

   ```bash
   docker run -it \
     -e KOPS_STATE_STORE \
     -v "$HOME"/.ssh:/home/kops/.ssh:rw \
     -v "$HOME"/.aws:/home/kops/.aws:ro \
     -v "$HOME"/.kube:/home/kops/.kube:rw \
     -v /your/workdir:/home/kops/work \
     sigursoft/kops.aws
   ```

Build from Source
-----------------

1. Make sure [Docker](https://www.docker.com) is installed.
3. Clone _docker-kops_ from [GitHub](https://github.com/sigursoft/docker-kops)

   ```bash
   git clone https://github.com/sigursoft/docker-kops.git
   ```
4. Build the docker image

   ```bash
   cd docker-kops
   docker build -t="mykops" .
   ```

5. Run a docker container with that image

   ```bash
   docker run -t -i mykops
   ```

Getting started with kops, kubectl and AWS CLI
--------------------------------

The most recent kops documentation is located on official [kops GitHub page](https://github.com/kubernetes/kops/tree/master/docs).

Kubectl documentation can be found on [Kubernetes.io documentation](https://kubernetes.io/docs/reference/kubectl/overview/).

For documentation on the AWS CLI, see the [AWS command line interface documentation](http://aws.amazon.com/documentation/cli/) and the [aws-cli GitHub page](https://github.com/aws/aws-cli).
