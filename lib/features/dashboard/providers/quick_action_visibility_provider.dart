import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../modules/quick_action_item.dart';
import '../../../modules/module_registry.dart';

/// Key for storing quick action visibility settings in SharedPreferences
const String _quickActionVisibilityKey = 'quick_action_visibility';

/// Provider for managing quick action visibility state
/// 
/// Usage:
/// ```dart
/// final visibility = ref.watch(quickActionVisibilityProvider);
/// final isVisible = visibility[actionId] ?? true;
/// 
/// // To toggle visibility
/// ref.read(quickActionVisibilityProvider.notifier).toggle(actionId);
/// ```
final quickActionVisibilityProvider =
    StateNotifierProvider<QuickActionVisibilityNotifier, Map<String, bool>>(
        (ref) {
  return QuickActionVisibilityNotifier();
});

/// Provider for getting only visible quick actions
final visibleQuickActionsProvider = Provider<List<QuickActionItem>>((ref) {
  final allActions = ref.watch(allQuickActionsProvider);
  final visibility = ref.watch(quickActionVisibilityProvider);
  
  return allActions.where((action) {
    return visibility[action.id] ?? action.enabledByDefault;
  }).toList();
});

/// Provider for quick actions to show in menu grid (limited count)
/// maxItems = number of action icons to show (not including "More" button)
final menuGridQuickActionsProvider = Provider.family<List<QuickActionItem>, int>((ref, maxItems) {
  final visibleActions = ref.watch(visibleQuickActionsProvider);
  
  // Return up to maxItems actions
  // The "More" button is added separately in the widget
  if (visibleActions.length > maxItems) {
    return visibleActions.take(maxItems).toList();
  }
  
  return visibleActions;
});

/// Provider to check if "More" button should be shown (when items exceed maxItems)
/// Note: The widget may also show "More" based on alwaysShowMore parameter
final showMoreButtonProvider = Provider.family<bool, int>((ref, maxItems) {
  final visibleActions = ref.watch(visibleQuickActionsProvider);
  return visibleActions.length > maxItems;
});

/// StateNotifier for managing quick action visibility
class QuickActionVisibilityNotifier extends StateNotifier<Map<String, bool>> {
  QuickActionVisibilityNotifier() : super({}) {
    _loadFromPrefs();
  }

  /// Load visibility settings from SharedPreferences
  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_quickActionVisibilityKey);
      
      if (jsonString != null) {
        final Map<String, dynamic> decoded = json.decode(jsonString);
        state = decoded.map((key, value) => MapEntry(key, value as bool));
      }
    } catch (e) {
      // If there's an error, start with empty state (all default visibility)
      state = {};
    }
  }

  /// Save visibility settings to SharedPreferences
  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(state);
      await prefs.setString(_quickActionVisibilityKey, jsonString);
    } catch (e) {
      // Silently fail on save error
    }
  }

  /// Check if a quick action is visible
  bool isVisible(String actionId, {bool defaultValue = true}) {
    return state[actionId] ?? defaultValue;
  }

  /// Set visibility for a quick action
  Future<void> setVisibility(String actionId, bool visible) async {
    state = {...state, actionId: visible};
    await _saveToPrefs();
  }

  /// Toggle visibility for a quick action
  Future<void> toggle(String actionId, {bool defaultValue = true}) async {
    final currentValue = state[actionId] ?? defaultValue;
    await setVisibility(actionId, !currentValue);
  }

  /// Reset all visibility to default
  Future<void> resetToDefault() async {
    state = {};
    await _saveToPrefs();
  }

  /// Set visibility for multiple actions at once
  Future<void> setMultiple(Map<String, bool> visibilityMap) async {
    state = {...state, ...visibilityMap};
    await _saveToPrefs();
  }

  /// Show all quick actions
  Future<void> showAll(List<String> actionIds) async {
    final newState = {...state};
    for (final id in actionIds) {
      newState[id] = true;
    }
    state = newState;
    await _saveToPrefs();
  }

  /// Hide all quick actions
  Future<void> hideAll(List<String> actionIds) async {
    final newState = {...state};
    for (final id in actionIds) {
      newState[id] = false;
    }
    state = newState;
    await _saveToPrefs();
  }
}
