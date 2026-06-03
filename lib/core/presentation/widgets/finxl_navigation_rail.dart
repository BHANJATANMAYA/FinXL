import 'dart:ui';
import 'package:finxl/core/navigation/app_tab.dart';
import 'package:finxl/core/navigation/app_router.dart';
import 'package:finxl/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class FinxlNavigationRail extends StatelessWidget {
  const FinxlNavigationRail({
    required this.currentTab,
    required this.onTabSelected,
    super.key,
  });

  final AppTab currentTab;
  final ValueChanged<AppTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          right: BorderSide(
            color: AppTheme.onSurfaceVariant.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
      ),
      child: Stack(
        children: [
          // Glassmorphic background
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  color: AppTheme.surfaceContainerLowest.withValues(alpha: 0.88),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Logo branding
                Center(
                  child: Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.onSurface.withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/logo/finxl_logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Navigation items
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: AppTab.values.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final tab = AppTab.values[index];
                      final isActive = tab == currentTab;
                      return _RailItem(
                        tab: tab,
                        isActive: isActive,
                        onTap: () => onTabSelected(tab),
                      );
                    },
                  ),
                ),
                // Add button at the bottom of the rail
                Center(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => context.push(AppRouter.addTransactionPath),
                        customBorder: const CircleBorder(),
                        child: const Icon(
                          Icons.add,
                          size: 28,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
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
      AppTab.dashboard => Icons.dashboard_outlined,
      AppTab.analytics => Icons.insights_outlined,
      AppTab.goals => Icons.track_changes_outlined,
      AppTab.budget => Icons.account_balance_wallet_outlined,
      AppTab.bills => Icons.event_repeat_outlined,
    };

    final activeIcon = switch (tab) {
      AppTab.dashboard => Icons.dashboard,
      AppTab.analytics => Icons.insights,
      AppTab.goals => Icons.track_changes,
      AppTab.budget => Icons.account_balance_wallet,
      AppTab.bills => Icons.event_repeat,
    };

    final label = switch (tab) {
      AppTab.dashboard => 'Home',
      AppTab.analytics => 'Insights',
      AppTab.goals => 'Goals',
      AppTab.budget => 'Budget',
      AppTab.bills => 'Bills',
    };

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: isActive
                      ? AppTheme.primary.withValues(alpha: 0.12)
                      : Colors.transparent,
                ),
                child: Icon(
                  isActive ? activeIcon : icon,
                  size: 24,
                  color: isActive
                      ? AppTheme.primary
                      : AppTheme.onSurfaceVariant.withValues(alpha: 0.72),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
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
