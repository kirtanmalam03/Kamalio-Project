
docker compose logs -f kamailio 2>&1 | Select-String -Pattern "REGISTER|INVITE|BYE|Lookup|Reply|Failure|REGISTER ok"
