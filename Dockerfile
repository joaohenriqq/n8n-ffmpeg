###############################################################
# 1) STAGE builder – compila o snapshot git-master do FFmpeg
#    habilitando apenas librubberband extra.
###############################################################
FROM alpine:3.19 AS ffmpeg-builder
USER root

# Ferramentas mínimas de build + librubberband
RUN apk add --no-cache \
    build-base yasm nasm autoconf automake libtool cmake pkgconf \
    curl git tar xz zlib-dev librubberband-dev

WORKDIR /ffmpeg

# ↓ clone raso → sempre pega o master mais recente
RUN git clone --depth 1 https://git.ffmpeg.org/ffmpeg.git .

RUN ./configure \
      --prefix=/usr/local \
      --enable-gpl --enable-version3 --enable-nonfree \
      --enable-librubberband \
      --disable-debug && \
    make -j"$(nproc)" && \
    make install && \
    make distclean

###############################################################
# 2) STAGE final – seu container n8n com o FFmpeg mais recente
###############################################################
FROM n8nio/n8n:latest
USER root

# As ferramentas que você já utilizava
RUN apk update && apk upgrade && apk add --no-cache \
  lame libvpx x264 \
  imagemagick ghostscript tesseract-ocr \
  curl wget zip unzip tar jq openssh-client

# Sobrescreve ffmpeg/ffprobe e copia as libs necessárias
COPY --from=ffmpeg-builder /usr/local/bin/ffmpeg  /usr/local/bin/
COPY --from=ffmpeg-builder /usr/local/bin/ffprobe /usr/local/bin/
COPY --from=ffmpeg-builder /usr/local/lib/ /usr/local/lib/

# Garante que o loader musl encontre /usr/local/lib
RUN echo "/usr/local/lib" > /etc/ld-musl-x86_64.path

USER node
