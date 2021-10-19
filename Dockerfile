FROM golang:alpine

ENV TERRAFORM_VERSION=1.0.9
ENV TFSEC_VERSION=0.39.29
ENV TFLINT_VERSION=0.28.1

RUN apk update --no-cache && \
    apk add python3 nodejs npm

RUN go get golang.org/x/tools/cmd/goimports && \
    go get golang.org/x/lint/golint

RUN wget https://releases.hashicorp.com/terraform/"${TERRAFORM_VERSION}"/terraform_"${TERRAFORM_VERSION}"_linux_amd64.zip && \
    unzip terraform_"${TERRAFORM_VERSION}"_linux_amd64.zip -d /usr/local/bin && \
    rm terraform_"${TERRAFORM_VERSION}"_linux_amd64.zip

RUN python3 -m ensurepip && \
    pip3 install pre-commit

RUN wget https://github.com/tfsec/tfsec/releases/download/v"${TFSEC_VERSION}"/tfsec-checkgen-linux-amd64 && \
    chmod +x tfsec-checkgen-linux-amd64 && \
    mv tfsec-checkgen-linux-amd64 /usr/local/bin/tfsec

RUN python3 -m pip install -U checkov

RUN wget https://github.com/terraform-linters/tflint/releases/download/v"${TFLINT_VERSION}"/tflint_linux_amd64.zip && \
    unzip tflint_linux_amd64.zip -d /usr/local/bin && \
    rm tflint_linux_amd64.zip

RUN npm install -g markdown-link-check

COPY test.sh .
RUN sh test.sh
