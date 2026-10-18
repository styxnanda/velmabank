// Runs the app's actual HTTP + AES-GCM client against an already running backend.
import 'dart:convert';

import 'dart:io';

import 'package:velma_bank/api.dart';

void check(bool condition, String message) {
  if (!condition) {
    throw StateError(message);
  }
}

Future<void> main(List<String> args) async {
  final a = BankApi()
    ..baseUrl = args.isEmpty ? 'http://127.0.0.1:8080' : args[0]
    ..allowHttp = true;
  final b = BankApi()
    ..baseUrl = a.baseUrl
    ..allowHttp = true;
  if (args.length > 1) {
    a.caPem = File(args[1]).readAsStringSync();
    b.caPem = a.caPem;
  }
  await a.login('alice', 'VelmaDemo!2026');
  await b.login('bob', 'VelmaDemo!2026');
  final beforeA = await a.request('GET', '/me');
  final beforeB = await b.request('GET', '/me');
  check(a.sessionKey != b.sessionKey, 'Per-user keys must differ');
  final pending = await a.request('POST', '/transfers', {
    'recipient': beforeB['account'],
    'amount': 10000,
    'note': 'E2E smoke',
  });
  final inbox = await a.request('GET', '/lab/otp-inbox') as List;
  final otp = inbox.firstWhere((i) => i['id'] == pending['id'])['otp'];
  final body = {'otp': otp};
  await a.request('POST', '/transfers/${pending['id']}/confirm', body);
  await a.request('POST', '/transfers/${pending['id']}/confirm', body);
  check(
    (await a.request('GET', '/me'))['balance'] == beforeA['balance'] - 10000,
    'Exactly-once debit',
  );
  check(
    (await b.request('GET', '/me'))['balance'] == beforeB['balance'] + 10000,
    'Recipient credited',
  );
  try {
    await b.request('POST', '/transfers/${pending['id']}/confirm', body);
    throw StateError('Cross-user transfer exposed');
  } on ApiException catch (e) {
    check(e.status == 404, 'Ownership enforced');
  }
  await a.request('POST', '/card', {'frozen': true});
  check((await a.request('GET', '/me'))['frozen'] == 1, 'Card state persists');
  await a.request('POST', '/card', {'frozen': false});
  final encrypted = await a.encryptedEcho('Hello from the Flutter app client');
  check(
    encrypted['verified_response']['echo']['message'] ==
        'Hello from the Flutter app client',
    'AES-GCM interoperability',
  );
  try {
    await b.request('POST', '/lab/encryption', encrypted['sent_envelope']);
    throw StateError('Cross-session decryption worked');
  } on ApiException catch (e) {
    check(e.status == 400, 'Wrong session key rejected');
  }
  await a.request('POST', '/lab/events', {
    'scenario': 'Smoke check',
    'outcome': 'baseline',
    'details': 'Dart client HTTP and AES-GCM passed',
  });
  check(
    (await a.request('GET', '/lab/events') as List).isNotEmpty,
    'Evidence saved',
  );
  final key = a.sessionKey;
  final oldToken = a.token;
  await a.request('POST', '/auth/logout');
  try {
    await a.request('GET', '/me');
    throw StateError('Revoked token accepted');
  } on ApiException catch (e) {
    check(e.status == 401, 'Logout revokes token');
  }
  await a.login('alice', 'VelmaDemo!2026');
  check(
    key != a.sessionKey && oldToken != a.token,
    'New login rotates token and key',
  );
  await a.request('POST', '/auth/logout');
  await b.request('POST', '/auth/logout');
  stdout.writeln(
    jsonEncode({
      'result': 'PASS',
      'checks': [
        'login',
        'transfer',
        'idempotent confirmation',
        'ownership',
        'balances',
        'card',
        'AES-GCM round trip',
        'cross-session rejection',
        'evidence',
        'logout',
        'key rotation',
      ],
    }),
  );
}
