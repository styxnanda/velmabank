import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';

class ApiException implements Exception {
  final String message;
  final int status;
  ApiException(this.message, [this.status = 0]);
  @override
  String toString() => message;
}

class BankApi {
  String baseUrl = const String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://10.0.2.2:8443',
  );
  String caPem = '';
  bool allowHttp = false;
  String? token;
  String? sessionKey;
  int? userId;
  DateTime? expires;

  void clearSession() {
    token = null;
    sessionKey = null;
    userId = null;
    expires = null;
  }

  Future<dynamic> request(String method, String path, [Object? data]) async {
    final uri = Uri.parse('$baseUrl$path');
    if (!['https', 'http'].contains(uri.scheme) ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty) {
      throw ApiException(
        'Enter a valid HTTP(S) server URL without credentials.',
      );
    }
    if (uri.scheme == 'http' && !allowHttp) {
      throw ApiException(
        'HTTP is disabled. Enable explicit HTTP lab mode in Connection settings.',
      );
    }
    final context = SecurityContext(withTrustedRoots: true);
    if (caPem.trim().isNotEmpty) {
      context.setTrustedCertificatesBytes(utf8.encode(caPem));
    }
    final client = HttpClient(context: context)
      ..connectionTimeout = const Duration(seconds: 12);
    try {
      final req = await client
          .openUrl(method, uri)
          .timeout(const Duration(seconds: 15));
      req.followRedirects = false;
      req.headers.contentType = ContentType.json;
      if (token != null) {
        req.headers.set('Authorization', 'Bearer $token');
      }
      if (data != null) {
        req.write(jsonEncode(data));
      }
      final res = await req.close().timeout(const Duration(seconds: 15));
      final raw = await res
          .transform(utf8.decoder)
          .join()
          .timeout(const Duration(seconds: 15));
      final decoded = raw.isEmpty ? <String, dynamic>{} : jsonDecode(raw);
      if (res.statusCode < 200 || res.statusCode >= 300) {
        if (res.statusCode == 401) {
          clearSession();
        }
        throw ApiException(
          decoded is Map
              ? '${decoded['detail'] ?? 'Request failed'}'
              : 'HTTP ${res.statusCode}',
          res.statusCode,
        );
      }
      return decoded;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        'Connection failed. Check server address, reachability and TLS certificate. $e',
      );
    } finally {
      client.close(force: true);
    }
  }

  Future<void> login(String username, String password) async {
    final result = await request('POST', '/auth/login', {
      'username': username,
      'password': password,
    });
    token = result['token'];
    sessionKey = result['session_key'];
    userId = result['user_id'];
    expires = DateTime.fromMillisecondsSinceEpoch(result['expires_at'] * 1000);
  }

  Future<Map<String, dynamic>> encryptedEcho(String message) async {
    if (sessionKey == null) {
      throw ApiException('Sign in first');
    }
    final aes = AesGcm.with256bits();
    final key = SecretKey(base64Decode(sessionKey!));
    final aad = utf8.encode('velma:$userId');
    final box = await aes.encrypt(
      utf8.encode(jsonEncode({'message': message})),
      secretKey: key,
      aad: aad,
    );
    final envelope = {
      'nonce': base64Encode(box.nonce),
      'ciphertext': base64Encode([...box.cipherText, ...box.mac.bytes]),
    };
    final result = await request('POST', '/lab/encryption', envelope);
    final bytes = base64Decode(result['ciphertext']);
    final opened = await aes.decrypt(
      SecretBox(
        bytes.sublist(0, bytes.length - 16),
        nonce: base64Decode(result['nonce']),
        mac: Mac(bytes.sublist(bytes.length - 16)),
      ),
      secretKey: key,
      aad: aad,
    );
    return {
      'sent_envelope': envelope,
      'verified_response': jsonDecode(utf8.decode(opened)),
    };
  }
}
