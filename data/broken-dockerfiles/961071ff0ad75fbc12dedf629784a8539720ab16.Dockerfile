FROM python:3.7

RUN apt update
RUN apt install -y apt-transport-https ca-certificates wget dirmngr gnupg software-properties-common
RUN wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | apt-key add -
RUN add-apt-repository -y https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/
RUN apt update
RUN apt install -y adoptopenjdk-8-hotspot

RUN java -version


ARG project_dir=/teaspn-server

WORKDIR $project_dir

COPY requirements.txt $project_dir

RUN pip install -U pip
RUN pip install -r ./requirements.txt

COPY teaspn_server $project_dir/teaspn_server

RUN python -m spacy download en
RUN python -c "import nltk; nltk.download('wordnet')"
RUN python -c "import logging; logging.basicConfig(level=logging.INFO); import neuralcoref"
RUN python -c "from transformers import GPT2Tokenizer, GPT2LMHeadModel; GPT2LMHeadModel.from_pretrained('distilgpt2'); GPT2Tokenizer.from_pretrained('distilgpt2')"

RUN mkdir -p  $project_dir/model/paraphrase
RUN mkdir -p  $project_dir/model/paraphrase/spm

RUN curl -sLJ --output $project_dir/model/paraphrase/dict.target.spm.txt "https://teaspn.s3.amazonaws.com/server/0.0.1/assets/dict.target.spm.txt"
RUN curl -sLJ --output $project_dir/model/paraphrase/dict.source.spm.txt "https://teaspn.s3.amazonaws.com/server/0.0.1/assets/dict.source.spm.txt"
RUN curl -sLJ --output $project_dir/model/paraphrase/checkpoint_best.pt "https://teaspn.s3.amazonaws.com/server/0.0.1/assets/checkpoint_best.pt"
RUN curl -sLJ --output $project_dir/model/paraphrase/spm/para_nmt.model "https://teaspn.s3.amazonaws.com/server/0.0.1/assets/para_nmt.model"

