FROM n8nio/n8n:latest
USER root

ENV GLIBC_VER=2.35-r1

# 1) glibc-compat
RUN apk update && apk upgrade && \
    apk add --no-cache ca-certificates wget curl xz tar && \
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub \
      https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    wget -q https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-${GLIBC_VER}.apk && \
    wget -q https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-bin-${GLIBC_VER}.apk && \
    apk add --no-cache glibc-${GLIBC_VER}.apk glibc-bin-${GLIBC_VER}.apk && \
    rm glibc-${GLIBC_VER}.apk glibc-bin-${GLIBC_VER}.apk && \
    update-ca-certificates

# 2) remove o ffmpeg mínimo
RUN apk del ffmpeg

# 3) instala o FFmpeg-Builds diário do BtbN
RUN cd /tmp && \
    curl -fsSL https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-linux64-gpl.tar.xz \
      -o ffmpeg.tar.xz && \
    tar -xJf ffmpeg.tar.xz -C /usr/local --strip-components=1 && \
    rm ffmpeg.tar.xz

# 4) reinstala suas ferramentas auxiliares
RUN apk update && apk upgrade && \
    apk add --no-cache \
      lame libvpx x264 \
      imagemagick ghostscript tesseract-ocr \
      curl wget zip unzip tar jq openssh-client && \
    rm -rf /var/cache/apk/*

USER node
