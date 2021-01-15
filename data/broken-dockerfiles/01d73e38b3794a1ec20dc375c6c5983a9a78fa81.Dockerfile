FROM nickstenning/java7

RUN apt-get install -y curl unzip vim

RUN adduser hipster --home /home/hipster --gecos "" --disabled-password

WORKDIR /home/hipster
USER hipster
ENV HOME /home/hipster
RUN mkdir /home/hipster/bin

# gvm
RUN curl -s get.gvmtool.net | bash

# frameworks
RUN bash -c "source ~/.gvm/bin/gvm-init.sh && gvm install gradle; exit 0"
RUN bash -c "source ~/.gvm/bin/gvm-init.sh && gvm install lazybones; exit 0"
RUN bash -c "source ~/.gvm/bin/gvm-init.sh && gvm install vertx; exit 0"
RUN bash -c "source ~/.gvm/bin/gvm-init.sh && gvm install springboot; exit 0"
RUN wget https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein -O ~/bin/lein && chmod +x ~/bin/lein

# home
RUN echo "source /home/hipster/.gvm/bin/gvm-init.sh" >> /home/hipster/.bashrc
RUN echo "export PATH=$PATH:/home/hipster/bin" >> /home/hipster/.bashrc

EXPOSE 8080

CMD /bin/bash
