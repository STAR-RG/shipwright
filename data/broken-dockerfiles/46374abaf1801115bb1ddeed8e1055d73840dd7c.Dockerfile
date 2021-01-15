FROM java:latest
MAINTAINER Dr. Christian Klukas <christian.klukas@gmail.com>
LABEL Description="The Integrated Analysis Platform for high-throughput plant image analysis" Version="2.0.5"
RUN apt-get update -qq && apt-get install --no-install-recommends -y ant openjfx imagemagick
RUN git clone --depth=1 https://github.com/OpenImageAnalysisGroup/IAP.git
RUN ant -f IAP/IAP\ CONSOLE/build.xml cleanall
RUN ant -f IAP/IAP\ CONSOLE/build.xml
RUN IAP/make/createfilelist.sh
RUN ant -f IAP/IAP/createReleaseQuick.xml
RUN mv IAP/IAP/release/iap_2_0.jar .
RUN echo '#!/bin/bash' > IAPconsole.sh
RUN echo 'java -cp iap_2_0.jar iap.Console "$@"' >> IAPconsole.sh
RUN chmod +x IAPconsole.sh
RUN echo '#!/bin/bash' > IAPgui.sh
RUN echo 'java -cp iap_2_0.jar de.ipk.ag_ba.gui.webstart.IAPmain'  >> IAPgui.sh
RUN chmod +x IAPgui.sh
RUN ["/IAPconsole.sh", "E1F1,_Quit"]
CMD [ "/IAPconsole.sh" ]
