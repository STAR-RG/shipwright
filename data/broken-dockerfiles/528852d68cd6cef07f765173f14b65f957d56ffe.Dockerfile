FROM ros:kinetic
RUN apt-get update
RUN apt-get install build-essential -y
RUN apt-get install -y ros-kinetic-desktop
RUN apt-get install -y ros-kinetic-controller-interface ros-kinetic-controller-manager ros-kinetic-control-toolbox ros-kinetic-transmission-interface ros-kinetic-joint-limits-interface 

# gazebo7 installation 
#RUN curl -ssL http://get.gazebosim.org | sh
RUN apt-get install -y gazebo7 libgazebo7-dev && \
    apt-get install -y ros-kinetic-gazebo-ros-pkgs
RUN mkdir -p /root/.gazebo/models && cd /root/.gazebo/models && curl --header 'Host: bitbucket.org' --header 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:48.0) Gecko/20100101 Firefox/48.0' --header 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' --header 'Accept-Language: en-US,en;q=0.5' --header 'Referer: https://bitbucket.org/osrf/gazebo_models/downloads' --header 'Cookie: optimizelyEndUserId=oeu1465803474757r0.721831156094469; optimizelySegments=%7B%22176560975%22%3A%22direct%22%2C%22176875467%22%3A%22ff%22%2C%22176926205%22%3A%22false%22%2C%222634280139%22%3A%22none%22%2C%223170030171%22%3A%22true%22%2C%223174420008%22%3A%22true%22%2C%223206571187%22%3A%22returning%22%2C%225878270315%22%3A%22true%22%2C%225328870012%22%3A%22true%22%7D; optimizelyBuckets=%7B%7D; __utma=254090395.406115464.1465803475.1467745360.1470829794.7; __utmz=254090395.1470829794.7.4.utmcsr=github.com|utmccn=(referral)|utmcmd=referral|utmcct=/Roboy/ros_control/tree/develop; _ga=GA1.2.406115464.1465803475; ajs_user_id=null; ajs_group_id=null; ajs_anonymous_id=%22c6cd4644-3d9c-4c9b-b4af-4e52e6b90893%22; _sio=c6cd4644-3d9c-4c9b-b4af-4e52e6b90893; __atl_path=172.26.28.13.1465803425100406; csrftoken=nYG7piEgKojonjhK973ImhCJ8XRqy7TE; __utmv=254090395.|1=isBBUser=true=1; recently-viewed-repos_letrend=12205081; _gat_atl=1; __utmb=254090395.1.10.1470829794; __utmc=254090395; __utmt_atl=1; blocking-ads=true' --header 'Connection: keep-alive' --header 'Upgrade-Insecure-Requests: 1' 'https://bitbucket.org/osrf/gazebo_models/get/eb999f3c1642.zip' -o 'osrf-gazebo_models-eb999f3c1642.zip' -L
RUN apt-get install -y unzip
RUN cd /root/.gazebo/models && unzip osrf-gazebo_models-*.zip && mv osrf-gazebo_models-eb999f3c1642/* . && rm osrf-gazebo_models-eb999f3c1642 -r

# ros env variables
ENV ROS_ROOT=/opt/ros/kinetic/share/ros
ENV ROS_PACKAGE_PATH=/root/catkin_ws/src:/opt/ros/kinetic/share:/opt/ros/kinetic/stacks
ENV ROS_MASTER_URI=http://localhost:11311
ENV LD_LIBRARY_PATH=/root/catkin_ws/devel/lib:/root/catkin_ws/devel/lib/x86_64-linux-gnu:/opt/ros/kinetic/lib/x86_64-linux-gnu:/opt/ros/kinetic/lib
ENV CATKIN_TEST_RESULTS_DIR=/root/catkin_ws/build/test_results
ENV CPATH=/root/catkin_ws/devel/include:/opt/ros/kinetic/include
ENV ROS_TEST_RESULTS_DIR=/root/catkin_ws/build/test_results
ENV PATH=/root/catkin_ws/devel/bin:/opt/ros/kinetic/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV ROSLISP_PACKAGE_DIRECTORIES=/root/catkin_ws/devel/share/common-lisp
ENV ROS_DISTRO=kinetic
ENV PYTHONPATH=/root/catkin_ws/devel/lib/python2.7/dist-packages:/opt/ros/kinetic/lib/python2.7/dist-packages
ENV PKG_CONFIG_PATH=/root/catkin_ws/devel/lib/pkgconfig:/root/catkin_ws/devel/lib/x86_64-linux-gnu/pkgconfig:/opt/ros/kinetic/lib/x86_64-linux-gnu/pkgconfig:/opt/ros/kinetic/lib/pkgconfig
ENV CMAKE_PREFIX_PATH=/root/catkin_ws/devel:/opt/ros/kinetic
ENV ROS_ETC_DIR=/opt/ros/kinetic/etc/ros

# gazebo env variables
ENV GAZEBO_MODEL_PATH=/root/catkin_ws/src/roboy_simulation:/root/.gazebo/models
ENV ROS_HOSTNAME=localhost
ENV GAZEBO_MASTER_URI=http://localhost:11345
ENV GAZEBO_MODEL_DATABASE_URI=http://gazebosim.org/models
ENV GAZEBO_RESOURCE_PATH=/usr/share/gazebo-7:/usr/share/gazebo_models:${GAZEBO_RESOURCE_PATH}
ENV GAZEBO_PLUGIN_PATH=/usr/lib/x86_64-linux-gnu/gazebo-7/plugins:${GAZEBO_PLUGIN_PATH}
ENV GAZEBO_MODEL_PATH=/usr/share/gazebo-7/models:${GAZEBO_MODEL_PATH}
ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/lib/x86_64-linux-gnu/gazebo-7/plugins
ENV OGRE_RESOURCE_PATH=/usr/lib/x86_64-linux-gnu/OGRE-1.8.0

RUN apt-get install -y libncurses5-dev

WORKDIR /root/catkin_ws
# clone the actual roboy ros_control repo and build it
RUN git clone --recursive https://github.com/Roboy/roboy-ros-control /root/catkin_ws/roboy-ros-control
# install ftd2xx driver
RUN dpkg -i /root/catkin_ws/roboy-ros-control/src/flexrayusbinterface/lib/libftd2xx_1.1.12_amd64.deb
WORKDIR /root/catkin_ws/roboy-ros-control
RUN apt install -y ros-kinetic-ecl-geometry ros-kinetic-gazebo-ros-control wget
RUN sh -c 'echo "deb http://roboy.org/dists/stable/main/binary /" > /etc/apt/sources.list.d/roboy.list'
RUN wget -qO - http://roboy.org/dists/stable/main/binary/public.key | apt-key add -
RUN apt update
RUN apt install -y libcmaes
RUN catkin_make 
