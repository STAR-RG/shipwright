### "from"
FROM ubuntu:latest
MAINTAINER Ana Nelson <ana@ananelson.com>

### "localedef"
RUN locale-gen en_US.UTF-8

### "apt-defaults"
RUN echo "APT::Get::Assume-Yes true;" >> /etc/apt/apt.conf.d/80custom ; \
    echo "APT::Get::Quiet true;" >> /etc/apt/apt.conf.d/80custom ; \
    apt-get update

### "utils"
RUN apt-get install \
      ack-grep \
      adduser \
      build-essential \
      curl \
      git \
      man-db \
      pkg-config \
      rsync \
      strace \
      sudo \
      tree \
      unzip \
      vim \
      wget \
    ;

### "python"
RUN apt-get install \
      python-dev \
      python-pip \
    ;

### "asciidoctor"
RUN apt-get install \
      ruby1.9.1 \
      ruby1.9.1-dev \
    ; \
    gem install \
      asciidoctor \
      pygments.rb \
    ;

### "matplotlib"
RUN apt-get install \
        libfreetype6-dev \
        libpng-dev \
    ; \
    pip install matplotlib

### "dexy"
RUN pip install dexy

### "dev-dexy"
WORKDIR /tmp
RUN echo "dirty2"; \
    git clone https://github.com/dexy/dexy && \
    cd dexy && \
    pip install -e .

### "research"
RUN pip install simpy

### "create-user"
RUN useradd -m repro && \
    echo "repro:password" | chpasswd ; \
    echo "repro ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/repro

### "activate-user"
ENV HOME /home/repro
USER repro
WORKDIR /home/repro

### "run"
ADD run.sh /home/repro/run.sh
CMD ["/bin/bash", "/home/repro/run.sh"]
