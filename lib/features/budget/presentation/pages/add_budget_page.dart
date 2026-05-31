import 'package:finxl/core/presentation/widgets/section_card.dart';
import 'package:finxl/core/theme/app_theme.dart';
import 'package:finxl/core/utils/finance_lookups.dart';
import 'package:finxl/features/budget/domain/entities/budget_overview.dart';
import 'package:finxl/features/budget/presentation/cubit/budget_cubit.dart';
import 'package:finxl/features/sync/presentation/bloc/sync_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class AddBudgetPage extends StatefulWidget {
  const AddBudgetPage({super.key, this.budgetToEdit});

  final BudgetCategory? budgetToEdit;

  @override
  State<AddBudgetPage> createState() => _AddBudgetPageState();
}

class _AddBudgetPageState extends State<AddBudgetPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _limitController;
  late String _category;

  bool get _isEdit => widget.budgetToEdit != null;

  @override
  void initState() {
    super.initState();
    _limitController = TextEditingController(
      text: _isEdit ? widget.budgetToEdit!.limit.toStringAsFixed(0) : '',
    );
    _category = _isEdit
        ? widget.budgetToEdit!.title
        : FinanceLookups.transactionCategories.first.label;
  }

  @override
  void dispose() {
    _limitController.dispose();
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
          _isEdit ? 'Edit Budget' : 'Create Budget',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
        ),
      ),
      body: BlocListener<BudgetCubit, BudgetState>(
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
            child: Column(
              children: [
                SectionCard(
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: _category,
                        borderRadius: BorderRadius.circular(24),
                        decoration: const InputDecoration(
                          labelText: 'Category',
                        ),
                        items: FinanceLookups.transactionCategories
                            .map(
                              (item) => DropdownMenuItem(
                                value: item.label,
                                child: Text(item.label),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _category = value);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _limitController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? 'Required'
                            : null,
                        decoration: const InputDecoration(
                          labelText: 'Monthly limit',
                          hintText: 'Enter monthly budget limit',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                BlocBuilder<BudgetCubit, BudgetState>(
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
                          : Text(_isEdit ? 'Update Budget' : 'Save Budget'),
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

  // Future<void> _submit() async {
  //   if (!_formKey.currentState!.validate()) return;

  //   final limit = double.tryParse(_limitController.text.trim());
  //   if (limit == null || limit <= 0) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Enter a valid budget limit.')),
  //     );
  //     return;
  //   }

  //   final success = _isEdit
  //       ? await context.read<BudgetCubit>().updateBudget(
  //           id: widget.budgetToEdit!.id!,
  //           categoryName: _category,
  //           limitAmount: limit,
  //         )
  //       : await context.read<BudgetCubit>().createBudget(
  //           categoryName: _category,
  //           limitAmount: limit,
  //         );

  //   if (success && mounted) context.pop();
  // }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final limit = double.tryParse(_limitController.text.trim());
    if (limit == null || limit <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid budget limit.')),
      );
      return;
    }

    final cubit = context.read<BudgetCubit>();

    bool success = false;

    if (_isEdit) {
      final id = widget.budgetToEdit?.id;
      if (id == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invalid budget data.')));
        return;
      }

      success = await cubit.updateBudget(
        id: id,
        categoryName: _category,
        limitAmount: limit,
      );
    } else {
      success = await cubit.createBudget(
        categoryName: _category,
        limitAmount: limit,
      );
    }

    if (!mounted) return;

    if (success) {
      context.read<SyncBloc>().syncInBackground();
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save budget. Try again.')),
      );
    }
  }
}
