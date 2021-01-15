FROM library/debian:latest

RUN apt-get update
RUN apt-get install -y wget
RUN apt-get install -y
RUN apt-get install -y wget build-essential libbz2-dev \
    libc6-dev libdb-dev libexpat1-dev libffi-dev \
    libncursesw5-dev libreadline-dev libsqlite3-dev libssl-dev \
    libtinfo-dev zlib1g-dev python3-setuptools python-setuptools python-pip \
    virtualenv build-essential autoconf libtool pkg-config \
    python-opengl python-imaging python-pyrex python-pyside.qtopengl \
    idle-python2.7 qt4-dev-tools qt4-designer libqtgui4 libqtcore4 libqt4-xml \
    libqt4-test libqt4-script libqt4-network libqt4-dbus python-qt4 \
    python-qt4-gl libgle3 python-dev libssl-dev curl --no-install-recommends

RUN apt-get install -y python3 python3-dev

RUN mkdir le
COPY src/ le/src/
COPY test/ le/test/
COPY setup.py le/setup.py

RUN cd le && python setup.py build && python setup.py install


