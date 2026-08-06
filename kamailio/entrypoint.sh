
set -euo pipefail

MYSQL_HOST="${MYSQL_HOST:-mysql}"
MYSQL_PORT="${MYSQL_PORT:-3306}"
MYSQL_USER="${MYSQL_USER:-kamailio}"
MYSQL_PASSWORD="${MYSQL_PASSWORD:-kamailiorw}"
MYSQL_DATABASE="${MYSQL_DATABASE:-kamailio}"
SIP_DOMAIN="${SIP_DOMAIN:-kamailio.local}"
ADVERTISED_IP="${ADVERTISED_IP:-127.0.0.1}"

echo "[entrypoint] Waiting for MySQL at ${MYSQL_HOST}:${MYSQL_PORT}..."
for i in $(seq 1 60); do
  if mysqladmin ping -h"${MYSQL_HOST}" -P"${MYSQL_PORT}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" --silent 2>/dev/null; then
    echo "[entrypoint] MySQL is reachable."
    break
  fi
  if [ "$i" -eq 60 ]; then
    echo "[entrypoint] ERROR: MySQL did not become ready in time." >&2
    exit 1
  fi
  sleep 2
done

echo "[entrypoint] Checking Kamailio tables..."
TABLE_COUNT=$(mysql -h"${MYSQL_HOST}" -P"${MYSQL_PORT}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -N -e \
  "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='${MYSQL_DATABASE}' AND table_name IN ('subscriber','location','version');" 2>/dev/null || echo "0")

if [ "${TABLE_COUNT}" != "3" ]; then
  echo "[entrypoint] ERROR: Expected subscriber, location, version tables in '${MYSQL_DATABASE}'. Found count=${TABLE_COUNT}." >&2
  echo "[entrypoint] Tip: reset the MySQL volume with: docker compose down -v && docker compose up -d --build" >&2
  exit 1
fi

USER_COUNT=$(mysql -h"${MYSQL_HOST}" -P"${MYSQL_PORT}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -N -e \
  "SELECT COUNT(*) FROM ${MYSQL_DATABASE}.subscriber;" 2>/dev/null || echo "0")
echo "[entrypoint] Demo SIP subscribers in DB: ${USER_COUNT}"

DBURL="mysql://${MYSQL_USER}:${MYSQL_PASSWORD}@${MYSQL_HOST}:${MYSQL_PORT}/${MYSQL_DATABASE}"

mkdir -p /etc/kamailio
cat > /etc/kamailio/local.defs <<EOF
#!substdef "#DBURL#${DBURL}#g"
#!substdef "#SIP_DOMAIN#${SIP_DOMAIN}#g"
#!substdef "#ADVERTISED_IP#${ADVERTISED_IP}#g"
EOF

echo "[entrypoint] SIP domain: ${SIP_DOMAIN}"
echo "[entrypoint] Advertised IP: ${ADVERTISED_IP}"
echo "[entrypoint] DBURL: mysql://${MYSQL_USER}:****@${MYSQL_HOST}:${MYSQL_PORT}/${MYSQL_DATABASE}"
echo "[entrypoint] Starting Kamailio..."

exec "$@"
