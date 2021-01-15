FROM mbrt/rust
MAINTAINER Michele Bertasi

ADD fs/ /

# install pagkages
RUN apt-get update                                                          && \
    apt-get install -y ncurses-dev libtolua-dev exuberant-ctags                \
        git make bash-completion                                            && \
    ln -s /usr/include/lua5.2/ /usr/include/lua                             && \
    ln -s /usr/lib/x86_64-linux-gnu/liblua5.2.so /usr/lib/liblua.so         && \
    cd /tmp                                                                 && \
# bash completion for cargo
    cp /usr/local/etc/bash_completion.d/* /etc/bash_completion.d/           && \
# build and install vim
    git clone https://github.com/vim/vim.git                                && \
    cd vim                                                                  && \
    ./configure --with-features=huge --enable-luainterp                        \
        --enable-gui=no --without-x --prefix=/usr                           && \
    make VIMRUNTIMEDIR=/usr/share/vim/vim74                                 && \
    make install                                                            && \
# build and install racer
    cargo install --git https://github.com/phildawes/racer.git              && \
    cp /root/.cargo/bin/racer /usr/local/bin/racer                          && \
# build and install rustfmt
    cargo install rustfmt                                                   && \
    cp /root/.cargo/bin/rustfmt /usr/local/bin/rustfmt                      && \
    cp /root/.cargo/bin/cargo-fmt /usr/local/bin/cargo-fmt                  && \
# source dir
    mkdir /source                                                           && \
# add dev user
    adduser dev --disabled-password --gecos ""                              && \
    echo "ALL            ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers         && \
    chown -R dev:dev /home/dev /source                                      && \
# cleanup
    apt-get remove -y ncurses-dev                                           && \
    apt-get autoremove -y                                                   && \
    apt-get clean                                                           && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/.cargo

USER dev
ENV HOME=/home/dev                                                             \
    USER=dev                                                                   \
    RUST_SRC_PATH=/usr/local/src/rust/src/

# install vim plugins
RUN mkdir -p ~/.vim/bundle                                                  && \
    cd  ~/.vim/bundle                                                       && \
    git clone --depth 1 https://github.com/gmarik/Vundle.vim.git            && \
    git clone --depth 1 https://github.com/majutsushi/tagbar.git            && \
    git clone --depth 1 https://github.com/Shougo/neocomplete.vim.git       && \
    git clone --depth 1 https://github.com/scrooloose/nerdtree.git          && \
    git clone --depth 1 https://github.com/bling/vim-airline.git            && \
    git clone --depth 1 https://github.com/tpope/vim-fugitive.git           && \
    git clone --depth 1 https://github.com/jistr/vim-nerdtree-tabs.git      && \
    git clone --depth 1 https://github.com/mbbill/undotree.git              && \
    git clone --depth 1 https://github.com/Lokaltog/vim-easymotion.git      && \
    git clone --depth 1 https://github.com/scrooloose/nerdcommenter.git     && \
    git clone --depth 1 https://github.com/scrooloose/syntastic.git         && \
    git clone --depth 1 https://github.com/milkypostman/vim-togglelist.git  && \
    git clone --depth 1 https://github.com/ctrlpvim/ctrlp.vim               && \
    git clone --depth 1 https://github.com/cespare/vim-toml.git             && \
    git clone --depth 1 https://github.com/racer-rust/vim-racer.git         && \
    git clone --depth 1 https://github.com/rust-lang/rust.vim.git           && \
    vim +PluginInstall +qall                                                && \
# set vim as git editor
    git config --global core.editor vim                                     && \
# cleanup
    rm -rf Vundle.vim/.git tagbar/.git neocomplete.vim/.git nerdtree/.git      \
        vim-airline/.git vim-fugitive/.git vim-nerdtree-tabs/.git              \
        undotree/.git vim-easymotion/.git nerdcommenter/.git                   \
        syntastic/.git vim-togglelist/.git ctrlp.vim/.git vim-toml/.git        \
        vim-racer/.git rust.vim/.git

VOLUME ["/source"]
WORKDIR /source
