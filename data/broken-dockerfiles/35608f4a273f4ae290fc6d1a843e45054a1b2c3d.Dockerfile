# Copyright (c) Matthew Moocarme.
# Distributed under the terms of the Modified BSD License.
FROM jupyter/base-notebook

LABEL maintainer="Jupyter Project <jupyter@googlegroups.com>"

USER root

# Install all OS dependencies for fully functional notebook server
RUN apt-get update && apt-get install -yq --no-install-recommends \
    build-essential \
    # emacs \
    git \
    # inkscape \
    # jed \
    libsm6 \
    libxext-dev \
    libxrender1 \
    lmodern \
    netcat \
    pandoc \
    python-dev \
    # texlive-fonts-extra \
    # texlive-fonts-recommended \
    # texlive-generic-recommended \
    # texlive-latex-base \
    # texlive-latex-extra \
    # texlive-xetex \
    unzip \
    nano \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER $NB_UID

# Setup pydata directory for backward-compatibility
RUN mkdir /home/$NB_USER/pydata_2018 && \
    fix-permissions /home/$NB_USER

COPY bayes_spend_tutorial.ipynb pydata_2018/
COPY spend_data_distribute_short.csv pydata_2018/

# Install Python 3 packages
# Remove pyqt and qt pulled in for matplotlib since we're only ever going to
# use notebook-friendly backends in these images
RUN conda install --quiet --yes \
    'conda-forge::blas=*=openblas' \
    'ipywidgets=7.2*' \
    'pandas=0.23*' \
    # 'numexpr=2.6*' \
    'matplotlib=2.2*' \
    'scipy=1.1*' \
    'seaborn=0.9*' \
    'scikit-learn=0.19*' \
    # 'scikit-image=0.14*' \
    # 'sympy=1.1*' \
    # 'cython=0.28*' \
    # 'patsy=0.5*' \
    # 'statsmodels=0.9*' \
    # 'cloudpickle=0.5*' \
    # 'dill=0.2*' \
    # 'numba=0.38*' \
    # 'bokeh=0.12*' \
    # 'sqlalchemy=1.2*' \
    # 'hdf5=1.10*' \
    # 'h5py=2.7*' \
    # 'vincent=0.4.*' \
    # 'beautifulsoup4=4.6.*' \
    # 'protobuf=3.*' \
    'pymc3=3.*' \
    'theano=1.*' && \
    # 'xlrd'  && \
    conda remove --quiet --yes --force qt pyqt && \
    conda clean -tipsy && \
    # Activate ipywidgets extension in the environment that runs the notebook server
    jupyter nbextension enable --py widgetsnbextension --sys-prefix && \
    # Also activate ipywidgets extension for JupyterLab
    #jupyter labextension install @jupyter-widgets/jupyterlab-manager@^0.37.0 && \
    #jupyter labextension install jupyterlab_bokeh@^0.6.0 && \
    npm cache clean --force && \
    rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    rm -rf /home/$NB_USER/.node-gyp && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# Install facets which does not have a pip or conda package at the moment
# RUN cd /tmp && \
#     git clone https://github.com/PAIR-code/facets.git && \
#    cd facets && \
#    jupyter nbextension install facets-dist/ --sys-prefix && \
#    cd && \
#    rm -rf /tmp/facets && \
#    fix-permissions $CONDA_DIR && \
#    fix-permissions /home/$NB_USER

# Import matplotlib the first time to build the font cache.
ENV XDG_CACHE_HOME /home/$NB_USER/.cache/
RUN MPLBACKEND=Agg python -c "import matplotlib.pyplot" && \
    fix-permissions /home/$NB_USER

USER $NB_UID
