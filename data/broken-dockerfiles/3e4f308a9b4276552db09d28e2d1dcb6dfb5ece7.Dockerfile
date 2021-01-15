FROM andrewosh/binder-base

MAINTAINER Fabien Benureau <fabien.benureau@gmail.com>

USER main

# switching to Python3
ADD requirements.txt requirements.txt
ENV PATH $HOME/anaconda2/envs/python3/bin/:$PATH
RUN python -m ipykernel install --user --name python3 --display-name "Python 3"
RUN pip install -r requirements.txt
RUN jupyter nbextension enable --py --sys-prefix widgetsnbextension
