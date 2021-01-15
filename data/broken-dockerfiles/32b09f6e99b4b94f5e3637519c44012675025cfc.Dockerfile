FROM debian:sid

RUN dpkg --add-architecture i386 >/dev/null 2>&1 && \
	apt-get update -y >/dev/null 2>&1 && \
	yes | apt-get install -y build-essential gettext gawk libssl-dev texinfo libgmp10 libmpfr6 libmpc3 cpio rsync gcc-7-multilib flex bc bison grub grub-pc-bin bash-completion xorriso gcc gdb python cmake zip unzip curl cppcheck rubygems cscope doxygen graphviz git xvfb x11vnc qemu-system openbox libgmp-dev libmpfr-dev libmpc-dev >/dev/null \
	&& apt-get clean >/dev/null 2>&1 && rm -rf /var/lib/apt/lists/* /tmp/*

ENV WINDOW_MANAGER="openbox"

RUN git clone https://github.com/novnc/noVNC.git /opt/novnc && git clone https://github.com/novnc/websockify /opt/novnc/utils/websockify
COPY data/novnc-index.html /opt/novnc/index.html

COPY data/start-vnc-session.sh /usr/bin/
RUN chmod +x /usr/bin/start-vnc-session.sh

RUN useradd builder -m -u 1000
RUN passwd -d builder

RUN gem install mdl

USER builder
WORKDIR /usr/src

RUN echo "export DISPLAY=:0" >> ~/.bashrc
RUN echo "[ ! -e /tmp/.X0-lock ] && (/usr/bin/start-vnc-session.sh &> /tmp/display-\${DISPLAY}.log)" >> ~/.bashrc

CMD ["./scripts/build.sh"]
