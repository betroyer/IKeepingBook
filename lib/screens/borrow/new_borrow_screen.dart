import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/book.dart';
import '../../models/borrow_record.dart';
import '../../providers/book_provider.dart';
import '../../providers/borrow_provider.dart';
import '../../services/email_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/case_background.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/glass_card.dart';

class NewBorrowScreen extends StatefulWidget {
  const NewBorrowScreen({super.key});

  @override
  State<NewBorrowScreen> createState() => _NewBorrowScreenState();
}

class _NewBorrowScreenState extends State<NewBorrowScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _studentId = TextEditingController();
  final _email = TextEditingController();
  final _programOther = TextEditingController();
  final _dateFormat = DateFormat.yMMMd();

  Book? _book;
  StudentLevel _level = StudentLevel.college;
  String? _program;
  String? _yearLevel;
  DateTime _borrowedAt = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  bool _saving = false;
  bool _emailVerified = false;
  String? _pendingCode;
  bool _sendingCode = false;

  @override
  void dispose() {
    _fullName.dispose();
    _studentId.dispose();
    _email.dispose();
    _programOther.dispose();
    super.dispose();
  }

  List<String> get _programOptions => _level == StudentLevel.college
      ? AppConstants.collegeCourses
      : AppConstants.highSchoolStrands;

  List<String> get _yearOptions => _level == StudentLevel.college
      ? AppConstants.collegeYears
      : AppConstants.highSchoolYears;

  @override
  Widget build(BuildContext context) {
    final books = context
        .watch<BookProvider>()
        .books
        .where((b) => b.quantity > 0)
        .toList();

    return CaseBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('New borrow')),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: GlassCard(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Student information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _fullName,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Full name',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                      validator: Validators.displayName,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _studentId,
                      decoration: const InputDecoration(
                        labelText: 'Student ID',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      validator: Validators.studentId,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (_) {
                        if (_emailVerified || _pendingCode != null) {
                          setState(() {
                            _emailVerified = false;
                            _pendingCode = null;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Student email',
                        prefixIcon: const Icon(Icons.mail_outline_rounded),
                        suffixIcon: _emailVerified
                            ? const Icon(
                                Icons.verified_rounded,
                                color: AppColors.signalGreen,
                              )
                            : null,
                      ),
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _emailVerified
                          ? 'Email verified — student can receive due reminders.'
                          : 'Verify email to enable 1-day-before return reminders.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _emailVerified
                                ? AppColors.signalGreen
                                : AppColors.labelMuted,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _sendingCode || _emailVerified
                                ? null
                                : _startVerification,
                            icon: _sendingCode
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.mark_email_read_outlined),
                            label: Text(
                              _emailVerified ? 'Verified' : 'Verify email',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'School level',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<StudentLevel>(
                      segments: const [
                        ButtonSegment(
                          value: StudentLevel.college,
                          label: Text('College'),
                        ),
                        ButtonSegment(
                          value: StudentLevel.highSchool,
                          label: Text('High school'),
                        ),
                      ],
                      selected: {_level},
                      onSelectionChanged: (s) {
                        setState(() {
                          _level = s.first;
                          _program = null;
                          _yearLevel = null;
                          _programOther.clear();
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      // ignore: deprecated_member_use
                      value: _programOptions.contains(_program) ? _program : null,
                      decoration: InputDecoration(
                        labelText: _level.programFieldLabel,
                      ),
                      items: _programOptions
                          .map(
                            (p) => DropdownMenuItem(value: p, child: Text(p)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _program = v),
                      validator: (v) =>
                          Validators.requiredField(v, _level.programFieldLabel),
                    ),
                    if (_program == 'Other') ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _programOther,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText:
                              'Specify ${_level.programFieldLabel.toLowerCase()}',
                        ),
                        validator: (v) => Validators.requiredField(
                          v,
                          _level.programFieldLabel,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      // ignore: deprecated_member_use
                      value:
                          _yearOptions.contains(_yearLevel) ? _yearLevel : null,
                      decoration: InputDecoration(
                        labelText: _level.yearFieldLabel,
                      ),
                      items: _yearOptions
                          .map(
                            (y) => DropdownMenuItem(value: y, child: Text(y)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _yearLevel = v),
                      validator: (v) =>
                          Validators.requiredField(v, _level.yearFieldLabel),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Book & dates',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<Book>(
                      // ignore: deprecated_member_use
                      value: books.contains(_book) ? _book : null,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Book to borrow',
                      ),
                      items: books
                          .map(
                            (b) => DropdownMenuItem(
                              value: b,
                              child: Text(
                                '${b.name} (${b.quantity} available)',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _book = v),
                      validator: (v) => v == null ? 'Select a book' : null,
                    ),
                    if (books.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'No copies available. Add stock before lending.',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.signalAmber,
                                  ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    _DateField(
                      label: 'Date borrowed',
                      value: _dateFormat.format(_borrowedAt),
                      onTap: () => _pickBorrowed(),
                    ),
                    const SizedBox(height: 12),
                    _DateField(
                      label: 'Date to return',
                      value: _dateFormat.format(_dueDate),
                      onTap: () => _pickDue(),
                    ),
                    const SizedBox(height: 24),
                    GlassButton(
                      label: _saving ? 'Saving…' : 'Save borrow record',
                      icon: Icons.check_rounded,
                      onPressed: _saving || books.isEmpty ? null : _save,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _startVerification() async {
    final emailError = Validators.email(_email.text);
    final nameError = Validators.displayName(_fullName.text);
    if (emailError != null || nameError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(emailError ?? nameError!)),
      );
      return;
    }

    setState(() => _sendingCode = true);
    final code = EmailService.instance.generateVerificationCode();
    var emailed = false;
    String? sendError;
    try {
      await EmailService.instance.sendVerificationCode(
        toEmail: _email.text,
        studentName: _fullName.text.trim(),
        code: code,
      );
      emailed = true;
    } catch (e) {
      sendError = e.toString().replaceFirst('Exception: ', '');
    }
    if (!mounted) return;
    setState(() {
      _sendingCode = false;
      _pendingCode = code;
    });

    final entered = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Verify student email'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                emailed
                    ? 'A verification code was emailed to ${_email.text.trim()}.'
                    : 'Could not email the code'
                        '${sendError != null ? ': $sendError' : '.'}\n\n'
                        'On-device code for the student/librarian to confirm:\n$code',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'Enter 6-digit code',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    if (entered != null && entered == _pendingCode) {
      setState(() => _emailVerified = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student email verified')),
      );
    } else if (entered != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect verification code')),
      );
    }
  }

  Future<void> _pickBorrowed() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _borrowedAt,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _borrowedAt = picked;
        if (_dueDate.isBefore(_borrowedAt)) {
          _dueDate = _borrowedAt.add(const Duration(days: 7));
        }
      });
    }
  }

  Future<void> _pickDue() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate.isBefore(_borrowedAt) ? _borrowedAt : _dueDate,
      firstDate: _borrowedAt,
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_book == null || _program == null || _yearLevel == null) return;

    final programValue =
        _program == 'Other' ? _programOther.text.trim() : _program!;

    setState(() => _saving = true);
    final ok = await context.read<BorrowProvider>().createLoan(
          book: _book!,
          studentFullName: _fullName.text,
          studentId: _studentId.text,
          studentEmail: _email.text,
          emailVerified: _emailVerified,
          studentLevel: _level,
          program: programValue,
          yearLevel: _yearLevel!,
          borrowedAt: _borrowedAt,
          dueDate: _dueDate,
        );
    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _emailVerified
                ? 'Borrow saved. Email reminders enabled for this student.'
                : 'Borrow saved. Email not verified — librarian alerts only.',
          ),
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<BorrowProvider>().error ??
                'Could not save borrow record',
          ),
        ),
      );
    }
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today_outlined),
        ),
        child: Text(value),
      ),
    );
  }
}
