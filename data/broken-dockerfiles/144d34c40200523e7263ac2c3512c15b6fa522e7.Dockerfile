FROM ubuntu:18.04
ENV LC_ALL=C.UTF-8

# Install this
RUN apt-get update && apt-get install -y --no-install-recommends \
    gnupg2 curl ca-certificates

# Install some basic utilities
RUN . /etc/os-release; \
    printf "deb http://ppa.launchpad.net/jonathonf/vim/ubuntu %s main" "$UBUNTU_CODENAME" main | tee /etc/apt/sources.list.d/vim-ppa.list && \
    apt-key  adv --keyserver hkps://keyserver.ubuntu.com --recv-key 4AB0F789CBA31744CC7DA76A8CF63AD3F06FC659 && \
    apt-get update && \
    env DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade --autoremove --purge --no-install-recommends -y \
    build-essential \
    bzip2 \
    ca-certificates \
    curl \
    git \
    libcanberra-gtk-module \
    libgtk2.0-0 \
    libx11-6 \
    sudo \
    graphviz \
    vim-nox

# Create a working directory
RUN mkdir /app
WORKDIR /app

# Create a non-root user and switch to it
RUN adduser --disabled-password --gecos '' --shell /bin/bash user \
    && chown -R user:user /app
RUN echo "user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-user
USER user

# All users can use /home/user as their home directory
ENV HOME=/home/user
RUN chmod 777 /home/user

# Install Miniconda
RUN curl -so ~/miniconda.sh https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && bash ~/miniconda.sh -b -p ~/miniconda \
    && rm ~/miniconda.sh
ENV PATH=/home/user/miniconda/bin:$PATH
ENV CONDA_AUTO_UPDATE_CONDA=false

# Create a Python 3.6 environment
RUN /home/user/miniconda/bin/conda update -n base -c defaults conda -y && \
    /home/user/miniconda/bin/conda install conda-build -y \
    && /home/user/miniconda/bin/conda create -y --name py36 python=3.6.6 \
    && /home/user/miniconda/bin/conda clean -ya
ENV CONDA_DEFAULT_ENV=py36
ENV CONDA_PREFIX=/home/user/miniconda/envs/$CONDA_DEFAULT_ENV
ENV PATH=$CONDA_PREFIX/bin:$PATH

# nodejs for jupyterlab
RUN conda install nodejs tini -y && \
    conda clean -a -y

COPY requirements.txt /app/.
COPY --chown=user:user .jupyter /home/user/.jupyter

# Install OpenCV, Jupyter Lab
RUN pip install --no-cache-dir -r requirements.txt
RUN jupyter labextension install @jupyter-widgets/jupyterlab-manager -y --clean && \
    jupyter labextension install @jupyterlab/toc -y --clean && \
    jupyter labextension install jupyter-matplotlib -y --clean && \
    jlpm cache clean

COPY docker/. /app/.
RUN make -C /app adduser && \
    sudo chown root:root /app/adduser && \
    sudo chmod u+s /app/adduser && \
    sudo mv adduser /usr/local/bin/adduser2 && \
    rm /app/adduser.cpp && \
    sudo chmod +x /app/start.sh

ENTRYPOINT ["/app/start.sh"]
CMD ["jupyter", "lab"]
ENV SHELL=/bin/bash
