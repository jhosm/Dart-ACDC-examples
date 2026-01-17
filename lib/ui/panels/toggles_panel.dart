import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/code_snippet_generator.dart';

/// Panel displaying feature toggles for Dart-ACDC features
/// (Authentication, Caching, Offline Detection) with live code snippet.
class TogglesPanel extends StatelessWidget {
  final bool authEnabled;
  final String clientId;
  final bool cacheEnabled;
  final int cacheTtl;
  final bool offlineEnabled;
  final ValueChanged<bool> onAuthToggled;
  final ValueChanged<String> onClientIdChanged;
  final ValueChanged<bool> onCacheToggled;
  final ValueChanged<int> onCacheTtlChanged;
  final ValueChanged<bool> onOfflineToggled;

  const TogglesPanel({
    super.key,
    required this.authEnabled,
    required this.clientId,
    required this.cacheEnabled,
    required this.cacheTtl,
    required this.offlineEnabled,
    required this.onAuthToggled,
    required this.onClientIdChanged,
    required this.onCacheToggled,
    required this.onCacheTtlChanged,
    required this.onOfflineToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Feature Toggles',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Offline Mode Banner
            if (offlineEnabled)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.error,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.wifi_off,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Offline Mode Active',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

            // Authentication Toggle
            _buildToggleSection(
              context: context,
              title: 'Authentication',
              icon: Icons.lock,
              value: authEnabled,
              onChanged: onAuthToggled,
              child: authEnabled
                  ? Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: TextFormField(
                        initialValue: clientId,
                        decoration: const InputDecoration(
                          labelText: 'Client ID',
                          hintText: 'your-client-id',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.key),
                        ),
                        onChanged: onClientIdChanged,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 12),

            // Caching Toggle
            _buildToggleSection(
              context: context,
              title: 'Caching',
              icon: Icons.storage,
              value: cacheEnabled,
              onChanged: onCacheToggled,
              child: cacheEnabled
                  ? Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Cache TTL',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                '$cacheTtl seconds',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Slider(
                            value: cacheTtl.toDouble(),
                            min: 10,
                            max: 300,
                            divisions: 29,
                            label: '$cacheTtl seconds',
                            onChanged: (value) =>
                                onCacheTtlChanged(value.toInt()),
                          ),
                        ],
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 12),

            // Offline Detection Toggle
            _buildToggleSection(
              context: context,
              title: 'Offline Detection',
              icon: Icons.wifi_off,
              value: offlineEnabled,
              onChanged: onOfflineToggled,
            ),
            const SizedBox(height: 24),

            // Code Snippet Section
            _buildCodeSnippetSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
    Widget? child,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Switch(value: value, onChanged: onChanged),
            ],
          ),
          if (child != null) child,
        ],
      ),
    );
  }

  Widget _buildCodeSnippetSection(BuildContext context) {
    final codeSnippet = CodeSnippetGenerator.generateBuilderCode(
      authEnabled: authEnabled,
      clientId: clientId,
      cacheEnabled: cacheEnabled,
      cacheTtl: cacheTtl,
      offlineEnabled: offlineEnabled,
    );

    return ExpansionTile(
      title: Row(
        children: [
          const Icon(Icons.code, size: 20),
          const SizedBox(width: 8),
          Text(
            'Live Code Snippet',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
      initiallyExpanded: true,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'AcdcClientBuilder Configuration',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    tooltip: 'Copy to clipboard',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: codeSnippet));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Code copied to clipboard'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SelectableText(
                codeSnippet,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
