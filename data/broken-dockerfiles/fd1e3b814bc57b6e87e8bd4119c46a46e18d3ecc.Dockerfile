FROM ubuntu:15.10
RUN apt-get update
RUN apt-get install -y software-properties-common 

RUN add-apt-repository ppa:neovim-ppa/unstable && \
    apt-get update && \
    locale-gen en_US.UTF-8 && \
    apt-get install -y neovim zsh httpie ssh git ruby htop curl gnupg2 \
            git-crypt apt-transport-https sudo python-pip  mercurial \
            make binutils bison gcc build-essential


RUN useradd -m ryan && \
    echo "ryan ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    chsh -s /bin/zsh ryan

# Replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/zsh /bin/sh

# Install Docker so we can link it in
RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D && \
    echo "deb https://apt.dockerproject.org/repo ubuntu-wily main" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && apt-get install -y docker-engine


ADD files/ssh/main-id_rsa.pub /home/ryan/.ssh/authorized_keys

RUN chown -R ryan:ryan /home/ryan/.ssh



# Install Dotfiles
ADD . /home/ryan/.dotfiles
USER ryan
RUN cd ~/.dotfiles && ./install.rb && \
    /bin/zsh ~/.dotfiles/zsh/load-antigen.zsh

USER root
RUN chown -R ryan:ryan /home/ryan
USER ryan

# Install nvm with node and npm
ENV NVM_DIR /home/ryan/.nvm
ENV NODE_VERSION 5.5
ENV IS_DOCKER true

RUN curl https://raw.githubusercontent.com/creationix/nvm/v0.29.0/install.sh | bash \
    && source $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default \
    && npm -g install typescript tslint eslint nip \
    && cd ~/.dotfiles \
    && git reset --hard # Undo NVM install modifying zshrc

# Install powerline for tmux
RUN pip install --user powerline-status

RUN cd /tmp && git clone https://github.com/tmux/tmux.git && cd tmux && \
    sudo apt-get install -y libevent-dev automake pkg-config libncurses5-dev && \
    git reset --hard 2.0 && \
    curl https://gist.githubusercontent.com/JohnMorales/0579990993f6dec19e83/raw/75b073e85f3d539ed24907f1615d9e0fa3e303f4/tmux-24.diff | git apply && \
    ./autogen.sh && ./configure && make && sudo make install && \
    rm -rf /tmp/tmux

# Install nvim plugins

RUN sudo apt-get install -y python-dev && \
    pip2 install --user neovim


RUN mkdir /home/ryan/.config && \
    ln -s /home/ryan/.dotfiles/nvim /home/ryan/.config/nvim && \
    ln -s /home/ryan/.dotfiles/nvimrc /home/ryan/.config/nvim/init.vim && \
    curl -fLo ~/.nvim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim && \
    nvim +PlugInstall +qall --headless


EXPOSE 22
VOLUME /src

ADD start.sh /

USER root
CMD ["/start.sh"]
