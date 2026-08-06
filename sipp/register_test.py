
import hashlib
import random
import re
import socket
import sys
import time
import uuid

HOST = sys.argv[1] if len(sys.argv) > 1 else "127.0.0.1"
PORT = int(sys.argv[2]) if len(sys.argv) > 2 else 5060
USER = sys.argv[3] if len(sys.argv) > 3 else "1001"
PASSWORD = sys.argv[4] if len(sys.argv) > 4 else "password1001"
REALM_EXPECT = sys.argv[5] if len(sys.argv) > 5 else "kamailio.local"
TIMEOUT = 5.0


def md5(s: str) -> str:
    return hashlib.md5(s.encode()).hexdigest()


def parse_auth_header(msg: str):
   
    m = re.search(r"WWW-Authenticate:\s*Digest\s+(.+)", msg, re.I)
    if not m:
        raise RuntimeError("No WWW-Authenticate header in 401 response")
    params = {}
    for part in m.group(1).split(","):
        part = part.strip()
        if "=" not in part:
            continue
        k, v = part.split("=", 1)
        params[k.strip()] = v.strip().strip('"')
    return params


def build_register(call_id, cseq, branch, contact_host, contact_port, auth_line=None):
    lines = [
        f"REGISTER sip:{REALM_EXPECT} SIP/2.0",
        f"Via: SIP/2.0/UDP {contact_host}:{contact_port};branch={branch};rport",
        f"From: <sip:{USER}@{REALM_EXPECT}>;tag={uuid.uuid4().hex[:8]}",
        f"To: <sip:{USER}@{REALM_EXPECT}>",
        f"Call-ID: {call_id}",
        f"CSeq: {cseq} REGISTER",
        f"Contact: <sip:{USER}@{contact_host}:{contact_port}>",
        "Max-Forwards: 70",
        "Expires: 3600",
        "User-Agent: kamailio-beginner-python-test",
    ]
    if auth_line:
        lines.append(auth_line)
    lines.append("Content-Length: 0")
    lines.append("")
    lines.append("")
    return "\r\n".join(lines).encode()


def main():
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.settimeout(TIMEOUT)
    sock.bind(("0.0.0.0", 0))
    local_port = sock.getsockname()[1]

    contact_host = "127.0.0.1"

    call_id = f"{uuid.uuid4().hex}@python-test"
    branch1 = f"z9hG4bK{random.randint(100000,999999)}"

    print(f"Sending REGISTER to {HOST}:{PORT} as {USER} ...")
    req1 = build_register(call_id, 1, branch1, contact_host, local_port)
    sock.sendto(req1, (HOST, PORT))
    data, _ = sock.recvfrom(65535)
    resp1 = data.decode(errors="replace")
    print("--- Response 1 ---")
    print(resp1.split("\r\n\r\n")[0])
    if "401" not in resp1.split("\r\n", 1)[0]:
        print("ERROR: expected 401 Unauthorized")
        sys.exit(1)

    auth = parse_auth_header(resp1)
    realm = auth.get("realm", REALM_EXPECT)
    nonce = auth["nonce"]
    qop = auth.get("qop")
    opaque = auth.get("opaque")
    algorithm = auth.get("algorithm", "MD5")

    uri = f"sip:{REALM_EXPECT}"
    ha1 = md5(f"{USER}:{realm}:{PASSWORD}")
    ha2 = md5(f"REGISTER:{uri}")
    nc = "00000001"
    cnonce = uuid.uuid4().hex[:8]
    if qop:
        response = md5(f"{ha1}:{nonce}:{nc}:{cnonce}:{qop}:{ha2}")
        auth_line = (
            f'Authorization: Digest username="{USER}", realm="{realm}", '
            f'nonce="{nonce}", uri="{uri}", response="{response}", '
            f'algorithm={algorithm}, qop={qop}, nc={nc}, cnonce="{cnonce}"'
        )
        if opaque:
            auth_line += f', opaque="{opaque}"'
    else:
        response = md5(f"{ha1}:{nonce}:{ha2}")
        auth_line = (
            f'Authorization: Digest username="{USER}", realm="{realm}", '
            f'nonce="{nonce}", uri="{uri}", response="{response}", algorithm={algorithm}'
        )
        if opaque:
            auth_line += f', opaque="{opaque}"'

    branch2 = f"z9hG4bK{random.randint(100000,999999)}"
    req2 = build_register(call_id, 2, branch2, contact_host, local_port, auth_line)
    sock.sendto(req2, (HOST, PORT))
    data, _ = sock.recvfrom(65535)
    resp2 = data.decode(errors="replace")
    print("--- Response 2 ---")
    print(resp2.split("\r\n\r\n")[0])
    if "200" in resp2.split("\r\n", 1)[0]:
        print("SUCCESS: REGISTER authenticated and accepted (200 OK)")
        sys.exit(0)
    print("ERROR: expected 200 OK")
    sys.exit(2)


if __name__ == "__main__":
    main()
 