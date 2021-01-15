FROM ikeyasu/opengl:cuda9.0-cudnn7-devel-ubuntu16.04
MAINTAINER ikeyasu <ikeyasu@gmail.com>

ENV DEBIAN_FRONTEND oninteractive

############################################
# Basic dependencies
############################################
RUN apt-get update --fix-missing && apt-get install -y \
      python3-numpy python3-matplotlib python3-dev \
      python3-opengl python3-pip \
      cmake zlib1g-dev libjpeg-dev xvfb libav-tools \
      xorg-dev libboost-all-dev libsdl2-dev swig \
      git wget openjdk-8-jdk ffmpeg unzip\
    && apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

############################################
# Change the working directory
############################################
WORKDIR /opt

############################################
# OpenAI Gym and Keras
# It seems that keras always use the module installed last. 
# https://github.com/fchollet/keras/issues/6997
############################################
RUN pip3 install --upgrade pip
RUN pip3 install h5py keras future pyvirtualdisplay 'gym[atari]' 'gym[box2d]' 'gym[classic_control]'

############################################
# Roboschool
# https://github.com/openai/roboschool/blob/d057eaa/Dockerfile
############################################
RUN apt-get update && apt-get install -y \
      git cmake ffmpeg pkg-config \
      qtbase5-dev libqt5opengl5-dev libassimp-dev \
      patchelf curl\
    && apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*\
    && git clone --depth 1 https://github.com/openai/roboschool

ENV ROBOSCHOOL_PATH /opt/roboschool

RUN cd $ROBOSCHOOL_PATH && bash -c ". ./exports.sh && ./install_boost.sh"
RUN cd $ROBOSCHOOL_PATH && bash -c ". ./exports.sh && ./install_bullet.sh"
RUN cd /usr/lib/x86_64-linux-gnu && ln -s libboost_python-py35.so libboost_python35.so 
RUN cd $ROBOSCHOOL_PATH && bash -c ". ./exports.sh && PYTHONPATH=/usr/bin/python3 CPLUS_INCLUDE_PATH=/usr/include/python3.5 ./roboschool_compile_and_graft.sh"
RUN pip install -e $ROBOSCHOOL_PATH

# test
RUN python3 -c "import gym; gym.make('roboschool:RoboschoolAnt-v1').reset()"

############################################
# marlo
############################################

RUN pip3 install -U malmo
RUN pip3 install -U marlo

RUN cd /opt \
    && python3 -c 'import malmo.minecraftbootstrap; malmo.minecraftbootstrap.download()' \
    && chown -R user:user MalmoPlatform/

ENV MALMO_MINECRAFT_ROOT /opt/MalmoPlatform/Minecraft

############################################
# Deep Reinforcement Learning
#    OpenAI Baselines
#    Keras-RL
#    ChainerRL
############################################
RUN pip3 install keras-rl opencv-python
RUN pip3 install chainer==5.1.0 cupy-cuda90==5.1.0 chainerrl==0.6.0

# Need to remove mujoco dependency from baselines
RUN git clone --depth 1 https://github.com/openai/baselines.git \
    && sed --in-place 's/mujoco,//' baselines/setup.py \
    && pip3 install mpi4py cloudpickle

############################################
# Tensorflow (GPU)
# If tensorflow and tensorflow-gpu are installed simultaneously,
# keras selects tensorflow (CPU). So, I uninstall the cpu version,
# and install the gpu version at the end.
############################################
RUN pip3 install tensorflow-gpu==1.8

############################################
# PyBullet
############################################
RUN pip3 install pybullet==2.5.0
RUN sed -i 's/robot_bases/pybullet_envs.robot_bases/' /usr/local/lib/python3.5/dist-packages/pybullet_envs/robot_locomotors.py

############################################
# locate, less, lxterminal, and vim
############################################
RUN apt-get update && apt-get install -y mlocate less vim lxterminal mesa-utils\
    && updatedb\
    && apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

ENV APP "lxterminal -e bash"
