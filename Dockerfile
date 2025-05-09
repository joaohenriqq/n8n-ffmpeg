###############################################################
# 1) STAGE builder – compila Rubber Band + FFmpeg (git-master)
###############################################################
FROM alpine:3.19 AS builder
USER root

# Ferramentas mínimas de build
RUN apk add --no-cache \
    build-base cmake git pkgconf yasm nasm autoconf automake libtool \
    curl wget tar xz zlib-dev

########################
# 1A) compila Rubber Band
########################
ARG RB_VER=3.3.0
RUN wget -q https://breakfastquay.com/files/releases/rubberband-${RB_VER}.tar.bz2 \
 && tar -xjf rubberband-${RB_VER}.tar.bz2 \
 && cd rubberband-${RB_VER} \
 && cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_BUILD_TYPE=Release . \
 && make -j"$(nproc)" && make install \
 && cd .. && rm -rf rubberband-${RB_VER}*

########################
# 1B) clona e compila FFmpeg com librubberband
########################
WORKDIR /ffmpeg
RUN git clone --depth 1 https://git.ffmpeg.org/ffmpeg.git .

RUN ./configure --prefix=/usr/local \
      --enable-gpl --enable-version3 --enable-nonfree \
      --enable-librubberband         \
      --disable-debug &&             \
    make -j"$(nproc)" && make install && make distclean

###############################################################
# 2) STAGE final – seu Dockerfile original + novo FFmpeg
###############################################################
FROM n8nio/n8n:latest
USER root

RUN apk update && apk upgrade && apk add --no-cache \
  lame libvpx x264 \
  imagemagick ghostscript tesseract-ocr \
  curl wget zip unzip tar jq openssh-client

# Sobrescreve ffmpeg/ffprobe e traz as libs do builder
COPY --from=builder /usr/local /usr/local

# Faz o loader musl enxergar /usr/local/lib
RUN echo "/usr/local/lib" > /etc/ld-musl-x86_64.path

USER node
