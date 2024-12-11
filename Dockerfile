ARG VERSION=8
FROM rockylinux:${VERSION}

ARG VERSION=8
ENV EL_VERSION "${VERSION}"

RUN yum install epel-release -y
RUN set -eux \
    && yum update -y \
    && yum install -y --allowerasing \
        gcc \
        vim \
        curl \
        less \
        make \
        ccache \
        rpmlint \
        python3 \
        rpm-sign \
        rpm-build \
        yum-utils \
        createrepo \
        rpmdevtools \
        ca-certificates \
    && yum clean all

# Enable PowerTools or CodeReady Builder
RUN set -eux \
    && /usr/bin/crb enable

ENV GCLOUD_SDK "503.0.0"
ENV PATH /google-cloud-sdk/bin:$PATH
ENV CLOUDSDK_PYTHON_SITEPACKAGES 1
RUN set -eux \
    && mkdir -p /tmp/build \
    && cd /tmp/build \
    && curl -sS -L -o google-cloud-sdk.tar.gz https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GCLOUD_SDK}-linux-x86_64.tar.gz \
    && tar xfz google-cloud-sdk.tar.gz -C / \
    && cd /tmp \
    && rm -rf /tmp/build /google-cloud-sdk/bin/anthoscli \
    && gcloud components remove bq \
    && gcloud config set core/disable_usage_reporting true \
    && gcloud config set component_manager/disable_update_check true \
    && gcloud config set metrics/environment github_docker_image \
    && rm -rf /google-cloud-sdk/.install/.backup \
    && rm -rfv /google-cloud-sdk/bin/kubectl.* /google-cloud-sdk/bin/anthoscli

ENV JFROG_CLI_VERSION "2.72.2"
RUN set -eux \
    && curl -sS -L -o /usr/local/bin/jfrog https://releases.jfrog.io/artifactory/jfrog-cli/v2/${JFROG_CLI_VERSION}/jfrog-cli-linux-amd64/jfrog

ENV VAULT_VERSION "1.18.2"
RUN set -eux \
    && mkdir -p /tmp/build \
    && cd /tmp/build \
    && curl -sS -L -o vault.zip https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip \
    && unzip -oqd /usr/local/bin vault.zip \
    && rm -rf /tmp/build \
    && chmod +x /usr/local/bin/*

WORKDIR /rpm

CMD ["/bin/bash"]
