import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onScanTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onScanTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double outerPadding = screenWidth < 360 ? 12.0 : 16.0;
    final double innerSpacing = screenWidth < 360 ? 8.0 : 12.0;
    final double scanButtonSize = screenWidth < 360 ? 60.0 : 68.0;
    final double scanIconSize = screenWidth < 360 ? 24.0 : 28.0;

    final items = [
      const _NavBarItemData(
        index: 0,
        icon: LucideIcons.home,
        label: 'Home',
      ),
      const _NavBarItemData(
        index: 1,
        icon: LucideIcons.users,
        label: 'Contacts',
      ),
      const _NavBarItemData(
        index: 3,
        icon: LucideIcons.barChart2,
        label: 'Statistics',
      ),
      const _NavBarItemData(
        index: 4,
        icon: LucideIcons.creditCard,
        label: 'My Card',
      ),
    ];

    return Padding(
      padding: EdgeInsets.only(
        left: outerPadding,
        right: outerPadding,
        bottom: 16 + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Navigation Bar Pill
          Expanded(
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 30,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: items.map((item) {
                  final isActive = currentIndex == item.index;
                  return _NavBarTab(
                    icon: item.icon,
                    label: item.label,
                    isActive: isActive,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onTabSelected(item.index);
                    },
                  );
                }).toList(),
              ),
            ),
          ),
          SizedBox(width: innerSpacing),
          // Scan Floating Action Button
          _ScanButton(
            onTap: onScanTap,
            buttonSize: scanButtonSize,
            iconSize: scanIconSize,
          ),
        ],
      ),
    );
  }
}

class _NavBarItemData {
  final int index;
  final IconData icon;
  final String label;

  const _NavBarItemData({
    required this.index,
    required this.icon,
    required this.label,
  });
}

class _NavBarTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarTab({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double iconSize = screenWidth < 360 ? 20.0 : 22.0;
    final double fontSize = screenWidth < 360 ? 11.0 : 12.0;
    final double activePadding = screenWidth < 360 ? 10.0 : 12.0;
    final double inactivePadding = screenWidth < 360 ? 6.0 : 8.0;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? activePadding : inactivePadding,
          vertical: 10.0,
        ),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFF2F2F2) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: isActive ? const Color(0xFF000000) : const Color(0xFFA0A0A0),
            ),
            ClipRect(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                child: SizedBox(
                  width: isActive ? null : 0.0,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOutCubic,
                    opacity: isActive ? 1.0 : 0.0,
                    child: AnimatedSlide(
                      offset: isActive ? Offset.zero : const Offset(-0.3, 0.0),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOutCubic,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 6.0),
                        child: Text(
                          label,
                          style: TextStyle(
                            color: const Color(0xFF000000),
                            fontSize: fontSize,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.clip,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanButton extends StatefulWidget {
  final VoidCallback onTap;
  final double buttonSize;
  final double iconSize;

  const _ScanButton({
    required this.onTap,
    required this.buttonSize,
    required this.iconSize,
  });

  @override
  State<_ScanButton> createState() => _ScanButtonState();
}

class _ScanButtonState extends State<_ScanButton> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    HapticFeedback.lightImpact();
    setState(() {
      _scale = 0.95;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _scale = 1.0;
    });
    widget.onTap();
  }

  void _onTapCancel() {
    setState(() {
      _scale = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutBack,
        child: Container(
          width: widget.buttonSize,
          height: widget.buttonSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF000000),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.20),
                blurRadius: 25,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              LucideIcons.scanLine,
              color: const Color(0xFFFFFFFF),
              size: widget.iconSize,
            ),
          ),
        ),
      ),
    );
  }
}
