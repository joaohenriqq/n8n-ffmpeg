FROM n8nio/n8n:latest AS builder

USER root

# 1) Instala dependências oficiais do Alpine para compilar FFmpeg
RUN apk update && apk add --no-cache \
    autoconf \
    automake \
    build-base \
    cmake \
    git \
    libass-dev \
    libfreetype-dev \
    libvorbis-dev \
    libogg-dev \
    libtheora-dev \
    libx264-dev \
    libx265-dev \
    libvpx-dev \
    libopus-dev \
    libmp3lame-dev \
    librubberband-dev \
    libsoxr-dev \
    libsdl2-dev \
    libwebp-dev \
    xz-dev \
    zlib-dev \
    yasm \
    pkgconfig \
    nasm \
    wget \
    tar

WORKDIR /ffmpeg

# 2) Baixa o tarball oficial do FFmpeg (ajuste a versão se desejar)
ARG FFMPEG_VERSION=6.0
RUN wget https://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.xz \
 && tar -xJf ffmpeg-${FFMPEG_VERSION}.tar.xz --strip-components=1 \
 && rm ffmpeg-${FFMPEG_VERSION}.tar.xz

# 3) Configura e compila com todos os filtros/codecs principais
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
      --enable-librubberband \
      --enable-libsoxr \
      --enable-libwebp \
      --enable-filter=zscale \
      --enable-filter=frei0r \
      --enable-postproc \
      --disable-debug \
    && make -j$(nproc) \
    && make install \
    && make distclean

# ------------------------------------------------------------
# Imagem final: n8n + FFmpeg full compilado
# ------------------------------------------------------------
FROM n8nio/n8n:latest

USER root

# 4) Copia ffmpeg/ffprobe do builder, instala auxiliares que você já usava
COPY --from=builder /usr/local/bin/ffmpeg /usr/local/bin/ffmpeg
COPY --from=builder /usr/local/bin/ffprobe /usr/local/bin/ffprobe

RUN apk update && apk upgrade && apk add --no-cache \
    imagemagick \
    ghostscript \
    tesseract-ocr \
    curl \
    wget \
    zip \
    unzip \
    tar \
    jq \
    openssh-client

USER node

