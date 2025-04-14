FROM n8nio/n8n:1.86.1

USER root

RUN apk add --no-cache ffmpeg

USER node
# rebuild
