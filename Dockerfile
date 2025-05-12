# 1) Build FFmpeg completo com drawtext
FROM jrottenberg/ffmpeg:5.1-alpine AS ffmpeg

# 2) Imagem n8n baseada em Alpine
FROM n8nio/n8n:latest
USER root

# 3) Copia o FFmpeg e libs compilados
COPY --from=ffmpeg /usr/local/bin/ffmpeg   /usr/local/bin/ffmpeg
COPY --from=ffmpeg /usr/local/bin/ffprobe  /usr/local/bin/ffprobe
COPY --from=ffmpeg /usr/local/lib          /usr/local/lib

# 4) Instala pacotes de runtime via apk
RUN apk update && apk add --no-cache \
    imagemagick \
    tesseract-ocr \
    curl \
    wget \
    zip \
    unzip \
    tar \
    jq \
    openssh-client \
    frei0r-plugins \
    ladspa \
    rubberband \
    fontconfig \
    freetype \
    libass \
    libssl1.1
      
USER node
