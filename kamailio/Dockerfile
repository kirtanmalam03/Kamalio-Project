# Kamailio SIP Server - Beginner Project Image
# Installs Kamailio + MySQL module from the official Kamailio 5.8 Debian repo.

FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive \
    KAMAILIO_CFG=/etc/kamailio/kamailio.cfg

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gnupg \
        wget \
        procps \
        net-tools \
        iproute2 \
        default-mysql-client \
    && wget -O- https://deb.kamailio.org/kamailiodebkey.gpg \
        | gpg --dearmor -o /usr/share/keyrings/kamailio.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/kamailio.gpg] http://deb.kamailio.org/kamailio58 bookworm main" \
        > /etc/apt/sources.list.d/kamailio.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        kamailio \
        kamailio-mysql-modules \
        kamailio-extra-modules \
    && mkdir -p /var/run/kamailio \
    && chown kamailio:kamailio /var/run/kamailio \
    && rm -rf /var/lib/apt/lists/*

# Entry script waits for MySQL, then starts Kamailio in foreground
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 5060/udp 5060/tcp

ENTRYPOINT ["/entrypoint.sh"]
CMD ["kamailio", "-DD", "-E", "-f", "/etc/kamailio/kamailio.cfg"]
