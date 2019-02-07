FROM buildpack-deps:stretch AS libressl

ARG ARCH=x86_64
ARG LIBRE_VER=2.9.0
ARG PREFIX=/libressl

WORKDIR $PREFIX

# Configure the output filesystem a bit
RUN mkdir -p usr/bin usr/lib etc/ssl/certs

WORKDIR /tmp/libressl

# Build and install LibreSSL
RUN curl -sSL https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-${LIBRE_VER}.tar.gz \
        | tar xz --strip-components=1 && \
    ./configure \
        --prefix= \
        --exec-prefix=/usr && \
    make -j "$(nproc)" && \
    make DESTDIR="$(pwd)/build" install

RUN cp -d build/usr/lib/*.so* "${PREFIX}/usr/lib" && \
    cp -d build/usr/bin/openssl "${PREFIX}/usr/bin" && \
    mkdir -p "${PREFIX}/etc/ssl" && \
    cp -d build/etc/ssl/openssl.cnf "${PREFIX}/etc/ssl" && \
    cd "${PREFIX}/usr/lib" && \
    ln -s libssl.so libssl.so.1.0.0 && \
    ln -s libssl.so libssl.so.1.0 && \
    ln -s libtls.so libtls.so.1.0.0 && \
    ln -s libtls.so libtls.so.1.0 && \
    ln -s libcrypto.so libcrypto.so.1.0.0 && \
    ln -s libcrypto.so libcrypto.so.1.0

RUN update-ca-certificates && \
    cp /etc/ssl/certs/ca-certificates.crt "${PREFIX}/etc/ssl/certs"

FROM scratch
COPY --from=libressl /libressl/ /
