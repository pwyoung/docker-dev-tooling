FROM infra-dev:latest

# Set timezone and avoid being prompted for it
ARG TZ=UTC
ARG DEBIAN_FRONTEND=noninteractive

# Default shell
SHELL ["/bin/bash", "-c"]


## Get aws-shell (comes with AWS CLI v1)
#RUN pip install aws-shell
#
## https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
#RUN cd /tmp && \
#  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
#  unzip ./awscliv2.zip && \
#  /tmp/aws/install -b /root && \
#  mv /root/aws /usr/local/bin/aws-v2 && \
#  mv /usr/local/bin/aws /usr/local/bin/aws-v1 && \
#  ln -s /usr/local/bin/aws-v2 /usr/local/bin/aws && \
#  echo 'Sanity check installed tools' && \
#  /usr/local/bin/aws-v1 --version && \
#  /usr/local/bin/aws-v2 --version && \
#  /usr/local/bin/aws-shell --help
#
## Add AWS SAM CLI
## https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install-linux.html
## The above URL redirects, so use "wget" (not curl)
#RUN mkdir -p /tmp/aws-sam-cli && \
#  cd /tmp/aws-sam-cli && \
#  wget https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip -O "aws-sam-cli-linux-x86_64.zip" && \
#  unzip aws-sam-cli-linux-x86_64.zip && \
#  /tmp/aws-sam-cli/install && \
#  echo 'Sanity check installed tools' && \
#  /usr/local/bin/sam --version

USER $DEVUSER
WORKDIR $DEVHOME

# For AWS Bedrock, we need newer AWS-cli and Boto3
#   https://github.com/aws-samples/amazon-bedrock-workshop
RUN cd && \
    git clone https://github.com/aws-samples/amazon-bedrock-workshop.git && \
    cd ./amazon-bedrock-workshop && \
    bash ./download-dependencies.sh

# Avoid https://github.com/yaml/pyyaml/issues/724
# by adding the pip constraint
RUN cd ~/amazon-bedrock-workshop/dependencies && \
    echo 'cython < 3.0' > ./constraints.txt && \
    PIP_CONSTRAINT=constraints.txt pip install --force-reinstall \
    ../dependencies/awscli-*-py3-none-any.whl \
    ../dependencies/boto3-*-py3-none-any.whl \
    ../dependencies/botocore-*-py3-none-any.whl \
    2>&1 | tee $HOME/pip-install.log

# https://pypi.org/project/langchain/#history
#RUN pip install --quiet langchain==0.0.249
RUN pip install --quiet langchain==0.0.265

# AWS-CLI
RUN cd ~/amazon-bedrock-workshop/dependencies && \
    tar xvzf awscli-*.tar.gz
RUN chmod 750 ~/amazon-bedrock-workshop/dependencies/awscli-*/bin/*
RUN sudo mv ~/amazon-bedrock-workshop/dependencies/awscli-*/bin/* /usr/local/bin/

# Since pyenv is virtually impossible to install via Dockerfile
RUN sudo apt-get install python-is-python3

# Ensure these succeed
RUN aws --version
RUN python --version
RUN python3 --version

# TODO: (probably via venv later)
# BOTO3 client
# https://github.com/aws-samples/amazon-bedrock-workshop/blob/main/00_Intro/bedrock_boto3_setup.ipynb

# CLEANUP
RUN rm -rf /tmp/*

CMD ["sleep", "infinity"]
