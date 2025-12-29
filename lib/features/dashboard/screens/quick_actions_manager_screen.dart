import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../modules/quick_action_item.dart';
import '../../../modules/module_registry.dart';
import '../providers/quick_action_visibility_provider.dart';

/// Screen for managing quick actions visibility
/// Users can enable/disable individual quick actions
class QuickActionsManagerScreen extends ConsumerWidget {
  const QuickActionsManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allActions = ref.watch(allQuickActionsProvider);
    final visibility = ref.watch(quickActionVisibilityProvider);
    final colorScheme = Theme.of(context).colorScheme;

    // Group actions by module
    final groupedActions = <String, List<QuickActionItem>>{};
    for (final action in allActions) {
      groupedActions.putIfAbsent(action.moduleId, () => []).add(action);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Actions'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              final notifier =
                  ref.read(quickActionVisibilityProvider.notifier);
              final actionIds = allActions.map((a) => a.id).toList();
              
              switch (value) {
                case 'show_all':
                  notifier.showAll(actionIds);
                  break;
                case 'hide_all':
                  notifier.hideAll(actionIds);
                  break;
                case 'reset':
                  notifier.resetToDefault();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'show_all',
                child: Row(
                  children: [
                    Icon(Icons.visibility),
                    SizedBox(width: 12),
                    Text('Show All'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'hide_all',
                child: Row(
                  children: [
                    Icon(Icons.visibility_off),
                    SizedBox(width: 12),
                    Text('Hide All'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.restore),
                    SizedBox(width: 12),
                    Text('Reset to Default'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: groupedActions.length,
        itemBuilder: (context, index) {
          final moduleId = groupedActions.keys.elementAt(index);
          final actions = groupedActions[moduleId]!;
          
          // Get module display name
          String moduleName;
          if (moduleId == StaticQuickActions.moduleId) {
            moduleName = 'Default Actions';
          } else {
            final module = ModuleRegistry.getModule(moduleId);
            moduleName = module?.displayName ?? moduleId;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Module header
              Padding(
                padding: EdgeInsets.only(bottom: 8, top: index > 0 ? 16 : 0),
                child: Row(
                  children: [
                    Icon(
                      moduleId == StaticQuickActions.moduleId
                          ? Icons.apps
                          : Icons.extension,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      moduleName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                    ),
                    const Spacer(),
                    Text(
                      '${actions.length} actions',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              
              // Actions list
              Card(
                elevation: 0,
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                child: Column(
                  children: actions.asMap().entries.map((entry) {
                    final actionIndex = entry.key;
                    final action = entry.value;
                    final isVisible = visibility[action.id] ?? action.enabledByDefault;
                    
                    return Column(
                      children: [
                        _QuickActionTile(
                          action: action,
                          isVisible: isVisible,
                          onToggle: () {
                            ref
                                .read(quickActionVisibilityProvider.notifier)
                                .toggle(action.id, defaultValue: action.enabledByDefault);
                          },
                        ),
                        if (actionIndex < actions.length - 1)
                          Divider(
                            height: 1,
                            indent: 56,
                            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                          ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final QuickActionItem action;
  final bool isVisible;
  final VoidCallback onToggle;

  const _QuickActionTile({
    required this.action,
    required this.isVisible,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final itemColor = action.color ?? colorScheme.primary;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isVisible 
              ? itemColor.withValues(alpha: 0.15) 
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          action.icon,
          color: isVisible ? itemColor : colorScheme.onSurfaceVariant,
          size: 22,
        ),
      ),
      title: Text(
        action.label,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isVisible ? null : colorScheme.onSurfaceVariant,
        ),
      ),
      subtitle: action.description != null
          ? Text(
              action.description!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            )
          : null,
      trailing: Switch.adaptive(
        value: isVisible,
        onChanged: (_) => onToggle(),
        activeTrackColor: colorScheme.primary,
        activeThumbColor: colorScheme.onPrimary,
      ),
      onTap: onToggle,
    );
  }
}
