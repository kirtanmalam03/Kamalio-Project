# List who is currently registered (usrloc + MySQL location table)

Write-Host "=== kamcmd ul.dump ==="
docker compose exec kamailio kamcmd ul.dump

Write-Host ""
Write-Host "=== MySQL location ==="
docker compose exec mysql mysql -ukamailio -pkamailiorw_change_me kamailio -e "SELECT username, contact, received, expires, user_agent FROM location;"
