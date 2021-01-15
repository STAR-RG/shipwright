
FROM gcr.io/tensorflow/tensorflow:1.5.0-py3
   #Install packages
   RUN DEBIAN_FRONTEND=noninteractive apt-get update
   RUN DEBIAN_FRONTEND=noninteractive apt-get -qqy install wget python3-pip git
   RUN DEBIAN_FRONTEND=noninteractive pip3 install --upgrade pip
   RUN DEBIAN_FRONTEND=noninteractive pip3 install tqdm seaborn keras edward autograd pymc3 gym gensim

   #Remove examples
   RUN rm -Rf *