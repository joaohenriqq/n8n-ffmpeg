################################################################
# 1) Stage: builder  ·  compila Rubber Band + FFmpeg (git master)
################################################################
FROM alpine:3.19 AS builder
USER root

# Repositórios edge para dev-packages extras
RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/main"      >> /etc/apk/repositories && \
    echo "https://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories

RUN apk update && apk add --no-cache \
    autoconf automake build-base cmake git pkgconf yasm nasm \
    curl wget tar xz zlib-dev \
    freetype-dev libass-dev lame-dev opus-dev libvorbis-dev libogg-dev \
    theora-dev x264-dev x265-dev libvpx-dev aom-dev svt-av1-dev \
    librubberband-dev libsoxr-dev frei0r-dev libwebp-dev openjpeg-dev

############################
# 1A) Compila Rubber Band
############################
ARG RB_VER=3.3.0
RUN wget -q https://breakfastquay.com/files/releases/rubberband-${RB_VER}.tar.bz2 && \
    tar -xjf rubberband-${RB_VER}.tar.bz2 && \
    cd rubberband-${RB_VER} && \
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_BUILD_TYPE=Release . && \
    make -j$(nproc) && make install && cd .. && \
    rm -rf rubberband-${RB_VER}*

############################
# 1B) Clona FFmpeg git master e compila
############################
WORKDIR /ffmpeg
RUN git clone --depth 1 https://git.ffmpeg.org/ffmpeg.git . && \
    ./configure \
      --prefix=/usr/local \
      --enable-gpl --enable-nonfree --enable-version3 \
      --enable-libass  --enable-libfreetype \
      --enable-libmp3lame --enable-libopus --enable-libvorbis \
      --enable-libx264  --enable-libx265 \
      --enable-libaom   --enable-libsvtav1 \
      --enable-libvpx   --enable-libwebp \
      --enable-librubberband --enable-libsoxr \
      --enable-libopenjpeg --enable-libtheora \
      --enable-frei0r  --enable-postproc \
      --enable-filter=zscale --enable-filter=frei0r \
      --disable-debug && \
    make -j$(nproc) && make install && make distclean

##############################################################
# 2) Stage final  ·  n8n Alpine + FFmpeg full
##############################################################
FROM n8nio/n8n:latest
USER root

RUN apk add --no-cache \
    imagemagick ghostscript tesseract-ocr \
    curl wget zip unzip tar jq openssh-client

COPY --from=builder /usr/local /usr/local
RUN echo "/usr/local/lib" > /etc/ld-musl-x86_64.path

USER node
