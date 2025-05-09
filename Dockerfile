################################################################
# 1) STAGE builder · Debian + libs extras + FFmpeg git-master
################################################################
FROM debian:12-slim AS builder
ENV DEBIAN_FRONTEND=noninteractive
USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl git build-essential autoconf automake cmake pkg-config yasm nasm \
    libfreetype6-dev libass-dev libvorbis-dev libogg-dev libtheora-dev \
    libx264-dev libx265-dev libvpx-dev libaom-dev libsvtav1-dev \
    libmp3lame-dev libopus-dev librubberband-dev libsoxr-dev frei0r-plugins-dev \
    libwebp-dev libopenjp2-7-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /ffmpeg
RUN git clone --depth 1 https://git.ffmpeg.org/ffmpeg.git .

RUN ./configure \
      --prefix=/usr/local \
      --enable-gpl --enable-nonfree --enable-version3 \
      --enable-libass --enable-libfreetype \
      --enable-libmp3lame --enable-libopus --enable-libvorbis \
      --enable-libx264 --enable-libx265 --enable-libvpx \
      --enable-libaom  --enable-libsvtav1 \
      --enable-libwebp --enable-libopenjpeg \
      --enable-librubberband --enable-libsoxr \
      --enable-libtheora --enable-frei0r \
      --enable-postproc  --enable-filter=zscale --enable-filter=frei0r \
      --disable-debug && \
    make -j"$(nproc)" && \
    make install && \
    make distclean

################################################################
# 2) STAGE final · n8n (Debian) + FFmpeg completo
################################################################
FROM n8nio/n8n:latest-debian
USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    imagemagick ghostscript tesseract-ocr \
    curl wget zip unzip tar jq openssh-client && \
    rm -rf /var/lib/apt/lists/*

# Copia ffmpeg/ffprobe + libs necessárias
COPY --from=builder /usr/local /usr/local
ENV LD_LIBRARY_PATH=/usr/local/lib

USER node
