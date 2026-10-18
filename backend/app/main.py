"""Velma Bank: isolated lab backend; all balances and OTPs are fictional."""
import base64
import hashlib
import hmac
import json
import os
import secrets
import sqlite3
import time
from contextlib import asynccontextmanager, contextmanager
from typing import Annotated

from cryptography.hazmat.primitives.ciphers.aead import AESGCM
from fastapi import Depends, FastAPI, Header, HTTPException
from pydantic import BaseModel, Field

DB = os.getenv('VELMA_DB', '/data/velma.db')
TTL = 3600

def password_hash(password, salt):
    return hashlib.scrypt(password.encode(), salt=bytes.fromhex(salt), n=16384, r=8, p=1).hex()

@contextmanager
def database():
    conn = sqlite3.connect(DB, timeout=15)
    conn.row_factory = sqlite3.Row
    conn.execute('PRAGMA foreign_keys=ON')
    try:
        yield conn
        conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()

def init_db():
    os.makedirs(os.path.dirname(os.path.abspath(DB)), exist_ok=True)
    with database() as db:
        db.executescript('''
        CREATE TABLE IF NOT EXISTS users(id INTEGER PRIMARY KEY, username TEXT UNIQUE, name TEXT, salt TEXT, password TEXT, account TEXT UNIQUE, balance INTEGER, frozen INTEGER DEFAULT 0);
        CREATE TABLE IF NOT EXISTS sessions(token TEXT PRIMARY KEY, user_id INTEGER REFERENCES users(id), expires INTEGER, encryption_key TEXT);
        CREATE TABLE IF NOT EXISTS transfers(id TEXT PRIMARY KEY, user_id INTEGER REFERENCES users(id), recipient_id INTEGER REFERENCES users(id), amount INTEGER, note TEXT, otp TEXT, expires INTEGER, attempts INTEGER DEFAULT 0, status TEXT DEFAULT 'pending', created INTEGER);
        CREATE TABLE IF NOT EXISTS transactions(id TEXT PRIMARY KEY, user_id INTEGER REFERENCES users(id), amount INTEGER, description TEXT, created INTEGER);
        CREATE TABLE IF NOT EXISTS events(id INTEGER PRIMARY KEY, user_id INTEGER REFERENCES users(id), scenario TEXT, outcome TEXT, details TEXT, created INTEGER);
        CREATE TABLE IF NOT EXISTS login_limits(username TEXT PRIMARY KEY, attempts INTEGER, reset_at INTEGER);
        ''')
        for username, name, account in [('alice', 'Alice Morgan', '880010001'), ('bob', 'Bob Chen', '880010002')]:
            if not db.execute('SELECT id FROM users WHERE username=?', (username,)).fetchone():
                salt = secrets.token_hex(16)
                db.execute('INSERT INTO users(username,name,salt,password,account,balance) VALUES(?,?,?,?,?,?)',
                           (username, name, salt, password_hash('VelmaDemo!2026', salt), account, 250000000))

@asynccontextmanager
async def lifespan(app):
    init_db()
    yield

app = FastAPI(title='Velma Bank Lab API', version='1.0.0', lifespan=lifespan)

class Login(BaseModel):
    username: str = Field(min_length=1, max_length=64)
    password: str = Field(min_length=1, max_length=128)

class Transfer(BaseModel):
    recipient: str = Field(min_length=1, max_length=32)
    amount: int = Field(gt=0, le=100000000, strict=True)
    note: str = Field(default='', max_length=140)

class OTP(BaseModel):
    otp: str = Field(pattern=r'^\d{6}$')

class Card(BaseModel):
    frozen: bool

class Event(BaseModel):
    scenario: str = Field(min_length=1, max_length=100)
    outcome: str = Field(pattern='^(baseline|pass|fail|blocked|not_supported|observation)$')
    details: str = Field(default='', max_length=2000)

class Envelope(BaseModel):
    nonce: str = Field(max_length=32)
    ciphertext: str = Field(max_length=8192)

def session(authorization: Annotated[str | None, Header()] = None):
    token = (authorization or '').removeprefix('Bearer ')
    with database() as db:
        row = db.execute('SELECT * FROM sessions WHERE token=? AND expires>?', (hashlib.sha256(token.encode()).hexdigest(), int(time.time()))).fetchone()
        if not row:
            raise HTTPException(401, 'Session expired. Please sign in again.')
        return dict(row)

Auth = Annotated[dict, Depends(session)]

@app.get('/health')
def health():
    return {'status': 'ok', 'service': 'Velma Bank', 'lab': True}

@app.post('/auth/login')
def login(body: Login):
    now = int(time.time())
    with database() as db:
        limit = db.execute('SELECT * FROM login_limits WHERE username=?', (body.username,)).fetchone()
        if limit and limit['reset_at'] > now and limit['attempts'] >= 10:
            raise HTTPException(429, 'Too many attempts. Try again in five minutes.')
        user = db.execute('SELECT * FROM users WHERE username=?', (body.username,)).fetchone()
        valid = user and hmac.compare_digest(user['password'], password_hash(body.password, user['salt']))
        if not valid:
            attempts = limit['attempts'] + 1 if limit and limit['reset_at'] > now else 1
            reset = limit['reset_at'] if limit and limit['reset_at'] > now else now + 300
            db.execute('INSERT OR REPLACE INTO login_limits VALUES(?,?,?)', (body.username, attempts, reset))
        else:
            db.execute('DELETE FROM login_limits WHERE username=?', (body.username,))
            db.execute('DELETE FROM sessions WHERE expires<=?', (now,))
            token = secrets.token_urlsafe(32)
            key = base64.b64encode(AESGCM.generate_key(bit_length=256)).decode()
            db.execute('INSERT INTO sessions VALUES(?,?,?,?)', (hashlib.sha256(token.encode()).hexdigest(), user['id'], now + TTL, key))
    if not valid:
        raise HTTPException(401, 'Invalid username or password')
    return {'token': token, 'expires_at': now + TTL, 'session_key': key, 'user_id': user['id']}

@app.post('/auth/logout')
def logout(auth: Auth):
    with database() as db:
        db.execute('DELETE FROM sessions WHERE token=?', (auth['token'],))
    return {'ok': True}

@app.get('/me')
def me(auth: Auth):
    with database() as db:
        user = dict(db.execute('SELECT id,username,name,account,balance,frozen FROM users WHERE id=?', (auth['user_id'],)).fetchone())
    user.update(currency='IDR', balance_unit='minor (100 = Rp 1)', card_last4='4829', card_expiry='12/29')
    return user

@app.get('/beneficiaries')
def beneficiaries(auth: Auth):
    with database() as db:
        return [dict(row) for row in db.execute('SELECT name,account FROM users WHERE id!=?', (auth['user_id'],))]

@app.get('/transactions')
def transactions(auth: Auth):
    with database() as db:
        return [dict(row) for row in db.execute('SELECT * FROM transactions WHERE user_id=? ORDER BY created DESC,rowid DESC LIMIT 100', (auth['user_id'],))]

@app.post('/transfers')
def create_transfer(body: Transfer, auth: Auth):
    now = int(time.time())
    with database() as db:
        recipient = db.execute('SELECT id,name FROM users WHERE account=? AND id!=?', (body.recipient, auth['user_id'])).fetchone()
        if not recipient:
            raise HTTPException(400, 'Choose another Velma account')
        balance = db.execute('SELECT balance FROM users WHERE id=?', (auth['user_id'],)).fetchone()[0]
        if body.amount > balance:
            raise HTTPException(400, 'Insufficient funds')
        transfer_id, otp = secrets.token_hex(12), f'{secrets.randbelow(1000000):06d}'
        db.execute('INSERT INTO transfers(id,user_id,recipient_id,amount,note,otp,expires,created) VALUES(?,?,?,?,?,?,?,?)',
                   (transfer_id, auth['user_id'], recipient['id'], body.amount, body.note, otp, now + 300, now))
    return {'id': transfer_id, 'recipient': recipient['name'], 'expires_at': now + 300, 'message': 'Open Lab OTP inbox; no real SMS is sent.'}

@app.get('/lab/otp-inbox')
def inbox(auth: Auth):
    with database() as db:
        return [dict(row) for row in db.execute("SELECT id,otp,amount,expires FROM transfers WHERE user_id=? AND status='pending' AND expires>? ORDER BY created DESC,rowid DESC LIMIT 20", (auth['user_id'], int(time.time())))]

@app.post('/transfers/{transfer_id}/confirm')
def confirm(transfer_id: str, body: OTP, auth: Auth):
    error = None
    with database() as db:
        db.execute('BEGIN IMMEDIATE')
        row = db.execute('SELECT * FROM transfers WHERE id=? AND user_id=?', (transfer_id, auth['user_id'])).fetchone()
        if not row:
            raise HTTPException(404, 'Transfer not found')
        if row['status'] == 'completed':
            return {'id': transfer_id, 'status': 'completed'}
        if row['expires'] <= int(time.time()) or row['attempts'] >= 5:
            raise HTTPException(400, 'OTP expired or locked. Create a new transfer.')
        if not hmac.compare_digest(row['otp'], body.otp):
            db.execute('UPDATE transfers SET attempts=attempts+1 WHERE id=?', (transfer_id,))
            error = 'Incorrect OTP'
        else:
            updated = db.execute('UPDATE users SET balance=balance-? WHERE id=? AND balance>=?', (row['amount'], auth['user_id'], row['amount'])).rowcount
            if not updated:
                raise HTTPException(400, 'Insufficient funds')
            db.execute('UPDATE users SET balance=balance+? WHERE id=?', (row['amount'], row['recipient_id']))
            db.execute("UPDATE transfers SET status='completed',otp='' WHERE id=?", (transfer_id,))
            for uid, amount, description in [(auth['user_id'], -row['amount'], 'Transfer sent'), (row['recipient_id'], row['amount'], 'Transfer received')]:
                db.execute('INSERT INTO transactions VALUES(?,?,?,?,?)', (secrets.token_hex(12), uid, amount, description + (': ' + row['note'] if row['note'] else ''), int(time.time())))
    if error:
        raise HTTPException(400, error)
    return {'id': transfer_id, 'status': 'completed'}

@app.post('/card')
def card(body: Card, auth: Auth):
    with database() as db:
        db.execute('UPDATE users SET frozen=? WHERE id=?', (body.frozen, auth['user_id']))
    return {'frozen': body.frozen, 'message': 'Demo card state updated; bank transfers are independent.'}

@app.post('/lab/encryption')
def encryption(body: Envelope, auth: Auth):
    try:
        key = base64.b64decode(auth['encryption_key'], validate=True)
        nonce = base64.b64decode(body.nonce, validate=True)
        if len(nonce) != 12:
            raise ValueError('nonce')
        aad = f"velma:{auth['user_id']}".encode()
        plain = AESGCM(key).decrypt(nonce, base64.b64decode(body.ciphertext, validate=True), aad)
        message = json.loads(plain)
        response = json.dumps({'echo': message, 'user_id': auth['user_id'], 'server_time': int(time.time())}).encode()
        fresh_nonce = secrets.token_bytes(12)
        return {'nonce': base64.b64encode(fresh_nonce).decode(), 'ciphertext': base64.b64encode(AESGCM(key).encrypt(fresh_nonce, response, aad)).decode()}
    except Exception:
        raise HTTPException(400, 'Invalid encrypted payload for this session')

@app.post('/lab/events')
def record_event(body: Event, auth: Auth):
    with database() as db:
        db.execute('INSERT INTO events(user_id,scenario,outcome,details,created) VALUES(?,?,?,?,?)', (auth['user_id'], body.scenario, body.outcome, body.details, int(time.time())))
    return {'ok': True}

@app.get('/lab/events')
def events(auth: Auth):
    with database() as db:
        return [dict(row) for row in db.execute('SELECT * FROM events WHERE user_id=? ORDER BY id DESC LIMIT 200', (auth['user_id'],))]
