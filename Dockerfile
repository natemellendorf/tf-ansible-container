FROM hashicorp/terraform:0.13.4 as terraform
FROM python:3.8.3-alpine3.10

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
  ca-certificates && \
  update-ca-certificates && \
  rm -rf /var/cache/apk/*

RUN \
  pip install \
  ansible \
  ansible-lint \
  awscli \
  boto3 \
  botocore \
  jxmlease \
  jsnapy \
  ncclient \
  junos-eznc \
  kubernetes \
  hvac hvac[parser]

RUN \
  ansible-galaxy collection install \
  cisco.ios \
  cisco.aci \
  amazon.aws

ENTRYPOINT ["/bin/ash"]
