# Stage “build”: compila o FFmpeg com todos os filtros necessários
FROM n8nio/n8n:latest AS build

USER root

# 1) Instala dependências de build + libs de runtime necessárias para linkar
RUN apk update && apk add --no-cache --virtual .build-deps \
      build-base \
      git \
      pkgconf \
      yasm \
      nasm \
      libx264-dev \
      libvpx-dev \
      lame-dev \
      libvorbis-dev \
      opus-dev \
      libtheora-dev \
      libass-dev \
      freetype-dev \
      fontconfig-dev \
      ladspa-dev \
      rubberband-dev \
      frei0r-plugins-dev \
      openssl-dev \
      zlib-dev \
    && apk add --no-cache \
      openssl \
      zlib

# 2) Clona e configura o FFmpeg com drawtext, ladspa, rubberband, frei0r etc.
RUN git clone --depth 1 https://git.ffmpeg.org/ffmpeg.git /tmp/ffmpeg \
  && cd /tmp/ffmpeg \
  && ./configure \
       --prefix=/usr/local \
       --disable-static \
       --enable-shared \
       --enable-gpl \
       --enable-nonfree \
       --enable-libx264 \
       --enable-libvpx \
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
       --enable-openssl \
  && make -j$(nproc) \
  && make install \
  && rm -rf /tmp/ffmpeg \
  && apk del .build-deps \
  && fc-cache -f

# Stage “final”: herda a mesma imagem, só copia o FFmpeg compilado e adiciona runtime extras
FROM n8nio/n8n:latest

USER root

# 3) Copia binários e libs compilados
COPY --from=build /usr/local/bin/ffmpeg   /usr/local/bin/ffmpeg
COPY --from=build /usr/local/bin/ffprobe  /usr/local/bin/ffprobe
COPY --from=build /usr/local/lib          /usr/local/lib

# 4) Garante suas ferramentas auxiliares já conhecidas
RUN apk update && apk add --no-cache \
      imagemagick \
      tesseract-ocr \
      curl \
      wget \
      zip \
      unzip \
      tar \
      jq \
      openssh-client \
      frei0r-plugins \
      ladspa \
      rubberband \
      fontconfig \
      freetype \
      libass \
      openssl \
      zlib

USER node
