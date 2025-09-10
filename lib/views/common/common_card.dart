import 'package:flutter/material.dart';

/// Common Card widget
class CommonCard extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget? icon;
  final List<Widget> children;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;

  const CommonCard({
    super.key,
    this.title,
    this.subtitle,
    this.icon,
    required this.children,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(12.0),
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      child: Padding(
        padding: padding!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Row(
                children: [
                  if (icon != null) ...[icon!, const SizedBox(width: 8)],
                  Expanded(
                    child: Text(
                      title!,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
              const SizedBox(height: 12),
            ],
            ...children,
          ],
        ),
      ),
    );
  }
}
