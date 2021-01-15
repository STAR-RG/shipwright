FROM fadawar/docker-pyqt5-qml

MAINTAINER fadawar <fadawar@gmail.com>

# Install additional PyQt5 packages
RUN apt-get install -y \
        python3-pyqt5.qtmultimedia \
        # Install Gstreamer
        gstreamer1.0-libav \
        gstreamer1.0-plugins-bad \
        gstreamer1.0-plugins-base \
        gstreamer1.0-plugins-base-apps \
        gstreamer1.0-plugins-good \
        gstreamer1.0-plugins-ugly \
        alsa-base \
        alsa-utils
