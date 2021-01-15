# marceldiass/dotfiles test container
FROM ubuntu
MAINTAINER Marcel Dias <marceldiass@gmail.com>

RUN apt-get install -y software-properties-common wget zsh git curl python

COPY . /root/.dotfiles

RUN cd /root/.dotfiles && \
  rm -f ./git/gitconfig.symlink && \
  sed \
    -e "s/AUTHORNAME/dotfiles-demo/g" \
    -e "s/AUTHOREMAIL/dotfiles-demo/g" \
    -e "s/GIT_CREDENTIAL_HELPER/cache/g" \
    ./git/gitconfig.symlink.example > ./git/gitconfig.symlink && \
  git remote rm origin && \
  ./script/bootstrap && \
  zsh -c "source ~/.zshrc" || true

ENTRYPOINT zsh
