"""Offline certificate generation using the dependencies already inside the API image."""
import datetime
import ipaddress
import os
from pathlib import Path
import re
import sys
from cryptography import x509
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.x509.oid import NameOID, ExtendedKeyUsageOID

host = sys.argv[1]
if not re.fullmatch(r'[a-zA-Z0-9.-]+', host):
    raise SystemExit('Supply a DNS hostname or IPv4 address, without scheme or port')
folder = Path('/certs')
folder.mkdir(exist_ok=True)
if (folder / 'server.key').exists() and '--replace' not in sys.argv:
    raise SystemExit('Certificates exist. Pass --replace to deliberately rotate them.')
now = datetime.datetime.now(datetime.timezone.utc)
ca_key = rsa.generate_private_key(public_exponent=65537, key_size=2048)
ca_name = x509.Name([x509.NameAttribute(NameOID.COMMON_NAME, 'Velma Bank Lab CA')])
ca = (x509.CertificateBuilder().subject_name(ca_name).issuer_name(ca_name).public_key(ca_key.public_key())
      .serial_number(x509.random_serial_number()).not_valid_before(now - datetime.timedelta(minutes=5))
      .not_valid_after(now + datetime.timedelta(days=365)).add_extension(x509.BasicConstraints(ca=True, path_length=0), critical=True)
      .sign(ca_key, hashes.SHA256()))
key = rsa.generate_private_key(public_exponent=65537, key_size=2048)
sans = [x509.DNSName('localhost'), x509.IPAddress(ipaddress.ip_address('127.0.0.1')), x509.IPAddress(ipaddress.ip_address('10.0.2.2'))]
try:
    sans.append(x509.IPAddress(ipaddress.ip_address(host)))
except ValueError:
    sans.append(x509.DNSName(host))
cert = (x509.CertificateBuilder().subject_name(x509.Name([x509.NameAttribute(NameOID.COMMON_NAME, host)]))
        .issuer_name(ca.subject).public_key(key.public_key()).serial_number(x509.random_serial_number())
        .not_valid_before(now - datetime.timedelta(minutes=5)).not_valid_after(now + datetime.timedelta(days=365))
        .add_extension(x509.SubjectAlternativeName(sans), critical=False)
        .add_extension(x509.BasicConstraints(ca=False, path_length=None), critical=True)
        .add_extension(x509.ExtendedKeyUsage([ExtendedKeyUsageOID.SERVER_AUTH]), critical=False).sign(ca_key, hashes.SHA256()))
os.umask(0o077)
(folder / 'server.key').write_bytes(key.private_bytes(serialization.Encoding.PEM, serialization.PrivateFormat.PKCS8, serialization.NoEncryption()))
for name, value in [('ca.crt', ca), ('server.crt', cert)]:
    (folder / name).write_bytes(value.public_bytes(serialization.Encoding.PEM))
    (folder / name).chmod(0o644)
print(f'HTTPS certificate created for {host}. Paste ca.crt into app Connection settings.')
