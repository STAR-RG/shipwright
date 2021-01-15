ARG CPU_OR_GPU
ARG AWS_REGION
FROM 520713654638.dkr.ecr.${AWS_REGION}.amazonaws.com/sagemaker-rl-tensorflow:ray0.5.3-${CPU_OR_GPU}-py3

WORKDIR /opt/ml

RUN apt-get update && apt-get install -y \
      git cmake ffmpeg pkg-config \
      qtbase5-dev libqt5opengl5-dev libassimp-dev \
      libpython3.5-dev libtinyxml-dev \
    && cd /opt \
    && apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

RUN pip install --upgrade \
    pip \
    setuptools


RUN pip install -U gym && pip install gym[atari] && pip install -U ray==0.6.5 && ldconfig
  
RUN pip install setproctitle

RUN pip install sagemaker-containers --upgrade

ENV PYTHONUNBUFFERED 1

############################################
# Test Installation
############################################
# Test to verify if all required dependencies installed successfully or not.
#RUN python -c "import gym;import sagemaker_containers.cli.train; import roboschool; import ray; from sagemaker_containers.cli.train import main"
RUN python -c "import gym;import sagemaker_containers.cli.train; import ray; from sagemaker_containers.cli.train import main"

# Make things a bit easier to debug
WORKDIR /opt/ml/code
