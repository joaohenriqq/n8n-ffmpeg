FROM n8nio/n8n:latest
USER root

# 1) instala deps de build, clona e compila FFmpeg com LADSPA, RubberBand e frei0r
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

# 2) instala libs de runtime e plugins extras
RUN apk update && apk add --no-cache \
    imagemagick ghostscript tesseract-ocr ladspa frei0r-plugins rubberband \
    curl wget zip unzip tar jq openssh-client \
  && rm -rf /var/cache/apk/*

USER node
