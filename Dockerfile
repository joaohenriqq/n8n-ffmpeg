FROM n8nio/n8n:latest
USER root

# Instala dependências de build e bibliotecas de desenvolvimento
RUN apk update && apk add --no-cache \
    build-base \
    yasm \
    pkgconfig \
    git \
    libvpx-dev \
    x264-dev \
    lame-dev \
    libvorbis-dev \
    opus-dev \
    libogg-dev \
    libtheora-dev \
    libass-dev \
    freetype-dev \
    fontconfig-dev \
    ladspa-dev \
    rubberband-dev && \
    rm -rf /var/cache/apk/*

# Clona e compila o FFmpeg com suporte a codecs, LADSPA e RubberBand (sem frei0r)
WORKDIR /tmp/ffmpeg
RUN git clone --depth 1 https://git.ffmpeg.org/ffmpeg.git . && \
    ./configure \
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
      --enable-libogg \
      --enable-libtheora \
      --enable-libass \
      --enable-libfreetype \
      --enable-libfontconfig \
      --enable-ladspa \
      --enable-librubberband && \
    make -j$(nproc) && \
    make install && \
    rm -rf /tmp/ffmpeg

# Reseta diretório de trabalho
WORKDIR /

# Remove dependências de build para manter imagem leve
RUN apk del --purge \
    build-base \
    yasm \
    pkgconfig \
    git \
    libvpx-dev \
    x264-dev \
    lame-dev \
    libvorbis-dev \
    opus-dev \
    libogg-dev \
    libtheora-dev \
    libass-dev \
    freetype-dev \
    fontconfig-dev \
    ladspa-dev \
    rubberband-dev && \
    rm -rf /var/cache/apk/*

# Instala ferramentas de runtime e plugins extras
RUN apk update && apk add --no-cache \
    ffmpeg \
    imagemagick \
    ghostscript \
    tesseract-ocr \
    ladspa \
    frei0r-plugins \
    rubberband \
    curl \
    wget \
    zip \
    unzip \
    tar \
    jq \
    openssh-client && \
    rm -rf /var/cache/apk/*

USER node
