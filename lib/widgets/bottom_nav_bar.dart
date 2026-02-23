import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: const BoxDecoration(
        color: Color(0xFF0A1730),
        border: Border(top: BorderSide(color: Color(0xFF1D2C44))),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: _NavItem(icon: Icons.home_outlined, label: 'Головна', isActive: true),
          ),
          Expanded(
            child: _NavItem(icon: Icons.search, label: 'Пошук'),
          ),
          Expanded(
            child: _NavItem(icon: Icons.bar_chart, label: 'Аналітика'),
          ),
          Expanded(
            child: _NavItem(icon: Icons.settings, label: 'Налаштування'),
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
  });

  final IconData icon;
  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xFF4BA2FF) : const Color(0xFF95A4BE);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 29),
        const SizedBox(height: 5),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
