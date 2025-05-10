FROM n8nio/n8n:latest
USER root

# 1) Instala dependências de sistema e ferramentas auxiliares
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      wget \
      curl \
      xz-utils \
      tar \
      lame \
      imagemagick \
      ghostscript \
      tesseract-ocr \
      zip \
      unzip \
      jq \
      openssh-client && \
    rm -rf /var/lib/apt/lists/*

# 2) Baixa e extrai o build diário do FFmpeg do BtbN (binários estáticos)
RUN cd /tmp && \
    wget -q -O ffmpeg.tar.xz \
      https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-linux64-gpl.tar.xz && \
    tar -xJf ffmpeg.tar.xz -C /usr/local --strip-components=1 && \
    rm ffmpeg.tar.xz

# 3) Garante limpeza final de cache
RUN rm -rf /tmp/*

USER node
