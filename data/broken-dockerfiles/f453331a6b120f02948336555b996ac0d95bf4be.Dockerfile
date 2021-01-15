FROM nvidia/cuda:9.0-base-ubuntu16.04 as base

# Install some basic utilities
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    sudo \
    git \
    bzip2 \
    libx11-6 \
 && rm -rf /var/lib/apt/lists/*

# Create a non-root user and switch to it
RUN adduser --disabled-password --gecos '' --shell /bin/bash user
RUN echo "user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-user
USER user

# All users can use /home/user as their home directory
ENV HOME=/home/user
RUN chmod 777 /home/user

# Install Miniconda
RUN curl -so ~/miniconda.sh https://repo.continuum.io/miniconda/Miniconda3-4.5.4-Linux-x86_64.sh \
 && chmod +x ~/miniconda.sh \
 && ~/miniconda.sh -b -p ~/miniconda \
 && rm ~/miniconda.sh
ENV PATH=/home/user/miniconda/bin:$PATH
ENV CONDA_AUTO_UPDATE_CONDA=false

# Create a Python 3.6 environment
RUN /home/user/miniconda/bin/conda install conda-build \
 && /home/user/miniconda/bin/conda create -y --name py36 python=3.6.5 \
 && /home/user/miniconda/bin/conda clean -ya
ENV CONDA_DEFAULT_ENV=py36
ENV CONDA_PREFIX=/home/user/miniconda/envs/$CONDA_DEFAULT_ENV
ENV PATH=$CONDA_PREFIX/bin:$PATH


################################################################################


FROM base as pillow-simd-builder

RUN sudo apt-get update && sudo apt-get install -y gcc \
 && sudo rm -rf /var/lib/apt/lists/*

RUN conda install -y jpeg && conda clean -ya

RUN cd /tmp \
 && curl -sLo source.tar.gz https://github.com/uploadcare/pillow-simd/archive/v4.2.1.post0.tar.gz \
 && tar xzf source.tar.gz \
 && cd pillow-simd-4.2.1.post0 \
 && CC="cc -mavx2" python setup.py bdist_egg \
 && sudo mv dist/Pillow_SIMD-4.2.1.post0-py3.6-linux-x86_64.egg /Pillow_SIMD-4.2.1.egg


################################################################################


FROM base

# Create a working directory
RUN sudo mkdir /app && sudo chown -R user:user /app
WORKDIR /app

# Install some dependencies from conda
RUN conda install -y --name py36 -c pytorch \
    cuda90=1.0 \
    magma-cuda90=2.3.0 \
    "pytorch=0.3.1=py36_cuda9.0.176_cudnn7.0.5_2" \
    torchvision=0.2.0 \
    graphviz=2.38.0 \
 && conda clean -ya

# Install other dependencies from pip
COPY requirements.txt .
RUN pip install -r requirements.txt

# Replace Pillow with the faster Pillow-SIMD (optional)
COPY --from=pillow-simd-builder --chown=user:user /Pillow_SIMD-4.2.1.egg /tmp/Pillow-4.2.1.egg
RUN pip uninstall -y pillow \
 && easy_install /tmp/Pillow-4.2.1.egg && rm /tmp/Pillow-4.2.1.egg

COPY --chown=user:user . /app
RUN pip install -U .

# Set the default command to python3
CMD ["python3"]
