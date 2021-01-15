FROM python:3.6

RUN pip3 install --no-cache-dir numpy==1.11.0 scipy==1.0.0 opencv-python==3.4.0.12

ADD requirements.txt /app/requirements.txt

RUN pip3 install --no-cache-dir -r /app/requirements.txt

ADD src /app
ADD test_image.jpg /data/test_image.jpg

RUN pip3 install --no-cache-dir flake8 \
  && flake8 /app \
  && pip3 uninstall --yes flake8

RUN printf '#!/usr/bin/env bash\nhug -f /app/labelling.py -c $*' > /do \
  && chmod +x /do

WORKDIR /app

CMD ["hug", "-f", "labelling.py", "-p", "80"]

ENV MASK_COLOR="(0, 0, 255)"
ENV OUTPUT_IMAGE_FORMAT="jpg"

EXPOSE 80
