FROM ubuntu:18.04

WORKDIR /aeiou
COPY . .

RUN apt-get update -y
RUN apt-get install -y \
    curl pkg-config gcc \
    libx11-dev libasound2-dev libudev-dev libwayland-dev libxkbcommon-dev

RUN curl https://sh.rustup.rs -sSf | bash -s -- --default-toolchain nightly --profile minimal -y
ENV PATH="/root/.cargo/bin:${PATH}"

RUN printf "\
[build] \n\
rustflags = [\"-C\", \"embed-bitcode=off\"] \n\
[profile.dev] \n\
lto = \"off\" \
" >> /root/.cargo/config

RUN cargo build
