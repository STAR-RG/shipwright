FROM debian:jessie
MAINTAINER zealic <zealic@gmail.com>

# Base
RUN  export DEBIAN_CODENAME=jessie \
  && export DEBIAN_MIRROR_HOST=mirrors.ustc.edu.cn \
  && echo "deb http://$DEBIAN_MIRROR_HOST/debian $DEBIAN_CODENAME main" > /etc/apt/sources.list \
  && echo "deb-src http://$DEBIAN_MIRROR_HOST/debian $DEBIAN_CODENAME main" >> /etc/apt/sources.list \
  && echo "deb http://$DEBIAN_MIRROR_HOST/debian-security $DEBIAN_CODENAME/updates main" >> /etc/apt/sources.list \
  && echo "deb-src http://$DEBIAN_MIRROR_HOST/debian-security $DEBIAN_CODENAME/updates main" >> /etc/apt/sources.list \
  && echo "deb http://$DEBIAN_MIRROR_HOST/debian $DEBIAN_CODENAME-updates main" >> /etc/apt/sources.list \
  && echo "deb-src http://$DEBIAN_MIRROR_HOST/debian $DEBIAN_CODENAME-updates main" >> /etc/apt/sources.list \
  && apt-get update \
  && apt-get install -y kvm qemu qemu-kvm curl unzip python default-jre gcc g++ make gnupg2 \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# RVM
RUN ln -sf /bin/bash /bin/sh
RUN curl -sSL https://rvm.io/mpapis.asc | gpg2 --import - \
  && curl -L https://get.rvm.io | bash -s stable --autolibs=enabled --ruby \
  && echo "/usr/local/rvm/scripts/rvm" >> /etc/bash.bashrc
RUN bash --login -c "rvm use ruby && gem install --no-document rdoc rake thor json"

# For AWS AMI Builder
# Use `aws ec2 import-snapshot` to import snapshot
# Use `ec2iv` to import snapshot (China cn-north-1 region)
# 1. `export AWS_ACCESS_KEY=<YOUR_ACCESS_KEY> && `export AWS_SECRET_KEY=<YOUR_SECRET_KEY>`
# 2. `export EC2_URL=ec2.cn-north-1.amazonaws.com.cn`
# 3. `ec2iv <LOCAL_VMDK_FILE> -f VMDK -z cn-north-1a -b <BUCKET> -o $AWS_ACCESS_KEY -w $AWS_SECRET_KEY`
RUN curl -SL -o /tmp/ec2-api-tools.zip http://s3.amazonaws.com/ec2-downloads/ec2-api-tools.zip \
  && mkdir -p /opt && unzip -d /opt /tmp/ec2-api-tools.zip \
  && mv `dirname /opt/ec2-api-tools-*/.` /opt/ec2-api-tools \
  && echo 'export EC2_HOME=/opt/ec2-api-tools' >> /etc/bash.bashrc \
  && echo "export PATH=/opt/ec2-api-tools/bin:\$PATH" >> /etc/bash.bashrc \
  && echo 'export JAVA_HOME=/usr/lib/jvm/default-java' >> /etc/bash.bashrc \
  && curl -SL -o /tmp/aws.zip https://s3.amazonaws.com/aws-cli/awscli-bundle.zip \
  && unzip -d /tmp /tmp/aws.zip \
  && /tmp/awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws \
  && rm -rf /tmp/* /var/tmp/*

# Packer
ENV PACKER_VERSION=0.9.0
RUN curl -SL -o /tmp/packer.zip https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip \
  && mkdir -p /opt/packer && unzip /tmp/packer.zip -d /opt/packer \
  && ln -sf /opt/packer/packer /usr/local/bin/packer

# packer-boxes
RUN mkdir -p /packer-boxes
WORKDIR /packer-boxes
COPY ["lib/", "manifests/", "Rakefile", "config.yml", "./"]

ENTRYPOINT ["/bin/bash"]
