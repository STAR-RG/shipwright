# Define base image
FROM centos:latest
# Setting up environment
RUN rpm --import https://mirror.go-repo.io/centos/RPM-GPG-KEY-GO-REPO && \
    curl -s https://mirror.go-repo.io/centos/go-repo.repo | tee /etc/yum.repos.d/go-repo.repo && \
    yum update -y && \
    yum install -y git golang sudo bash psmisc bash-completion speex pkg-config wget && \
    wget https://www.nasm.us/pub/nasm/releasebuilds/2.14.02/linux/nasm-2.14.02-0.fc27.x86_64.rpm && \
    rpm -i ./nasm-2.14.02-0.fc27.x86_64.rpm && \
# Download source code
    mkdir /root/software && \
    cd /root/software && \
    git clone -b 2.0release https://github.com/ossrs/srs.git && \
    git clone https://github.com/ossrs/srs-ngb.git && \
    git clone https://github.com/ossrs/go-oryx.git && \
    git clone https://github.com/winlinvip/videojs-flow.git && \
# Download Golang libs
    go get github.com/ossrs/go-oryx && \
    go get github.com/ossrs/go-oryx-lib && \
    mkdir /root/go/src/golang.org && \
    mkdir /root/go/src/golang.org/x && \
    cd /root/go/src/golang.org/x && \
    git clone https://github.com/golang/net.git && \
# Patch the system checking code,and do some fixing
    touch /etc/redhat-release && \
    sed -i '40c ret=$?; if [[ 0 -eq $ret ]]; then' /root/software/srs/trunk/auto/depends.sh && \
# Install SRS
    cd /root/software/srs/trunk && \
    sudo ./configure --jobs=4 --full && \
    sudo make -j4 && \
    yum clean all && \
# Create soft links for SRS
    cd /root && \
    ln -s /root/software/srs/trunk srs && \
# Build Go-oryx
    cd /root/software/go-oryx && \
    ./build.sh && \
    cd /root && \
# Create soft links for go-oryx
    ln -s /root/software/go-oryx/shell go-oryx && \
# Build and link http proxy
    cd /root/software/go-oryx/httpx-static && \
    go build main.go && \
    cd /root && \
    ln -s /root/software/go-oryx/httpx-static https_proxy && \
#Build and link websocket proxy
    cd /root/software/videojs-flow/demo && \
    go build server.go && \
    go build mse.go && \
# Add the SRS console
    cd /root/software/srs-ngb/trunk/research && \
    \cp -rf srs-console /root/software/srs/trunk/objs/nginx/html && \
    rm -rf /root/software/srs/trunk/objs/nginx/html/srs-console/js/README.md && \
    cd /root/software/srs-ngb/trunk/src && \
    \cp -rf * /root/software/srs/trunk/objs/nginx/html/srs-console/js/ && \
    cd /root && \
# Create soft links
    ln -s /root/software/videojs-flow/demo videojs-flow && \
    ln -s /root/software/srs-ngb srs-ngb && \
# Create necessary folders
    mkdir /root/sample_conf && \
    mkdir /root/logs && \
    mkdir /root/logs/srs_log && \
    mkdir /root/logs/go-oryx_log && \
    mkdir /root/logs/mse_log && \
    mkdir /root/shell && \
    mkdir /root/cert && \
# Clean up
    yum autoremove -y gcc gcc-c++ kernel-headers git golang nasm automake autoconf make patch unzip && \
    rm -rf /root/go && \
    cd /root/software && \
    find . -name '*.c' -type f -exec rm -rf {} \; && \
    find . -name '*.o' -type f -exec rm -rf {} \; && \
    find . -name '*.h' -type f -exec rm -rf {} \; && \
    find . -name '*.cpp' -type f -exec rm -rf {} \; && \
    find . -name '*.hpp' -type f -exec rm -rf {} \; && \
    find . -name '*.go' -type f -exec rm -rf {} \; && \
    find . -name '*.zip' -type f -exec rm -rf {} \; && \
    find . -type d -empty -delete
# Add conf files,scripts
ADD conf /root/sample_conf
ADD shell /root/shell
ADD README.md /root
# Copy and link the files
RUN cd /root/software/srs/trunk/conf && \
    mv srs.conf srs.conf.bak && \
    ln -s /root/sample_conf/srsconfig.conf srs.conf && \
    ln -s /root/sample_conf/srsedge.conf srsedge.conf  && \
    cd /root/software/go-oryx/conf && \
    mv srs.conf srs.conf.bak && \
    mv bms.conf /root/sample_conf/go-oryx_bms.conf && \
    ln -s /root/sample_conf/go-oryx_bms.conf srs.conf && \
    chmod -R 777 /root/shell && \
    ln -s /root/shell/start_srs.sh /root/start.sh && \
    ln -s /root/shell/stop.sh /root/stop.sh && \
    ln -s /root/shell/start_srs_edge.sh /root/start_edge.sh
# Setting up volumes
VOLUME ["/root/sample_conf","/root/shell","/root/logs","/root/software/srs/trunk/objs/nginx/html"]
# Expose ports
EXPOSE 1935
EXPOSE 1985
EXPOSE 8080
EXPOSE 8082
# Startup Command
CMD /bin/bash -c /root/start.sh
