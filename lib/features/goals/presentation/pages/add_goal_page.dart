import 'package:finxl/core/presentation/widgets/section_card.dart';
import 'package:finxl/core/theme/app_theme.dart';
import 'package:finxl/features/goals/domain/entities/goals_overview.dart';
import 'package:finxl/features/goals/presentation/cubit/goals_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class AddGoalPage extends StatefulWidget {
  const AddGoalPage({super.key, this.goalToEdit});

  final SavingsGoal? goalToEdit;

  @override
  State<AddGoalPage> createState() => _AddGoalPageState();
}

class _AddGoalPageState extends State<AddGoalPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _targetController;
  late final TextEditingController _savedController;
  late DateTime _deadline;

  bool get _isEdit => widget.goalToEdit != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: _isEdit ? widget.goalToEdit!.title : '',
    );
    _targetController = TextEditingController(
      text: _isEdit ? widget.goalToEdit!.targetAmount.toStringAsFixed(0) : '',
    );
    _savedController = TextEditingController(
      text: _isEdit ? widget.goalToEdit!.savedAmount.toStringAsFixed(0) : '0',
    );
    _deadline = _isEdit
        ? widget.goalToEdit!.deadline
        : DateTime.now().add(const Duration(days: 90));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    _savedController.dispose();
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
          _isEdit ? 'Edit Goal' : 'Create Goal',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
        ),
      ),
      body: BlocListener<GoalsCubit, GoalsState>(
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
                      _field(
                        controller: _titleController,
                        label: 'Goal title',
                        hint: 'Emergency Fund',
                      ),
                      const SizedBox(height: 16),
                      _field(
                        controller: _targetController,
                        label: 'Target amount',
                        hint: '50000',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _field(
                        controller: _savedController,
                        label: 'Already saved',
                        hint: '0',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Deadline'),
                        subtitle: Text(
                          '${_deadline.day}/${_deadline.month}/${_deadline.year}',
                        ),
                        trailing: const Icon(Icons.calendar_today_outlined),
                        onTap: _pickDate,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                BlocBuilder<GoalsCubit, GoalsState>(
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
                          : Text(_isEdit ? 'Update Goal' : 'Save Goal'),
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

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (value) =>
          (value == null || value.trim().isEmpty) ? 'Required' : null,
      decoration: InputDecoration(labelText: label, hintText: hint),
    );
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      initialDate: _deadline,
    );
    if (selected != null) {
      setState(() => _deadline = selected);
    }
  }

  // Future<void> _submit() async {
  //   if (!_formKey.currentState!.validate()) return;

  //   final target = double.tryParse(_targetController.text.trim());
  //   final saved = double.tryParse(_savedController.text.trim()) ?? 0;
  //   if (target == null || target <= 0) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Enter a valid target amount.')),
  //     );
  //     return;
  //   }

  //   final success = _isEdit
  //       ? await context.read<GoalsCubit>().updateGoal(
  //           id: widget.goalToEdit!.id!,
  //           title: _titleController.text.trim(),
  //           targetAmount: target,
  //           savedAmount: saved,
  //           deadline: _deadline,
  //         )
  //       : await context.read<GoalsCubit>().createGoal(
  //           title: _titleController.text.trim(),
  //           targetAmount: target,
  //           savedAmount: saved,
  //           deadline: _deadline,
  //         );

  //   if (success && mounted) context.pop();
  // }
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final target = double.tryParse(_targetController.text.trim());
    final saved = double.tryParse(_savedController.text.trim()) ?? 0;

    if (target == null || target <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid target amount.')),
      );
      return;
    }
    final goalsCubit = context.read<GoalsCubit>();

    final success = _isEdit
        ? await goalsCubit.updateGoal(
            id: widget.goalToEdit!.id!,
            title: _titleController.text.trim(),
            targetAmount: target,
            savedAmount: saved,
            deadline: _deadline,
          )
        : await goalsCubit.createGoal(
            title: _titleController.text.trim(),
            targetAmount: target,
            savedAmount: saved,
            deadline: _deadline,
          );

    // ✅ Check mounted AFTER async
    if (!mounted) return;

    if (success) context.pop();
  }
}
