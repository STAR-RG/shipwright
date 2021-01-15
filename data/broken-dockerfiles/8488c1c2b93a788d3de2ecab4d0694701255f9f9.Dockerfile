FROM ubuntu:18.04  
MAINTAINER tatiana.ovsiannikova <tatiana.ovsiannikova@cern.ch>
LABEL description="ostap HEP framework"

RUN #!/bin/bash
RUN  apt-get update\ 
	&& apt-get  install -y dpkg-dev  git wget tar make binutils
RUN wget -nv http://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
RUN bash miniconda.sh -b -p /root/miniconda
ENV PATH="/root/miniconda/bin:${PATH}"
RUN echo $PATH
RUN conda config --set always_yes yes --set changeps1 no
RUN conda config --add channels conda-forge
RUN conda create -q -n ostapenv  root_base root-binaries root-dependencies gsl  future configparser  numpy scipy pathos dill multiprocess ppft terminaltables binutils-meta c-compiler compilers cxx-compiler fortran-compiler python ipython cmake


ADD . /ostap
WORKDIR /ostap

ENV PATH="/root/miniconda/envs/ostapenv/bin:${PATH}"

RUN  mkdir build && cd build && cmake .. -DCMAKE_INSTALL_PREFIX=./INSTALL/ && make -j12 && make install && echo "source build/INSTALL/thisostap.sh" >> ~/.bashrc

CMD /bin/bash
