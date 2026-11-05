FROM debian:trixie

ARG lnav_VERSION
ARG BUILD_VERSION
ARG FULL_VERSION
ARG ARCH
ARG LNAV_RELEASE

# Upstream ships the binaries with full debug info (~80 MB). Drop it but keep
# the symbol table, so lnav's crash backtraces still name functions. The
# cross binutils strip the arm64 binary on an amd64 builder.
RUN apt-get update && apt-get install -y --no-install-recommends \
    binutils-x86-64-linux-gnu binutils-aarch64-linux-gnu \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /output/usr/bin
RUN mkdir -p /output/usr/share/doc/lnav
RUN mkdir -p /output/usr/share/man/man1
RUN mkdir -p /output/DEBIAN

COPY ${LNAV_RELEASE}/lnav /output/usr/bin/
COPY ${LNAV_RELEASE}/lnav.1 /output/usr/share/man/man1/
RUN case "$ARCH" in \
        amd64) x86_64-linux-gnu-strip --strip-debug /output/usr/bin/lnav ;; \
        arm64) aarch64-linux-gnu-strip --strip-debug /output/usr/bin/lnav ;; \
        *) echo "Unsupported architecture: $ARCH"; exit 1 ;; \
    esac
RUN gzip -9n /output/usr/share/man/man1/*.1
RUN chmod 644 /output/usr/share/man/man1/*
COPY output/DEBIAN/control /output/DEBIAN/
COPY output/DEBIAN/postinst /output/DEBIAN/postinst
RUN chmod 755 /output/DEBIAN/postinst
COPY output/copyright /output/usr/share/doc/lnav/
COPY output/changelog.Debian /output/usr/share/doc/lnav/
COPY output/README.md /output/usr/share/doc/lnav/

RUN sed -i "s/FULL_VERSION/$FULL_VERSION/" /output/usr/share/doc/lnav/changelog.Debian
RUN sed -i "s/lnav_VERSION/$lnav_VERSION/" /output/DEBIAN/control
RUN sed -i "s/BUILD_VERSION/$BUILD_VERSION/" /output/DEBIAN/control
RUN sed -i "s/SUPPORTED_ARCHITECTURES/$ARCH/" /output/DEBIAN/control

RUN chmod 644 /output/usr/share/doc/lnav/* /output/DEBIAN/control
RUN dpkg-deb -Zxz --build /output /lnav_${FULL_VERSION}.deb
