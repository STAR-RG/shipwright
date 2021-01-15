# Make sure you have a recent docker version
# Install nvidia-docker https://github.com/NVIDIA/nvidia-docker
# Build this dockerfile into an image
# Run the image
# Go to localhost:9999/lab to use Jupyter Lab with Tectosaur
# Try the Tectosaur examples
FROM nvidia/cuda:9.0-devel
RUN nvcc -V

RUN apt-get update --fix-missing && \
    apt-get install -y wget bzip2 ca-certificates curl git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-4.5.11-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda clean -tipsy && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

ENV PATH /opt/conda/bin:$PATH

RUN apt-get update && \
    apt-get install -y gfortran libcapnp-dev gcc build-essential

RUN conda install -c conda-forge pycapnp numpy jupyterlab
RUN pip install pycuda

RUN git clone https://github.com/tbenthompson/tectosaur.git
WORKDIR /tectosaur
RUN pip install .

ENTRYPOINT jupyter lab --no-browser --ip=0.0.0.0 --allow-root --port 9999 --NotebookApp.token=''
EXPOSE 9999
