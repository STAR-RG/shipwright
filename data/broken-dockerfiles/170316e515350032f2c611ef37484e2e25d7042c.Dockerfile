FROM ubuntu:15.10
MAINTAINER Maxim Kolodyazhny <mw26@rydlab.ru>

VOLUME /opt/share

RUN apt-get update\
&& apt-get -y install apt-utils\
&& apt-get -y install make\
&& apt-get -y install gcc\ 
&& apt-get -y install perl\
\
&& apt-get -y install curl\
&& curl -L http://cpanmin.us | perl - App::cpanminus\
&& cpanm IPC::Run\ 
&& cpanm JSON::PP\
\
&& apt-get -y install haskell-platform\
\
&& apt-get -y install erlang\
\
&& apt-get -y install php5-cli\
\
&& apt-get -y install python2.7\
&& apt-get -y install python3.5\
&& ln -s /usr/bin/python3.5 /usr/bin/python3\
\
&& apt-get -y install ruby1.9.1\
\
&& apt-get -y install ruby2.2\
\
&& apt-get -y install nodejs\
\
&& curl -o /usr/bin/golfscript.rb www.golfscript.com/golfscript/golfscript.rb\
&& chmod 751 /usr/bin/golfscript.rb\
\
&& apt-get install -y unzip\
\
&& curl -LOk https://github.com/catseye/Befunge-93/archive/master.zip\
&& unzip master.zip\
&& make -C Befunge-93-master\
&& cp ./Befunge-93-master/bin/bef /usr/bin/\
&& rm -rf ./Befunge-93-master/\
&& rm master.zip\
\
&& curl -LOk https://github.com/isaacg1/pyth/archive/master.zip\
&& unzip master.zip\
&& cp pyth-master/*.py /usr/bin/\
&& rm -rf pyth-master/\
&& rm master.zip\
\
&& curl -L http://downloads.sourceforge.net/project/cjam/cjam-0.6.5/cjam-0.6.5.jar -o /usr/bin/cjam-0.6.5.jar\
&& chmod +x /usr/bin/cjam-0.6.5.jar\
\
&& apt-get install -y julia\
\
&& apt-get install -y lua5.3\
&& apt-get purge -y curl\
&& apt-get purge -y unzip\
&& chmod 755 /opt/share -R\
&& locale-gen en_US.UTF-8

USER nobody
WORKDIR /dev/shm
ENV TMPDIR="/dev/shm"
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8     
