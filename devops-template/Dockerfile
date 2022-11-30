FROM ghcr.io/luca-heitmann/coder-templates/base:v1.0.0

    # Install Ansible
RUN python3 -m pip install ansible openshift passlib && \
    # Install Terraform
    cd /tmp && \
    curl -o terraform.zip https://releases.hashicorp.com/terraform/1.3.5/terraform_1.3.5_linux_arm64.zip && \
    unzip terraform.zip && \
    sudo mv terraform /usr/local/bin && \
    cd - && \
    # Add Kubernetes apt repository
    sudo curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list && \
    # Add Helm apt repository
    curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list && \
    # Install Terraform
    sudo apt-get update && \
    DEBIAN_FRONTEND="noninteractive" sudo apt-get install -y kubectl helm

# Install code-server devops extensions
RUN code-server \
    --install-extension redhat.ansible \
    --install-extension hashicorp.terraform
