FROM python:3.8.3-alpine3.10
FROM hashicorp/terraform:full as terraform

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
  ca-certificates && \
  update-ca-certificates && \
  rm -rf /var/cache/apk/*

RUN \
  pip install \
  ansible \
  ansible-lint \
  jxmlease \
  jsnapy \
  ncclient \
  junos-eznc \
  kubernetes \
  hvac hvac[parser]

RUN \
  ansible-galaxy collection install \
  juniper.device \
  cisco.ios

COPY --from=terraform /go/bin/terraform /usr/local/bin/

ENTRYPOINT ["/bin/ash"]
