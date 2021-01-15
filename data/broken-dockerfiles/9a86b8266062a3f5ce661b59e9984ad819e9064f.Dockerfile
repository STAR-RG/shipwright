FROM alpine:latest

# Source repo: https://github.com/dachiefjustice/aws-sec-tools
# Purpose: bundle tools for performing AWS platform-layer security audits

# Install system-wide packages as root:
#   - python3: for most tools, includes pip3 and venv functionality
#   - s3-inspector: python2, py2-pip, py2-virtualenv (python2 worked best when testing)
#   - nodejs for CloudSpoit Scans
#   - groff/less for awscli help system
#   - bash, curl for Prowler
#   - git for cloning from tool source repos
#   - sudo for convenience in dev environments
RUN apk add --no-cache --update vim git bash curl sudo \
    python2 py2-virtualenv py2-pip python3 \
    tmux groff less \
    nodejs nodejs-npm

# Update pip
RUN pip3 install --upgrade pip && \
    pip2 install --upgrade pip

# Add alpine user to sudoers
RUN echo 'awssec	ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers

# No need to run as root after this point
RUN addgroup -g 1000 -S awssec && \
    adduser -u 1000 -S awssec -G awssec -s /bin/sh 
USER awssec:awssec

# Set up AWS CLI in a virtualenv; system-wide autocomplete
WORKDIR /home/awssec/
RUN python3 -m venv awscli && \
    echo complete -C ~/awscli/bin/aws_completer aws > ~/.bashrc && \
    source ~/awscli/bin/activate && \
    pip3 install --upgrade awscli && \
    deactivate

# Set up AWS Shell in a virtualenv
RUN python3 -m venv awsshell && \
    source ~/awsshell/bin/activate && \
    pip3 install --upgrade aws-shell && \
    deactivate

# Set up Scout2 in a virtualenv
# python-dateutil version pin to avoid a boto version conflict
# Other boto-based tools seem to have a similar issue, https://github.com/boto/boto3/issues/1485
RUN python3 -m venv scout2 && \
    source ~/scout2/bin/activate && \
    pip3 install awsscout2 --upgrade && \
    pip3 install python-dateutil==2.6.1 && \
    deactivate

# Set up Pacu in a virtualenv
RUN git clone https://github.com/RhinoSecurityLabs/pacu.git && \
    python3 -m venv pacu && \
    source ~/pacu/bin/activate && \
    cd ~/pacu/ && \
    pip3 install -I urllib3==1.22 && \
    bash ~/pacu/install.sh && \
    deactivate

# Set up AWSBucketDump in a virtualenv
RUN git clone https://github.com/jordanpotti/AWSBucketDump.git awsbucketdump && \ 
    python3 -m venv awsbucketdump && \
    source ~/awsbucketdump/bin/activate && \
    pip3 install -r awsbucketdump/requirements.txt && \
    deactivate 

# Install s3-inspector (https://github.com/kromtech/s3-inspector)
RUN git clone https://github.com/kromtech/s3-inspector.git s3inspector && \
    virtualenv s3inspector && \
    source ~/s3inspector/bin/activate && \
    pip install boto3 botocore termcolor requests && \
    deactivate

# Install Prowler (https://github.com/toniblyx/prowler)
RUN git clone https://github.com/toniblyx/prowler.git prowler

# Install CloudSploit Scans (https://github.com/cloudsploit/scans)
RUN git clone https://github.com/cloudsploit/scans.git cloudsploitscan
WORKDIR /home/awssec/cloudsploitscan
RUN npm install

# Back to the homedir
WORKDIR /home/awssec/

# Copy the wrapper script into the container
COPY ./tool_launcher.py .
USER root:root
RUN chown awssec:awssec tool_launcher.py && \
    chmod 770 tool_launcher.py
USER awssec:awssec

# Launch the wrapper script
CMD ["/bin/bash"]
