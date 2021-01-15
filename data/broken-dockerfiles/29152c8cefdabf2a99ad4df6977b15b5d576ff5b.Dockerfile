FROM ubuntu:15.04

# AWS CLI tool, plus dependencies for log parser
RUN apt-get update && apt-get -y install awscli python-pip python-dev
RUN pip install pandas
CMD bash
