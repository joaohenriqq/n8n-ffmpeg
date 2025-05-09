FROM n8nio/n8n:latest-debian

USER root

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      xz-utils \
      imagemagick \
      ghostscript \
      tesseract-ocr \
      zip \
      unzip \
      tar \
      jq \
      openssh-client \
 # remove o ffmpeg caso exista, mas não falha se não estiver instalado
 && apt-get remove -y ffmpeg || true \
 && rm -rf /var/lib/apt/lists/*

# Baixa e extrai o FFmpeg full do BtbN
RUN cd /tmp \
 && curl -fsSL \
      https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-linux64-gpl.tar.xz \
      -o ffmpeg.tar.xz \
 && tar -xJf ffmpeg.tar.xz -C /usr/local --strip-components=1 \
 && rm ffmpeg.tar.xz

USER node
