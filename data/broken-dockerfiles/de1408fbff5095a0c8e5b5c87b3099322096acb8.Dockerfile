# ServiceStack Nginx Mono_fastcgi Host
#
# VERSION 0.01

FROM	lopter/raring-base
MAINTAINER Pauli Price "pauli.price@gmail.com"

# make sure the package repository is up to date
RUN echo "deb http://archive.ubuntu.com/ubuntu raring main universe" > /etc/apt/sources.list
RUN apt-get update

RUN apt-get install -y mono-complete
RUN apt-get install -y mono-fastcgi-server4
RUN apt-get install -y inotify-tools nginx apache2 openssh-server
RUN apt-get install -y git ca-certificates
RUN apt-get install -y curl

RUN git config --global http.sslVerify true
RUN git config --global http.sslCAinfo  /etc/ssl/certs/ca-certificates.crt
RUN mkdir -p  /var/www/
RUN mkdir -p /var/log/mono
RUN git clone https://github.com/MarFarMa/ServiceStack.Hello.git /var/www/hello
WORKDIR /var/www/hello

# TODO: symlink instead:
RUN cp /var/www/hello/lib/nuget.exe /usr/local/bin
RUN cp /var/www/hello/lib/Microsoft.Build.dll /usr/local/bin

RUN mozroots --import --sync
RUN echo | openssl s_client -showcerts -connect go.microsoft.com:443 2>&1 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > cert.pem
RUN echo | openssl s_client -showcerts -connect nugetgallery.blob.core.windows.net:443 2>&1 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' >> cert.pem
RUN echo | openssl s_client -showcerts -connect nuget.org:443 2>&1 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' >> cert.pem
RUN openssl crl2pkcs7 -nocrl -certfile cert.pem -out cert.p7b
RUN certmgr -add -c -m Trust ./cert.p7b
RUN mono --runtime=v4.0 /usr/local/bin/nuget.exe install /var/www/hello/packages.config -o /var/www/hello/packages
RUN cd /var/www/hello && /usr/bin/xbuild ServiceStack.Hello.sln

RUN mv -f /var/www/hello/fastcgi_params /etc/nginx/fastcgi_params
RUN mv -f /var/www/hello/default /etc/nginx/sites-available/default
RUN update-rc.d nginx defaults
EXPOSE 80
CMD ["/var/www/hello/start"]
