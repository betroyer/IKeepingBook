import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/book_provider.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/case_background.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/glass_card.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _quantity = TextEditingController(text: '1');
  String? _category;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _quantity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CaseBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Add book')),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: GlassCard(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Book name',
                        hintText: 'Enter the title',
                      ),
                      validator: Validators.bookName,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _quantity,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        hintText: 'Copies on hand',
                      ),
                      validator: Validators.quantity,
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      // ignore: deprecated_member_use
                      value: _category,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                      ),
                      items: AppConstants.categories
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(c),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _category = v),
                      validator: Validators.category,
                    ),
                    const SizedBox(height: 24),
                    GlassButton(
                      label: _saving ? 'Saving…' : 'Add book',
                      icon: Icons.add_rounded,
                      onPressed: _saving ? null : _save,
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final ok = await context.read<BookProvider>().addBook(
          name: _name.text,
          quantity: int.parse(_quantity.text.trim()),
          category: _category!,
        );
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Book added successfully' : 'Could not add the book',
        ),
      ),
    );
    if (ok) Navigator.of(context).pop();
  }
}
