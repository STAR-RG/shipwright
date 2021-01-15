FROM    laincloud/centos-lain

RUN     mkdir -p $GOPATH/src/github.com/laincloud

ADD     . $GOPATH/src/github.com/laincloud/deployd

RUN     cd $GOPATH/src/github.com/laincloud/deployd && go build -v -a -tags netgo -installsuffix netgo -o deployd

RUN     mv $GOPATH/src/github.com/laincloud/deployd/deployd /usr/bin/

