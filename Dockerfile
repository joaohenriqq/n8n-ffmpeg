################################################################
# 1) STAGE builder · Alpine edge + libs extras + FFmpeg git-master
################################################################
FROM alpine:3.19 AS builder
USER root

# → habilita repositórios edge (main / community / testing)
RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/main"       >> /etc/apk/repositories && \
    echo "https://dl-cdn.alpinelinux.org/alpine/edge/community"  >> /etc/apk/repositories && \
    echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing"    >> /etc/apk/repositories

# toolchain + pacotes sempre presentes
RUN apk update && apk add --no-cache \
    autoconf automake build-base cmake git pkgconf yasm nasm \
    curl wget tar xz zlib-dev freetype-dev libass-dev \
    lame-dev opus-dev libvorbis-dev libogg-dev theora-dev \
    x264-dev libvpx-dev soxr-dev libwebp-dev openjpeg-dev

# libs opcionais (edge/testing)
RUN apk add --no-cache \
    x265-dev aom-dev svt-av1-dev frei0r-dev librubberband-dev

########################
# baixa e compila FFmpeg (git-master, snapshot mais recente)
########################
WORKDIR /ffmpeg
RUN git clone --depth 1 https://git.ffmpeg.org/ffmpeg.git .

RUN ./configure \
      --prefix=/usr/local \
      --enable-gpl           --enable-nonfree    --enable-version3 \
      --enable-libass        --enable-libfreetype \
      --enable-libmp3lame    --enable-libopus    --enable-libvorbis \
      --enable-libx264       --enable-libx265    --enable-libvpx \
      --enable-libaom        --enable-libsvtav1 \
      --enable-libwebp       --enable-libopenjpeg \
      --enable-librubberband --enable-libsoxr \
      --enable-libtheora     --enable-frei0r \
      --enable-postproc \
      --enable-filter=zscale --enable-filter=frei0r \
      --disable-debug && \
    make -j"$(nproc)" && \
    make install && \
    make distclean

################################################################
# 2) STAGE final · n8n Alpine + FFmpeg completo
################################################################
FROM n8nio/n8n:latest
USER root

# utilitários já usados nos workflows
RUN apk add --no-cache \
    imagemagick ghostscript tesseract-ocr \
    curl wget zip unzip tar jq openssh-client

# copia ffmpeg/ffprobe + libs necessárias
COPY --from=builder /usr/local /usr/local

# registra /usr/local/lib no loader musl
RUN echo "/usr/local/lib" > /etc/ld-musl-x86_64.path

USER node
