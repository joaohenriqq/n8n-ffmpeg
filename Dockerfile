################################################################
# 1 · STAGE builder — Ubuntu 24.04 + FFmpeg git-master
################################################################
FROM ubuntu:24.04 AS builder
ENV DEBIAN_FRONTEND=noninteractive
USER root

# Toolchain + bibliotecas estritamente necessárias
RUN apt-get update && apt-get install -y --no-install-recommends \
    autoconf automake build-essential cmake git pkg-config yasm nasm \
    curl ca-certificates zlib1g-dev libtool \
    libfreetype6-dev libass-dev                               \
    libmp3lame-dev libopus-dev libvorbis-dev                  \
    librubberband-dev libsoxr-dev frei0r-plugins-dev          \
    libx264-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /ffmpeg
RUN git clone --depth 1 https://git.ffmpeg.org/ffmpeg.git .

# Configura e compila com rubberband + frei0r
RUN ./configure --prefix=/usr/local      \
      --enable-gpl --enable-version3 --enable-nonfree \
      --enable-libass        --enable-libfreetype   \
      --enable-libmp3lame    --enable-libopus       \
      --enable-libvorbis     --enable-libx264       \
      --enable-librubberband --enable-libsoxr       \
      --enable-frei0r        --enable-filter=zscale \
      --enable-postproc      --disable-debug &&     \
    make -j"$(nproc)" && make install && make distclean

################################################################
# 2 · STAGE final — n8n (Debian) + FFmpeg completo
################################################################
FROM n8nio/n8n:latest-debian
USER root

# Ferramentas que você sempre teve
RUN apt-get update && apt-get install -y --no-install-recommends \
    imagemagick ghostscript tesseract-ocr          \
    curl wget zip unzip tar jq openssh-client &&   \
    rm -rf /var/lib/apt/lists/*

# Copia ffmpeg/ffprobe + libs
COPY --from=builder /usr/local /usr/local
ENV LD_LIBRARY_PATH=/usr/local/lib

USER node
