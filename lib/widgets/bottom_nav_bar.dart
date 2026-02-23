import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    this.activeIndex = 0,
    this.onTap,
  });

  final int activeIndex;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    const itemWidth = 92.4;
    const indicatorWidth = 44.0;

    return Container(
      height: 82,
      decoration: const BoxDecoration(
        color: Color(0xFF0A1730),
        border: Border(top: BorderSide(color: Color(0xFF1D2C44))),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalNavWidth = itemWidth * 4;
          final leftInset = (constraints.maxWidth - totalNavWidth) / 2;
          final indicatorLeft =
              leftInset + (itemWidth * activeIndex) + (itemWidth - indicatorWidth) / 2;

          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                left: indicatorLeft,
                top: 0,
                child: Container(
                  width: indicatorWidth,
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4BA2FF),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: itemWidth,
                    child: _NavItem(
                      icon: Icons.home_outlined,
                      label: 'Головна',
                      isActive: activeIndex == 0,
                      onTap: () => onTap?.call(0),
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _NavItem(
                      icon: Icons.search_outlined,
                      label: 'Пошук',
                      isActive: activeIndex == 1,
                      onTap: () => onTap?.call(1),
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _NavItem(
                      icon: Icons.bar_chart_outlined,
                      label: 'Аналітика',
                      isActive: activeIndex == 2,
                      onTap: () => onTap?.call(2),
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _NavItem(
                      icon: Icons.settings_outlined,
                      label: 'Налаштування',
                      isActive: activeIndex == 3,
                      onTap: () => onTap?.call(3),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xFF4BA2FF) : const Color(0xFF95A4BE);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(1, 8, 1, 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 32,
                height: 32,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Icon(icon, color: color, size: 29.7),
                ),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
