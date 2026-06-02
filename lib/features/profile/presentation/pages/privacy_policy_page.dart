import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:finxl/core/theme/app_theme.dart';
import 'package:finxl/core/presentation/widgets/finxl_page_body.dart';
import 'package:finxl/core/presentation/widgets/section_card.dart';
import 'package:finxl/core/common/widgets/entrance_fader.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.onSurface,
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Decorative Blurs
          Positioned(
            top: -80,
            right: -80,
            child: _buildBlurCircle(
              color: AppTheme.primaryContainer.withValues(alpha: 0.12),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: _buildBlurCircle(
              color: AppTheme.secondary.withValues(alpha: 0.12),
            ),
          ),

          SafeArea(
            child: FinxlPageBody(
              maxWidth: 600,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Intro Card
                    EntranceFader(
                      delay: const Duration(milliseconds: 50),
                      child: _buildHeaderCard(context),
                    ),
                    const SizedBox(height: 20),

                    // Section 1: Info Collect
                    EntranceFader(
                      delay: const Duration(milliseconds: 150),
                      child: _buildSectionCard(
                        title: '1. Information We Collect',
                        icon: Icons.info_outline_rounded,
                        points: [
                          'Email address and secure profile information provided during sign-in.',
                          'Transaction data you manually input or auto-detected via SMS (with your explicit consent).',
                          'Anonymous usage patterns and performance logs to help us improve the app.',
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Section 2: How We Use Data
                    EntranceFader(
                      delay: const Duration(milliseconds: 250),
                      child: _buildSectionCard(
                        title: '2. How We Use Your Data',
                        icon: Icons.insights_rounded,
                        points: [
                          'To calculate and display personalized budget metrics and financial trends.',
                          'To synchronize your local database securely across your signed-in devices via cloud backup.',
                          'To send you budget alerts and reminders (which can be customized in Settings).',
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Section 3: Storage & Security
                    EntranceFader(
                      delay: const Duration(milliseconds: 350),
                      child: _buildSectionCard(
                        title: '3. Data Storage & Security',
                        icon: Icons.verified_user_outlined,
                        points: [
                          'All sensitive database files are stored locally on your device in SQL databases.',
                          'Cloud backup data is encrypted in transit and at rest using industry-standard protocols.',
                          'Authentication uses industry-grade OAuth authentication methods.',
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Section 4: Sharing & Third-Party
                    EntranceFader(
                      delay: const Duration(milliseconds: 450),
                      child: _buildSectionCard(
                        title: '4. Third-Party Services',
                        icon: Icons.cloud_done_outlined,
                        points: [
                          'FinXL does not sell, lease, or distribute your personal financial data to anyone.',
                          'Authentication and secure cloud storage are managed by Supabase, governed by their standard security policies.',
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Section 5: Your Rights
                    EntranceFader(
                      delay: const Duration(milliseconds: 550),
                      child: _buildSectionCard(
                        title: '5. Your Control & Rights',
                        icon: Icons.settings_accessibility_rounded,
                        points: [
                          'You can wipe your database and permanently delete your account directly from the Profile Settings.',
                          'You can toggle off SMS detection and notifications permissions at any time.',
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Section 6: Policy Changes
                    EntranceFader(
                      delay: const Duration(milliseconds: 650),
                      child: _buildSectionCard(
                        title: '6. Policy Changes',
                        icon: Icons.update_rounded,
                        points: [
                          'We may update this policy periodically to reflect security and feature enhancements.',
                          'For any privacy concerns or support inquiries, contact us at support@finxl.com.',
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Consent Button
                    EntranceFader(
                      delay: const Duration(milliseconds: 750),
                      child: FilledButton(
                        onPressed: () => context.pop(),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                          backgroundColor: AppTheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          'I Understand',
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlurCircle({required Color color}) {
    return Container(
      width: 320,
      height: 320,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
        child: Container(color: Colors.transparent),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return SectionCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.privacy_tip_outlined,
              color: AppTheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'We value your privacy',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'FinXL respects your privacy and is committed to protecting your personal financial information. Read below to understand how we store and handle your data.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<String> points,
  }) {
    return SectionCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppTheme.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...points.map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      point,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppTheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
