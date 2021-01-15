FROM golang:1.12.1-alpine

LABEL maintainer "https://github.com/blacktop"

RUN apk add --no-cache ca-certificates git python3 ctags tzdata bash neovim neovim-doc

######################
### SETUP ZSH/TMUX ###
######################

RUN apk add --no-cache zsh tmux && rm -rf /tmp/*

RUN git clone git://github.com/robbyrussell/oh-my-zsh.git /root/.oh-my-zsh
RUN git clone https://github.com/tmux-plugins/tpm /root/.tmux/plugins/tpm
RUN git clone https://github.com/tmux-plugins/tmux-cpu /root/.tmux/plugins/tmux-cpu
RUN git clone https://github.com/tmux-plugins/tmux-prefix-highlight /root/.tmux/plugins/tmux-prefix-highlight

COPY zshrc /root/.zshrc
COPY tmux.conf /root/.tmux.conf
COPY tmux.linux.conf /root/.tmux.linux.conf

####################
### SETUP NEOVIM ###
####################

# Install vim plugin manager
RUN apk add --no-cache curl \
  && curl -fLo /root/.local/share/nvim/site/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
  && rm -rf /tmp/* \
  && apk del --purge curl

# Install vim plugins
RUN apk add --no-cache -t .build-deps build-base python3-dev \
  && pip3 install -U neovim \
  && rm -rf /tmp/* \
  && apk del --purge .build-deps

RUN mkdir -p /root/.config/nvim
COPY vimrc /root/.config/nvim/init.vim
RUN ln -s /root/.config/nvim/init.vim /root/.vimrc

COPY nvim/snippets /root/.config/nvim/snippets
COPY nvim/spell /root/.config/nvim/spell

# Go get popular golang libs
RUN echo "===> go get popular golang libs..." \
  && go get -u github.com/go-delve/delve/cmd/dlv \
  && go get -u github.com/sirupsen/logrus \
  && go get -u github.com/spf13/cobra/cobra \
  && go get -u github.com/golang/dep/cmd/dep \
  && go get -u github.com/fatih/structs \
  && go get -u github.com/gorilla/mux \
  && go get -u github.com/gorilla/handlers \
  && go get -u github.com/parnurzeal/gorequest \
  && go get -u github.com/urfave/cli \
  && go get -u github.com/apex/log/...
# Go get vim-go binaries
RUN echo "===> get vim-go binaries..." \
  && go get -u -v github.com/klauspost/asmfmt/cmd/asmfmt \
  && go get -u -v github.com/kisielk/errcheck \
  && go get -u -v github.com/davidrjenni/reftools/cmd/fillstruct \
  && go get -u -v github.com/stamblerre/gocode \
  && go get -u -v github.com/rogpeppe/godef \
  && go get -u -v github.com/zmb3/gogetdoc \
  && go get -u -v golang.org/x/tools/cmd/goimports \
  && go get -u -v golang.org/x/lint/golint \
  && go get -u -v golang.org/x/tools/cmd/gopls \
  && go get -u -v github.com/alecthomas/gometalinter \
  && go get -u -v github.com/golangci/golangci-lint/cmd/golangci-lint \
  && go get -u -v github.com/fatih/gomodifytags \
  && go get -u -v golang.org/x/tools/cmd/gorename \
  && go get -u -v github.com/jstemmer/gotags \
  && go get -u -v golang.org/x/tools/cmd/guru \
  && go get -u -v github.com/josharian/impl \
  && go get -u -v honnef.co/go/tools/cmd/keyify \
  && go get -u -v github.com/fatih/motion \
  && go get -u -v github.com/koron/iferr

# Install nvim plugins
RUN apk add --no-cache -t .build-deps build-base python3-dev \
  && echo "===> neovim PlugInstall..." \
  && nvim -i NONE -c PlugInstall -c quitall > /dev/null 2>&1 \
  && echo "===> neovim UpdateRemotePlugins..." \
  && nvim -i NONE -c UpdateRemotePlugins -c quitall > /dev/null 2>&1 \
  && rm -rf /tmp/* \
  && apk del --purge .build-deps

# Get powerline font just in case (to be installed on the docker host)
RUN apk add --no-cache wget \
  && mkdir /root/powerline \
  && cd /root/powerline \
  && wget https://github.com/powerline/fonts/raw/master/Meslo%20Slashed/Meslo%20LG%20M%20Regular%20for%20Powerline.ttf \
  && rm -rf /tmp/* \
  && apk del --purge wget

ENV TERM=screen-256color
# Setup Language Environtment
ENV LANG="C.UTF-8"
ENV LC_COLLATE="C.UTF-8"
ENV LC_CTYPE="C.UTF-8"
ENV LC_MESSAGES="C.UTF-8"
ENV LC_MONETARY="C.UTF-8"
ENV LC_NUMERIC="C.UTF-8"
ENV LC_TIME="C.UTF-8"

# RUN go get -d -v github.com/maliceio/engine/...

ENTRYPOINT ["tmux"]
