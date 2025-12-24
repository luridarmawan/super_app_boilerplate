import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notification/notification_provider.dart';
import '../notification/notification_interface.dart';
import '../notification/mock_notification_service.dart';
import '../constants/app_info.dart';

/// Debug panel for testing notifications
/// Only works when notificationProvider is set to 'mock'
class NotificationTestPanel extends ConsumerStatefulWidget {
  const NotificationTestPanel({super.key});

  @override
  ConsumerState<NotificationTestPanel> createState() => _NotificationTestPanelState();
}

class _NotificationTestPanelState extends ConsumerState<NotificationTestPanel> {
  final _titleController = TextEditingController(text: 'Test Notification');
  final _bodyController = TextEditingController(text: 'This is a test notification body');
  final _topicController = TextEditingController(text: 'news');
  
  final List<String> _logs = [];

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _topicController.dispose();
    super.dispose();
  }

  void _addLog(String message) {
    setState(() {
      _logs.insert(0, '[${DateTime.now().toString().substring(11, 19)}] $message');
      if (_logs.length > 20) _logs.removeLast();
    });
  }

  MockNotificationService? get _mockService {
    if (AppInfo.notificationProvider.toLowerCase() != 'mock' &&
        AppInfo.notificationProvider.toLowerCase() != 'test') {
      return null;
    }
    try {
      return ref.read(notificationServiceProvider) as MockNotificationService;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final isMockProvider = AppInfo.notificationProvider.toLowerCase() == 'mock' ||
        AppInfo.notificationProvider.toLowerCase() == 'test';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Test Panel'),
        backgroundColor: colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              color: isMockProvider ? colorScheme.primaryContainer : colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isMockProvider ? Icons.check_circle : Icons.warning,
                          color: isMockProvider ? colorScheme.primary : colorScheme.error,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Provider: ${AppInfo.notificationProvider.toUpperCase()}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (!isMockProvider)
                      Text(
                        '⚠️ Set notificationProvider ke "mock" di app_info.dart untuk testing',
                        style: TextStyle(color: colorScheme.error),
                      ),
                    const SizedBox(height: 8),
                    _buildStatusRow('Initialized', notificationState.isInitialized),
                    _buildStatusRow('Has Permission', notificationState.hasPermission),
                    _buildStatusRow('Loading', notificationState.isLoading),
                    if (notificationState.deviceToken != null)
                      Text('Token: ${notificationState.deviceToken!.substring(0, 20)}...'),
                    if (notificationState.error != null)
                      Text('Error: ${notificationState.error}', 
                        style: TextStyle(color: colorScheme.error)),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Actions Section
            Text('📤 Actions', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildActionButton(
                  'Initialize',
                  Icons.play_arrow,
                  () async {
                    await ref.read(notificationProvider.notifier).initialize();
                    _addLog('✅ Initialized');
                  },
                ),
                _buildActionButton(
                  'Request Permission',
                  Icons.security,
                  () async {
                    final granted = await ref.read(notificationProvider.notifier).requestPermission();
                    _addLog(granted ? '✅ Permission granted' : '❌ Permission denied');
                  },
                ),
                _buildActionButton(
                  'Get Token',
                  Icons.vpn_key,
                  () {
                    final state = ref.read(notificationProvider);
                    _addLog('🔑 Token: ${state.deviceToken ?? 'null'}');
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Send Notification Section
            Text('📨 Send Local Notification', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _bodyController,
              decoration: const InputDecoration(
                labelText: 'Body',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () async {
                await ref.read(notificationProvider.notifier).showLocalNotification(
                  title: _titleController.text,
                  body: _bodyController.text,
                  data: {'route': '/test', 'timestamp': DateTime.now().toString()},
                );
                _addLog('📤 Sent: ${_titleController.text}');
              },
              icon: const Icon(Icons.send),
              label: const Text('Send Notification'),
            ),
            
            const SizedBox(height: 24),
            
            // Topic Section
            Text('📌 Topics', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _topicController,
                    decoration: const InputDecoration(
                      labelText: 'Topic Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: () async {
                    await ref.read(notificationProvider.notifier)
                        .subscribeToTopic(_topicController.text);
                    _addLog('📌 Subscribed to: ${_topicController.text}');
                  },
                  icon: const Icon(Icons.add),
                  tooltip: 'Subscribe',
                ),
                IconButton.outlined(
                  onPressed: () async {
                    await ref.read(notificationProvider.notifier)
                        .unsubscribeFromTopic(_topicController.text);
                    _addLog('📌 Unsubscribed from: ${_topicController.text}');
                  },
                  icon: const Icon(Icons.remove),
                  tooltip: 'Unsubscribe',
                ),
              ],
            ),
            
            if (isMockProvider) ...[
              const SizedBox(height: 8),
              if (_mockService != null)
                Wrap(
                  spacing: 4,
                  children: _mockService!.subscribedTopics.map((topic) => 
                    Chip(
                      label: Text(topic),
                      onDeleted: () async {
                        await ref.read(notificationProvider.notifier)
                            .unsubscribeFromTopic(topic);
                        setState(() {});
                        _addLog('📌 Removed topic: $topic');
                      },
                    ),
                  ).toList(),
                ),
            ],
            
            const SizedBox(height: 24),
            
            // Simulate Section (Mock only)
            if (isMockProvider) ...[
              Text('🎭 Simulate (Mock Only)', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildActionButton(
                    'Simulate Foreground',
                    Icons.notifications_active,
                    () {
                      _mockService?.simulateForegroundNotification(
                        title: 'Simulated Notification',
                        body: 'This notification was simulated',
                        data: {'simulated': true, 'timestamp': DateTime.now().toString()},
                      );
                      _addLog('🎭 Simulated foreground notification');
                    },
                    color: colorScheme.secondaryContainer,
                    foregroundColor: colorScheme.onSecondaryContainer,
                  ),
                  _buildActionButton(
                    'Simulate Tap',
                    Icons.touch_app,
                    () {
                      _mockService?.simulateNotificationTap(NotificationMessage(
                        id: 'sim_${DateTime.now().millisecondsSinceEpoch}',
                        title: 'Tapped Notification',
                        body: 'User tapped this notification',
                        data: {'route': '/simulated'},
                        receivedAt: DateTime.now(),
                      ));
                      _addLog('🎭 Simulated notification tap');
                    },
                    color: colorScheme.tertiaryContainer,
                    foregroundColor: colorScheme.onTertiaryContainer,
                  ),
                  _buildActionButton(
                    'Simulate Token Refresh',
                    Icons.refresh,
                    () {
                      final newToken = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
                      _mockService?.simulateTokenRefresh(newToken);
                      _addLog('🎭 Simulated token refresh');
                    },
                    color: colorScheme.primaryContainer,
                    foregroundColor: colorScheme.onPrimaryContainer,
                  ),
                  _buildActionButton(
                    'Set Permission Denied',
                    Icons.block,
                    () {
                      _mockService?.setPermissionStatus(NotificationPermissionStatus.denied);
                      _addLog('🎭 Set permission to denied');
                    },
                    color: colorScheme.errorContainer,
                    foregroundColor: colorScheme.onErrorContainer,
                  ),
                  _buildActionButton(
                    'Set Permission Granted',
                    Icons.check_circle,
                    () {
                      _mockService?.setPermissionStatus(NotificationPermissionStatus.authorized);
                      _addLog('🎭 Set permission to authorized');
                    },
                    color: Colors.green.shade100,
                    foregroundColor: Colors.green.shade900,
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Mock Service Info
              if (_mockService != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mock Service Info', 
                          style: Theme.of(context).textTheme.titleSmall),
                        const Divider(),
                        Text('Shown notifications: ${_mockService!.shownNotifications.length}'),
                        Text('Subscribed topics: ${_mockService!.subscribedTopics.length}'),
                        Text('Is initialized: ${_mockService!.isInitialized}'),
                      ],
                    ),
                  ),
                ),
            ],
            
            const SizedBox(height: 24),
            
            // Logs Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('📋 Logs', style: Theme.of(context).textTheme.titleMedium),
                TextButton(
                  onPressed: () => setState(() => _logs.clear()),
                  child: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            Container(
              height: 200,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: _logs.isEmpty
                  ? Center(
                      child: Text(
                        'No logs yet...',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _logs.length,
                      itemBuilder: (context, index) => Text(
                        _logs[index],
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
            ),
            
            const SizedBox(height: 100), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, bool value) {
    return Row(
      children: [
        Icon(
          value ? Icons.check_circle : Icons.cancel,
          size: 16,
          color: value ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 4),
        Text('$label: ${value ? 'Yes' : 'No'}'),
      ],
    );
  }

  Widget _buildActionButton(
    String label, 
    IconData icon, 
    VoidCallback onPressed, {
    Color? color,
    Color? foregroundColor,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: color != null
          ? ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: foregroundColor ?? Colors.white,
            )
          : null,
    );
  }
}

/// Quick access button to open test panel
class NotificationTestButton extends StatelessWidget {
  const NotificationTestButton({super.key});

  @override
  Widget build(BuildContext context) {
    // Only show when notification enabled AND mock mode
    final isMockMode = AppInfo.enableNotification &&
        (AppInfo.notificationProvider.toLowerCase() == 'mock' ||
         AppInfo.notificationProvider.toLowerCase() == 'test');
    
    if (!isMockMode) return const SizedBox.shrink();

    return FloatingActionButton.small(
      heroTag: 'notification_test',
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const NotificationTestPanel()),
        );
      },
      backgroundColor: Colors.orange,
      child: const Icon(Icons.bug_report),
    );
  }
}
