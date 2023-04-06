FROM --platform=linux/amd64 ubuntu:18.04

WORKDIR /aeiou
COPY . .

RUN dpkg --add-architecture i386
RUN dpkg --add-architecture armhf
RUN dpkg --add-architecture arm64
RUN dpkg --add-architecture ppc64el

RUN echo "deb [arch=amd64,i386] http://archive.ubuntu.com/ubuntu/ bionic main restricted universe multiverse" >> /etc/apt/sources.list
RUN echo "deb [arch=armhf,arm64,ppc64el] http://ports.ubuntu.com/ubuntu-ports bionic main restricted universe multiverse" >> /etc/apt/sources.list
RUN echo "deb [arch=armhf,arm64,ppc64el] http://ports.ubuntu.com/ubuntu-ports bionic-updates main restricted universe multiverse" >> /etc/apt/sources.list

RUN apt-get update -y
RUN apt-get install -y \
    curl gcc pkg-config \
    {libx11-dev,libasound2-dev,libudev-dev,libwayland-dev,libxkbcommon-dev}:{amd64,i386,armhf,arm64,ppc64el}

RUN curl https://sh.rustup.rs -sSf | bash -s -- --default-toolchain nightly --profile minimal -y
ENV PATH="$HOME/.cargo/bin:$PATH"

RUN curl -L https://ziglang.org/builds/zig-linux-x86_64-0.11.0-dev.2375+771d07268.tar.xz -o zig.tar.xz
RUN tar -xf zig.tar.xz
RUN rm zig.tar.xz
RUN mv zig-linux-x86_64-0.11.0* $HOME
ENV PATH="$HOME/zig:$PATH"

RUN cargo install cargo-zigbuild
RUN rustup target add \
    x86_64-unknown-linux-gnu i686-unknown-linux-gnu \
    aarch64-unknown-linux-gnu armv7-unknown-linux-gnueabihf \
    powerpc64le-unknown-linux-gnu \
    x86_64-pc-windows-gnu i686-pc-windows-gnu

ENV PKG_CONFIG_SYSROOT_DIR=/
ENV PKG_CONFIG_LIBDIR=/usr/lib/x86_64-linux-gnu/pkgconfig
RUN cargo zigbuild --target x86_64-unknown-linux-gnu.2.27

ENV PKG_CONFIG_LIBDIR=/usr/lib/i386-linux-gnu/pkgconfig
RUN cargo zigbuild --target i686-unknown-linux-gnu.2.27

ENV PKG_CONFIG_LIBDIR=/usr/lib/aarch64-linux-gnu/pkgconfig
RUN cargo zigbuild --target aarch64-unknown-linux-gnu.2.27

ENV PKG_CONFIG_LIBDIR=/usr/lib/arm-linux-gnueabihf/pkgconfig
RUN cargo zigbuild --target armv7-unknown-linux-gnueabihf.2.27

ENV PKG_CONFIG_LIBDIR=/usr/lib/x86_64-linux-gnu/pkgconfig
RUN cargo zigbuild --target powerpc64le-unknown-linux-gnu.2.27

ENV PKG_CONFIG_SYSROOT_DIR=
ENV PKG_CONFIG_PATH=
ENV PKG_CONFIG_LIBDIR=

RUN cargo zigbuild --target x86_64-pc-windows-gnu --target i686-pc-windows-gnu
