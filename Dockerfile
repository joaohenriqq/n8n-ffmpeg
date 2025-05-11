FROM n8nio/n8n:latest

USER root

# 1) Instala dependências de build e compila o FFmpeg com todos os codecs e plugins
RUN apk add --no-cache --virtual .build-deps \
      build-base yasm pkgconfig git nasm \
      libvpx-dev x264-dev lame-dev libvorbis-dev opus-dev libtheora-dev \
      libass-dev freetype-dev fontconfig-dev \
      ladspa-dev rubberband-dev frei0r-plugins-dev \
    && git clone --depth 1 https://git.ffmpeg.org/ffmpeg.git /tmp/ffmpeg \
    && cd /tmp/ffmpeg \
    && ./configure \
         --prefix=/usr \
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
    && cd / \
    && rm -rf /tmp/ffmpeg \
    && apk del .build-deps

# 2) Instala ferramentas de runtime e bibliotecas necessárias para o FFmpeg e outros serviços
RUN apk update && apk add --no-cache \
      imagemagick \
      ghostscript \
      tesseract-ocr \
      curl \
      wget \
      zip \
      unzip \
      tar \
      jq \
      openssh-client \
      ladspa \
      frei0r-plugins \
      rubberband-libs \
      libass \
      libvpx \
      x264-libs \
      lame-libs \
      libvorbis \
      opus \
      libtheora \
      libogg \
      fontconfig \
      freetype \
    && ln -s /usr/lib/frei0r-1 /usr/lib/frei0r \
    && rm -rf /var/cache/apk/*

# 3) Instala Python e Vocos para re-sintetizar áudio com neural vocoder
RUN apk add --no-cache python3 py3-pip \
    && pip3 install --no-cache-dir vocos \
    && apk del py3-pip \
    && pip3 cache purge

USER node
