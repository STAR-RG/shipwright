FROM tensorflow/tensorflow:0.11.0rc2

RUN apt-get update
RUN apt-get -y install git

RUN pip install prettytensor
RUN pip install pandas
RUN pip install plotly
RUN pip install pdoc
RUN pip install mako
RUN pip install markdown
RUN pip install decorator==4.0.9
RUN pip install tflearn
RUN pip install asq==1.2.1
RUN pip install pytest
RUN pip install pytest-sugar
RUN pip install fn
