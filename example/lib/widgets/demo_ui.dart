import 'package:flutter/material.dart';

import 'button_widget.dart';

class DemoColors {
  static const background = Color(0xFFF0F2F5);
  static const surface = Colors.white;
  static const border = Color(0xFFE8ECF0);
  static const title = Color(0xFF1A202C);
  static const subtitle = Color(0xFF718096);
  static const primary = Color(0xFF4A90E2);
  static const accentA = Color(0xFF4A90E2);
  static const accentB = Color(0xFF50C878);
  static const feedText = Color(0xFF2D3748);
  static const feedMuted = Color(0xFF4A5568);
}

PreferredSizeWidget demoAppBar(String title) {
  return AppBar(
    title: Text(title),
    elevation: 0,
    backgroundColor: DemoColors.surface,
    foregroundColor: DemoColors.title,
  );
}

class DemoPageHeader extends StatelessWidget {
  const DemoPageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.primaryText,
    this.onPrimaryTap,
    this.primaryColor = DemoColors.primary,
    this.children = const [],
  });

  final String title;
  final String subtitle;
  final String? primaryText;
  final VoidCallback? onPrimaryTap;
  final Color primaryColor;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: DemoColors.surface,
        border: Border(bottom: BorderSide(color: DemoColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: DemoColors.title,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: DemoColors.subtitle),
          ),
          if (primaryText != null && onPrimaryTap != null) ...[
            const SizedBox(height: 12),
            ButtonWidget(
              buttonText: primaryText!,
              backgroundColor: primaryColor,
              callBack: onPrimaryTap!,
            ),
          ],
          ...children,
        ],
      ),
    );
  }
}

class DemoInstanceBadge extends StatelessWidget {
  const DemoInstanceBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final isA = label == 'A';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isA ? DemoColors.accentA : DemoColors.accentB,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        '实例 $label',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class DemoFeedTile extends StatelessWidget {
  const DemoFeedTile({super.key, required this.index, required this.title});

  final int index;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: DemoColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DemoColors.border),
      ),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2F7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: DemoColors.feedMuted,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 15, color: DemoColors.feedText),
            ),
          ),
        ],
      ),
    );
  }
}

class DemoInfoCard extends StatelessWidget {
  const DemoInfoCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DemoColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DemoColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: DemoColors.primary),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: DemoColors.subtitle),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: DemoColors.title,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
