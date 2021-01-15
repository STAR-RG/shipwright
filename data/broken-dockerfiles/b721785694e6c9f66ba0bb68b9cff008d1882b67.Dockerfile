FROM resin/%%RESIN_MACHINE_NAME%%-buildpack-deps

MAINTAINER Spyros Maniatopoulos spmaniato@gmail.com

# Switch on systemd init system in container and set various other variables
ENV INITSYSTEM="on" \
    TERM="xterm" \
    PYTHONIOENCODING="UTF-8"

# Variables for ROS distribution, configuration, and relevant directories
ENV ROS_DISTRO="indigo" \
    ROS_CONFIG="ros_base"
ENV CATKIN_WS="/usr/catkin_ws" \
    ROS_INSTALL_DIR="/opt/ros/$ROS_DISTRO"

RUN apt-get update && apt-get install -yq --no-install-recommends \
    python-dev python-pip

# Install ROS-related Python tools
COPY ./requirements.txt .
RUN pip install -r requirements.txt && rm requirements.txt

RUN rosdep init \
    && rosdep update

RUN mkdir -p $CATKIN_WS/src $ROS_INSTALL_DIR

WORKDIR $CATKIN_WS

RUN rosinstall_generator $ROS_CONFIG --rosdistro $ROS_DISTRO \
    --deps --tar > .rosinstall \
    && wstool init src .rosinstall \
    && rosdep install --from-paths src --ignore-src --rosdistro $ROS_DISTRO -y \
       --skip-keys python-rosdep \
       --skip-keys python-rospkg \
       --skip-keys python-catkin-pkg \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN catkin init \
    && catkin config --install --install-space $ROS_INSTALL_DIR \
       --cmake-args -DCMAKE_BUILD_TYPE=Release \
    && catkin build --no-status --no-summary --no-notify \
    && catkin clean -y --logs --build --devel

WORKDIR /usr

RUN rm -rf $CATKIN_WS

COPY ./ros_entrypoint.sh .

ENTRYPOINT ["bash", "ros_entrypoint.sh"]

CMD ["bash"]
