FROM tianon/centos:5.9
MAINTAINER John Regan <john@jrjrtech.com>

RUN rpm -i http://dl.fedoraproject.org/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm
RUN yum -y update
RUN yum -y install gcc git curl make zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel openssl openssl-devel


RUN useradd -m python_user

WORKDIR /home/python_user
USER python_user

RUN git clone git://github.com/yyuu/pyenv.git .pyenv

ENV HOME  /home/python_user
ENV PYENV_ROOT $HOME/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH

RUN pyenv install 2.7.6
RUN pyenv global 2.7.6
RUN pyenv rehash

RUN pip install --egg scons

ADD info.py /home/python_user/info.py

ENTRYPOINT ["python"]
CMD ["info.py"]
