FROM alpine

RUN apk add --no-cache \
    bash \
    curl \
    docker \
    git \
    jq \
    make \
    openssl \
    shadow \
    vim \
    wget

RUN  git clone https://git.systemprep.net/schmots/kind_awx /root/kind_awx

# Install kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.17.0/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl

# Install Kubernetes in Docker (kind)
RUN curl -Lo ./kind https://github.com/kubernetes-sigs/kind/releases/download/v0.7.0/kind-linux-amd64 && \
    chmod +x ./kind && \
    mv ./kind /usr/local/bin/kind

WORKDIR /root/kind_awx
ENTRYPOINT ["make"]
