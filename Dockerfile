FROM n8nio/n8n:latest
USER root

# 1) Instalação do glibc no Alpine (necessário para os builds glibc-linked do FFmpeg)
ENV GLIBC_VERSION=2.35-r1
RUN apk update && apk add --no-cache \
      ca-certificates \
      wget \
      curl \
      xz \
      tar && \
    # Importa chave de assinatura do SGerrand (expirada, por isso o --allow-untrusted)
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub \
      https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    # Faz o download dos pacotes glibc
    wget -q \
      https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk && \
    wget -q \
      https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk && \
    # Instalaignora avisos de trust por causa da chave expirada
    apk add --no-cache --allow-untrusted \
      glibc-${GLIBC_VERSION}.apk \
      glibc-bin-${GLIBC_VERSION}.apk && \
    # Limpa apk e atualiza certificados
    rm glibc-${GLIBC_VERSION}.apk glibc-bin-${GLIBC_VERSION}.apk && \
    update-ca-certificates

# 2) Remove o ffmpeg-minimal padrão para evitar conflitos
RUN apk del ffmpeg

# 3) Instala o build diário do FFmpeg do BtbN
RUN cd /tmp && \
    curl -fsSL \
      https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-linux64-gpl.tar.xz \
      -o ffmpeg.tar.xz && \
    tar -xJf ffmpeg.tar.xz -C /usr/local --strip-components=1 && \
    rm ffmpeg.tar.xz

# 4) Instala as demais ferramentas auxiliares usadas nos workflows
RUN apk update && apk add --no-cache \
      lame \
      libvpx \
      x264 \
      imagemagick \
      ghostscript \
      tesseract-ocr \
      curl \
      wget \
      zip \
      unzip \
      tar \
      jq \
      openssh-client && \
    rm -rf /var/cache/apk/*

USER node

