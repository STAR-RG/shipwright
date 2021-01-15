FROM python:2.7-alpine

RUN apk add --no-cache gcc g++ make linux-headers libxml2 libxslt-dev

ENV FLASK_APP index.py

WORKDIR ./

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

CMD [ "flask", "run", "--host=0.0.0.0" ]

# build example : docker build -t keyword-mining .
# run example : docker run -p 5000:5000 keyword-mining
