import 'dart:ui';

import 'package:finxl/core/navigation/app_tab.dart';
import 'package:finxl/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FinxlBottomNav extends StatelessWidget {
  const FinxlBottomNav({
    required this.currentTab,
    required this.onTabSelected,
    super.key,
  });

  final AppTab currentTab;
  final ValueChanged<AppTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: AppTheme.surfaceContainerLowest.withValues(alpha: 0.84),
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 28),
          child: Row(
            children: AppTab.values
                .map(
                  (tab) => Expanded(
                    child: _NavItem(
                      tab: tab,
                      isActive: tab == currentTab,
                      onTap: () => onTabSelected(tab),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.isActive,
    required this.onTap,
  });

  final AppTab tab;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = switch (tab) {
      AppTab.dashboard => Icons.dashboard,
      AppTab.analytics => Icons.insights,
      AppTab.goals => Icons.track_changes,
      AppTab.budget => Icons.account_balance_wallet,
      AppTab.bills => Icons.event_repeat,
    };

    final label = switch (tab) {
      AppTab.dashboard => 'HOME',
      AppTab.analytics => 'INSIGHTS',
      AppTab.goals => 'GOALS',
      AppTab.budget => 'BUDGET',
      AppTab.bills => 'BILLS',
    };

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isActive
                    ? AppTheme.primaryContainer.withValues(alpha: 0.14)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                size: 24,
                color: isActive
                    ? AppTheme.primary
                    : AppTheme.onSurfaceVariant.withValues(alpha: 0.72),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                letterSpacing: 0.9,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive
                    ? AppTheme.primary
                    : AppTheme.onSurfaceVariant.withValues(alpha: 0.72),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
