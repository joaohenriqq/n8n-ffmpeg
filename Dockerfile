FROM jrottenberg/ffmpeg:5.1-alpine AS ffmpeg
FROM n8nio/n8n:latest
USER root

COPY --from=ffmpeg /usr/local/bin/ffmpeg   /usr/local/bin/ffmpeg
COPY --from=ffmpeg /usr/local/bin/ffprobe  /usr/local/bin/ffprobe
COPY --from=ffmpeg /usr/local/lib          /usr/local/lib

RUN apt-get update && apt-get install -y --no-install-recommends \
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
      ladspa-sdk \
      rubberband-cli \
      fontconfig \
      fonts-dejavu-core \
      libass9 \
      libssl1.1 \
  && rm -rf /var/lib/apt/lists/*

USER node
