import 'package:finxl/core/presentation/widgets/section_card.dart';
import 'package:finxl/core/theme/app_theme.dart';
import 'package:finxl/features/bills/domain/entities/bills_overview.dart';
import 'package:finxl/features/bills/presentation/cubit/bills_cubit.dart';
import 'package:finxl/features/sync/presentation/bloc/sync_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class AddBillPage extends StatefulWidget {
  const AddBillPage({super.key});

  @override
  State<AddBillPage> createState() => _AddBillPageState();
}

class _AddBillPageState extends State<AddBillPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _customRecurrenceController = TextEditingController();

  String _selectedRecurrence = 'Monthly';
  final List<String> _recurrenceOptions = const [
    'Weekly',
    'Monthly',
    'Yearly',
    'Custom',
  ];

  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  BillCategory _category = BillCategory.bill;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _customRecurrenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close),
        ),
        title: Text(
          'New Reminder',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
        ),
      ),
      body: BlocListener<BillsCubit, BillsState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage,
        listener: (context, state) {
          final error = state.errorMessage;
          if (error != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(error)));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                SectionCard(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _titleController,
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? 'Required'
                            : null,
                        decoration: const InputDecoration(labelText: 'Title'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? 'Required'
                            : null,
                        decoration: const InputDecoration(labelText: 'Amount'),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<BillCategory>(
                        initialValue: _category,
                        borderRadius: BorderRadius.circular(24),
                        decoration: const InputDecoration(
                          labelText: 'Reminder type',
                        ),
                        items: BillCategory.values
                            .map(
                              (item) => DropdownMenuItem(
                                value: item,
                                child: Text(_label(item)),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (value) {
                          if (value != null) setState(() => _category = value);
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedRecurrence,
                        borderRadius: BorderRadius.circular(24),
                        decoration: const InputDecoration(
                          labelText: 'Recurrence',
                        ),
                        items: _recurrenceOptions
                            .map(
                              (item) => DropdownMenuItem(
                                value: item,
                                child: Text(item),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedRecurrence = value);
                          }
                        },
                      ),
                      if (_selectedRecurrence == 'Custom') ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _customRecurrenceController,
                          decoration: const InputDecoration(
                            labelText: 'Custom Recurrence',
                            hintText: 'e.g. Every 2 weeks',
                          ),
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                      ],
                      const SizedBox(height: 20),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Due date'),
                        subtitle: Text(
                          '${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
                        ),
                        trailing: const Icon(Icons.calendar_today_outlined),
                        onTap: _pickDate,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                BlocBuilder<BillsCubit, BillsState>(
                  builder: (context, state) {
                    return FilledButton(
                      onPressed: state.isSaving ? null : _submit,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        backgroundColor: AppTheme.primary,
                      ),
                      child: state.isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save Reminder'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _label(BillCategory category) {
    return switch (category) {
      BillCategory.subscription => 'Subscription',
      BillCategory.bill => 'Bill',
      BillCategory.emi => 'EMI',
    };
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      initialDate: _dueDate,
    );
    if (selected != null) setState(() => _dueDate = selected);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter a valid amount.')));
      return;
    }

    final recurrenceValue = _selectedRecurrence == 'Custom'
        ? _customRecurrenceController.text.trim()
        : _selectedRecurrence;

    final success = await context.read<BillsCubit>().createBill(
      title: _titleController.text.trim(),
      amount: amount,
      dueDate: _dueDate,
      category: _category,
      recurrence: recurrenceValue.isEmpty ? 'Monthly' : recurrenceValue,
    );
    if (success && mounted) {
      context.read<SyncBloc>().syncInBackground();
      context.pop();
    }
  }
}
