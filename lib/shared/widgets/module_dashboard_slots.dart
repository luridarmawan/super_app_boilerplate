import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../modules/module_registry.dart';

/// A widget that displays dashboard widgets from all active modules.
/// 
/// This widget automatically collects and displays widgets provided by
/// registered modules, creating a dynamic and extensible dashboard.
/// 
/// Usage:
/// ```dart
/// ModuleDashboardSlots(
///   title: 'Modul Aktif',
///   showTitle: true,
/// )
/// ```
class ModuleDashboardSlots extends ConsumerWidget {
  /// Title displayed above the module widgets
  final String? title;

  /// Whether to show the title section
  final bool showTitle;

  /// Number of columns in the grid
  final int crossAxisCount;

  /// Aspect ratio for each grid item
  final double childAspectRatio;

  /// Spacing between grid items
  final double spacing;

  /// Padding around the entire widget
  final EdgeInsets padding;

  /// Whether to show empty state when no modules have widgets
  final bool showEmptyState;

  /// Custom empty state widget
  final Widget? emptyStateWidget;

  const ModuleDashboardSlots({
    super.key,
    this.title,
    this.showTitle = true,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.5,
    this.spacing = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.showEmptyState = false,
    this.emptyStateWidget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final widgets = ModuleRegistry.dashboardWidgets;

    // Return empty if no widgets and showEmptyState is false
    if (widgets.isEmpty && !showEmptyState) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title section
          if (showTitle && title != null) ...[
            Text(
              title!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
          ],

          // Module widgets grid or empty state
          if (widgets.isEmpty)
            _buildEmptyState(context)
          else
            _buildModuleGrid(context, widgets),
        ],
      ),
    );
  }

  Widget _buildModuleGrid(BuildContext context, List<Widget> widgets) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: widgets.length,
      itemBuilder: (context, index) {
        return widgets[index];
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    if (emptyStateWidget != null) {
      return emptyStateWidget!;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.extension_off,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            'Tidak ada modul aktif',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Aktifkan modul di .env untuk menampilkan',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// A simpler inline version that just returns the list of module widgets
/// Use this if you want more control over the layout
class ModuleWidgetsList extends ConsumerWidget {
  const ModuleWidgetsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final widgets = ModuleRegistry.dashboardWidgets;
    
    if (widgets.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: widgets.map((widget) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: widget,
        );
      }).toList(),
    );
  }
}
