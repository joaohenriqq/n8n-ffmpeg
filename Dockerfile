################################################################
# 1 · Stage builder — Ubuntu 24.04 + FFmpeg git-master
################################################################
FROM ubuntu:24.04 AS builder
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    autoconf automake build-essential cmake git pkg-config yasm nasm \
    curl ca-certificates zlib1g-dev libtool libnuma-dev \
    # --- filtros e codecs principais ---
    libfreetype6-dev libass-dev frei0r-plugins-dev librubberband-dev \
    libsoxr-dev libmp3lame-dev libopus-dev libvorbis-dev libtheora-dev \
    libx264-dev libx265-dev libvpx-dev libaom-dev libsvtav1-dev \
    libwebp-dev libopenjp2-7-dev libfdk-aac-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /ffmpeg
RUN git clone --depth 1 https://git.ffmpeg.org/ffmpeg.git .

RUN ./configure --prefix=/usr/local --enable-gpl --enable-version3 --enable-nonfree \
      --enable-libass --enable-libfreetype --enable-frei0r \
      --enable-librubberband --enable-libsoxr \
      --enable-libmp3lame --enable-libopus --enable-libvorbis --enable-libtheora \
      --enable-libx264 --enable-libx265 --enable-libvpx \
      --enable-libaom  --enable-libsvtav1  --enable-libfdk_aac \
      --enable-libwebp --enable-libopenjpeg \
      --enable-postproc --enable-filter=zscale --enable-filter=frei0r \
      --disable-debug && \
    make -j"$(nproc)" && make install && make distclean

################################################################
# 2 · Stage final — n8n (Debian) + FFmpeg completo
################################################################
FROM n8nio/n8n:latest-debian
USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    imagemagick ghostscript tesseract-ocr \
    curl wget zip unzip tar jq openssh-client && \
    rm -rf /var/lib/apt/lists/*
COPY --from=builder /usr/local /usr/local
ENV LD_LIBRARY_PATH=/usr/local/lib
USER node
