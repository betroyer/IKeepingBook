import 'package:shared_preferences/shared_preferences.dart';

class SmtpSettings {
  const SmtpSettings({
    required this.enabled,
    required this.host,
    required this.port,
    required this.username,
    required this.password,
    required this.fromName,
    required this.useSsl,
  });

  final bool enabled;
  final String host;
  final int port;
  final String username;
  final String password;
  final String fromName;
  final bool useSsl;

  bool get isGmail {
    final u = username.trim().toLowerCase();
    return u.endsWith('@gmail.com') || u.endsWith('@googlemail.com');
  }

  bool get isConfigured =>
      enabled &&
      isGmail &&
      password.isNotEmpty &&
      host.trim().isNotEmpty;

  static const empty = SmtpSettings(
    enabled: false,
    host: 'smtp.gmail.com',
    port: 465,
    username: '',
    password: '',
    fromName: 'I-Keeping Books Library',
    useSsl: true,
  );
}

class SmtpSettingsStore {
  SmtpSettingsStore._();

  static const _enabled = 'smtp_enabled';
  static const _host = 'smtp_host';
  static const _port = 'smtp_port';
  static const _user = 'smtp_user';
  static const _pass = 'smtp_pass';
  static const _from = 'smtp_from';
  static const _ssl = 'smtp_ssl';

  static Future<SmtpSettings> load() async {
    final p = await SharedPreferences.getInstance();
    return SmtpSettings(
      enabled: p.getBool(_enabled) ?? false,
      host: p.getString(_host) ?? SmtpSettings.empty.host,
      port: p.getInt(_port) ?? SmtpSettings.empty.port,
      username: p.getString(_user) ?? '',
      password: p.getString(_pass) ?? '',
      fromName: p.getString(_from) ?? SmtpSettings.empty.fromName,
      useSsl: p.getBool(_ssl) ?? true,
    );
  }

  static Future<void> save(SmtpSettings s) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_enabled, s.enabled);
    await p.setString(_host, 'smtp.gmail.com');
    await p.setInt(_port, 465);
    await p.setString(_user, s.username.trim());
    await p.setString(_pass, s.password);
    await p.setString(_from, s.fromName.trim());
    await p.setBool(_ssl, true);
  }
}
