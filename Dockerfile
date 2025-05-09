# ------------------------------------------------------------
# Dockerfile: n8n + FFmpeg “Tudo Incluído”
# ------------------------------------------------------------
FROM n8nio/n8n:latest

USER root

# Instala todas as dependências auxiliares (sem o ffmpeg Alpine)
RUN apk update && apk upgrade && apk add --no-cache \
    lame \
    libvpx \
    x264-libs \
    imagemagick \
    ghostscript \
    tesseract-ocr \
    curl \
    wget \
    zip \
    unzip \
    tar \
    jq \
    openssh-client \
 && apk del ffmpeg

# Baixa e instala o FFmpeg static build completo (com rubberband, frei0r, zscale etc.)
RUN cd /tmp \
 && wget https://johnvansickle.com/ffmpeg/builds/ffmpeg-git-amd64-static.tar.xz -O ffmpeg-static.tar.xz \
 && tar -xJf ffmpeg-static.tar.xz -C /usr/local/bin --strip-components=1 \
 && rm ffmpeg-static.tar.xz \
 && ffmpeg -version \
 && ffmpeg -filters | grep rubberband

USER node
