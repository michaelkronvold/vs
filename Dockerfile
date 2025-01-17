# docker build -t kpod .
# docker run -it --rm kpod

# Use an official Ubuntu as a parent image
FROM ubuntu:22.04

# Set environment variables to non-interactive
ENV     DEBIAN_FRONTEND=noninteractive \
        USER_ID=50507 \
        USER_NAME=eoadmin \
        KAFKA_VERSION=2.13-3.8.0 \
        HOME=/home/eoadmin \
        TANZU_CLI_CEIP_OPT_IN_PROMPT_ANSWER=yes

# Install dependencies
RUN apt-get update \
&&  apt-get install -y -q --allow-unauthenticated \
    ca-certificates \
    wget curl \
    apt-transport-https \
    gnupg tar unzip gzip \
    software-properties-common \
    bash sed mg less \
    python3 jq \
    ncurses-base ncurses-bin ncurses-term fzf \
    openssl openssh-client \
    sudo git

RUN adduser --shell /bin/bash --home ${HOME} --uid ${USER_ID} ${USER_NAME} \
&&  mkdir -p ${HOME}/log ${HOME}/tmp ${HOME}/src \
&&  chown ${USER_NAME} -R ${HOME} \
&&  usermod -aG sudo eoadmin


# Install Tanzu CLI and vSphere plugin
RUN curl -L https://github.com/vmware-tanzu/tanzu-cli/releases/download/v1.5.1/tanzu-cli-linux-amd64.tar.gz -o tanzu-cli.tar.gz \
&&  tar -xvf tanzu-cli.tar.gz \
&&  install v1.5.1/tanzu-cli-linux_amd64 /usr/local/bin/tanzu \
&&  tanzu config eula accept \
&&  tanzu plugin install --group vmware-vsphere/default

#&&  tanzu plugin install --group vmware-tanzucli/essentials \
#&&  tanzu plugin install --group vmware-tkg/default \
#&&  tanzu plugin install --group vmware-tanzu/platform-engineer \
#&&  tanzu plugin install --local-source cli all

# install kubectl and vsphere plugin
RUN curl -Lk "https://github.com/michaelkronvold/vs/raw/refs/heads/main/vsphere-plugin.zip" -o /var/tmp/vsphere-plugin.zip \
&&  unzip /var/tmp/vsphere-plugin.zip -d /var/tmp \
&&  chmod +x /var/tmp/bin/kubectl /var/tmp/bin/kubectl-vsphere \
&&  mv /var/tmp/bin/kubectl /var/tmp/bin/kubectl-vsphere /usr/local/bin/
ENV     PATH=$PATH:/usr/local/bin


# test kubectl vsphere plugin
RUN kubectl vsphere version

# Install vanilla kubectl
#RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
#&&  chmod +x kubectl \
#&&  mv kubectl /usr/local/bin/

# Install krew
#RUN set -x; \
#    cd "$(mktemp -d)" && \
#    OS="$(uname | tr '[:upper:]' '[:lower:]')" && \
#    ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" && \
#    KREW="krew-${OS}_${ARCH}" && \
#    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" && \
#    tar zxvf "${KREW}.tar.gz" && \
#    ./"${KREW}" install krew && \
#    rm -rf "${KREW}.tar.gz" ./"${KREW}"
# Set up PATH for krew
#ENV    PATH="${KREW_ROOT:-/root/.krew}/bin:$PATH"

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set the entrypoint
ENTRYPOINT ["/bin/bash"]
# Set the entrypoint to keep the container alive
#CMD ["tail", "-f", "/dev/null"]
