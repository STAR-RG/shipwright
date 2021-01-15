FROM tensorflow/tensorflow:latest-devel-gpu-py3

RUN apt-get update
RUN apt-get install -y ffmpeg git cmake

RUN pip install matplotlib pandas scikit-learn librosa seaborn hickle hypothesis[pandas]

RUN mkdir -p /home/data-science/projects
VOLUME /home/data-science/projects

RUN echo "c.NotebookApp.token = ''" >> ~/.jupyter/jupyter_notebook_config.py
RUN echo "c.NotebookApp.password = ''" >> ~/.jupyter/jupyter_notebook_config.py

WORKDIR /home/data-science/projects

RUN pip install git+https://github.com/Supervisor/supervisor && \
  mkdir -p /var/log/supervisor

ADD supervisor.conf /etc/supervisor.conf

EXPOSE 80
EXPOSE 6006

CMD supervisord -c /etc/supervisor.conf
