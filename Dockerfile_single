FROM debian:bookworm-slim AS base

ARG WEB_PORT=8314
ARG VER=8.5.1.1343
ARG SETUP_URL=https://cloud.banana.org/distr/server64_8_5_1_1343.zip

ENV PORT=${WEB_PORT}
ENV ONEC_VER=${VER}

ENV LANG=ru_RU.UTF-8
ENV LANGUAGE=ru_RU:ru

WORKDIR /tmp

RUN set -xe \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        libgtk-3-0 \
        libenchant-2-2 \
        libharfbuzz-icu0 \
        libgstreamer1.0-0 \
        libgstreamer-plugins-base1.0-0 \
        gstreamer1.0-plugins-good \
        gstreamer1.0-plugins-bad \
        libsecret-1-0 \
        libsoup2.4-1 \
        libsqlite3-0 \
        libegl1 \
        libxrender1 \
        libxfixes3 \
        libxslt1.1 \
        geoclue-2.0

RUN set -xe \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        unzip \
    && rm -rf /var/lib/apt/lists/* \
    && curl -L -o server64.zip ${SETUP_URL} \
    && unzip server64.zip -d server64 \
    && rm server64.zip \
    && chmod +x ./server64/setup-full-${ONEC_VER}-x86_64.run \
    && ./server64/setup-full-${ONEC_VER}-x86_64.run --installer-language en --mode unattended --enable-components server \
    && rm -rf ./server64

RUN echo "deb http://deb.debian.org/debian bookworm main contrib non-free" >> /etc/apt/sources.list \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ttf-mscorefonts-installer \
        fontconfig \
        openssh-client \
        sshpass \
        locales \
        && rm -rf /var/lib/apt/lists/* \
        && sed -i 's/^# *\(ru_RU.UTF-8\)/\1/' /etc/locale.gen \
        && locale-gen ru_RU.UTF-8 \
        && update-locale LANG=ru_RU.UTF-8 \
        && fc-cache -fv

WORKDIR /opt/1cv8/x86_64/${ONEC_VER}

EXPOSE ${WEB_PORT}

#CMD echo $PORT \
#    && ./ibsrv --data=/fs-data --address=any --port=$PORT

CMD ["sh", "-c", "echo $PORT && ./ibsrv --data=/fs-data --address=any --port=$PORT"]