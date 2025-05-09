# ------------------------------------------------------------
# n8n (Debian) + FFmpeg “Tudo Incluído” via BtbN/FFmpeg-Builds
# ------------------------------------------------------------
FROM n8nio/n8n:latest-debian

USER root

# 1) Atualiza e instala dependências, removendo qualquer FFmpeg pré-existente
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      xz-utils \
      lame \
      libvpx6 \
      libx264-160 \
      imagemagick \
      ghostscript \
      tesseract-ocr \
      zip \
      unzip \
      tar \
      jq \
      openssh-client \
 && apt-get remove -y ffmpeg \
 && rm -rf /var/lib/apt/lists/*

# 2) Baixa e extrai o FFmpeg static build completo do BtbN
RUN cd /tmp \
 && curl -fsSL \
      https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-linux64-gpl.tar.xz \
      -o ffmpeg.tar.xz \
 && tar -xJf ffmpeg.tar.xz -C /usr/local --strip-components=1 \
 && rm ffmpeg.tar.xz

USER node
