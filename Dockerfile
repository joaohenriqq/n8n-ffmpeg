FROM n8nio/n8n:latest
USER root

# 1) Instala glibc para suportar builds GLIBC-linked
ENV GLIBC_VERSION=2.35-r1
RUN apk update && apk add --no-cache ca-certificates wget curl xz tar && \
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    wget -q https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk && \
    wget -q https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk && \
    apk add --no-cache --allow-untrusted glibc-${GLIBC_VERSION}.apk glibc-bin-${GLIBC_VERSION}.apk && \
    rm glibc-${GLIBC_VERSION}.apk glibc-bin-${GLIBC_VERSION}.apk && \
    update-ca-certificates

# 2) Remove o ffmpeg padrão do Alpine
RUN apk del ffmpeg || true

# 3) Baixa e instala o FFmpeg diário do BtbN (com frei0r, ladspa, drawtext etc.)
RUN cd /tmp && \
    curl -fsSL https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-linux64-gpl.tar.xz -o ffmpeg.tar.xz && \
    tar -xJf ffmpeg.tar.xz -C /usr/local --strip-components=1 && \
    rm ffmpeg.tar.xz

# 4) Instala ferramentas auxiliares e plugins (frei0r-plugins, ladspa, rubberband etc.)
RUN apk update && apk add --no-cache \
      imagemagick \        # ImageMagick (convert/magick)
      ghostscript \        # processamento de PDFs
      tesseract-ocr \      # OCR
      fontconfig \         # drawtext dependency
      freetype \           # drawtext dependency
      ladspa \             # LADSPA filters
      frei0r-plugins \     # Frei0r filters
      rubberband \         # Rubber Band CLI
      curl \               # HTTP client
      wget \               # HTTP client
      zip \                # ZIP utility
      unzip \              # Unzip utility
      tar \                # Tar utility
      jq \                 # JSON processor
      openssh-client && \  # SSH client
    rm -rf /var/cache/apk/*

USER node
