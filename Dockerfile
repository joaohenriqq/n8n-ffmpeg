################################################################
# 1) Stage builder · Alpine edge + libs extras + FFmpeg git-master
################################################################
FROM alpine:3.19 AS builder
USER root

# Habilita main, community e testing de edge (pacotes dev extras)
RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/main"       >> /etc/apk/repositories && \
    echo "https://dl-cdn.alpinelinux.org/alpine/edge/community"  >> /etc/apk/repositories && \
    echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing"    >> /etc/apk/repositories

# 1A) toolchain + libs de áudio/vídeo que sempre existem
RUN apk update && apk add --no-cache \
    autoconf automake build-base cmake git pkgconf yasm nasm \
    curl wget tar xz zlib-dev freetype-dev libass-dev \
    lame-dev opus-dev libvorbis-dev libogg-dev theora-dev \
    x264-dev libvpx-dev soxr-dev libwebp-dev openjpeg-dev

# 1B) libs opcionais presentes em edge/testing (codecs/filtros avançados)
RUN apk add --no-cache \
    x265-dev aom-dev svt-av1-dev frei0r-dev librubberband-dev

########################
# Baixa e compila FFmpeg
########################
WORKDIR /ffmpeg
RUN git clone --depth 1 https://git.ffmpeg.org/ffmpeg.git .

RUN ./configure \
      --prefix=/usr/local \
      --enable-gpl --enable-nonfree --enable-version3 \
      --enable-libass      --enable-libfreetype \
      --enable-libmp3lame  --enable-libopus   --enable-libvorbis \
      --enable-libx264     --enable-libx265   --enable-libvpx \
      --enable-libaom      --enable-libsvtav1 \
      --enable-libwebp     --enable-libopenjpeg \
      --enable-librubberband   --enable-libsoxr \
      --enable-libtheora   --enable-frei0r \
      --enable-postproc    --enable-filter=zscale --enable-filter=frei0r \
      --disable-debug && \
    make -j$(nproc) && make install && make distclean

################################################################
# 2) Stage final · n8n Alpine + FFmpeg full
################################################################
FROM n8nio/n8n:latest
USER root

# Utilitários já usados nos workflows
RUN apk add --no-cache \
    imagemagick ghostscript tesseract-ocr \
    curl wget zip unzip tar jq openssh-client

# Copia ffmpeg/ffprobe + libs necessárias do builder
COPY --from=builder /usr/local /usr/local

# Garante que musl encontre libs em /usr/local/lib
RUN echo "/usr/local/lib" > /etc/ld-musl-x86_64.path

USER node
