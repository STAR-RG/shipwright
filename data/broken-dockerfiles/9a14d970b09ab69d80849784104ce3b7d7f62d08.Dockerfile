FROM pytorch/pytorch:1.1.0-cuda10.0-cudnn7.5-devel
ARG CUDA=false


WORKDIR /workspace/
COPY . .
# install basics
RUN apt-get update -y
RUN apt-get install -y git curl ca-certificates bzip2 cmake tree htop bmon iotop sox libsox-dev libsox-fmt-all vim wget

ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

# install python deps
RUN pip install -r requirements.txt

RUN rm -rf warp-ctc
RUN git clone https://github.com/SeanNaren/warp-ctc.git
RUN if [ "$CUDA" = false ] ; then sed -i 's/option(WITH_OMP \"compile warp-ctc with openmp.\" ON)/option(WITH_OMP \"compile warp-ctc with openmp.\" ${CUDA_FOUND})/' warp-ctc/CMakeLists.txt ; else export CUDA_HOME="/usr/local/cuda" ; fi
RUN cd warp-ctc; mkdir build; cd build; cmake ..; make
RUN cd warp-ctc/pytorch_binding && python setup.py install
RUN rm -rf warp-ctc

RUN pip install -r post_requirements.txt


#TODO: Do we need those two below?
# install ctcdecode
#RUN git clone --recursive https://github.com/parlance/ctcdecode.git
#RUN cd ctcdecode; pip install .

# install deepspeech.pytorch
ADD . /workspace/deepspeech.pytorch
RUN cd deepspeech.pytorch; pip install -r requirements.txt

# launch jupiter
RUN pip install jupyter
RUN mkdir data; mkdir notebooks;
#CMD jupyter-notebook --ip="*" --no-browser --allow-root