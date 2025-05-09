################################################################
# 1) STAGE builder – Alpine 3.19 · frei0r + FFmpeg git-master
################################################################
FROM alpine:3.19 AS builder
USER root

RUN apk add --no-cache \
    build-base cmake git pkgconf yasm nasm autoconf automake libtool \
    curl wget tar xz zlib-dev \
    freetype-dev fontconfig-dev libass-dev fribidi-dev harfbuzz-dev

WORKDIR /src
RUN git clone --depth 1 https://github.com/dyne/frei0r.git && \
    cd frei0r && cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_BUILD_TYPE=Release . && \
    make -j"$(nproc)" && make install && cd .. && rm -rf frei0r

WORKDIR /ffmpeg
RUN git clone --depth 1 https://git.ffmpeg.org/ffmpeg.git . && \
    ./configure --prefix=/usr/local \
      --enable-gpl --enable-version3 --enable-nonfree \
      --enable-libass --enable-libfreetype --enable-libfontconfig \
      --enable-frei0r \
      --disable-debug && \
    make -j"$(nproc)" && make install && make distclean

################################################################
# 2) STAGE final – n8n Alpine + FFmpeg com frei0r & drawtext/libass
################################################################
FROM n8nio/n8n:latest
USER root

RUN apk update && apk upgrade && apk add --no-cache \
    lame libvpx x264 \
    imagemagick ghostscript tesseract-ocr \
    curl wget zip unzip tar jq openssh-client \
    fontconfig freetype libass fribidi harfbuzz ttf-freefont

COPY --from=builder /usr/local /usr/local

# Remove runtimes C++ duplicados (evita conflito com o Node)
RUN rm -f /usr/local/lib/libstdc++.so* /usr/local/lib/libgcc_s.so* && \
    echo "/usr/local/lib" > /etc/ld-musl-x86_64.path

USER node
