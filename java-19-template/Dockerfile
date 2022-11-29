FROM ubuntu:22.04

SHELL ["/bin/bash", "-c"]

RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get install -y \
      bash \
      build-essential \
      ca-certificates \
      curl \
      htop \
      locales \
      man \
      python3 \
      python3-pip \
      software-properties-common \
      sudo \
      unzip \
      vim \
      wget

    # Add official git apt repository
RUN add-apt-repository ppa:git-core/ppa && \
    # Add official docker apt repository
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    # Add official temurin apt repository
    wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | apt-key add - && \
    echo "deb https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list && \
    # Install git, docker and java
    apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get install -y git temurin-19-jdk docker-ce-cli && \
    update-alternatives --config java

ENV LANG en_US.UTF-8

RUN useradd coder \
      --create-home \
      --shell=/bin/bash \
      --uid=1000 \
      --user-group && \
    echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd

USER coder

RUN curl -fsSL https://code-server.dev/install.sh | sh
RUN code-server \
    --install-extension redhat.java \
    --install-extension vscjava.vscode-java-debug \
    --install-extension vscjava.vscode-java-test \
    --install-extension vscjava.vscode-maven \
    --install-extension Pivotal.vscode-spring-boot \
    --install-extension vscjava.vscode-spring-initializr
