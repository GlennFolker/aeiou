FROM --platform=linux/amd64 ubuntu:18.04

WORKDIR /aeiou
COPY . .

RUN dpkg --print-foreign-architectures
RUN dpkg --add-architecture i386 armhf arm64
