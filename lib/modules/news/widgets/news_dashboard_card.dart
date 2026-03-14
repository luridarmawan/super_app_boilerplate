import 'package:flutter/material.dart';

import '../../../shared/widgets/workspace_icon.dart';

/// Dashboard card widget for the News module
class NewsDashboardCard extends StatelessWidget {
  const NewsDashboardCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const WorkspaceIcon(
      pushUrl: '/news',
      title: 'News',
      subTitle: 'News & insights',
      icon: Icons.widgets,
    );
  }
}
