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
  final _user = TextEditingController();
  final _pass = TextEditingController();
  final _from = TextEditingController();
  bool _enabled = false;
  bool _loading = true;
  bool _saving = false;
  String? _error;

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
      _user.text = s.username;
      _pass.text = s.password;
      _from.text = s.fromName;
      _loading = false;
    });
  }

  @override
  void dispose() {
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
                          'Library Gmail account',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Use a real Gmail account for the library. Students '
                          'receive a borrow receipt when a loan is saved, and a '
                          'return reminder 1 day before the due date.\n\n'
                          'Create a Google App Password (Google Account → '
                          'Security → 2-Step Verification → App passwords) and '
                          'paste it below — not your normal Gmail password.',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.labelMuted,
                                    height: 1.45,
                                  ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Send student emails',
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
                        const SizedBox(height: 12),
                        TextField(
                          controller: _user,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          decoration: const InputDecoration(
                            labelText: 'Library Gmail',
                            hintText: 'yourlibrary@gmail.com',
                            prefixIcon: Icon(Icons.mail_outline_rounded),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _pass,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Gmail App Password',
                            hintText: '16-character app password',
                            prefixIcon: Icon(Icons.lock_outline_rounded),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _from,
                          decoration: const InputDecoration(
                            labelText: 'From display name',
                            hintText: 'I-Keeping Books Library',
                          ),
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _error!,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.signalRed),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          'SMTP: smtp.gmail.com · port 465 · SSL',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.labelMuted,
                                  ),
                        ),
                        const SizedBox(height: 20),
                        GlassButton(
                          label: _saving ? 'Saving…' : 'Save Gmail settings',
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
    final user = _user.text.trim().toLowerCase();
    if (_enabled) {
      if (!(user.endsWith('@gmail.com') || user.endsWith('@googlemail.com'))) {
        setState(() => _error = 'Enter a valid Gmail address (@gmail.com).');
        return;
      }
      if (_pass.text.trim().isEmpty) {
        setState(() => _error = 'Enter the Gmail App Password.');
        return;
      }
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    await SmtpSettingsStore.save(
      SmtpSettings(
        enabled: _enabled,
        host: 'smtp.gmail.com',
        port: 465,
        username: user,
        password: _pass.text.trim(),
        fromName: _from.text.trim().isEmpty
            ? SmtpSettings.empty.fromName
            : _from.text.trim(),
        useSsl: true,
      ),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Library Gmail settings saved')),
    );
  }
}
