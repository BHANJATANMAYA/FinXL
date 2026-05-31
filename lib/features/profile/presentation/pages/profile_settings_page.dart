import 'package:finxl/core/navigation/app_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:finxl/core/common/load_status.dart';
import 'package:finxl/core/notifications/local_notification_service.dart';
import 'package:finxl/core/presentation/widgets/finxl_page_body.dart';
import 'package:finxl/core/theme/app_theme.dart';
import 'package:finxl/core/theme/theme_cubit.dart';
import 'package:finxl/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:finxl/features/sms_detection/presentation/bloc/sms_detection_bloc.dart';
import 'package:finxl/features/sms_detection/presentation/pages/sms_transaction_review_screen.dart';
import 'package:finxl/features/sync/presentation/bloc/sync_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  // State for toggles in preferences, notifications, and security sections
  bool _transactionAlerts = true;
  bool _budgetAlerts = true;
  bool _appLock = true;
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkNotificationPermission();
  }

  Future<void> _checkNotificationPermission() async {
    final status = await Permission.notification.status;
    if (mounted) {
      setState(() {
        _notificationsEnabled =
            status.isGranted || status.isProvisional || status.isLimited;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SmsDetectionBloc, SmsDetectionState>(
      listenWhen: (previous, current) =>
          (!previous.reviewPending && current.reviewPending) ||
          previous.errorMessage != current.errorMessage ||
          (!previous.savedTransaction && current.savedTransaction),
      listener: (context, state) {
        if (state.reviewPending) {
          SmsTransactionReviewScreen.showReviewSheet(context);
        } else if (state.errorMessage != null &&
            state.status == LoadStatus.failure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.surface,
        appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: Icon(Icons.arrow_back, color: AppTheme.onSurface),
          ),
          title: Text(
            'Profile',
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.w800,
              color: AppTheme.onSurface,
              fontSize: 18,
            ),
          ),
        ),
        body: FinxlPageBody(
          maxWidth: 480, // Target mobile dimension optimized context
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Header & Centered Avatar Section
                _buildProfileHeader(context),
                const SizedBox(height: 24),

                // 2. Quick Actions
                _buildSectionHeader('QUICK ACTIONS'),
                const SizedBox(height: 8),
                _buildQuickActionsCard(context),
                const SizedBox(height: 24),

                // 3. Preferences (UI only)
                _buildSectionHeader('PREFERENCES'),
                const SizedBox(height: 8),
                _buildPreferencesCard(),
                const SizedBox(height: 24),

                // 4. Notifications
                _buildSectionHeader('NOTIFICATIONS'),
                const SizedBox(height: 8),
                _buildNotificationsCard(),
                const SizedBox(height: 24),

                // 5. Finance Tools (2x2 Grid)
                _buildSectionHeader('FINANCE TOOLS'),
                const SizedBox(height: 8),
                _buildFinanceToolsGrid(context),
                const SizedBox(height: 24),

                // 6. Security
                _buildSectionHeader('SECURITY'),
                const SizedBox(height: 8),
                _buildSecurityCard(),
                const SizedBox(height: 24),

                // 7. About
                _buildSectionHeader('ABOUT'),
                const SizedBox(height: 8),
                _buildAboutCard(),
                const SizedBox(height: 32),

                // 8. Logout Button
                _buildLogoutButton(context),
                const SizedBox(height: 24),

                // 9. Footer
                Center(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'FINXL',
                            style: GoogleFonts.manrope(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.onSurface.withValues(alpha: 0.6),
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '© 2026 FinXL Financial Technologies',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.onSurfaceVariant.withValues(
                            alpha: 0.4,
                          ),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: GoogleFonts.manrope(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppTheme.onSurfaceVariant.withValues(alpha: 0.6),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // 1. Profile Header
  Widget _buildProfileHeader(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        String displayName = 'User';
        String email = '';
        String? avatarUrl;

        if (state is AuthAuthenticated) {
          final user = state.user;
          displayName =
              user.fullName ??
              (user.email != null && user.email!.isNotEmpty
                  ? user.email!.split('@').first
                  : 'User');
          email = user.email ?? '';
          avatarUrl = user.avatarUrl;
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

        return Column(
          children: [
            const SizedBox(height: 12),
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF0F9B8E), // Teal Ring Border
                        width: 3.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(56),
                        child: Container(
                          color: AppTheme.surfaceContainerLow,
                          child: avatarImage,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2ECC71), // Bright Active Green
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  displayName,
                  style: GoogleFonts.manrope(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.onSurface,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.verified, color: Color(0xFF2ECC71), size: 19),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              email,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }

  // 2. Quick Actions Row
  Widget _buildQuickActionsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildQuickActionCircle(
            context,
            icon: Icons.account_balance_wallet_outlined,
            label: 'Create\nBudget',
            onTap: () => context.push(AppRouter.addBudgetPath),
          ),
          _buildQuickActionCircle(
            context,
            icon: Icons.notifications_active_outlined,
            label: 'Add\nReminder',
            onTap: () => context.push(AppRouter.addBillPath),
          ),
          _buildQuickActionCircle(
            context,
            icon: Icons.bar_chart_outlined,
            label: 'Insights',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Insights are fully compiled and optimized.'),
                ),
              );
            },
          ),
          _buildQuickActionCircle(
            context,
            icon: Icons.track_changes_outlined,
            label: 'Set\nGoals',
            onTap: () => context.push(AppRouter.addGoalPath),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCircle(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLowest,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: const Color(0xFF0F9B8E), // Match Teal from avatar outline
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppTheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  // 3. Preferences Section (UI Only)
  Widget _buildPreferencesCard() {
    return _buildCardGroup([
      _buildRowTile(
        icon: Icons.account_balance_wallet_outlined,
        iconColor: AppTheme.onSurface,
        title: 'Currency',
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '₹ INR',
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2ECC71),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              color: AppTheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ],
        ),
        onTap: () {},
      ),
      _buildRowTile(
        icon: Icons.language,
        iconColor: AppTheme.onSurface,
        title: 'Language',
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'English',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              color: AppTheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ],
        ),
        onTap: () {},
      ),
      _buildRowTile(
        icon: Icons.dark_mode_outlined,
        iconColor: AppTheme.onSurface,
        title: 'Dark Mode',
        trailing: Switch.adaptive(
          value: context.watch<ThemeCubit>().state == ThemeMode.dark,
          activeColor: const Color(0xFF2ECC71),
          activeTrackColor: const Color(0xFF2ECC71).withValues(alpha: 0.3),
          onChanged: (val) {
            context.read<ThemeCubit>().toggleTheme(val);
          },
        ),
      ),
    ]);
  }

  // 4. Notifications Section
  Widget _buildNotificationsCard() {
    return _buildCardGroup([
      _buildRowTile(
        icon: Icons.notifications_none_outlined,
        iconColor: AppTheme.onSurface,
        title: 'Transaction Alerts',
        subtitle: 'Real-time spending updates',
        trailing: Switch.adaptive(
          value: _transactionAlerts,
          activeColor: const Color(0xFF2ECC71),
          activeTrackColor: const Color(0xFF2ECC71).withValues(alpha: 0.3),
          onChanged: (val) {
            setState(() {
              _transactionAlerts = val;
            });
          },
        ),
      ),
      _buildRowTile(
        icon: Icons.trending_up,
        iconColor: AppTheme.onSurface,
        title: 'Budget Alerts',
        subtitle: 'When you reach 80% limit',
        trailing: Switch.adaptive(
          value: _budgetAlerts,
          activeColor: const Color(0xFF2ECC71),
          activeTrackColor: const Color(0xFF2ECC71).withValues(alpha: 0.3),
          onChanged: (val) {
            setState(() {
              _budgetAlerts = val;
            });
          },
        ),
      ),
    ]);
  }

  // 5. Finance Tools (Vertical List)
  Widget _buildFinanceToolsGrid(BuildContext context) {
    return Column(
      children: [
        _buildFinanceToolCard(
          context,
          icon: Icons.picture_as_pdf_outlined,
          iconColor: Colors.deepPurple,
          title: 'Export Data',
          subtitle: 'Export transactions to CSV or PDF files',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Exporting financial logs as CSV/PDF...'),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildCloudSyncCard(),
        const SizedBox(height: 12),
        _buildSmartSmsCard(),
        const SizedBox(height: 12),
        _buildEnableNotificationsCard(),
      ],
    );
  }

  Widget _buildFinanceToolCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailingWidget,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailingWidget != null)
                  trailingWidget
                else
                  Icon(
                    Icons.chevron_right,
                    color: AppTheme.onSurfaceVariant.withValues(alpha: 0.4),
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Cloud Sync dynamic card
  Widget _buildCloudSyncCard() {
    return BlocBuilder<SyncBloc, SyncState>(
      builder: (context, state) {
        final isSyncing = state.status == SyncViewStatus.syncing;
        final statusText = switch (state.status) {
          SyncViewStatus.synced => 'ACTIVE',
          SyncViewStatus.syncing => 'SYNCING',
          SyncViewStatus.failed => 'OFFLINE',
          _ => 'ACTIVE',
        };

        return _buildFinanceToolCard(
          context,
          icon: Icons.cloud_done_outlined,
          iconColor: Colors.blue,
          title: 'Cloud Sync',
          subtitle: 'Backup database changes to the cloud',
          trailingWidget: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: state.status == SyncViewStatus.failed
                      ? AppTheme.tertiary
                      : const Color(0xFF2ECC71),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                statusText,
                style: GoogleFonts.manrope(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: state.status == SyncViewStatus.failed
                      ? AppTheme.tertiary
                      : const Color(0xFF2ECC71),
                ),
              ),
            ],
          ),
          onTap: isSyncing
              ? () {}
              : () {
                  context.read<SyncBloc>().syncNow();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Syncing changes to Cloud...'),
                    ),
                  );
                },
        );
      },
    );
  }

  // Smart SMS dynamic card
  Widget _buildSmartSmsCard() {
    return BlocBuilder<SmsDetectionBloc, SmsDetectionState>(
      builder: (context, state) {
        final active = state.userConsented && state.listening;
        return _buildFinanceToolCard(
          context,
          icon: Icons.sms_outlined,
          iconColor: Colors.orange,
          title: 'SMS Detect',
          subtitle: 'Auto-track transactions from finance SMS',
          trailingWidget: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: active ? const Color(0xFF2ECC71) : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                active ? 'ACTIVE' : 'DISABLED',
                style: GoogleFonts.manrope(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: active ? const Color(0xFF2ECC71) : Colors.grey,
                ),
              ),
            ],
          ),
          onTap: () async {
            if (active) {
              context.read<SmsDetectionBloc>().disable();
            } else {
              final accepted = await _showSmsConsentDialog(context);
              if (accepted == true && context.mounted) {
                context.read<SmsDetectionBloc>().enable();
              }
            }
          },
        );
      },
    );
  }

  // Notification Permissions Request Card
  Widget _buildEnableNotificationsCard() {
    return _buildFinanceToolCard(
      context,
      icon: Icons.notifications_none_outlined,
      iconColor: Colors.teal,
      title: 'Permissions',
      subtitle: 'Configure notification & alarm alerts',
      trailingWidget: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: _notificationsEnabled
                  ? const Color(0xFF2ECC71)
                  : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            _notificationsEnabled ? 'ACTIVE' : 'DISABLED',
            style: GoogleFonts.manrope(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: _notificationsEnabled
                  ? const Color(0xFF2ECC71)
                  : Colors.grey,
            ),
          ),
        ],
      ),
      onTap: () async {
        final status = await Permission.notification.status;
        if (status.isGranted || status.isProvisional || status.isLimited) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Notification permissions are already active.'),
              ),
            );
          }
        } else if (status.isPermanentlyDenied || status.isRestricted) {
          if (context.mounted) {
            _showNotificationPermissionDeniedDialog(context);
          }
        } else {
          final result = await Permission.notification.request();
          if (result.isGranted || result.isProvisional || result.isLimited) {
            await LocalNotificationService.instance.initialize();
            if (mounted) {
              setState(() {
                _notificationsEnabled = true;
              });
            }
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Notification permissions granted successfully.',
                  ),
                ),
              );
            }
          } else if (result.isPermanentlyDenied || result.isRestricted) {
            if (context.mounted) {
              _showNotificationPermissionDeniedDialog(context);
            }
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notification permissions denied.'),
                ),
              );
            }
          }
        }
      },
    );
  }

  void _showNotificationPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: AppTheme.surfaceContainerLowest,
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 28.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_off_outlined,
                    color: Colors.teal,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Enable Notifications',
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Notifications are currently disabled. Please enable them in your device settings to receive bill reminders and app alerts.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: AppTheme.onSurfaceVariant.withValues(
                                alpha: 0.2,
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.manrope(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: AppTheme.primaryGradient,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryContainer.withValues(
                                  alpha: 0.2,
                                ),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () async {
                                Navigator.of(dialogContext).pop();
                                await openAppSettings();
                              },
                              child: Center(
                                child: Text(
                                  'Settings',
                                  style: GoogleFonts.manrope(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 6. Security Section
  Widget _buildSecurityCard() {
    return _buildCardGroup([
      _buildRowTile(
        icon: Icons.face_unlock_outlined,
        iconColor: AppTheme.onSurface,
        title: 'App Lock (Face ID)',
        trailing: Switch.adaptive(
          value: _appLock,
          activeColor: const Color(0xFF2ECC71),
          activeTrackColor: const Color(0xFF2ECC71).withValues(alpha: 0.3),
          onChanged: (val) {
            setState(() {
              _appLock = val;
            });
          },
        ),
      ),
      _buildRowTile(
        icon: Icons.lock_outline,
        iconColor: AppTheme.onSurface,
        title: 'Change PIN',
        trailing: Icon(
          Icons.chevron_right,
          color: AppTheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
        onTap: () {},
      ),
    ]);
  }

  // 7. About Section
  Widget _buildAboutCard() {
    return _buildCardGroup([
      _buildRowTile(
        icon: Icons.help_outline,
        iconColor: AppTheme.onSurface,
        title: 'Help Center',
        trailing: Icon(
          Icons.open_in_new,
          size: 18,
          color: AppTheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
        onTap: () {},
      ),
      _buildRowTile(
        icon: Icons.shield_outlined,
        iconColor: AppTheme.onSurface,
        title: 'Privacy Policy',
        trailing: Icon(
          Icons.chevron_right,
          color: AppTheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
        onTap: () => context.push(AppRouter.privacyPolicyPath),
      ),
      _buildRowTile(
        icon: Icons.info_outline,
        iconColor: AppTheme.onSurface,
        title: 'App Version',
        trailing: Text(
          '2.4.0',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.onSurfaceVariant,
          ),
        ),
      ),
    ]);
  }

  // 8. Logout Button
  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.danger.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showLogoutDialog(context),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout_rounded, color: AppTheme.danger, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Logout',
                  style: GoogleFonts.manrope(
                    color: AppTheme.danger,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(children.length, (index) {
          if (index == children.length - 1) {
            return children[index];
          }
          return Column(
            children: [
              children[index],
              Divider(
                height: 1,
                thickness: 1,
                color: AppTheme.surfaceContainerLow,
                indent: 56,
                endIndent: 16,
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildRowTile({
    required IconData icon,
    Color? iconColor,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final effectiveIconColor = iconColor ?? AppTheme.onSurface;
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: effectiveIconColor, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.manrope(
          fontWeight: FontWeight.w800,
          fontSize: 14,
          color: AppTheme.onSurface,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppTheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            )
          : null,
      trailing: trailing,
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Log Out',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
        ),
        content: Text(
          'Are you sure you want to log out of FinXL?',
          style: GoogleFonts.inter(color: AppTheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: AppTheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Log Out',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      context.read<AuthCubit>().signOut();
    }
  }

  Future<bool?> _showSmsConsentDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Enable Smart SMS Detection?',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
        ),
        content: Text(
          'FinXL will listen only for new transactional financial SMS after permission is granted. OTP, promotional, and personal messages are ignored, and every detected transaction must be reviewed before it is saved.',
          style: GoogleFonts.inter(color: AppTheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}
