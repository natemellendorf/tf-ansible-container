FROM golang:alpine AS builder

RUN apk update && apk add --no-cache git make bash
WORKDIR /root

RUN \
git clone https://github.com/natemellendorf/terraform-provider-infoblox.git \
&& cd terraform-provider-infoblox \
&& make build

FROM hashicorp/terraform:0.14.6 as terraform
FROM python:3.9.1-alpine3.13

ENV ANSIBLE_VERSION 2.10.7
ENV ANSIBLE_LINT 5.0.0
ENV CRYPTOGRAPHY_DONT_BUILD_RUST 1

COPY --from=builder /root/terraform-provider-infoblox /root/terraform-provider-infoblox
COPY --from=terraform /bin/terraform /usr/local/bin/

RUN \
  apk update && \ 
  apk add --no-cache \
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
  bash \
  curl \
  ca-certificates \
  && update-ca-certificates \
  && rm -rf /var/cache/apk/*

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
  yamllint \
  black \
  jxmlease \
  jsnapy \
  ncclient \
  junos-eznc \
  kubernetes \
  hvac hvac[parser]

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

RUN \
mkdir -p /usr/share/terraform/plugins/cloudpipeline.dev/devops/infoblox/0.0.1/linux_amd64 \
&& cp /root/terraform-provider-infoblox /usr/share/terraform/plugins/cloudpipeline.dev/devops/infoblox/0.0.1/linux_amd64/terraform-provider-infoblox_v0.0.1 \
&& chmod +x /usr/share/terraform/plugins/cloudpipeline.dev/devops/infoblox/0.0.1/linux_amd64/terraform-provider-infoblox_v0.0.1

#RUN addgroup -S ansible-group && adduser -S ansible -G ansible-group
#USER ansible

#WORKDIR /home/ansible

ENTRYPOINT ["/bin/ash"]
