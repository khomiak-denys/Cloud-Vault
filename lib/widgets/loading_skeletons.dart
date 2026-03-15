import 'package:flutter/material.dart';

import '../theme/app_theme_colors.dart';

class SkeletonBlock extends StatelessWidget {
  const SkeletonBlock({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.radius = 12,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final base = colors.inputBackground;
    final highlight = colors.softCardBackground;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.35, end: 0.75),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Color.lerp(base, highlight, 0.5),
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
        );
      },
      onEnd: () {},
    );
  }
}

class DashboardLoadingSkeleton extends StatelessWidget {
  const DashboardLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      child: Column(
        children: const [
          SkeletonBlock(height: 72, radius: 16),
          SizedBox(height: 10),
          SkeletonBlock(height: 72, radius: 16),
          SizedBox(height: 10),
          SkeletonBlock(height: 72, radius: 16),
          SizedBox(height: 18),
          SkeletonBlock(height: 84, radius: 16),
          SizedBox(height: 12),
          SkeletonBlock(height: 84, radius: 16),
          SizedBox(height: 12),
          SkeletonBlock(height: 84, radius: 16),
        ],
      ),
    );
  }
}

class SearchLoadingSkeleton extends StatelessWidget {
  const SearchLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SkeletonBlock(width: 160, height: 18, radius: 8),
          SizedBox(height: 14),
          SkeletonBlock(height: 84, radius: 16),
          SizedBox(height: 12),
          SkeletonBlock(height: 84, radius: 16),
          SizedBox(height: 12),
          SkeletonBlock(height: 84, radius: 16),
        ],
      ),
    );
  }
}

class AnalyticsLoadingSkeleton extends StatelessWidget {
  const AnalyticsLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: const [
          Row(
            children: [
              Expanded(child: SkeletonBlock(height: 86, radius: 12)),
              SizedBox(width: 10),
              Expanded(child: SkeletonBlock(height: 86, radius: 12)),
              SizedBox(width: 10),
              Expanded(child: SkeletonBlock(height: 86, radius: 12)),
            ],
          ),
          SizedBox(height: 16),
          SkeletonBlock(height: 260, radius: 12),
          SizedBox(height: 16),
          SkeletonBlock(height: 180, radius: 12),
          SizedBox(height: 16),
          SkeletonBlock(height: 120, radius: 12),
        ],
      ),
    );
  }
}

class ProfileLoadingSkeleton extends StatelessWidget {
  const ProfileLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: const [
          SkeletonBlock(height: 340, radius: 22),
          SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: SkeletonBlock(height: 108, radius: 18)),
              SizedBox(width: 10),
              Expanded(child: SkeletonBlock(height: 108, radius: 18)),
            ],
          ),
          SizedBox(height: 14),
          SkeletonBlock(height: 280, radius: 22),
        ],
      ),
    );
  }
}

class SettingsLoadingSkeleton extends StatelessWidget {
  const SettingsLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: const [
          SkeletonBlock(height: 128, radius: 20),
          SizedBox(height: 18),
          SkeletonBlock(height: 220, radius: 18),
          SizedBox(height: 20),
          SkeletonBlock(height: 168, radius: 18),
          SizedBox(height: 18),
          SkeletonBlock(height: 132, radius: 18),
        ],
      ),
    );
  }
}
