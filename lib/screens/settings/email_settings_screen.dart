import 'package:flutter/material.dart';

import '../../services/email_service.dart';
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
  bool _testing = false;
  bool _obscure = true;
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
                          'Enter the library Gmail here on this device. '
                          'Passwords are stored only on this phone — never in '
                          'the app source code or GitHub.\n\n'
                          '1. Open Google Account → Security\n'
                          '2. Turn on 2-Step Verification\n'
                          '3. Create an App password (Mail)\n'
                          '4. Paste the 16-character App Password below '
                          '(not your normal Gmail password)',
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
                          obscureText: _obscure,
                          decoration: InputDecoration(
                            labelText: 'Gmail App Password',
                            hintText: '16-character app password',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              tooltip: _obscure ? 'Show' : 'Hide',
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
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
                        const SizedBox(height: 10),
                        GlassButton(
                          label: _testing ? 'Sending test…' : 'Send test email',
                          icon: Icons.send_outlined,
                          filled: false,
                          onPressed: _testing || _saving ? null : _sendTest,
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
      const SnackBar(content: Text('Library Gmail settings saved on this device')),
    );
  }

  Future<void> _sendTest() async {
    await _save();
    if (!mounted) return;
    if (_error != null) return;
    if (!_enabled) {
      setState(() => _error = 'Turn on “Send student emails” first.');
      return;
    }

    setState(() {
      _testing = true;
      _error = null;
    });
    try {
      final to = _user.text.trim();
      await EmailService.instance.sendTestEmail(toEmail: to);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Test email sent to $to — check inbox/spam.')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }
}
