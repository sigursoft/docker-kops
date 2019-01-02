FROM debian:stable
LABEL maintainer="Anton Kozik"

ENV LAST_UPDATE=2018-12-16
ARG KOPS_VERSION=1.11.0
ARG KUBECTL_VERSION=1.11.6
ARG AWSCLI_VERSION=1.16.80

RUN apt-get update -qq

RUN apt-get install -y \
    jq \
    nano \
    groff \
    bash-completion

RUN apt-get -y install \
    python-pip && \
    pip install awscli==${AWSCLI_VERSION} && \
    apt-get clean && \
    apt-get autoclean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl /usr/local/bin/kubectl
RUN chmod +x /usr/local/bin/kubectl

ADD https://github.com/kubernetes/kops/releases/download/${KOPS_VERSION}/kops-linux-amd64 /usr/local/bin/kops
RUN chmod +x /usr/local/bin/kops

RUN useradd -ms /bin/bash kops
WORKDIR /home/kops
USER kops

RUN mkdir /home/kops/.kube && \
    touch /home/kops/.kube/config

RUN echo ". /etc/bash_completion" >> ~/.bashrc && \
    echo "source <(kubectl completion bash)" >> ~/.bashrc

ENTRYPOINT ["/bin/bash"]
