import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'api.dart';
import 'scenarios.dart';

void main() => runApp(const VelmaBank());
const platform = MethodChannel('com.velma.bank/lab');
const ink = Color(0xff142c38);
const teal = Color(0xff007e80);
String money(num minor) =>
    'Rp ${(minor / 100).toStringAsFixed(2).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')}';

class VelmaBank extends StatelessWidget {
  const VelmaBank({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Velma Bank',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: teal),
      scaffoldBackgroundColor: const Color(0xfff3f6f7),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xfff3f6f7),
        foregroundColor: ink,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    ),
    home: const BankHome(),
  );
}

class BankHome extends StatefulWidget {
  const BankHome({super.key});
  @override
  State<BankHome> createState() => _BankHomeState();
}

class _BankHomeState extends State<BankHome> {
  final api = BankApi();
  final username = TextEditingController(text: 'alice');
  final password = TextEditingController(text: 'VelmaDemo!2026');
  final amount = TextEditingController(text: '10000');
  final note = TextEditingController();
  final otp = TextEditingController();
  final evidence = TextEditingController();
  final secret = TextEditingController(text: 'Velma confidential test note');
  Map<String, dynamic>? me;
  List<dynamic> beneficiaries = [], transactions = [], inbox = [], events = [];
  Map<String, dynamic> diagnostics = {};
  String? recipient, transferId;
  String pendingSummary = '';
  String assetMarker = 'loading';

  void clearUserState() {
    me = null;
    recipient = null;
    transferId = null;
    beneficiaries = [];
    transactions = [];
    inbox = [];
    events = [];
    cryptoResult = '';
    evidence.clear();
    otp.clear();
    tab = 0;
  }

  String scenario = scenarios.first, outcome = 'baseline', cryptoResult = '';
  bool busy = false, secureWindow = false, hidePassword = true;
  int tab = 0, taps = 0;
  String? error;

  @override
  void initState() {
    super.initState();
    rootBundle.loadString('assets/integrity_marker.txt').then((value) {
      if (mounted) {
        setState(() => assetMarker = value.trim());
      }
    });
    platform.setMethodCallHandler((call) async {
      if (call.method == 'raspEvent' && mounted) {
        final event = Map<String, dynamic>.from(call.arguments as Map);
        setState(() {
          evidence.text = jsonEncode(event);
        });
        // Vendor events are evidence only until an explicit enforcement policy is integrated.
      }
    });
  }

  @override
  void dispose() {
    for (final c in [username, password, amount, note, otp, evidence, secret]) {
      c.dispose();
    }
    platform.setMethodCallHandler(null);
    super.dispose();
  }

  Future<void> run(Future<void> Function() action) async {
    if (busy) {
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await action();
    } catch (e) {
      if (mounted) {
        setState(() {
          error = '$e';
          if (api.token == null) {
            clearUserState();
          }
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          busy = false;
        });
      }
    }
  }

  Future<void> refresh() async {
    final profile = await api.request('GET', '/me');
    final people = await api.request('GET', '/beneficiaries');
    final history = await api.request('GET', '/transactions');
    if (mounted) {
      setState(() {
        me = Map<String, dynamic>.from(profile);
        beneficiaries = people;
        transactions = history;
        if (!beneficiaries.any((b) => b['account'] == recipient)) {
          recipient = beneficiaries.isEmpty
              ? null
              : beneficiaries.first['account'];
        }
      });
    }
  }

  void toast(String text) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    }
  }

  Widget heading(String title, String subtitle) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w700,
            color: ink,
          ),
        ),
        const SizedBox(height: 6),
        Text(subtitle, style: const TextStyle(color: Color(0xff627580))),
      ],
    ),
  );
  Widget panel(List<Widget> children) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    ),
  );
  Widget field(
    TextEditingController controller,
    String label, {
    TextInputType? keyboard,
    int lines = 1,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: lines,
      decoration: InputDecoration(labelText: label),
    ),
  );
  Widget button(
    String label,
    Future<void> Function() action, {
    IconData icon = Icons.arrow_forward,
  }) => FilledButton.icon(
    onPressed: busy ? null : () => run(action),
    icon: Icon(icon),
    label: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(label),
    ),
  );

  Future<void> connection() async {
    final url = TextEditingController(text: api.baseUrl);
    final ca = TextEditingController(text: api.caPem);
    bool http = api.allowHttp;
    final save = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, update) => AlertDialog(
          title: const Text('Connection settings'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: url,
                    decoration: const InputDecoration(
                      labelText: 'Backend URL (no trailing path)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Use the server LAN address from BlueStacks. HTTPS uses port 8443; HTTP lab uses 8080. Settings and sessions remain in memory only.',
                  ),
                  SwitchListTile(
                    title: const Text('Allow HTTP lab transport'),
                    subtitle: const Text(
                      'Credentials and session keys are exposed on HTTP.',
                    ),
                    value: http,
                    onChanged: (v) => update(() => http = v),
                  ),
                  TextField(
                    controller: ca,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Lab CA certificate PEM (optional)',
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Paste ca.crt from the offline bundle for private HTTPS. Certificate and hostname validation remain enabled. Redirects are rejected.',
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (save == true) {
      final value = url.text.trim().replaceAll(RegExp(r'/+$'), '');
      final parsed = Uri.tryParse(value);
      if (parsed == null ||
          !['http', 'https'].contains(parsed.scheme) ||
          parsed.host.isEmpty ||
          parsed.path.isNotEmpty ||
          parsed.hasQuery ||
          parsed.hasFragment ||
          parsed.userInfo.isNotEmpty) {
        toast('Use a server origin such as https://192.168.1.50:8443');
      } else {
        api.clearSession();
        setState(() {
          api.baseUrl = value;
          api.caPem = ca.text.trim();
          api.allowHttp = http;
          clearUserState();
          transferId = null;
          error = null;
        });
      }
    }
    // Dialog route may still be animating; its controllers are short-lived.
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'velma',
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.5,
        ),
      ),
      actions: [
        const Center(child: Chip(label: Text('BANK LAB'))),
        IconButton(
          onPressed: busy ? null : connection,
          icon: const Icon(Icons.settings_ethernet),
          tooltip: 'Connection settings',
        ),
        if (me != null)
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: busy
                ? null
                : () => run(() async {
                    try {
                      await api.request('POST', '/auth/logout');
                    } finally {
                      api.clearSession();
                      setState(() {
                        clearUserState();
                        transferId = null;
                        inbox = [];
                        events = [];
                        cryptoResult = '';
                        tab = 0;
                      });
                    }
                  }),
          ),
      ],
    ),
    body: SafeArea(
      child: Column(
        children: [
          if (busy) const LinearProgressIndicator(minHeight: 3),
          if (error != null)
            Container(
              width: double.infinity,
              color: const Color(0xffffe5df),
              padding: const EdgeInsets.all(12),
              child: Text(error!, maxLines: 5, overflow: TextOverflow.ellipsis),
            ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: me == null
                      ? loginView()
                      : [dashboard, transfer, activity, cards, lab][tab](),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    bottomNavigationBar: me == null
        ? null
        : NavigationBar(
            selectedIndex: tab,
            onDestinationSelected: (i) => setState(() => tab = i),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.account_balance_wallet_outlined),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.swap_horiz),
                label: 'Transfer',
              ),
              NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                label: 'Activity',
              ),
              NavigationDestination(
                icon: Icon(Icons.credit_card),
                label: 'Card',
              ),
              NavigationDestination(
                icon: Icon(Icons.science_outlined),
                label: 'Lab',
              ),
            ],
          ),
  );

  List<Widget> loginView() => [
    heading(
      'Banking, ready for testing.',
      'A complete fictional bank. Your RASP policy comes next.',
    ),
    panel([
      const Icon(Icons.account_balance, size: 54, color: teal),
      const SizedBox(height: 24),
      field(username, 'Username'),
      TextField(
        controller: password,
        obscureText: hidePassword,
        decoration: InputDecoration(
          labelText: 'Password',
          suffixIcon: IconButton(
            onPressed: () => setState(() => hidePassword = !hidePassword),
            icon: Icon(hidePassword ? Icons.visibility : Icons.visibility_off),
          ),
        ),
      ),
      const SizedBox(height: 20),
      button('Sign in', () async {
        await api.login(username.text.trim(), password.text);
        await refresh();
      }),
      const SizedBox(height: 16),
      const SelectableText(
        'Demo users: alice / bob\nPassword: VelmaDemo!2026\nStarting balance: Rp 2,500,000 each',
      ),
    ]),
    const SizedBox(height: 16),
    Text('Server: ${api.baseUrl}'),
    const SizedBox(height: 8),
    const Text(
      'No real money, SMS or payment services. Configure your server with the connection icon above.',
    ),
    TextButton(
      onPressed: busy
          ? null
          : () => run(() async {
              await api.request('GET', '/health');
              toast('Backend is reachable');
            }),
      child: const Text('Check backend connection'),
    ),
  ];

  List<Widget> dashboard() => [
    heading(
      'Hello, ${me!['name'].toString().split(' ').first}',
      'Your everyday banking sandbox',
    ),
    Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ink,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AVAILABLE BALANCE · IDR',
            style: TextStyle(color: Colors.white70, letterSpacing: 1.3),
          ),
          const SizedBox(height: 14),
          Text(
            money(me!['balance']),
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Velma Everyday     ${me!['account']}',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    ),
    const SizedBox(height: 16),
    panel([
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.send_outlined, color: teal),
        title: const Text('Send a transfer'),
        subtitle: const Text('Choose a recipient and confirm with a lab OTP'),
        onTap: () => setState(() => tab = 1),
      ),
      const Divider(),
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.science_outlined, color: teal),
        title: const Text('RASP workspace'),
        subtitle: const Text('Device context, encryption and PoC evidence'),
        onTap: () => setState(() => tab = 4),
      ),
    ]),
    heading('Recent activity', 'Your latest account movements'),
    ...historyTiles(3),
    TextButton(
      onPressed: busy ? null : () => run(refresh),
      child: const Text('Refresh account'),
    ),
  ];
  List<Widget> historyTiles(int limit) => transactions.isEmpty
      ? [
          panel([
            const Text('No transactions yet. Send your first test transfer.'),
          ]),
        ]
      : transactions
            .take(limit)
            .map(
              (t) => Card(
                child: ListTile(
                  leading: Icon(
                    t['amount'] < 0 ? Icons.north_east : Icons.south_west,
                    color: teal,
                  ),
                  title: Text(t['description']),
                  subtitle: Text(
                    DateTime.fromMillisecondsSinceEpoch(t['created'] * 1000)
                        .toLocal()
                        .toString()
                        .substring(0, 16),
                  ),
                  trailing: Text(
                    money(t['amount']),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            )
            .toList();
  List<Widget> activity() => [
    heading('Activity', 'Latest 100 movements · pull fresh records below'),
    button('Refresh activity', refresh, icon: Icons.refresh),
    const SizedBox(height: 12),
    ...historyTiles(100),
  ];
  List<Widget> transfer() => [
    heading('Move money', 'A real backend flow with fictional funds'),
    panel([
      DropdownButtonFormField<String>(
        initialValue: recipient,
        isExpanded: true,
        decoration: const InputDecoration(labelText: 'Recipient'),
        items: beneficiaries
            .map(
              (b) => DropdownMenuItem<String>(
                value: b['account'],
                child: Text('${b['name']} · ${b['account']}'),
              ),
            )
            .toList(),
        onChanged: transferId != null
            ? null
            : (v) => setState(() => recipient = v),
      ),
      const SizedBox(height: 14),
      field(
        amount,
        'Amount in rupiah',
        keyboard: const TextInputType.numberWithOptions(decimal: true),
      ),
      field(note, 'Payment note'),
      button('Create transfer', () async {
        if (recipient == null) {
          throw ApiException('Choose a recipient');
        }
        final input = amount.text.trim();
        if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(input)) {
          throw ApiException(
            'Enter a positive amount with at most two decimals',
          );
        }
        final parts = input.split('.');
        final value =
            int.parse(parts[0]) * 100 +
            (parts.length == 2 ? int.parse(parts[1].padRight(2, '0')) : 0);
        final result = await api.request('POST', '/transfers', {
          'recipient': recipient,
          'amount': value,
          'note': note.text,
        });
        setState(() {
          transferId = result['id'];
          pendingSummary = '${money(value)} to ${result['recipient']}';
          otp.clear();
          inbox = [];
        });
        toast('Transfer prepared. Open the lab OTP inbox.');
      }),
    ]),
    if (transferId != null)
      panel([
        Text(
          'Confirm $pendingSummary\nReference ${transferId!.substring(0, 8)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Text(
          'The OTP expires after five minutes. Five incorrect attempts lock it.',
        ),
        const SizedBox(height: 12),
        field(otp, 'Six-digit OTP', keyboard: TextInputType.number),
        button('Confirm payment', () async {
          final result = await api.request(
            'POST',
            '/transfers/$transferId/confirm',
            {'otp': otp.text.trim()},
          );
          if (result['status'] == 'completed') {
            setState(() {
              transferId = null;
              inbox = [];
              otp.clear();
            });
            await refresh();
            toast('Transfer complete');
          }
        }, icon: Icons.check),
        TextButton(
          onPressed: busy
              ? null
              : () => run(() async {
                  final result = await api.request('GET', '/lab/otp-inbox');
                  setState(() => inbox = result);
                }),
          child: const Text('Open lab OTP inbox'),
        ),
        ...inbox.map(
          (i) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: SelectableText('OTP ${i['otp']} · ${money(i['amount'])}'),
            subtitle: Text(
              'Transfer ${i['id'].toString().substring(0, 8)} — lab delivery only',
            ),
          ),
        ),
      ]),
  ];
  List<Widget> cards() => [
    heading('Your card', 'Virtual debit · demonstration only'),
    Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [teal, ink]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'velma / debit',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            '••••  ••••  ••••  4829',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
          const SizedBox(height: 24),
          Text(
            '${me!['name']}     12/29',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    ),
    const SizedBox(height: 16),
    panel([
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Freeze card'),
        subtitle: const Text(
          'Persists on the backend. Transfers remain available.',
        ),
        value: me!['frozen'] == 1,
        onChanged: busy
            ? null
            : (v) => run(() async {
                await api.request('POST', '/card', {'frozen': v});
                await refresh();
              }),
      ),
      const Text('This card has no usable PAN or CVV.'),
    ]),
  ];

  List<Widget> lab() => [
    heading('RASP workspace', 'Baseline app · SDK not yet integrated'),
    panel([
      const Text(
        'No threat detection or enforcement is claimed here. The controls below expose test surfaces and save operator observations.',
      ),
      const SizedBox(height: 12),
      Text('Session expires: ${api.expires?.toLocal()}'),
      Text('APK asset marker: $assetMarker'),
      Text(
        'Transport: ${api.baseUrl.startsWith('https:') ? 'TLS with certificate validation' : 'HTTP LAB — plaintext'}',
      ),
      const Text(
        'Build marker: ${String.fromEnvironment('BUILD_MARKER', defaultValue: 'baseline-v1')}',
      ),
    ]),
    panel([
      const Text(
        'Device context',
        style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 12),
      button('Refresh Android context', () async {
        final result = await platform.invokeMapMethod<String, dynamic>(
          'diagnostics',
        );
        setState(() => diagnostics = result ?? {});
      }, icon: Icons.phone_android),
      if (diagnostics.isNotEmpty)
        SelectableText(const JsonEncoder.withIndent('  ').convert(diagnostics)),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('OS secure-window control'),
        subtitle: const Text(
          'Off by default to test RASP screen protection independently.',
        ),
        value: secureWindow,
        onChanged: busy
            ? null
            : (v) => run(() async {
                await platform.invokeMethod('secureWindow', v);
                setState(() => secureWindow = v);
              }),
      ),
      button('Read location / mock flag', () async {
        final result = await platform.invokeMethod('location');
        setState(() => diagnostics['location'] = result);
      }, icon: Icons.location_on_outlined),
      const SizedBox(height: 10),
      const Text(
        'Location requests foreground permission. Developer Options may remain enabled; your SDK supplies mock-location policy.',
      ),
      OutlinedButton(
        onPressed: () => setState(() => taps++),
        child: Text('Auto-clicker target · $taps taps'),
      ),
      const Text(
        'Tap counter measures interaction only; it does not classify automation.',
      ),
    ]),
    panel([
      const Text(
        'Session encryption',
        style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 12),
      field(secret, 'Confidential test note'),
      button('Encrypt → server → decrypt', () async {
        final result = await api.encryptedEcho(secret.text);
        setState(
          () =>
              cryptoResult = const JsonEncoder.withIndent('  ').convert(result),
        );
      }, icon: Icons.lock_outline),
      const Text(
        'AES-256-GCM with fresh nonces and user-bound AAD. Login issues a new key per session. This is app encryption, not RASP encryption; use HTTPS to protect key delivery.',
      ),
      if (cryptoResult.isNotEmpty) SelectableText(cryptoResult),
    ]),
    panel([
      const Text(
        'Record PoC evidence',
        style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        initialValue: scenario,
        isExpanded: true,
        items: scenarios
            .map(
              (s) => DropdownMenuItem(
                value: s,
                child: Text(s, overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(),
        onChanged: (v) => setState(() => scenario = v!),
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        initialValue: outcome,
        items: [
          'baseline',
          'pass',
          'fail',
          'blocked',
          'not_supported',
          'observation',
        ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
        onChanged: (v) => setState(() => outcome = v!),
      ),
      const SizedBox(height: 12),
      field(
        evidence,
        'Expected / observed / SDK event / evidence reference',
        lines: 4,
      ),
      button('Save observation', () async {
        await api.request('POST', '/lab/events', {
          'scenario': scenario,
          'outcome': outcome,
          'details': evidence.text,
        });
        final result = await api.request('GET', '/lab/events');
        setState(() => events = result);
        toast('Observation saved');
      }, icon: Icons.save_outlined),
      TextButton(
        onPressed: busy
            ? null
            : () => run(() async {
                final result = await api.request('GET', '/lab/events');
                setState(() => events = result);
              }),
        child: const Text('Load saved observations'),
      ),
      TextButton(
        onPressed: events.isEmpty
            ? null
            : () async {
                await Clipboard.setData(
                  ClipboardData(
                    text: const JsonEncoder.withIndent('  ').convert(events),
                  ),
                );
                toast('Evidence JSON copied');
              },
        child: const Text('Copy loaded evidence JSON'),
      ),
      ...events
          .take(10)
          .map(
            (e) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('${e['scenario']} · ${e['outcome']}'),
              subtitle: Text(e['details']),
            ),
          ),
    ]),
  ];
}
