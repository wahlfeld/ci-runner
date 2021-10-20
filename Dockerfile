FROM golang:1.17-alpine3.14

ENV TERRAFORM_VERSION=1.0.9
ENV TFSEC_VERSION=0.58.14
ENV TFLINT_VERSION=0.33.0

RUN apk update --no-cache && \
    apk add \
        make \
        python3 \
        nodejs \
        npm

RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /bin && \
    rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

RUN python3 -m ensurepip && \
    pip3 install pre-commit

RUN wget https://github.com/aquasecurity/tfsec/releases/download/v${TFSEC_VERSION}/tfsec-linux-amd64 && \
    chmod +x tfsec-linux-amd64 && \
    mv tfsec-linux-amd64 /bin/tfsec

RUN python3 -m pip install -U checkov

RUN wget https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_amd64.zip && \
    unzip tflint_linux_amd64.zip -d /bin && \
    rm tflint_linux_amd64.zip

RUN npm install -g markdown-link-check

ADD test.sh test.sh
RUN sh test.sh
