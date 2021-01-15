FROM vaeum/ubuntu-python3-pip3

RUN apt-get update

RUN apt-get install -y curl
RUN apt-get install -y apt-transport-https
RUN apt-get install -y git-core

RUN pip3 install jupyter  
RUN pip3 install requests && \
    pip3 install pandas && \
    pip3 install fbprophet


RUN curl -sL https://deb.nodesource.com/setup_10.x |  bash -
RUN apt-get install --yes nodejs

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg |  apt-key add - 
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" |  tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update
RUN apt-get install yarn

RUN npm install --global lerna

#COPY . /nteract

RUN git clone https://github.com/teamdigitale/nteract.git

WORKDIR /nteract

RUN yarn

RUN cd applications/jupyter-extension && \
    pip3 install -e .  && \ 
    jupyter serverextension enable nteract_on_jupyter && \
    lerna run build:asap --scope nteract-on-jupyter --stream

EXPOSE 8888 

CMD ["jupyter", "nteract","--ip=0.0.0.0", "--allow-root"]