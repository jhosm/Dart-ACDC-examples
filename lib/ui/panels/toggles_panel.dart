import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/code_snippet_generator.dart';

/// Panel displaying feature toggles for Dart-ACDC features
/// (Authentication, Caching, Offline Detection, Deduplication, SWR) with live code snippet.
class TogglesPanel extends StatefulWidget {
  final bool authEnabled;
  final String clientId;
  final bool cacheEnabled;
  final int cacheTtl;
  final bool offlineEnabled;
  final bool deduplicationEnabled;
  final bool swrEnabled;
  final ValueChanged<bool> onAuthToggled;
  final ValueChanged<String> onClientIdChanged;
  final ValueChanged<bool> onCacheToggled;
  final ValueChanged<int> onCacheTtlChanged;
  final ValueChanged<bool> onOfflineToggled;
  final ValueChanged<bool> onDeduplicationToggled;
  final ValueChanged<bool> onSwrToggled;

  const TogglesPanel({
    super.key,
    required this.authEnabled,
    required this.clientId,
    required this.cacheEnabled,
    required this.cacheTtl,
    required this.offlineEnabled,
    required this.deduplicationEnabled,
    required this.swrEnabled,
    required this.onAuthToggled,
    required this.onClientIdChanged,
    required this.onCacheToggled,
    required this.onCacheTtlChanged,
    required this.onOfflineToggled,
    required this.onDeduplicationToggled,
    required this.onSwrToggled,
  });

  @override
  State<TogglesPanel> createState() => _TogglesPanelState();
}

class _TogglesPanelState extends State<TogglesPanel> {
  bool _showDescriptions = false;

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Feature Toggles',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _showDescriptions ? Icons.info : Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  tooltip: _showDescriptions
                      ? 'Hide descriptions'
                      : 'Show descriptions',
                  onPressed: () {
                    setState(() {
                      _showDescriptions = !_showDescriptions;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Offline Mode Banner
            if (widget.offlineEnabled)
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
              description:
                  'Simulates an authenticated session by injecting a mock token into requests.',
              icon: Icons.lock,
              value: widget.authEnabled,
              onChanged: widget.onAuthToggled,
              child: widget.authEnabled
                  ? Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: TextFormField(
                        initialValue: widget.clientId,
                        decoration: const InputDecoration(
                          labelText: 'Client ID',
                          hintText: 'your-client-id',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.key),
                        ),
                        onChanged: widget.onClientIdChanged,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 12),

            // Caching Toggle
            _buildToggleSection(
              context: context,
              title: 'Caching',
              description:
                  'Enables response caching to reduce network calls and improve performance.',
              icon: Icons.storage,
              value: widget.cacheEnabled,
              onChanged: widget.onCacheToggled,
              child: widget.cacheEnabled
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
                                '${widget.cacheTtl} seconds',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Slider(
                            value: widget.cacheTtl.toDouble(),
                            min: 10,
                            max: 300,
                            divisions: 29,
                            label: '${widget.cacheTtl} seconds',
                            onChanged: (value) =>
                                widget.onCacheTtlChanged(value.toInt()),
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
              title: 'Simulate Offline Mode',
              description:
                  'Forces the client to behave as if there is no internet connection.',
              icon: Icons.wifi_off,
              value: widget.offlineEnabled,
              onChanged: widget.onOfflineToggled,
            ),
            const SizedBox(height: 12),

            // Request Deduplication Toggle
            _buildToggleSection(
              context: context,
              title: 'Request Deduplication',
              description:
                  'Merges identical simultaneous requests into a single network call.',
              icon: Icons.copy_all,
              value: widget.deduplicationEnabled,
              onChanged: widget.onDeduplicationToggled,
            ),
            const SizedBox(height: 12),

            // SWR Toggle
            _buildToggleSection(
              context: context,
              title: 'Stale-While-Revalidate',
              description:
                  'Returns cached data immediately while fetching fresh data in the background.',
              icon: Icons.refresh,
              value: widget.swrEnabled,
              onChanged: widget.onSwrToggled,
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
    String? description,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Icon(icon, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (_showDescriptions && description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
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
      authEnabled: widget.authEnabled,
      clientId: widget.clientId,
      cacheEnabled: widget.cacheEnabled,
      cacheTtl: widget.cacheTtl,
      offlineEnabled: widget.offlineEnabled,
      deduplicationEnabled: widget.deduplicationEnabled,
      swrEnabled: widget.swrEnabled,
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
