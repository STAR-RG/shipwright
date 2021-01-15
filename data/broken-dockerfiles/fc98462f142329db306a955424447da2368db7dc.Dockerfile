FROM microsoft/aspnetcore-build:2.0-jessie

LABEL Gokhan GOKALP <gok.gokalp@yahoo.com>

# set up environment
ENV SONAR_SCANNER_VERSION=3.0.3.778 \
	SONAR_SCANNER_MSBUILD_VERSION=4.0.2.892 \
	SONAR_SCANNER_MSBUILD_PATH=/opt/sonar-scanner-msbuild \
	DOTNET_BUILD_DIR=/build_dir
	
# Install the java runtime environment 8
RUN echo "deb http://http.debian.net/debian jessie-backports main" | tee /etc/apt/sources.list.d/jessie-backports.list > /dev/null \
  && apt-get update \
  && apt-get install -t jessie-backports openjdk-8-jdk -y

# Install the mono & dotnet sdk
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF \
  && echo "deb http://download.mono-project.com/repo/debian jessie main" | tee /etc/apt/sources.list.d/mono-official.list \
  && apt-get update \
  && apt-get install \
	mono-devel \
	mono-complete \
	referenceassemblies-pcl \
	ca-certificates-mono \
	mono-xsp4 \
	libunwind8 \
	gettext \
	apt-transport-https \
	wget \
	unzip \
	-y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Download the sonar scanner for msbuild
RUN wget https://github.com/SonarSource/sonar-scanner-msbuild/releases/download/$SONAR_SCANNER_MSBUILD_VERSION/sonar-scanner-msbuild-$SONAR_SCANNER_MSBUILD_VERSION.zip -O /opt/sonar-scanner-msbuild.zip \
  && mkdir -p $SONAR_SCANNER_MSBUILD_PATH \
  && mkdir -p $DOTNET_BUILD_DIR \
  && unzip /opt/sonar-scanner-msbuild.zip -d $SONAR_SCANNER_MSBUILD_PATH \
  && rm /opt/sonar-scanner-msbuild.zip \
  && chmod -R 775 $SONAR_SCANNER_MSBUILD_PATH \
  && chmod -R 775 $DOTNET_BUILD_DIR

ENV PATH="$SONAR_SCANNER_MSBUILD_PATH:$SONAR_SCANNER_MSBUILD_PATH/sonar-scanner-$SONAR_SCANNER_VERSION/bin:${PATH}"

WORKDIR $DOTNET_BUILD_DIR