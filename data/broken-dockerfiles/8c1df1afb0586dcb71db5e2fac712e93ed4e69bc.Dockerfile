FROM python:3

# Instalar requerimientos del OS y limpiar
RUN apt-get update && apt-get install -y \
    python3-gdal \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

# Definir el directorio del proyecto
ENV PYTHONUNBUFFERED 1
ENV SITE_DIR=/project
RUN mkdir -p $SITE_DIR
WORKDIR $SITE_DIR
RUN mkdir -p proj

# Instalar un ambiente virtual para separar paquetes del sistema operativo
RUN python3 -mvenv env/

# Instalar requerimientos
COPY requirements.txt requirements.txt
RUN env/bin/pip install pip --upgrade
RUN env/bin/pip install -r requirements.txt

# Instalar uwsgi
RUN env/bin/pip install uwsgi

# Configurar variables de ambiente
ENV NUM_THREADS=2
ENV NUM_PROCS=2
ENV DJANGO_DATABASE_URL=postgres://postgres@db/postgres

# Copiar el proyecto
COPY . proj/

# Exponemos el puerto del servicio
EXPOSE 8000

# Definir un punto de entrada para poder inicializar
ENTRYPOINT ["./proj/docker/entrypoint.sh"]

# Definir un comando para ejecutar el servicio
CMD ["./proj/docker/app-start.sh"]