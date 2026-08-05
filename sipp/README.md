# SIPp Tests for the Kamailio Beginner Project

SIPp is an open-source SIP traffic generator. These scenarios verify that Kamailio accepts registrations and can proxy calls.

## Prerequisites

1. Project containers are running: `docker compose up -d`
2. Docker network `voip-net` exists
3. Demo users exist (`1001` / `1002`)

You do **not** need to install SIPp on Windows. Run it in a container attached to `voip-net`.

## Scenario files

| File | Purpose |
|------|---------|
| `register.xml` | REGISTER → 401 → REGISTER+auth → 200 OK |
| `call.xml` | INVITE(+auth) → 200 → ACK → BYE → 200 |
| `uas.xml` | Simple auto-answering UAS (callee side for call tests) |

---

## 1) Test REGISTER (recommended first test)

From the project root on **Windows (PowerShell)**:

```powershell
docker run --rm -it --network voip-net `
  -v "${PWD}/sipp:/sipp" ctaloi/sipp:latest `
  kamailio -sf /sipp/register.xml -m 1 -s 1001 -au 1001 -ap password1001
```

On **Linux / macOS / Git Bash**:

```bash
docker run --rm -it --network voip-net \
  -v "$(pwd)/sipp:/sipp" ctaloi/sipp:latest \
  kamailio -sf /sipp/register.xml -m 1 -s 1001 -au 1001 -ap password1001
```

### What the flags mean

| Flag | Meaning |
|------|---------|
| `kamailio` | Target hostname on Docker network (Compose service name) |
| `-sf /sipp/register.xml` | Scenario file |
| `-m 1` | Stop after 1 successful registration |
| `-s 1001` | SIP user / `[service]` in the XML |
| `-au 1001` | Digest authentication username |
| `-ap password1001` | Digest authentication password |

Expected result: SIPp exits successfully and Kamailio logs show REGISTER + 401 + REGISTER + 200.

Verify in MySQL:

```bash
docker compose exec mysql mysql -ukamailio -p"$MYSQL_PASSWORD" kamailio -e "SELECT username, contact, expires FROM location;"
```

(On Windows PowerShell, pass the password explicitly or use the value from `.env`.)

## Alternative: Python REGISTER test (no SIPp image required)

If Docker Hub pulls for SIPp are slow, use the included Python helper from the project root (Python 3 required on the host):

```powershell
python sipp\register_test.py 127.0.0.1 5060 1001 password1001 kamailio.local
python sipp\register_test.py 127.0.0.1 5060 1002 password1002 kamailio.local
```

Expected output includes `SUCCESS: REGISTER authenticated and accepted (200 OK)`.

---

## 2) Test a call with SIPp UAC + softphone

Terminal A — start auto-answer callee (`1002`):

```powershell
docker run --rm -it --network voip-net --name sipp-uas `
  -v "${PWD}/sipp:/sipp" ctaloi/sipp:latest `
  -sf /sipp/uas.xml -m 1
```

Terminal B — register callee Contact toward Kamailio using `register.xml` for `1002`, **or** register a softphone as 1002.

Because a pure SIPp UAS does not automatically create a usrloc entry in Kamailio, the easiest beginner call test is:

1. Register **Zoiper/Linphone as 1002** (auto-answer enabled)
2. Run `call.xml` as caller 1001

Caller command:

```powershell
docker run --rm -it --network voip-net `
  -v "${PWD}/sipp:/sipp" ctaloi/sipp:latest `
  kamailio -sf /sipp/call.xml -m 1 -s 1002
```

---

## 3) Watch Kamailio logs while testing

```bash
docker compose logs -f kamailio
```

You should see lines like:

- `SIP REGISTER from ...`
- `REGISTER success ...`
- `SIP INVITE from ...`
- `Lookup OK — relaying INVITE ...`
- `Reply 180 ...` / `Reply 200 ...`

---

## Common SIPp issues

| Symptom | Cause | Fix |
|---------|-------|-----|
| Cannot resolve `kamailio` | Wrong Docker network | Use `--network voip-net` |
| 403 / 401 loops | Bad password or realm | Use `password1001` and realm `kamailio.local` |
| 404 on INVITE | Callee not registered | Register 1002 first |
| Scenario stuck | Waiting for a response that never comes | Check `docker compose logs kamailio` |

---

## Note about media (RTP)

These beginner SIPp tests focus on **SIP signaling**. RTP may not be fully negotiated end-to-end in every automated case. That is OK: Kamailio in this project is a signaling proxy/registrar, not a media server.
