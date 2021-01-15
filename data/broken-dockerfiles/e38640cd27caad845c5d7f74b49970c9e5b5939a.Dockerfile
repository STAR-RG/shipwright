FROM python:3.6

WORKDIR opt/deploy/
RUN mkdir nvm
ENV NVM_DIR /opt/deploy/nvm

# Install nvm with node and npm
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install --lts\
    && nvm use --lts

ADD . .

RUN pip install -r requirements.txt
RUN python manage.py makemigrations catalog home \
    && python manage.py migrate \
    && python manage.py loadcountries

EXPOSE 8000
CMD python manage.py runserver 0.0.0.0:8000
