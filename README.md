A small Docker-based lab for learning and testing SIP registration and call signalling with **Kamailio** and **MySQL**.

## What it does

- Runs Kamailio as a SIP registrar and proxy.
- Stores SIP accounts and registrations in MySQL.
- Provides three demo users: `1001`, `1002`, and `1003`.
- Includes a Python REGISTER test and SIPp scenario files.
- Supports UDP and TCP SIP on port `5060` by default.

## Requirements

- Docker Desktop with Docker Compose
- Python 3 (only for the optional local REGISTER test)
- A SIP client such as Zoiper or Linphone (optional, for manual calls)

## Quick start

From the project folder:

```powershell
Copy-Item .env.example .env
docker compose up -d --build
docker compose logs -f kamailio
```

To stop the lab:

```powershell
docker compose down
```

```powershell
docker compose down -v
```

## Demo SIP accounts

| Extension | Password |
| --- | --- |
| `1001` | `password1001` |
| `1002` | `password1002` |
| `1003` | `password1003` |

Default SIP domain/realm: `kamailio.local`  
Default server address: `127.0.0.1:5060`


## Test registration



```powershell
python sipp\register_test.py 127.0.0.1 5060 1001 password1001 kamailio.local
```

Expected result:

```text
SUCCESS: REGISTER authenticated and accepted (200 OK)
```

To inspect active registrations:

```powershell
.\scripts\show-registrations.ps1
```

To watch signalling logs:

```powershell
.\scripts\watch-calls.ps1
```

## Softphone configuration

Configure Zoiper, Linphone, or a similar client with:

| Setting | Value |
| --- | --- |
| Host / server | Your computer's IP address, or `127.0.0.1` for the same computer |
| Port | `5060` |
| Transport | UDP (or TCP) |
| Domain / realm | `kamailio.local` |
| Username | One of the demo extensions |
| Password | Matching demo password |

For another device on your LAN, update `ADVERTISED_IP` in `.env` to the LAN IP address of the computer running Docker, then restart with `docker compose up -d`.

## Project structure

```text
kamailio/          Kamailio image, startup script, and active SIP configuration
mysql/init/        MySQL schema and demo users
sipp/              SIPp scenarios and Python registration test
scripts/           PowerShell helpers for logs and registrations
.env.example       Example local configuration
docker-compose.yml Starts the Kamailio and MySQL containers
```

## Notes

- The active Kamailio configuration is `kamailio/kamailio.cfg`.
- The root `cfg/kamailio.cfg` and root `Dockerfile` are older reference files and are not used by `docker compose`.
- SIPp test scenarios are intended for signalling checks; media/RTP is outside this project's scope.
