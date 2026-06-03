import 'package:finxl/core/navigation/app_router.dart';
import 'package:finxl/core/theme/app_theme.dart';
import 'package:finxl/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:finxl/features/auth/presentation/widgets/google_auth_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  int _passwordScore = 0;
  String _passwordStrengthText = 'Enter a password';
  Color _passwordStrengthColor = AppTheme.onSurfaceVariant;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_evaluatePassword);
  }

  void _evaluatePassword() {
    final pass = _passwordController.text;
    int score = 0;

    if (pass.length >= 6) {
      score++;
    }
    if (RegExp(r'[a-z]').hasMatch(pass) && RegExp(r'[A-Z]').hasMatch(pass)) {
      score++;
    }
    if (RegExp(r'[0-9]').hasMatch(pass)) {
      score++;
    }
    if (RegExp(r'[^a-zA-Z0-9]').hasMatch(pass)) {
      score++;
    }

    String text = 'Weak Password';
    Color color = Colors.red.shade400;

    if (score == 1) {
      text = 'Weak Password';
      color = Colors.red.shade400;
    } else if (score == 2) {
      text = 'Fair Password';
      color = Colors.orange.shade400;
    } else if (score == 3) {
      text = 'Good Password';
      color = Colors.blue.shade400;
    } else if (score == 4) {
      text = 'Strong Security Score';
      color = AppTheme.primary;
    }

    if (pass.isEmpty) {
      score = 0;
      text = 'Enter a password';
      color = AppTheme.onSurfaceVariant.withValues(alpha: 0.5);
    }

    setState(() {
      _passwordScore = score;
      _passwordStrengthText = text;
      _passwordStrengthColor = color;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().signUp(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _nameController.text.trim(),
    );
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
        body: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Minimal Back Navigation
                    IconButton(
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: AppTheme.onSurfaceVariant,
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(height: 32),

                    // Hero Title
                    Text(
                      'Create Account',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Join FinXL and start your financial evolution.',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Form Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration:
                          AppTheme.cardDecoration(
                            color: AppTheme.surfaceContainerLowest,
                          ).copyWith(
                            border: Border.all(
                              color: AppTheme.onSurfaceVariant.withValues(
                                alpha: 0.1,
                              ),
                            ),
                          ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Full Name Field
                          _buildLabel(context, 'FULL NAME'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              hintText: 'Enter your full name',
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Please enter your name'
                                : null,
                          ),
                          const SizedBox(height: 32),

                          // Email Field
                          _buildLabel(context, 'EMAIL'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              hintText: 'Enter your email',
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Please enter your email'
                                : null,
                          ),
                          const SizedBox(height: 32),

                          // Password Field
                          _buildLabel(context, 'PASSWORD'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: 'Create a password',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: AppTheme.onSurfaceVariant.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Please enter a password';
                              }
                              if (v.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              if (!RegExp(r'[a-z]').hasMatch(v) ||
                                  !RegExp(r'[A-Z]').hasMatch(v)) {
                                return 'Must have lowercase and uppercase letters';
                              }
                              if (!RegExp(r'[0-9]').hasMatch(v)) {
                                return 'Must contain a number';
                              }
                              if (!RegExp(r'[^a-zA-Z0-9]').hasMatch(v)) {
                                return 'Must contain a special symbol';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // Security Score Indicator
                          Row(
                            children: [
                              Expanded(
                                child: _buildPasswordStrengthBar(
                                  _passwordScore >= 1,
                                  _passwordStrengthColor,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: _buildPasswordStrengthBar(
                                  _passwordScore >= 2,
                                  _passwordStrengthColor,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: _buildPasswordStrengthBar(
                                  _passwordScore >= 3,
                                  _passwordStrengthColor,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: _buildPasswordStrengthBar(
                                  _passwordScore >= 4,
                                  _passwordStrengthColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _passwordStrengthText,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: _passwordStrengthColor,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  fontSize: 10,
                                ),
                          ),

                          const SizedBox(height: 32),

                          // Create Account Button
                          BlocBuilder<AuthCubit, AuthState>(
                            builder: (context, state) {
                              final isLoading = state is AuthLoading;
                              return SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: AppTheme.primaryGradient,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primary.withValues(
                                          alpha: 0.2,
                                        ),
                                        blurRadius: 16,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap: isLoading ? null : _signUp,
                                      child: Center(
                                        child: isLoading
                                            ? const SizedBox(
                                                height: 24,
                                                width: 24,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2.5,
                                                    ),
                                              )
                                            : Text(
                                                'Create Account',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 32),

                          // Divider
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: AppTheme.onSurfaceVariant.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  'OR CONTINUE WITH',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        letterSpacing: 2.0,
                                        color: AppTheme.onSurfaceVariant
                                            .withValues(alpha: 0.4),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: AppTheme.onSurfaceVariant.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // Social Login
                          BlocSelector<AuthCubit, AuthState, bool>(
                            selector: (state) => state is AuthLoading,
                            builder: (context, isLoading) {
                              return GoogleAuthButton(
                                isLoading: isLoading,
                                onPressed: () => context
                                    .read<AuthCubit>()
                                    .signInWithGoogle(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Footer Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppTheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        GestureDetector(
                          onTap: () {
                            context.push(AppRouter.signInPath);
                          },
                          child: Text(
                            'Login',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 48),

                    // Policy Context
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text.rich(
                        TextSpan(
                          text: 'By creating an account, you agree to our ',
                          children: [
                            TextSpan(
                              text: 'Terms of Service',
                              style: TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                                decorationColor: AppTheme.primary,
                              ),
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                                decorationColor: AppTheme.primary,
                              ),
                            ),
                            const TextSpan(
                              text:
                                  '. Your data is encrypted with bank-grade security protocols.',
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          height: 1.6,
                          color: AppTheme.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Security Badges
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
    ),
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        letterSpacing: 1.5,
        fontWeight: FontWeight.bold,
        color: AppTheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildPasswordStrengthBar(bool isFilled, Color fillAccent) {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: isFilled ? fillAccent : AppTheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
