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
    return Container(
      height: 90,
      decoration: const BoxDecoration(
        color: Color(0xFF0A1730),
        border: Border(top: BorderSide(color: Color(0xFF1D2C44))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: _NavItem(
              icon: Icons.home_outlined,
              label: 'Головна',
              isActive: activeIndex == 0,
              onTap: () => onTap?.call(0),
            ),
          ),
          Expanded(
            child: _NavItem(
              icon: Icons.search,
              label: 'Пошук',
              isActive: activeIndex == 1,
              onTap: () => onTap?.call(1),
            ),
          ),
          Expanded(
            child: _NavItem(
              icon: Icons.bar_chart,
              label: 'Аналітика',
              isActive: activeIndex == 2,
              onTap: () => onTap?.call(2),
            ),
          ),
          Expanded(
            child: _NavItem(
              icon: Icons.settings,
              label: 'Налаштування',
              isActive: activeIndex == 3,
              onTap: () => onTap?.call(3),
            ),
          ),
        ],
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
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 52,
                height: 4,
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF4BA2FF) : Colors.transparent,
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 14, 6, 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: Center(
                      child: Icon(icon, color: color, size: 31),
                    ),
                  ),
                  const SizedBox(height: 3),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
