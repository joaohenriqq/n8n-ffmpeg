################################################################
# 1) STAGE builder · Alpine edge + libs extras + FFmpeg git-master
################################################################
FROM alpine:3.19 AS builder
USER root

# Ativa os repositórios edge (main / community / testing)
RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/main"       >> /etc/apk/repositories && \
    echo "https://dl-cdn.alpinelinux.org/alpine/edge/community"  >> /etc/apk/repositories && \
    echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing"    >> /etc/apk/repositories

# Ferramentas de build + libs que SEMPRE existem
RUN apk update && apk add --no-cache \
    autoconf automake build-base cmake git pkgconf yasm nasm \
    curl wget tar xz zlib-dev freetype-dev libass-dev \
    lame-dev opus-dev libvorbis-dev libogg-dev libtheora-dev \
    x264-dev libvpx-dev soxr-dev libwebp-dev openjpeg-dev

# Libs avançadas presentes em edge/testing
RUN apk add --no-cache \
    x265-dev aom-dev svt-av1-dev frei0r-dev librubberband-dev

########################
# Baixa e compila FFmpeg
########################
WORKDIR /ffmpeg
RUN git clone --depth 1 https://git.ffmpeg.org/ffmpeg.git .

RUN ./configure \
      --prefix=/usr/local \
      --enable-gpl           --enable-nonfree      --enable-version3 \
      --enable-libass        --enable-libfreetype  \
      --enable-libmp3lame    --enable-libopus      --enable-libvorbis \
      --enable-libx264       --enable-libx265      --enable-libvpx \
      --enable-libaom        --enable-libsvtav1    \
      --enable-libwebp       --enable-libopenjpeg  \
      --enable-librubberband --enable-libsoxr      \
      --enable-libtheora     --enable-frei0r       \
      --enable-postproc      \
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

RUN apk add --no-cache \
    imagemagick ghostscript tesseract-ocr \
    curl wget zip unzip tar jq openssh-client

# Copia ffmpeg/ffprobe + libs do estágio builder
COPY --from=builder /usr/local /usr/local
RUN echo "/usr/local/lib" > /etc/ld-musl-x86_64.path

USER node
