FROM nvidia/cuda:8.0-devel-ubuntu16.04
MAINTAINER Karthik Ramasamy <karthikv2k@gmail.com>

RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install -y libopenblas-dev python-numpy python-dev swig git python-pip wget vim python-tk
RUN apt-get -y autoremove
RUN apt-get clean

RUN pip install --no-cache-dir --upgrade --ignore-installed pip
RUN pip install cython matplotlib pandas jupyter sklearn scipy

# Pre-populate font list to avoid warning on first import of matplotlib.pyplot
RUN python -c "import matplotlib.pyplot"

WORKDIR /opt
RUN git clone --depth=1 https://github.com/facebookresearch/faiss
WORKDIR /opt/faiss

ENV BLASLDFLAGS /usr/lib/libopenblas.so.0

RUN mv example_makefiles/makefile.inc.Linux ./makefile.inc

RUN make tests/test_blas -j $(nproc) && \
    make -j $(nproc) && \
    make tests/demo_sift1M -j $(nproc)

RUN make py

RUN cd gpu && \
    make -j $(nproc) && \
    make test/demo_ivfpq_indexing_gpu && \
    make py

RUN echo "export PYTHONPATH=\$PYTHONPATH:/opt/faiss" >> ~/.bashrc
ENV PYTHONPATH "$PYTHONPATH:/opt/faiss"
CMD ["jupyter-notebook",  "--no-browser", "--ip='*'", "--notebook-dir=/", "--allow-root", "--port=8000"]
