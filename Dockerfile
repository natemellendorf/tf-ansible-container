FROM hashicorp/terraform:0.14.6 as terraform
FROM python:3.9.1-alpine3.13

ENV ANSIBLE_VERSION 2.10.7
ENV ANSIBLE_LINT 5.0.0
ENV CRYPTOGRAPHY_DONT_BUILD_RUST 1

COPY --from=terraform /bin/terraform /usr/local/bin/

RUN \
  apk update && \ 
  apk add --no-cache \
  --virtual build-dependencies \
  build-base \
  libxml2-dev \
  libxslt-dev \
  python3-dev \
  gcc \
  sshpass \
  openssh \
  openssl-dev \
  musl-dev \
  libffi-dev \
  git \
  ca-certificates && \
  update-ca-certificates && \
  rm -rf /var/cache/apk/*

RUN \
  echo "Updating PIP..." \
  && pip install --upgrade pip cffi \
  && echo "Installing Ansible..." \
  && pip install \
  ansible==$ANSIBLE_VERSION \
  ansible-lint==$ANSIBLE_LINT \
  && echo "Installing additional Python packages..." \
  && pip install \
  awscli \
  boto3 \
  botocore \
  jxmlease \
  jsnapy \
  ncclient \
  junos-eznc \
  kubernetes \
  hvac hvac[parser] \
  && echo "Removing package list..." \
  && apk del build-dependencies \
  && rm -rf /var/cache/apk/*

RUN \
  echo "Installing Ansible collections..." \
  && ansible-galaxy collection install \
  cisco.ios \
  cisco.aci \
  amazon.aws

RUN \
mkdir -p /etc/ansible \
&& mkdir -p ~/.ssh/ \
&& mkdir -p ~/.kube \
&& mkdir -p ~/.aws \
&& mkdir -p ~/.gcp

#RUN addgroup -S ansible-group && adduser -S ansible -G ansible-group
#USER ansible

#WORKDIR /home/ansible

ENTRYPOINT ["/bin/ash"]
