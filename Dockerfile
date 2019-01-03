FROM debian:stretch-slim

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y git wget ca-certificates apt-transport-https gnupg1 sudo

RUN wget -q https://packages.sury.org/php/apt.gpg -O- | apt-key add - && \
    echo "deb https://packages.sury.org/php/ stretch main" | tee /etc/apt/sources.list.d/php.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    php7.2 php7.2-cli php7.2-common php7.2-opcache php7.2-curl php7.2-mbstring php7.2-mysql php7.2-zip php7.2-xml

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends php7.2-dev build-essential python2.7 lsb-release patchelf libglib2.0-0 libglib2.0-dev bzip2 xz-utils && \
    ln -s /usr/bin/python2.7 /usr/bin/python && \
    # Depot Tools
    git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git /tmp/depot_tools && \
    export PATH="$PATH:/tmp/depot_tools" && \
    # Fetch & Build V8
    cd /usr/local/src && fetch v8 && cd v8 && \
    git checkout 6.9.427.18 && gclient sync && \
    tools/dev/v8gen.py -vv x64.release -- is_component_build=true && \
    ninja -C out.gn/x64.release/ && \
    mkdir -p /opt/v8/lib /opt/v8/include && \
    cp out.gn/x64.release/lib*.so out.gn/x64.release/*_blob.bin out.gn/x64.release/icudtl.dat /opt/v8/lib/ && \
    cp -R include/* /opt/v8/include/ && \
    for A in /opt/v8/lib/*.so; do patchelf --set-rpath '$ORIGIN' $A; done && \
    # Fetch & Build V8js
    git clone --branch 2.1.0 --depth 1 https://github.com/phpv8/v8js.git /usr/local/src/v8js && \
    cd /usr/local/src/v8js && \
    phpize && ./configure --with-v8js=/opt/v8 LDFLAGS="-lstdc++" && \
    export NO_INTERACTION=1 && make && make install && \
    echo extension=v8js.so > /etc/php/7.2/cli/conf.d/99-v8js.ini && \
    # Cleanup
    rm -rf /tmp/depot_tools /usr/local/src/v8 /usr/local/src/v8js && \
    apt-get remove -y php7.2-dev build-essential python2.7 patchelf lsb-release libglib2.0-dev bzip2 xz-utils && \
    apt-get autoremove -y && apt-get clean && \
    rm -rf /var/lib/apt/lists/*
