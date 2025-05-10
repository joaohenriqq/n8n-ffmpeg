FROM n8nio/n8n:latest
USER root

# 1) Habilita o repositório edge/testing para ter a versão completa do ffmpeg
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

# 2) Atualiza e instala ffmpeg, extras, rubberband e ferramentas auxiliares
RUN apk update && apk upgrade --no-cache && \
    apk add --no-cache \
      ffmpeg \        # FFmpeg com codecs principais (x264, libvpx, MP3, AAC, Vorbis)
      lame \          # MP3 support
      libvpx \        # VP8/VP9 support
      x264-libs \     # H.264 support
      imagemagick \   # ImageMagick utilities
      ghostscript \   # Ghostscript for PDF processing
      tesseract-ocr \ # OCR via Tesseract
      fontconfig \    # drawtext filter dependency
      freetype \      # drawtext filter dependency
      ladspa-sdk \    # LADSPA audio filters
      frei0r-plugins \# Frei0r video/audio plugins
      rubberband \    # Rubber Band CLI
      rubberband-libs \# Rubber Band libraries
      rubberband-dev \# (opcional) para compilar apps com librubberband
      curl \          # HTTP client
      wget \          # HTTP client
      zip \           # ZIP utility
      unzip \         # Unzip utility
      tar \           # Tar utility
      jq \            # JSON processor
      openssh-client &&\ # SSH client
    rm -rf /var/cache/apk/*

USER node
