import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A reusable workspace icon card widget for dashboard modules.
///
/// This widget provides a consistent card design for workspace/module 
/// navigation items on the dashboard.
///
/// Example usage:
/// ```dart
/// WorkspaceIcon(
///   pushUrl: '/sales',
///   title: 'Sales',
///   subTitle: 'Tap to explore',
///   icon: Icons.point_of_sale,
/// )
/// ```
class WorkspaceIcon extends StatelessWidget {
  /// The URL to navigate to when tapped
  final String pushUrl;

  /// The main title text displayed on the card
  final String title;

  /// The subtitle text displayed below the title
  final String subTitle;

  /// The icon to display on the card
  final IconData icon;

  /// Icon size, defaults to 40
  final double iconSize;

  /// Card elevation, defaults to 2
  final double elevation;

  /// Border radius of the InkWell, defaults to 12
  final double borderRadius;

  /// Padding inside the card, defaults to EdgeInsets.all(12)
  final EdgeInsetsGeometry padding;

  /// Custom callback when card is tapped. If not provided, uses context.push(pushUrl)
  final VoidCallback? onTap;

  /// Creates a WorkspaceIcon widget.
  ///
  /// [pushUrl] is the navigation path when the card is tapped.
  /// [title] is the main text displayed on the card.
  /// [subTitle] is the secondary text displayed below the title.
  /// [icon] is the IconData to display.
  const WorkspaceIcon({
    super.key,
    required this.pushUrl,
    required this.title,
    required this.subTitle,
    required this.icon,
    this.iconSize = 40,
    this.elevation = 2,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.all(12),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: elevation,
      child: InkWell(
        onTap: onTap ?? () => context.push(pushUrl),
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: padding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                flex: 2,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Icon(
                    icon,
                    size: iconSize,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    subTitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
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
