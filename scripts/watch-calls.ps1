# Tail Kamailio logs filtered to REGISTER / INVITE / BYE / Lookup

docker compose logs -f kamailio 2>&1 | Select-String -Pattern "REGISTER|INVITE|BYE|Lookup|Reply|Failure|REGISTER ok"
