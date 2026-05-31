import 'dart:ui';
import 'dart:math' as math;
import 'package:finxl/core/common/widgets/entrance_fader.dart';
import 'package:finxl/core/common/widgets/floating_widget.dart';
import 'package:finxl/core/navigation/app_router.dart';
import 'package:finxl/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Stack(
        children: [
          // Background Decorative Elements
          Positioned(
            top: -100,
            right: -100,
            child: _buildBlurCircle(
                color: AppTheme.primaryContainer.withValues(alpha: 0.15)),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: _buildBlurCircle(
                color: AppTheme.secondary.withValues(alpha: 0.15)),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double screenWidth = MediaQuery.of(context).size.width;
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        child: Column(
                          children: [
                  // Top section (Branding)
                  EntranceFader(
                    delay: const Duration(milliseconds: 100),
                    child: Column(
                      children: [
                        Container(
                          height: 64,
                          width: 64,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.onSurface.withValues(alpha: 0.12),
                                blurRadius: 24,
                                spreadRadius: -2,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              'assets/logo/finxl_logo.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        RichText(
                          text: TextSpan(
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -1,
                                ),
                            children: [
                              TextSpan(text: 'Fin'),
                              TextSpan(
                                text: 'XL',
                                style: TextStyle(color: AppTheme.primary),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Track smarter. Spend wiser.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                color: AppTheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Middle Section: Visual Narrative
                  SizedBox(
                    height: 320,
                    width: double.infinity,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // Tilted background shadow block
                        EntranceFader(
                          delay: const Duration(milliseconds: 300),
                          offset: const Offset(0, 40),
                          child: Transform.rotate(
                            angle: -6 * math.pi / 180,
                            child: Container(
                              height: 190,
                              width: math.min(280, screenWidth - 48),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceContainerHigh
                                    .withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                          ),
                        ),
                        // Main Glass Card
                        EntranceFader(
                          delay: const Duration(milliseconds: 400),
                          offset: const Offset(0, 50),
                          child: FloatingWidget(
                            duration: const Duration(seconds: 4),
                            offsetY: 10,
                            child: Transform.rotate(
                              angle: 3 * math.pi / 180,
                              child: _buildGlassCard(context),
                            ),
                          ),
                        ),
                        // Floating Data Chips
                        Positioned(
                          right: -10,
                          top: 40,
                          child: EntranceFader(
                            delay: const Duration(milliseconds: 600),
                            offset: const Offset(20, 0),
                            child: FloatingWidget(
                              duration: const Duration(milliseconds: 3500),
                              offsetY: -8,
                              delay: const Duration(milliseconds: 500),
                              child: _buildDataChip(
                                  context: context,
                                  icon: Icons.trending_up_rounded,
                                  label: '+12.4%',
                                  colorContext: AppTheme.primaryContainer,
                                  iconColor: AppTheme.primary),
                            ),
                          ),
                        ),
                        Positioned(
                          left: -10,
                          bottom: 40,
                          child: EntranceFader(
                            delay: const Duration(milliseconds: 700),
                            offset: const Offset(-20, 0),
                            child: FloatingWidget(
                              duration: const Duration(milliseconds: 4200),
                              offsetY: 8,
                              delay: const Duration(milliseconds: 1000),
                              child: _buildDataChip(
                                  context: context,
                                  icon: Icons.auto_awesome_rounded,
                                  label: 'Insight Ready',
                                  colorContext: AppTheme.tertiary,
                                  iconColor: AppTheme.tertiary),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  EntranceFader(
                    delay: const Duration(milliseconds: 800),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 24),
                      child: Text(
                        'Experience a living financial ecosystem that adapts to your lifestyle and optimizes every dollar.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.onSurfaceVariant,
                              height: 1.6,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Bottom section (Actions)
                  EntranceFader(
                    delay: const Duration(milliseconds: 1000),
                    offset: const Offset(0, 30),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 64,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              gradient: AppTheme.primaryGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withValues(alpha: 0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(24),
                                onTap: () {
                                HapticFeedback.heavyImpact();
                                context.push(AppRouter.signUpPath);
                                },
                                child: Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Get Started',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.arrow_forward_rounded,
                                          color: Colors.white),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppTheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            GestureDetector(
                              onTap: () => context.push(AppRouter.signInPath),
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
                        const SizedBox(height: 32),
                        // Footer security note
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildSecurityItem(
                                context, Icons.verified_user_outlined, 'BANK-GRADE SECURITY'),
                            const SizedBox(width: 12),
                            Container(
                              height: 4,
                              width: 4,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.surfaceContainerHighest,
                              ),
                            ),
                            const SizedBox(width: 12),
                              _buildSecurityItem(
                                  context, Icons.lock_outline, 'END-TO-END ENCRYPTION'),
                            ],
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlurCircle({required Color color}) {
    return Container(
      width: 384,
      height: 384,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
        child: Container(color: Colors.transparent),
      ),
    );
  }

  Widget _buildDataChip({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color colorContext,
    required Color iconColor,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLow.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
                color: AppTheme.onSurfaceVariant.withValues(alpha: 0.12)),
            boxShadow: AppTheme.cardDecoration().boxShadow,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 24,
                width: 24,
                decoration: BoxDecoration(
                  color: colorContext.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 14, color: iconColor),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCard(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: math.min(320, MediaQuery.of(context).size.width - 48),
          height: 208,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLow.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: AppTheme.onSurfaceVariant.withValues(alpha: 0.2)),
            boxShadow: AppTheme.cardDecoration().boxShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GLOBAL BALANCE',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              letterSpacing: 1.2,
                              color: AppTheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$42,890.50',
                        style:
                            Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.onSurface,
                                ),
                      ),
                    ],
                  ),
                   Icon(Icons.contactless_outlined,
                      size: 32, color: AppTheme.secondary),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      _buildAvatarBubble(AppTheme.primaryContainer, 0),
                      _buildAvatarBubble(AppTheme.secondary, -12),
                      _buildAvatarBubble(AppTheme.tertiary, -24),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'PREMIUM MEMBER',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              letterSpacing: 2.0,
                              fontSize: 10,
                              color: AppTheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'VALID THRU 12/30',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarBubble(Color color, double paddingLeft) {
    return Transform.translate(
      offset: Offset(paddingLeft, 0),
      child: Container(
        height: 32,
        width: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
      ),
    );
  }

  Widget _buildSecurityItem(BuildContext context, IconData icon, String label) {
    return Opacity(
      opacity: 0.5,
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
