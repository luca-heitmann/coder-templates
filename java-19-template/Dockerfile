FROM ghcr.io/luca-heitmann/coder-templates/base:v1.0.0

# Install Temurin JDK
RUN wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | sudo apt-key add - && \
    echo "deb https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | sudo tee /etc/apt/sources.list.d/adoptium.list && \
    sudo apt-get update && \
    DEBIAN_FRONTEND="noninteractive" sudo apt-get install -y temurin-19-jdk && \
    sudo update-alternatives --config java

# Install code-server java extensions
RUN code-server \
    --install-extension redhat.java \
    --install-extension vscjava.vscode-java-debug \
    --install-extension vscjava.vscode-java-test \
    --install-extension vscjava.vscode-maven \
    --install-extension Pivotal.vscode-spring-boot \
    --install-extension vscjava.vscode-spring-initializr
