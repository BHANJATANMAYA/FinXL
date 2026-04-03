import 'package:finxl/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class GoogleAuthButton extends StatelessWidget {
  const GoogleAuthButton({
    required this.onPressed,
    required this.isLoading,
    this.label = 'Continue with Google',
    super.key,
  });

  final VoidCallback? onPressed;
  final bool isLoading;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppTheme.surfaceContainerLowest,
          side: BorderSide(
            color: AppTheme.onSurfaceVariant.withValues(alpha: 0.2),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading) ...[
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
            ] else ...[
              Image.asset(
                'assets/logo/icons/google.png',
                width: 24,
                height: 24,
                errorBuilder: (_, _, _) =>
                    const Icon(Icons.g_mobiledata, size: 32),
              ),
              const SizedBox(width: 12),
            ],
            Text(
              isLoading ? 'Connecting to Google...' : label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
