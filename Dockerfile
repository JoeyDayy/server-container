FROM alpine:latest as builder

ENV TES3MP_VERSION 0.6.2

ARG BUILD_THREADS="4"

RUN apk add --no-cache \
        libgcc \
        libstdc++ \
        boost-system \
        boost-filesystem \
        make \
        cmake \
        build-base \
        boost-dev \
        openssl-dev \
        ncurses \
        bash \
        git \
        wget

RUN git clone -b "${TES3MP_VERSION}" --depth 1 https://github.com/TES3MP/openmw-tes3mp.git /tmp/TES3MP \
    && git clone -b "${TES3MP_VERSION}" --depth 1 https://github.com/TES3MP/CoreScripts.git /tmp/CoreScripts \
    && git clone https://github.com/Koncord/CallFF.git --depth 1 /tmp/callff \
    && git clone https://github.com/TES3MP/CrabNet.git --depth 1 /tmp/CrabNet \
    && wget https://github.com/zdevito/terra/releases/download/release-2016-02-26/terra-Linux-x86_64-2fa8d0a.zip -O /tmp/terra.zip

RUN cd /tmp/callff \
    && mkdir build \
    && cd build \
    && cmake .. \
    && make

RUN cd /tmp/CrabNet \
    && git reset --hard origin/master \
    && mkdir build \
    && cd build \
    && cmake -DCMAKE_BUILD_TYPE=Release ..\
    && cmake --build . --target RakNetLibStatic --config Release

RUN cd /tmp/ \
    && unzip -o terra.zip \
    && mv terra-* terra \
    && rm terra.zip

RUN cd /tmp/TES3MP \
    && mkdir build \
    && cd build \
    && RAKNET_ROOT=/tmp/CrabNet/build cmake \
        -DCMAKE_BUILD_TYPE=Release .. \
        -DBUILD_OPENCS=OFF \
        -DBUILD_OPENMW_MP=ON \
        -DBUILD_BROWSER=OFF \
        -DBUILD_BSATOOL=OFF \
        -DBUILD_ESMTOOL=OFF \
        -DBUILD_ESSIMPORTER=OFF \
        -DBUILD_LAUNCHER=OFF \
        -DBUILD_MWINIIMPORTER=OFF \
        -DBUILD_MYGUI_PLUGIN=OFF \
        -DBUILD_OPENMW=OFF \
        -DBUILD_WIZARD=OFF \
        -DCallFF_INCLUDES=/tmp/callff/include \
        -DCallFF_LIBRARY=/tmp/callff/build/src/libcallff.a \
        -DTerra_INCLUDES=/tmp/terra/include \
        -DTerra_LIBRARY_RELEASE=/tmp/terra/lib/libterra.a \
        -DRakNet_INCLUDES=/tmp/CrabNet/build/include \
        -DRakNet_LIBRARY_RELEASE=/tmp/CrabNet/build/build/lib/libRakNetLibStatic.a \
        -DRakNet_LIBRARY_DEBUG=/tmp/CrabNet/build/build/lib/libRakNetLibStatic.a \
    && make

RUN mv /tmp/TES3MP/build /server \
    && mv /tmp/CoreScripts /server/Corescripts \
    && sed -i "s|home = .*|home = /server/data|g" /server/tes3mp-server-default.cfg \
    && mkdir /server/data

FROM alpine:latest

LABEL maintainer="Grim Kriegor <grimkriegor@krutt.org>"
LABEL description="Docker image for the TES3MP server"

COPY --from=builder /server /
ADD bootstrap.sh /bootstrap.sh

EXPOSE 25565/udp
VOLUME /server

WORKDIR /server
ENTRYPOINT [ "/bin/bash", "/bootstrap.sh", "--",  "/bin/bash", "tes3mp-server" ]
