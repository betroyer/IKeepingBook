import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/book.dart';
import '../../models/borrow_record.dart';
import '../../providers/book_provider.dart';
import '../../providers/borrow_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/case_background.dart';
import '../../widgets/custom_search_bar.dart';
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
  final _bookSearch = TextEditingController();
  final _dateFormat = DateFormat.yMMMd();

  final Set<int> _selectedBookIds = {};
  String _bookQuery = '';
  String? _booksError;
  StudentLevel _level = StudentLevel.college;
  String? _program;
  String? _yearLevel;
  DateTime _borrowedAt = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  bool _saving = false;

  @override
  void dispose() {
    _fullName.dispose();
    _studentId.dispose();
    _email.dispose();
    _programOther.dispose();
    _bookSearch.dispose();
    super.dispose();
  }

  List<String> get _programOptions => _level == StudentLevel.college
      ? AppConstants.collegeCourses
      : AppConstants.highSchoolStrands;

  List<String> get _yearOptions => _level == StudentLevel.college
      ? AppConstants.collegeYears
      : AppConstants.highSchoolYears;

  List<Book> _availableBooks(List<Book> all) {
    return all.where((b) => b.quantity > 0 && b.id != null).toList()
      ..sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
  }

  List<Book> _filteredBooks(List<Book> available) {
    final q = _bookQuery.trim().toLowerCase();
    if (q.isEmpty) return available;
    return available
        .where((b) => b.name.toLowerCase().contains(q))
        .toList();
  }

  List<Book> _selectedBooks(List<Book> available) {
    return available.where((b) => _selectedBookIds.contains(b.id)).toList();
  }

  void _toggleBook(Book book) {
    final id = book.id;
    if (id == null) return;
    setState(() {
      if (_selectedBookIds.contains(id)) {
        _selectedBookIds.remove(id);
      } else {
        _selectedBookIds.add(id);
      }
      if (_selectedBookIds.isNotEmpty) {
        _booksError = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final available = _availableBooks(context.watch<BookProvider>().books);
    final filtered = _filteredBooks(available);
    final selected = _selectedBooks(available);
    final theme = Theme.of(context);

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
                      style: theme.textTheme.titleMedium?.copyWith(
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
                      decoration: const InputDecoration(
                        labelText: 'Student email',
                        hintText: 'student@gmail.com',
                        prefixIcon: Icon(Icons.mail_outline_rounded),
                      ),
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'The library Gmail account (More → Email reminders) will '
                      'send a borrow receipt now and a return reminder 1 day '
                      'before the due date.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.labelMuted,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'School level',
                      style: theme.textTheme.labelLarge?.copyWith(
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
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: _level.programFieldLabel,
                      ),
                      items: _programOptions
                          .map(
                            (p) => DropdownMenuItem(
                              value: p,
                              child: Text(p, overflow: TextOverflow.ellipsis),
                            ),
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
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: _level.yearFieldLabel,
                      ),
                      items: _yearOptions
                          .map(
                            (y) => DropdownMenuItem(
                              value: y,
                              child: Text(y, overflow: TextOverflow.ellipsis),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _yearLevel = v),
                      validator: (v) =>
                          Validators.requiredField(v, _level.yearFieldLabel),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Books borrowed',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selected.isEmpty
                          ? 'Select every title this student is taking.'
                          : '${selected.length} book'
                              '${selected.length == 1 ? '' : 's'} selected',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.labelMuted,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (available.isEmpty)
                      Text(
                        'No copies available. Add stock before lending.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.signalAmber,
                        ),
                      )
                    else ...[
                      CustomSearchBar(
                        controller: _bookSearch,
                        hint: 'Search in-stock books',
                        onChanged: (q) => setState(() => _bookQuery = q),
                      ),
                      const SizedBox(height: 10),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: (_booksError != null
                                    ? AppColors.signalRed
                                    : AppColors.metalEdge)
                                .withValues(alpha: 0.55),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Material(
                            color: Colors.transparent,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 260),
                              child: filtered.isEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Text(
                                        'No in-stock books match “$_bookQuery”.',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: AppColors.labelMuted,
                                        ),
                                      ),
                                    )
                                  : ListView.separated(
                                      shrinkWrap: true,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      itemCount: filtered.length,
                                      separatorBuilder: (_, _) => Divider(
                                        height: 1,
                                        color: AppColors.metalEdge
                                            .withValues(alpha: 0.35),
                                      ),
                                      itemBuilder: (context, index) {
                                        final book = filtered[index];
                                        final selectedBook =
                                            _selectedBookIds.contains(book.id);
                                        return CheckboxListTile(
                                          value: selectedBook,
                                          onChanged: (_) => _toggleBook(book),
                                          controlAffinity:
                                              ListTileControlAffinity.leading,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                          title: Text(
                                            book.name,
                                            style: theme.textTheme.bodyLarge
                                                ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          subtitle: Text(
                                            '${book.quantity} available · ${book.category}',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color: AppColors.labelMuted,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ),
                        ),
                      ),
                      if (_booksError != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _booksError!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.signalRed,
                          ),
                        ),
                      ],
                      if (selected.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: selected
                              .map(
                                (b) => InputChip(
                                  label: Text(b.name),
                                  onDeleted: () => _toggleBook(b),
                                  deleteIconColor: AppColors.labelMuted,
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
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
                      label: _saving
                          ? 'Saving…'
                          : selected.isEmpty
                              ? 'Save borrow record'
                              : 'Save ${selected.length} book'
                                  '${selected.length == 1 ? '' : 's'}',
                      icon: Icons.check_rounded,
                      onPressed:
                          _saving || available.isEmpty ? null : () => _save(available),
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

  Future<void> _save(List<Book> available) async {
    final formOk = _formKey.currentState!.validate();
    final selected = _selectedBooks(available);
    if (selected.isEmpty) {
      setState(() => _booksError = 'Select at least one book');
    }
    if (!formOk || selected.isEmpty) return;
    if (_program == null || _yearLevel == null) return;

    final programValue =
        _program == 'Other' ? _programOther.text.trim() : _program!;

    setState(() => _saving = true);
    final provider = context.read<BorrowProvider>();
    final ok = await provider.createLoans(
      books: selected,
      studentFullName: _fullName.text,
      studentId: _studentId.text,
      studentEmail: _email.text,
      studentLevel: _level,
      program: programValue,
      yearLevel: _yearLevel!,
      borrowedAt: _borrowedAt,
      dueDate: _dueDate,
    );
    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      final mailNote = provider.error;
      final count = selected.length;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            mailNote != null && mailNote.startsWith('Borrow saved')
                ? mailNote
                : count == 1
                    ? 'Borrow saved. A receipt was emailed to the student '
                        '(if library Gmail is configured).'
                    : '$count books borrowed. A receipt was emailed to the '
                        'student (if library Gmail is configured).',
          ),
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.error ?? 'Could not save borrow record',
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
