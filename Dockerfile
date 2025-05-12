FROM n8nio/n8n:latest

USER root

# 0) Remove o FFmpeg pré-instalado
RUN apk del ffmpeg || true

# 1) Instala dependências de build + runtime (incluindo todas as libs de codec)
RUN apk add --no-cache --virtual .build-deps \
      build-base \
      yasm nasm pkgconfig git \
      libvpx-dev x264-dev \
      lame-dev libvorbis-dev opus-dev libtheora-dev \
      libass-dev freetype-dev fontconfig-dev \
      ladspa-dev rubberband-dev frei0r-plugins-dev \
    && apk add --no-cache \
      freetype fontconfig libass ladspa rubberband frei0r-plugins \
      imagemagick \
      tesseract-ocr \
      curl \
      wget \
      zip unzip \
      tar \
      jq \
      openssh-client \
      libvpx \
      x264-libs \
      lame-libs \
      libvorbis \
      opus \
      libtheora \
    \
# 2) Clona e compila o FFmpeg com drawtext e todos os filtros
    && git clone --depth 1 https://git.ffmpeg.org/ffmpeg.git /tmp/ffmpeg \
    && cd /tmp/ffmpeg \
    && ./configure \
         --prefix=/usr/local \
         --disable-static \
         --enable-shared \
         --enable-gpl \
         --enable-nonfree \
         --enable-libvpx \
         --enable-libx264 \
         --enable-libmp3lame \
         --enable-libvorbis \
         --enable-libopus \
         --enable-libtheora \
         --enable-libass \
         --enable-libfreetype \
         --enable-libfontconfig \
         --enable-ladspa \
         --enable-librubberband \
         --enable-frei0r \
    && make -j$(nproc) \
    && make install \
    && rm -rf /tmp/ffmpeg \
    \
# 3) Limpa dependências de build e atualiza cache de fontes
    && apk del .build-deps \
    && fc-cache -f

USER node
