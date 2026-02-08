# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository creates a Docker image that bundles three tools for Kubernetes cluster management on AWS:
- **kops** (v1.34.1): Kubernetes operations tool for cluster creation, upgrade, and maintenance
- **kubectl** (v1.35.0): Kubernetes command-line client
- **aws-cli** (v2): AWS command-line interface

The image is based on Debian 12 (Bookworm) and published to Docker Hub as `sigursoft/kops.aws`.

## Build and Test Commands

Build the Docker image:
```bash
docker build -t="sigursoft/kops.aws" .
```

Build with custom tag for local testing:
```bash
docker build -t="mykops" .
```

Run the container interactively:
```bash
docker run -it \
  -e KOPS_STATE_STORE \
  -v "$HOME"/.ssh:/home/kops/.ssh:rw \
  -v "$HOME"/.aws:/home/kops/.aws:ro \
  -v "$HOME"/.kube:/home/kops/.kube:rw \
  -v /your/workdir:/home/kops/work \
  sigursoft/kops.aws
```

## Architecture

### Dockerfile Structure

The Dockerfile follows a layered approach with security best practices:

1. **Base layer**: Debian 12 with system utilities (jq, ssh, nano, groff, bash-completion, curl, unzip) - all installed and cleaned up in a single layer
2. **AWS CLI layer**: Installs AWS CLI v2 from official installer bundle
3. **Kubernetes tools layer**: Downloads kubectl and kops binaries with SHA256 checksum verification for security
4. **User setup**: Creates unprivileged `kops` user with proper home directory structure
5. **Configuration**: Sets up bash completion for kubectl and kops

All binary downloads are verified using SHA256 checksums to ensure integrity and prevent supply chain attacks.

### Version Management

Tool versions are defined as build arguments at the top of the Dockerfile:
- `KOPS_VERSION`: kops version (Dockerfile:4)
- `KUBECTL_VERSION`: kubectl version (Dockerfile:5)

AWS CLI v2 is installed from the latest official installer bundle and does not require version pinning.

Update the ARG values to upgrade tool versions. The Dockerfile automatically verifies SHA256 checksums for kubectl and kops binaries during build to ensure integrity.

### CI/CD Pipeline

The `buildspec.yml` defines an AWS CodeBuild pipeline with three phases:
1. **pre_build**: Authenticates to Docker Hub using secrets from AWS Secrets Manager
2. **build**: Builds and tags the Docker image
3. **post_build**: Pushes the image to Docker Hub

Required environment variables for CI/CD:
- `IMAGE_REPO_NAME`: Docker Hub repository name
- `IMAGE_TAG`: Image tag to apply
- `DOCKERHUB_USERNAME`: Stored in AWS Secrets Manager (dockerhub:username)
- `DOCKERHUB_PASSWORD`: Stored in AWS Secrets Manager (dockerhub:password)

### Volume Mounts

The container expects these volume mounts:
- `/home/kops/.ssh`: SSH keys for cluster access (read-write)
- `/home/kops/.aws`: AWS credentials (read-only)
- `/home/kops/.kube`: Kubernetes config files (read-write)
- `/home/kops/work`: Working directory for user files (read-write)

### Environment Variables

- `KOPS_STATE_STORE`: Required for kops operations, specifies S3 bucket for cluster state (e.g., `s3://your-kops-state-store`). Must be set at runtime via `-e` flag or in the container environment.
