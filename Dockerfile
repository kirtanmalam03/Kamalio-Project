# Older image based on kamailio/kamailio:5.6.5 — not used by docker-compose.
# The lab builds from ./kamailio/Dockerfile (Debian + Kamailio 5.8 packages).
FROM kamailio/kamailio:5.6.5

COPY cfg/kamailio.cfg /etc/kamailio/kamailio.cfg

EXPOSE 5060/udp 5060/tcp

CMD ["kamailio", "-DD", "-E", "-e", "/etc/kamailio/kamailio.cfg"]
