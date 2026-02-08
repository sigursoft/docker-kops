FROM debian:12
LABEL maintainer="Anton Kozik"

ARG KOPS_VERSION=1.34.1
ARG KUBECTL_VERSION=1.35.0

# Install system dependencies and AWS CLI v2 in a single layer
RUN apt-get update -qq && \
    apt-get install -y \
        jq \
        ssh \
        nano \
        groff \
        bash-completion \
        curl \
        unzip && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip -q awscliv2.zip && \
    ./aws/install && \
    rm -rf aws awscliv2.zip && \
    apt-get clean && \
    apt-get autoclean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Download and verify kubectl with checksum
RUN curl -LO "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && \
    curl -LO "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl.sha256" && \
    echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/ && \
    rm kubectl.sha256

# Download and verify kops with checksum
RUN curl -LO "https://github.com/kubernetes/kops/releases/download/v${KOPS_VERSION}/kops-linux-amd64" && \
    curl -LO "https://github.com/kubernetes/kops/releases/download/v${KOPS_VERSION}/kops-linux-amd64.sha256" && \
    echo "$(cat kops-linux-amd64.sha256)  kops-linux-amd64" | sha256sum --check && \
    chmod +x kops-linux-amd64 && \
    mv kops-linux-amd64 /usr/local/bin/kops && \
    rm kops-linux-amd64.sha256

RUN useradd -ms /bin/bash kops

WORKDIR /home/kops
USER kops

# Set up kube config directory and bash completion
RUN mkdir /home/kops/.kube && \
    touch /home/kops/.kube/config && \
    echo ". /etc/bash_completion" >> ~/.bashrc && \
    echo "source <(kubectl completion bash)" >> ~/.bashrc && \
    echo "source <(kops completion bash)" >> ~/.bashrc

VOLUME ["/home/kops/.ssh"]
VOLUME ["/home/kops/.aws"]
VOLUME ["/home/kops/.kube"]
VOLUME ["/home/kops/work"]

# KOPS_STATE_STORE must be set at runtime (e.g., s3://your-kops-state-store)
ENV KOPS_STATE_STORE=""

ENTRYPOINT ["/bin/bash"]
