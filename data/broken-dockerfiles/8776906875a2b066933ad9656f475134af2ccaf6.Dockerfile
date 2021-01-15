FROM ruby

USER root

RUN apt-get update && apt-get install -y emacs25-nox vim-nox mlocate locales-all tmux gnuplot && gem install numo-gnuplot\
    git config --global alias.co checkout && \
    git config --global alias.br branch && \
    git config --global alias.ci commit && \
    git config --global alias.st status
