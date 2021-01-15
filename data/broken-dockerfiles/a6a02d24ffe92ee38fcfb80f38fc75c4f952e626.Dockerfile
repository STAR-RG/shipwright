# Copyright 2018 The Gluster Mixins Authors.

# Licensed under GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# You may obtain a copy of the License at
#    https://opensource.org/licenses/lgpl-3.0.html

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#-- Create build environment

FROM docker.io/openshift/origin-release:golang-1.10 as build

MAINTAINER Ankush Behl anbehl@redhat.com

# install clang and gcc-c++ required for jsonnet to build
RUN yum install -y clang \
    gcc-c++ \
    make

# get required go packages for building k8s objects
RUN go get github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb \
    github.com/brancz/gojsontoyaml \
    github.com/prometheus/prometheus/cmd/promtool

# building jsonnet
RUN git clone https://github.com/google/jsonnet && \
    git --git-dir=jsonnet/.git checkout v0.10.0 && \
    make -C jsonnet CC=clang CXX=clang++ && \
    cp jsonnet/jsonnet /usr/bin

# cloning the gluster-mixins project and making gluster-mixins as working dir
COPY . /gluster/gluster-mixins/
WORKDIR /gluster/gluster-mixins/

# make will run tests and generate the intermidiate files
RUN make 

WORKDIR /gluster/gluster-mixins/extras
#installing required dependency from jsonnetfile.json and building k8s objects
RUN jb install
RUN ./build.sh example.jsonnet

# Copy generated files to /
RUN cp -r manifests /


#-- Final container

FROM docker.io/centos:7 as final

RUN yum update -y \
    && yum clean all

# install kubectl package in container
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin

# copy required files from build to final container
COPY --from=build /manifests /manifests

# shell script to apply the k8s object to underlying cluster
COPY docker/entry.sh /
RUN chmod 755 /entry.sh

ARG builddate="(unknown)"
ARG version="(unknown)"

LABEL build-date="${builddate}" \
      io.k8s.description="Mixins will deploy Grafana dashboards and Prometheus alerts for Gluster." \
      name="Gluster Mixins" \
      Summary="Gluster Mixins will deploy Grafana dashboards and Prometheus alerts for Gluster." \
      vcs-type="git" \
      vcs-url="https://github.com/gluster/gluster-mixins" \
      vendor="gluster.org" \
      version="${version}"

ENTRYPOINT [ "/entry.sh" ]
