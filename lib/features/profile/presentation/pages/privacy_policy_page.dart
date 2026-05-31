import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:finxl/core/theme/app_theme.dart';
import 'package:finxl/core/presentation/widgets/finxl_page_body.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.onSurface,
          ),
        ),
      ),
      body: FinxlPageBody(
        maxWidth: 560,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Text(
            _privacyText,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.6,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  static const String _privacyText = '''
FinXL respects your privacy and is committed to protecting your personal data. This Privacy Policy explains how we collect, use, store, and disclose information when you use the FinXL application.

**1. Information We Collect**
- Email address and profile information you provide during sign‑in.
- Transaction data you manually add or auto‑detected via SMS (with your consent).
- Usage analytics to improve the app experience.

**2. How We Use Your Data**
- To display personalized financial insights.
- To synchronize data across devices via cloud backup.
- To send you important notifications (you can control these in Settings).

**3. Data Storage & Security**
- All data is stored locally on your device and optionally encrypted in cloud backups.
- We use industry‑standard encryption for data in transit and at rest.

**4. Sharing & Third‑Party Services**
- We do not sell your personal data.
- Selected third‑party services (e.g., Supabase, Google Sign‑In) may process data strictly for authentication and storage, governed by their own privacy policies.

**5. Your Rights**
- You may delete your account and all associated data from the Settings > Preferences section.
- You can revoke notification permissions at any time from the device settings.

**6. Changes to this Policy**
We may update this policy. Any changes will be posted within the app and will take effect immediately.

If you have any questions about this policy, please contact us at support@finxl.com.
''';
}
