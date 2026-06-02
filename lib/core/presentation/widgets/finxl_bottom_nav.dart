import 'dart:ui';

import 'package:finxl/core/navigation/app_tab.dart';
import 'package:finxl/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BottomNavPath {
  static Path getClipPath(Size size, double domeCenter) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    
    // Dome geometry
    const domeStartOffset = 48.0;
    const topY = 24.0; // The flat bar starts at Y = 24
    
    // Start at top-left corner (no rounding to prevent corner breaks at edges)
    path.moveTo(0, topY);
    
    // Left flat top line
    path.lineTo(domeCenter - domeStartOffset, topY);
    
    // Left cubic curve to peak of the dome
    path.cubicTo(
      domeCenter - 32, topY,
      domeCenter - 28, 0,
      domeCenter, 0,
    );
    
    // Right cubic curve from peak of the dome
    path.cubicTo(
      domeCenter + 28, 0,
      domeCenter + 32, topY,
      domeCenter + domeStartOffset, topY,
    );
    
    // Right flat top line to the top-right corner
    path.lineTo(w, topY);
    
    // Bottom right corner
    path.lineTo(w, h);
    
    // Bottom left corner
    path.lineTo(0, h);
    
    path.close();
    
    return path;
  }
}

class BottomNavClipper extends CustomClipper<Path> {
  BottomNavClipper({required this.domeCenter});
  final double domeCenter;

  @override
  Path getClip(Size size) => BottomNavPath.getClipPath(size, domeCenter);

  @override
  bool shouldReclip(covariant BottomNavClipper oldClipper) =>
      oldClipper.domeCenter != domeCenter;
}

class BottomNavShadowPainter extends CustomPainter {
  BottomNavShadowPainter({required this.shadowColor, required this.domeCenter});
  final Color shadowColor;
  final double domeCenter;

  @override
  void paint(Canvas canvas, Size size) {
    final path = BottomNavPath.getClipPath(size, domeCenter);
    final shadowPaint = Paint()
      ..color = shadowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      
    // Draw shifted shadow for depth
    canvas.drawPath(path.shift(const Offset(0, -2)), shadowPaint);
  }

  @override
  bool shouldRepaint(covariant BottomNavShadowPainter oldDelegate) =>
      oldDelegate.domeCenter != domeCenter;
}

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
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    final double barHeight = 60.0 + bottomPadding;
    final double totalHeight = barHeight + 24; // Bar height + dome space (24px)
    final double screenWidth = MediaQuery.of(context).size.width;
    
    // Find the target active index
    final double targetIndex = AppTab.values.indexOf(currentTab).toDouble();
    
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: targetIndex, end: targetIndex),
      duration: const Duration(milliseconds: 350),
      curve: Curves.fastOutSlowIn,
      builder: (context, animValue, child) {
        // Compute the animated dome center position
        final double domeCenter = screenWidth * (2 * animValue + 1) / 10;
        
        return Container(
          height: totalHeight,
          color: Colors.transparent,
          child: Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              // 1. Soft Shadow behind the clipped bar
              CustomPaint(
                size: Size(screenWidth, totalHeight),
                painter: BottomNavShadowPainter(
                  shadowColor: Colors.black.withValues(alpha: 0.08),
                  domeCenter: domeCenter,
                ),
              ),
              // 2. Glassmorphic Clipped Background
              ClipPath(
                clipper: BottomNavClipper(domeCenter: domeCenter),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    height: totalHeight,
                    color: AppTheme.surfaceContainerLowest.withValues(alpha: 0.88),
                  ),
                ),
              ),
              // 3. Row of Nav Items
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: barHeight,
                child: Padding(
                  padding: EdgeInsets.only(bottom: bottomPadding),
                  child: Row(
                    children: AppTab.values.asMap().entries.map((entry) {
                      final index = entry.key;
                      final tab = entry.value;
                      
                      // Compute distance to target animated index to fade out underlying icon
                      final double distance = (index - animValue).abs();
                      final double iconOpacity = distance.clamp(0.0, 1.0);
                      
                      return Expanded(
                        child: _NavItem(
                          tab: tab,
                          isActive: tab == currentTab,
                          opacity: iconOpacity,
                          onTap: () => onTabSelected(tab),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              // 4. Elevated Center Buttons (sink down / rise up vertically at their fixed horizontal position)
              ...List.generate(AppTab.values.length, (index) {
                final tab = AppTab.values[index];
                final isActive = tab == currentTab;
                final double tabCenter = screenWidth * (2 * index + 1) / 10;
                
                return Positioned(
                  left: tabCenter - 25, // Width of button is 50, radius is 25
                  top: 2, // Centered inside the dome
                  child: IgnorePointer(
                    ignoring: !isActive,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 250),
                      opacity: isActive ? 1.0 : 0.0,
                      child: AnimatedSlide(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutBack, // Playful bounce when rising up
                        offset: isActive ? Offset.zero : const Offset(0, 1.2),
                        child: _CenterNavItem(
                          tab: tab,
                          onTap: () => onTabSelected(tab),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.isActive,
    required this.opacity,
    required this.onTap,
  });

  final AppTab tab;
  final bool isActive;
  final double opacity;
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top active indicator line
            SizedBox(
              height: 3,
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isActive ? 22 : 0,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              ),
            ),
            const Spacer(),
            // Opacity transition hides the icon as the floating dome slides over it
            Opacity(
              opacity: opacity,
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

class _CenterNavItem extends StatelessWidget {
  const _CenterNavItem({
    required this.tab,
    required this.onTap,
  });

  final AppTab tab;
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
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
        child: Icon(
          icon,
          size: 26,
          color: Colors.white,
        ),
      ),
    );
  }
}
