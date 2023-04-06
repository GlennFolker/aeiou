FROM ubuntu:17.04

RUN dpkg --print-architecture

RUN apt-get update -y
RUN apt-get install -y \
    curl pkg-config gcc \
    libx11-dev libasound2-dev libudev-dev libwayland-dev libxkbcommon-dev

RUN curl https://sh.rustup.rs -sSf | sh -s -- --default-host $RUST_TRIPLET --default-toolchain nightly --profile minimal -y
ENV PATH="/root/.cargo/bin:${PATH}"

RUN printf "\
[build] \n\
rustflags = [\"-C\", \"embed-bitcode=off\"] \n\
[profile.dev] \n\
lto = \"off\" \
" > /root/.cargo/config

WORKDIR /aeiou
COPY . .

RUN cargo build --target $RUST_TRIPLET
