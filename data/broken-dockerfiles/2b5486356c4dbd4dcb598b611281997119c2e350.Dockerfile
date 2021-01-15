FROM nfcore/base
LABEL authors="phil@lifebit.ai" \
      description="Docker image containing all requirements for nf-core/deepvariant pipeline"

COPY environment.yml /
RUN conda env create -f /environment.yml && conda clean -a
ENV PATH /opt/conda/envs/nf-core-deepvariant-1.0/bin:$PATH
