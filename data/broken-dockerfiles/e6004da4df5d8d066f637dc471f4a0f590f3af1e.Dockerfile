FROM gcr.io/tensorflow/tensorflow

RUN apt-get update -y
RUN apt-get install python-tk -y
RUN apt-get clean
ADD requirements.txt /notebooks
RUN pip install -r /notebooks/requirements.txt
