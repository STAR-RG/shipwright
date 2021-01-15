FROM registry.saintic.com/python
MAINTAINER Mr.tao <staugur@saintic.com>
ADD ./src /EauDouce
ADD requirements.txt /tmp
ADD supervisord.conf /etc
WORKDIR /EauDouce
RUN pip install --index https://pypi.douban.com/simple/ -r /tmp/requirements.txt
ENTRYPOINT ["supervisord"]