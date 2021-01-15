FROM apache/zeppelin:0.8.1
RUN apt-get update && \
    apt-get install python3-pip wget -y && \
    pip3 install graphframes matplotlib==2.2.4 pandas==0.24.2 networkx \
    python-louvain scikit-learn cycler py2neo && \
    wget https://dl.bintray.com/spark-packages/maven/graphframes/graphframes/0.7.0-spark2.4-s_2.11/graphframes-0.7.0-spark2.4-s_2.11.jar && \
    mv graphframes-0.7.0-spark2.4-s_2.11.jar /zeppelin/interpreter/spark/dep/