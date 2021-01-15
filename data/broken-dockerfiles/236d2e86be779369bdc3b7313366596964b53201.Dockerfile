FROM ubuntu:16.04

RUN apt-get clean && apt-get -y update && apt-get install -y locales && locale-gen en_US.UTF-8 && update-locale && apt-get install -y libblas3 && apt-get install -y libxml2 \
&& (echo "deb http://cran.mtu.edu/bin/linux/ubuntu xenial/" >> /etc/apt/sources.list && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9) && \
apt-get update -q && apt-get upgrade -y -q && apt-get install -y -q --no-install-recommends r-base \
                                              r-base-dev \
                                              gdebi-core \
                                              libapparmor1  \
                                              sudo \
                                              libcurl4-openssl-dev \
                                              libssl1.0.0 \
                                              build-essential \
                                              cmake \
                                              curl \
                                              vim \
                                              ca-certificates \
                  && apt-get clean \
                  && rm -rf /tmp/* /var/tmp/* \
                  && rm -rf /var/lib/apt/lists/*

RUN sudo su - -c "R -e \"install.packages('tidyverse', repos='http://cran.rstudio.com/')\""
RUN sudo su - -c "R -e \"install.packages('lubridate', repos='http://cran.rstudio.com/')\""
RUN sudo su - -c "R -e \"install.packages('caret', repos='http://cran.rstudio.com/')\""
RUN sudo su - -c "R -e \"install.packages('randomForest', repos='http://cran.rstudio.com/')\""
RUN sudo su - -c "R -e \"install.packages('xgboost', repos='http://cran.rstudio.com/')\""

RUN curl -o ~/miniconda.sh -O  https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh  && \
     chmod +x ~/miniconda.sh && \
     ~/miniconda.sh -b -p /usr/conda && \     
     rm ~/miniconda.sh && \
     /usr/conda/bin/conda install -y numpy scipy pandas scikit-learn joblib tqdm ipython pip cython numba && usr/conda/bin/conda install -y pytorch-cpu -c pytorch && \
     /usr/conda/bin/conda clean -ya && \ 
     /usr/conda/bin/pip install xgboost lightgbm catboost statsmodels && \ 
     /usr/conda/bin/pip install --upgrade tensorflow && \
     /usr/conda/bin/pip install keras

RUN /usr/conda/bin/pip install --upgrade --force xlearn ml_metrics tsfresh mlxtend