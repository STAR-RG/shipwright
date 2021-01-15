FROM ubuntu:latest

RUN apt-get update && apt-get install -y -q git python-pip python-sphinx texlive texlive-latex-extra pandoc build-essential

RUN pip install sphinx_bootstrap_theme

RUN useradd sphinx -m -d /sphinx

RUN mkdir /sphinx/.ssh
ADD drone_id_rsa /sphinx/.ssh/id_rsa
ADD drone_id_rsa.pub /sphinx/.ssh/id_rsa.pub
ADD drone_ssh_known_hosts /sphinx/.ssh/known_hosts
ADD sync_built_docs.sh /sphinx/sync_built_docs.sh
ADD sync_unify_docs.sh /sphinx/sync_unify_docs.sh

RUN chown -R sphinx:sphinx /sphinx

USER sphinx
WORKDIR /sphinx

CMD ["/bin/bash"]
