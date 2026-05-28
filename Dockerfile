# =========================
#        BUILDER
# =========================
FROM debian:bookworm-slim AS builder

ARG WEB_PORT=8314
ARG VER=8.5.1.1343
ARG SETUP_URL=https://cloud.banana.org/distr/server64_8_5_1_1343.zip

ENV PORT=${WEB_PORT}
ENV ONEC_VER=${VER}

ENV LANG=ru_RU.UTF-8
ENV LANGUAGE=ru_RU:ru

WORKDIR /tmp

RUN set -eux; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates \
        wget \
        unzip; \
    wget -L -O server64.zip ${SETUP_URL}; \
    unzip server64.zip -d server64; \
    chmod +x ./server64/setup-full-${ONEC_VER}-x86_64.run; \
    ./server64/setup-full-${ONEC_VER}-x86_64.run \
        --installer-language en \
        --mode unattended \
        --enable-components server; \
    rm -rf /tmp/* /var/lib/apt/lists/*


# =========================
#        RUNTIME
# =========================
FROM debian:bookworm-slim

ARG WEB_PORT=8314
ARG VER=8.5.1.1343

ENV PORT=${WEB_PORT}
ENV ONEC_VER=${VER}

# Только реальные зависимости ibsrv
RUN set -eux; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        libgssapi-krb5-2 \
        libkrb5-3 \
        libk5crypto3 \
        libcom-err2 \
        libkrb5support0 \
        libkeyutils1 \
        zlib1g; \
    rm -rf /var/lib/apt/lists/*

# Копируем только установленную 1С
COPY --from=builder /opt/1cv8 /opt/1cv8

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

CMD ["sh", "-c", "./ibsrv --data=/fs-data --address=any --port=$PORT"]
