FROM python:3.6-alpine
ARG SERVICE_NAME
ARG SERVICE_VERSION
ENV SERVICE_NAME $SERVICE_NAME
ENV SERVICE_VERSION $SERVICE_VERSION
RUN mkdir /app
COPY . /app
RUN touch /app/.env
RUN pip install --find-links /app/wheels -r /app/requirements.txt
RUN pip install pymysql gunicorn
WORKDIR /app
EXPOSE 5000
CMD ["./boot.sh"]
