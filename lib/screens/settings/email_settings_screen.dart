import 'package:flutter/material.dart';

import '../../services/smtp_settings.dart';
import '../../theme/app_colors.dart';
import '../../widgets/case_background.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/glass_card.dart';

class EmailSettingsScreen extends StatefulWidget {
  const EmailSettingsScreen({super.key});

  @override
  State<EmailSettingsScreen> createState() => _EmailSettingsScreenState();
}

class _EmailSettingsScreenState extends State<EmailSettingsScreen> {
  final _host = TextEditingController();
  final _port = TextEditingController();
  final _user = TextEditingController();
  final _pass = TextEditingController();
  final _from = TextEditingController();
  bool _enabled = false;
  bool _ssl = true;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await SmtpSettingsStore.load();
    if (!mounted) return;
    setState(() {
      _enabled = s.enabled;
      _host.text = s.host;
      _port.text = s.port.toString();
      _user.text = s.username;
      _pass.text = s.password;
      _from.text = s.fromName;
      _ssl = s.useSsl;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _host.dispose();
    _port.dispose();
    _user.dispose();
    _pass.dispose();
    _from.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CaseBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Email reminders')),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Student email notices',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'When SMTP is enabled, verified student emails receive a '
                          'reminder 1 day before the return date. Librarian '
                          'device notifications work even without SMTP.',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.labelMuted,
                                  ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Enable SMTP email',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                            Switch(
                              value: _enabled,
                              onChanged: (v) => setState(() => _enabled = v),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _host,
                          decoration: const InputDecoration(
                            labelText: 'SMTP host',
                            hintText: 'smtp.gmail.com',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _port,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Port',
                            hintText: '465',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Use SSL',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            Switch(
                              value: _ssl,
                              onChanged: (v) => setState(() => _ssl = v),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _user,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'SMTP username / from email',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _pass,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'SMTP password / app password',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _from,
                          decoration: const InputDecoration(
                            labelText: 'From display name',
                          ),
                        ),
                        const SizedBox(height: 20),
                        GlassButton(
                          label: _saving ? 'Saving…' : 'Save email settings',
                          icon: Icons.save_rounded,
                          onPressed: _saving ? null : _save,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final port = int.tryParse(_port.text.trim()) ?? 465;
    await SmtpSettingsStore.save(
      SmtpSettings(
        enabled: _enabled,
        host: _host.text,
        port: port,
        username: _user.text,
        password: _pass.text,
        fromName: _from.text,
        useSsl: _ssl,
      ),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Email settings saved')),
    );
  }
}
