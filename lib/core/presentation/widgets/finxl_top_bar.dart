import 'package:finxl/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FinxlTopBar extends StatelessWidget implements PreferredSizeWidget {
  const FinxlTopBar({this.onProfileTap, this.onNotificationTap, super.key});

  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;

  @override
  Size get preferredSize => const Size.fromHeight(84);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surface.withValues(alpha: 0.96),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: onProfileTap,
              borderRadius: BorderRadius.circular(999),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.surfaceContainer,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'FinXL',
                    style: GoogleFonts.manrope(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                      color: AppTheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onNotificationTap,
              icon: const Icon(
                Icons.notifications_outlined,
                // Icons.menu_rounded,
                color: AppTheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
