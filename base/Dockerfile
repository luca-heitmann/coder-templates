FROM ubuntu:22.04

SHELL ["/bin/bash", "-c"]

RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get install -y \
      apt-transport-https \
      bash \
      build-essential \
      ca-certificates \
      curl \
      htop \
      locales \
      man \
      python3 \
      python3-pip \
      python3-venv \
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
    # Install git and docker
    apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get install -y git docker-ce-cli

ENV LANG en_US.UTF-8

RUN useradd coder \
      --create-home \
      --shell=/bin/bash \
      --uid=1000 \
      --user-group && \
    echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd

USER coder

ENV PATH /home/coder/.local/bin:$PATH

RUN curl -fsSL https://code-server.dev/install.sh | sh
RUN code-server \
    --install-extension streetsidesoftware.code-spell-checker
RUN python3 -m pip install -U pip wheel setuptools
