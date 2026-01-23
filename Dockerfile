ARG VERSION=8
FROM rockylinux/rockylinux:${VERSION}

ARG VERSION=8
ENV EL_VERSION="${VERSION}"

RUN yum install epel-release -y
RUN set -eux \
    && dnf update -y \
    && dnf install -y --allowerasing \
        gcc \
        vim \
        curl \
        less \
        make \
        ccache \
        rpmlint \
        python3.11 \
        python3.11-pip \
        rpm-sign \
        rpm-build \
        yum-utils \
        createrepo \
        rpmdevtools \
        ca-certificates \
    && dnf clean all

# Enable PowerTools or CodeReady Builder
RUN set -eux \
    && /usr/bin/crb enable

ENV CLOUD_SDK_VERSION="521.0.0"
ENV PATH=/google-cloud-sdk/bin:$PATH
ENV CLOUDSDK_PYTHON_SITEPACKAGES=1
RUN set -eux \
    && if [[ "$(uname -m)" == "aarch64" ]]; then export PLAT="arm"; elif [[ "$(uname -m)" == "x86_64" ]]; then export PLAT="x86_64"; else exit 1; fi \
    && mkdir -p /tmp/build \
    && cd /tmp/build \
    && curl -sS -L -o google-cloud-sdk.tar.gz https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-${PLAT}.tar.gz \
    && tar xfz google-cloud-sdk.tar.gz -C / \
    && cd /tmp \
    && rm -rf /tmp/build /google-cloud-sdk/bin/anthoscli \
    && gcloud components remove bq \
    && gcloud config set core/disable_usage_reporting true \
    && gcloud config set component_manager/disable_update_check true \
    && gcloud config set metrics/environment github_docker_image \
    && rm -rf /google-cloud-sdk/.install/.backup \
    && rm -rfv /google-cloud-sdk/bin/kubectl.* /google-cloud-sdk/bin/anthoscli

ENV JFROG_CLI_VERSION="2.75.1"
RUN set -eux \
    && if [[ "$(uname -m)" == "aarch64" ]]; then export PLAT="arm64"; elif [[ "$(uname -m)" == "x86_64" ]]; then export PLAT="amd64"; else exit 1; fi \
    && curl -sS -L -o /usr/local/bin/jfrog https://releases.jfrog.io/artifactory/jfrog-cli/v2/${JFROG_CLI_VERSION}/jfrog-cli-linux-${PLAT}/jfrog

ENV VAULT_VERSION="1.19.3"
RUN set -eux \
    && if [[ "$(uname -m)" == "aarch64" ]]; then export PLAT="arm64"; elif [[ "$(uname -m)" == "x86_64" ]]; then export PLAT="amd64"; else exit 1; fi \
    && mkdir -p /tmp/build \
    && cd /tmp/build \
    && curl -sS -L -o vault.zip  https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_${PLAT}.zip \
    && unzip -oqd /usr/local/bin vault.zip \
    && rm -rf /tmp/build \
    && chmod +x /usr/local/bin/*

WORKDIR /rpm

CMD ["/bin/bash"]
