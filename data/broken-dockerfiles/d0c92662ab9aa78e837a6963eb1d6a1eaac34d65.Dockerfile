FROM ubuntu:19.04

# Dependencies
RUN apt update \
  && apt install -y curl wget git gnupg zsh sudo snapd locales \
  apt-transport-https ca-certificates gnupg-agent software-properties-common && \
# User Setup
  useradd -u 1000 -d /home/kylecoberly -m -s /bin/zsh kylecoberly && echo "kylecoberly:kylecoberly" | chpasswd && adduser kylecoberly sudo && \
  chown -R kylecoberly:kylecoberly /home/kylecoberly && \
  echo 'kylecoberly ALL=(ALL) NOPASSWD: ALL' | sudo EDITOR='tee -a' visudo && \
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - # apt-key doesn't output a terminal, can't chain anything afterward

WORKDIR /home/kylecoberly
ENV HOME /home/kylecoberly
USER kylecoberly
COPY --chown=kylecoberly:kylecoberly ./dotfiles/init.vim $HOME/.config/nvim/init.vim
COPY --chown=kylecoberly:kylecoberly ./dotfiles/coberly-agnoster.zsh-theme $HOME

# Heroku Toolbelt & Oh-My-Zsh & Docker Compose
RUN sudo locale-gen en_US.UTF-8 && \
  curl https://cli-assets.heroku.com/install.sh | sh && \
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
  sudo curl -L "https://github.com/docker/compose/releases/download/1.25.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
  sudo chmod +x /usr/local/bin/docker-compose && \
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
# Ruby
  gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB && \
  curl -sSL https://get.rvm.io | bash -s stable --rails && \
  /bin/bash -l -c "source .rvm/scripts/rvm" && \
  /bin/bash -l -c "gem install pry" && \
# Node
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.2/install.sh | bash && \
  export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")" && \
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && \
  nvm install 12 && \
  nvm alias default $NODE_VERSION && \
  nvm use default && \
  npm i -g eslint knex mocha jest nodemon lite-server typescript yarn firebase-tools && \
  yarn global add ember-cli @vue/cli && \
# Packages
  sudo apt update && \
  sudo apt install -y iproute2 xclip tree nmap build-essential \
  ranger tmux fonts-powerline \
  neovim python-neovim python3-neovim \
  docker-ce docker-ce-cli containerd.io && \
# Theme
  mv $HOME/coberly-agnoster.zsh-theme $HOME/.oh-my-zsh/themes/coberly-agnoster.zsh-theme && \
# Vim
  nvim +PlugInstall +qall

ENTRYPOINT ["zsh", "-l"]
