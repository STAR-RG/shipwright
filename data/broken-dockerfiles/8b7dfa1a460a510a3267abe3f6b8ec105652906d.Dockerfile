FROM kaixhin/cuda-torch:latest

MAINTAINER Falcon Dai <me@falcondai.com>

# install NLTK
RUN easy_install nltk

# install tokenizers
RUN python -c "import nltk; nltk.download('punkt')"

WORKDIR /root
