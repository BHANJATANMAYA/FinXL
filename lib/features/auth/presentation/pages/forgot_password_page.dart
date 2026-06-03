import 'dart:ui';
import 'package:finxl/core/navigation/app_router.dart';
import 'package:finxl/core/theme/app_theme.dart';
import 'package:finxl/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<AuthCubit>().resetPassword(_emailController.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Reset link sent! Check your inbox.'),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.surface,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: AppTheme.primary),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Back',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: AppTheme.onSurfaceVariant),
          ),
          titleSpacing: 0,
        ),
        body: Stack(
          children: [
            // Background blobs
            Positioned(
              top: -100,
              right: -100,
              child: _buildBlurCircle(
                color: AppTheme.primaryContainer.withValues(alpha: 0.10),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -100,
              child: _buildBlurCircle(
                color: AppTheme.secondary.withValues(alpha: 0.10),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 32,
                      ),
                      child: Column(
                    children: [
                      // Icon
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: AppTheme.cardDecoration(
                          color: AppTheme.surfaceContainerLowest,
                        ),
                        child: Icon(
                          Icons.lock_reset_rounded,
                          size: 48,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Forgot Password?',
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Don't worry, it happens. Enter your email or phone number and we'll send you a link to reset your password.",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.onSurfaceVariant,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Main Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: AppTheme.cardDecoration(
                          color: AppTheme.surfaceContainerLowest,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'EMAIL',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      letterSpacing: 1.5,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.onSurfaceVariant,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  hintText: 'Enter your email',
                                  prefixIcon: Icon(
                                    Icons.alternate_email_rounded,
                                    color: AppTheme.onSurfaceVariant,
                                  ),
                                ),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'Please enter your email'
                                    : null,
                              ),
                              const SizedBox(height: 32),

                              // Send Button
                              BlocBuilder<AuthCubit, AuthState>(
                                builder: (context, state) {
                                  final isLoading = state is AuthLoading;
                                  return SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(32),
                                        gradient: AppTheme.primaryGradient,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.primaryContainer
                                                .withValues(alpha: 0.2),
                                            blurRadius: 16,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(
                                            32,
                                          ),
                                          onTap: isLoading ? null : _sendReset,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              if (isLoading)
                                                const SizedBox(
                                                  height: 24,
                                                  width: 24,
                                                  child:
                                                      CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 2.5,
                                                      ),
                                                )
                                              else ...[
                                                Text(
                                                  'Send Reset Link',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium
                                                      ?.copyWith(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),
                                                const SizedBox(width: 8),
                                                const Icon(
                                                  Icons.arrow_forward_rounded,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 32),
                              Divider(
                                color: AppTheme.surfaceContainerHighest,
                              ),
                              const SizedBox(height: 32),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Remembered your password? ',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppTheme.onSurfaceVariant,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                  GestureDetector(
                                    onTap: () =>
                                        context.go(AppRouter.signInPath),
                                    child: Text(
                                      'Sign in',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: AppTheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Footer
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.verified_user_rounded,
                              size: 13,
                              color: AppTheme.onSurfaceVariant.withValues(alpha: 0.5),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'BANK-GRADE SECURITY',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppTheme.onSurfaceVariant.withValues(alpha: 0.5),
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w700,
                                fontSize: 9,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Container(
                                width: 3,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: AppTheme.onSurfaceVariant.withValues(alpha: 0.3),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.lock_rounded,
                              size: 13,
                              color: AppTheme.onSurfaceVariant.withValues(alpha: 0.5),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'END-TO-END ENCRYPTION',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppTheme.onSurfaceVariant.withValues(alpha: 0.5),
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w700,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlurCircle({required Color color}) {
    return Container(
      width: 384,
      height: 384,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
        child: Container(color: Colors.transparent),
      ),
    );
  }
}
