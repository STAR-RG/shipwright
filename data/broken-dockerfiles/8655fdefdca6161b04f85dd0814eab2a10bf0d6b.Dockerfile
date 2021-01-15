from alpine:edge

workdir /tmp
run echo "http://nl.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

run apk update && apk upgrade && \
    apk add ghc cabal make gcc musl-dev linux-headers bash file curl bsd-compat-headers autoconf automake protobuf-dev zlib-dev openssl-dev g++ upx

env dest_prefix /usr

# libevent
env libevent_version 2.0.22
env libevent_name libevent-$libevent_version-stable
add https://github.com/libevent/libevent/releases/download/release-$libevent_version-stable/libevent-$libevent_version-stable.tar.gz /tmp/$libevent_name.tar.gz
run tar xvzf /tmp/$libevent_name.tar.gz && \
    cd $libevent_name && \
    ./configure --prefix=$dest_prefix --disable-shared && \
    make && \
    make install && \
    rm -fr /tmp/$libevent_name.tar.gz /tmp/$libevent_name

# ncurses
env ncurses_version 6.0
env ncurses_name ncurses-$ncurses_version
run curl -LO ftp://ftp.gnu.org/gnu/ncurses/$ncurses_name.tar.gz -o /tmp/$ncurses_name.tar.gz && \
    tar xvzf /tmp/$ncurses_name.tar.gz && \
    cd $ncurses_name && \
    ./configure --prefix=$dest_prefix --without-cxx --without-cxx-bindings --enable-static && \
    make && \
    make install && \
    rm -fr /tmp/$ncurses_name.tar.gz /tmp/$ncurses_name

# et tmux
env tmux_version 2.4
env tmux_name tmux-$tmux_version
env tmux_url $tmux_name/$tmux_name
add https://github.com/tmux/tmux/releases/download/$tmux_version/$tmux_name.tar.gz /tmp/$tmux_name.tar.gz
run tar xvzf /tmp/$tmux_name.tar.gz && \
    cd $tmux_name && \
    ./configure --prefix=$dest_prefix CFLAGS="-I$dest_prefix/include -I$dest_prefix/include/ncurses" LDFLAGS="-static -L$dest_prefix/lib -L$dest_prefix/include/ncurses -L$dest_prefix/include" && \
    env CPPFLAGS="-I$dest_prefix/include -I$dest_prefix/include/ncurses" LDFLAGS="-static -L$dest_prefix/lib -L$dest_prefix/include/ncurses -L$dest_prefix/include" make && \
    make install && \
    rm -fr /tmp/$tmux_name.tar.gz /tmp/$tmux_name && \
    cp /usr/bin/tmux /usr/bin/tmux.stripped && \
    strip /usr/bin/tmux.stripped && \
    cp /usr/bin/tmux /usr/bin/tmux.upx && \
    cp /usr/bin/tmux.stripped /usr/bin/tmux.stripped.upx && \
    upx --best --ultra-brute /usr/bin/tmux.upx /usr/bin/tmux.stripped.upx

# htop
env htop_version 2.0.2
env htop_name htop-$htop_version
add http://hisham.hm/htop/releases/$htop_version/$htop_name.tar.gz /tmp/$htop_name.tar.gz
run tar xvzf /tmp/$htop_name.tar.gz && \
    cd $htop_name && \
    ./configure --enable-static --disable-shared --disable-unicode --prefix=$dest_prefix CFLAGS="-I$dest_prefix/include -I$dest_prefix/include/ncurses" LDFLAGS="--static -lpthread -L$dest_prefix/lib -L$dest_prefix/include/ncurses -L$dest_prefix/include" && \
    env CPPFLAGS="-I$dest_prefix/include -I$dest_prefix/include/ncurses" LDFLAGS="--static -lpthread -L$dest_prefix/lib -L$dest_prefix/include/ncurses -L$dest_prefix/include" make && \
    make install && \
    rm -fr /tmp/$htop_name.tar.gz /tmp/$htop_name && \
    cp $dest_prefix/bin/htop $dest_prefix/bin/htop.stripped && \
    strip $dest_prefix/bin/htop.stripped && \
    cp $dest_prefix/bin/htop $dest_prefix/bin/htop.upx && \
    cp $dest_prefix/bin/htop.stripped $dest_prefix/bin/htop.stripped.upx && \
    upx --best --ultra-brute $dest_prefix/bin/htop.upx $dest_prefix/bin/htop.stripped.upx

# mobile shell
env mosh_version 1.3.0
env mosh_name mosh-$mosh_version
env mosh_url https://github.com/mobile-shell/mosh/archive/$mosh_name.tar.gz
add $mosh_url /tmp/$mosh_name.tar.gz
run tar xvzf /tmp/$mosh_name.tar.gz && \
    cd /tmp/mosh-$mosh_name && \
    ./autogen.sh && \
    ./configure --enable-static --disable-shared --prefix=$dest_prefix CFLAGS="-I$dest_prefix/include -I$dest_prefix/include/ncurses" LDFLAGS="--static -lpthread -L$dest_prefix/lib -L$dest_prefix/include/ncurses -L$dest_prefix/include" && \
    make && \
    make install && \
    rm -fr /tmp/mosh-$mosh_name && \
    cp $dest_prefix/bin/mosh-client $dest_prefix/bin/mosh-client.stripped && \
    strip $dest_prefix/bin/mosh-client.stripped && \
    cp $dest_prefix/bin/mosh-server $dest_prefix/bin/mosh-server.stripped && \
    strip $dest_prefix/bin/mosh-server.stripped && \
    cp $dest_prefix/bin/mosh-client $dest_prefix/bin/mosh-client.upx && \
    cp $dest_prefix/bin/mosh-client.stripped $dest_prefix/bin/mosh-client.stripped.upx && \
    cp $dest_prefix/bin/mosh-server $dest_prefix/bin/mosh-server.upx && \
    cp $dest_prefix/bin/mosh-server.stripped $dest_prefix/bin/mosh-server.stripped.upx && \
    upx --best --ultra-brute $dest_prefix/bin/mosh-client.upx $dest_prefix/bin/mosh-client.stripped.upx \
         $dest_prefix/bin/mosh-server.upx  $dest_prefix/bin/mosh-server.stripped.upx

# pandoc
env pandoc_version 1.19.1
env cabaldir /root/.cabal/bin
workdir /tmp
run cabal update && cabal install hsb2hs && \
    cabal get pandoc-$pandoc_version
run cd /tmp/pandoc-$pandoc_version && \
    sed -i '/Executable pandoc/a \ \ ld-options: -static' pandoc.cabal && \
    cabal install --flags="embed_data_files" && \
    cp $cabaldir/pandoc $cabaldir/pandoc.stripped && \
    strip $cabaldir/pandoc.stripped && \
    cp $cabaldir/pandoc $cabaldir/pandoc.upx && \
    cp $cabaldir/pandoc.stripped $cabaldir/pandoc.stripped.upx && \
    upx --best --ultra-brute $cabaldir/pandoc.upx $cabaldir/pandoc.stripped.upx

# oniguruma for jq regex support
env oni_version 5.9.6
env oni onig-$oni_version
add https://github.com/kkos/oniguruma/releases/download/v$oni_version/onig-$oni_version.tar.gz /tmp/$oni.tar.gz
workdir /tmp
run tar xvzf /tmp/$oni.tar.gz && \
    cd /tmp/$oni && \
    ./configure --enable-static --disable-shared --prefix=$dest_prefix && \
    make && \
    make install && \
    rm -fr /tmp/$oni

# jq as well
env jq_version 1.5
env jq jq-$jq_version
add https://github.com/stedolan/jq/releases/download/jq-1.5/jq-1.5.tar.gz /tmp/jq.tar.gz
workdir /tmp
run tar xvzf /tmp/jq.tar.gz && \
    cd /tmp/$jq && \
    ./configure --enable-static --disable-shared --prefix=$dest_prefix CFLAGS="-I$dest_prefix/include" LDFLAGS="--static -L$dest_prefix/lib -L$dest_prefix/include" && \
    make && \
    make install && \
    rm -fr /tmp/$jq && \
    cp $dest_prefix/bin/jq $dest_prefix/bin/jq.stripped && \
    strip $dest_prefix/bin/jq.stripped && \
    cp $dest_prefix/bin/jq $dest_prefix/bin/jq.upx && \
    cp $dest_prefix/bin/jq.stripped $dest_prefix/bin/jq.stripped.upx && \
    upx --best --ultra-brute $dest_prefix/bin/jq.stripped.upx $dest_prefix/bin/jq.upx
cmd ["bash"]
