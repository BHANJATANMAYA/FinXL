import 'package:finxl/core/theme/app_theme.dart';
import 'package:finxl/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class FinxlTopBar extends StatelessWidget implements PreferredSizeWidget {
  const FinxlTopBar({
    this.onProfileTap,
    this.syncIndicator,
    super.key,
  });

  final VoidCallback? onProfileTap;
  final Widget? syncIndicator;

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
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      String? avatarUrl;
                      if (state is AuthAuthenticated) {
                        avatarUrl = state.user.avatarUrl;
                      }

                      Widget avatarImage;
                      if (avatarUrl != null && avatarUrl.isNotEmpty) {
                        avatarImage = Image.network(
                          avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Image.asset(
                            'assets/logo/profile_avatar.png',
                            fit: BoxFit.cover,
                          ),
                        );
                      } else {
                        avatarImage = Image.asset(
                          'assets/logo/profile_avatar.png',
                          fit: BoxFit.cover,
                        );
                      }

                      return Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.surfaceContainer,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: avatarImage,
                        ),
                      );
                    },
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
            ?syncIndicator,
          ],
        ),
      ),
    );
  }
}

class FinxlSyncIndicator extends StatelessWidget {
  const FinxlSyncIndicator({
    required this.icon,
    required this.color,
    required this.tooltip,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(17),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
        ),
      ),
    );
  }
}
