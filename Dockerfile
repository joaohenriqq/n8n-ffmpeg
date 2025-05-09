FROM n8nio/n8n:latest AS builder

USER root

# 1) Instala dependências oficiais para compilação (inclui rubberband)
RUN apk update && apk add --no-cache \
    autoconf \
    automake \
    build-base \
    cmake \
    git \
    freetype-dev \
    libass-dev \
    libvorbis-dev \
    libogg-dev \
    libtheora-dev \
    x264-dev \
    x265-dev \
    libvpx-dev \
    opus-dev \
    lame-dev \
    librubberband-dev \       # <— aqui
    soxr-dev \
    sdl2-dev \
    libwebp-dev \
    xz-dev \
    zlib-dev \
    yasm \
    pkgconf \
    nasm \
    wget \
    tar \
    unzip

WORKDIR /ffmpeg

# 2) Baixa o source oficial do FFmpeg
ARG FFMPEG_VERSION=6.0
RUN wget https://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.xz && \
    tar -xJf ffmpeg-${FFMPEG_VERSION}.tar.xz --strip-components=1 && \
    rm ffmpeg-${FFMPEG_VERSION}.tar.xz

# 3) Configura e compila com codecs e filtros principais
RUN ./configure \
      --prefix=/usr/local \
      --enable-gpl \
      --enable-nonfree \
      --enable-libass \
      --enable-libfreetype \
      --enable-libvorbis \
      --enable-libx264 \
      --enable-libx265 \
      --enable-libvpx \
      --enable-libopus \
      --enable-libmp3lame \
      --enable-librubberband \   # <— e aqui
      --enable-libsoxr \
      --enable-libwebp \
      --enable-postproc \
      --enable-filter=zscale \
      --enable-filter=frei0r \
      --disable-debug \
    && make -j$(nproc) \
    && make install \
    && make distclean
