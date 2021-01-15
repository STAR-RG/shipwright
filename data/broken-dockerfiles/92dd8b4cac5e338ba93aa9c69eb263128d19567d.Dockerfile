# Liquid Galaxy
#
# VERSION 0.1

ARG UBUNTU_RELEASE=bionic
FROM 	ubuntu:${UBUNTU_RELEASE}

# Install basic stuff
RUN     apt-get install -y wget curl tmux git

# Add deb repos
RUN 	echo "deb http://packages.ros.org/ros/ubuntu $UBUNTU_RELEASE main" > /etc/apt/sources.list.d/ros-latest.list ;\
      apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 5523BAEEB01FA116 ;\
      wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - ;\
      echo "deb http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list ;\
      wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - ;\
      echo "deb http://dl.google.com/linux/earth/deb/ stable main" > /etc/apt/sources.list.d/google.list


# Stuff for GE and Chrome
RUN     apt-get update && apt-get install -y \
            x-window-system \
            binutils \
            mesa-utils \
            mesa-utils-extra \
            module-init-tools \
            gdebi-core \
            tar \
            libfreeimage3 ;\
        apt-get install -y --no-install-recommends xdg-utils

# Nvidia drivers
ADD 	nvidia-driver.run /tmp/nvidia-driver.run
RUN 	sh /tmp/nvidia-driver.run -a -N --ui=none --no-kernel-module ;\
      rm /tmp/nvidia-driver.run

# Install GE
WORKDIR /tmp
RUN     wget -q https://dl.google.com/dl/earth/client/current/google-earth-stable_current_amd64.deb ;\
        gdebi -n google-earth-stable_current_amd64.deb ;\
        rm google-earth-stable_current_amd64.deb

# Patch for google earth from amirpli to fix some bugs in google earth qt libs
# Without this patch, google earth can suddenly crash without a helpful error message.
# See https://productforums.google.com/forum/?fromgroups=#!category-topic/earth/linux/_h4t6SpY_II%5B1-25-false%5D
# and Readme-file https://docs.google.com/file/d/0B2F__nkihfiNMDlaQVoxNVVlaUk/edit?pli=1 for details

RUN     mkdir -p /opt/google/earth/free ;\
        touch /usr/bin/google-earth ;\
        cd /opt/google/earth ;\
        cp -a /opt/google/earth/free /opt/google/earth/free.newlibs ;\
        wget -q -P /opt/google/earth/free.newlibs \
          https://github.com/mviereck/dockerfile-x11docker-google-earth/releases/download/v0.3.0-alpha/ge7.1.1.1580-0.x86_64-new-qt-libs-debian7-ubuntu12.tar.xz ;\
        tar xvf /opt/google/earth/free.newlibs/ge7.1.1.1580-0.x86_64-new-qt-libs-debian7-ubuntu12.tar.xz ;\
        mv /usr/bin/google-earth /usr/bin/google-earth.old ;\
        ln -s /opt/google/earth/free.newlibs/googleearth /usr/bin/google-earth

# Install ROS
ARG ROS_RELEASE=melodic
RUN     apt-get update && apt-get install -y \
            ros-${ROS_RELEASE}-ros-base \
            ros-${ROS_RELEASE}-rosbridge-server \
            lsb-core \
            google-chrome-stable

# add galadmin user
RUN useradd -ms /bin/bash galadmin
RUN echo "galadmin   ALL=NOPASSWD: ALL" >> /etc/sudoers

# Use bash insted of default sh, to setup
# ROS evironment variables for nodes building
RUN     mv /bin/sh /bin/sh.bak && ln -s /bin/bash /bin/sh ;\
	    mkdir -p /home/galadmin/src ;\
        echo "source /opt/ros/${ROS_RELEASE}/setup.bash" >> /root/.bashrc ;\
        echo "source /opt/ros/${ROS_RELEASE}/setup.bash" >> /home/galadmin/.bashrc

# Add lg_ros_nodes and appctl repositories
# Use curent branch for lg_ros_nodes
WORKDIR /home/galadmin/src
RUN	    git clone git://github.com/EndPointCorp/appctl.git
ADD     workspace_copy /home/galadmin/src/lg_ros_nodes

USER    root

# Build and install ROS nodes
WORKDIR /home/galadmin/src/lg_ros_nodes
RUN     source /opt/ros/${ROS_RELEASE}/setup.bash;\
        rosdep init;\
        rosdep update;\
        ./scripts/init_workspace --appctl /home/galadmin/src/appctl ;\
        cd /home/galadmin/src/lg_ros_nodes/catkin ;\
        sudo rosdep install \
            --from-paths /home/galadmin/src/lg_ros_nodes/catkin/src \
            --ignore-src \
            --rosdistro ${ROS_RELEASE} \
            -y ;\
        catkin_make ;\
        catkin_make -DCMAKE_INSTALL_PREFIX=/opt/ros/${ROS_RELEASE} install;\
        source /home/galadmin/src/lg_ros_nodes/catkin/devel/setup.bash


WORKDIR /home/galadmin/src/lg_ros_nodes
ENV     DISPLAY :0

ADD     image_scripts/shell.sh /home/galadmin/shell.sh
ADD     image_scripts/tmux.conf /etc/tmux.conf
RUN     sudo chmod +x /home/galadmin/shell.sh

CMD     /bin/bash -c /home/galadmin/shell.sh
