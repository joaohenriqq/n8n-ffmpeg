# 1) Stage de build: compila FFmpeg estático com drawtext
FROM alpine:edge AS ffmpeg-build

RUN apk add --no-cache \
      build-base \
      git \
      yasm \
      nasm \
      pkgconfig \
      libvpx-dev \
      x264-dev \
      lame-dev \
      libvorbis-dev \
      opus-dev \
      libtheora-dev \
      libass-dev \
      freetype-dev \
      fontconfig-dev \
      ladspa-dev \
      rubberband-dev \
      frei0r-plugins-dev

WORKDIR /usr/src/ffmpeg
RUN git clone --depth 1 https://git.ffmpeg.org/ffmpeg.git . \
  && ./configure \
       --prefix=/usr/local \
       --disable-shared \
       --enable-static \
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
  && rm -rf /usr/src/ffmpeg

# 2) Stage final: imagem n8n com FFmpeg estático
FROM n8nio/n8n:latest

USER root

# Copia binários estáticos do build anterior
COPY --from=ffmpeg-build /usr/local/bin/ffmpeg /usr/local/bin/ffmpeg
COPY --from=ffmpeg-build /usr/local/bin/ffprobe /usr/local/bin/ffprobe

# Instala suas ferramentas de runtime (ImageMagick, Tesseract, etc)
RUN apk add --no-cache \
      imagemagick \
      tesseract-ocr \
      curl \
      wget \
      zip unzip \
      tar \
      jq \
      openssh-client

USER node
