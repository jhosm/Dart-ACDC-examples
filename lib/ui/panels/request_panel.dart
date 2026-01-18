import 'package:flutter/material.dart';

class RequestPanel extends StatefulWidget {
  final Function(String method, String url, Map<String, String> headers) onSend;

  // Demo Callbacks
  final VoidCallback? onFireDuplicateRequests;
  final VoidCallback? onCancelRequest;
  final VoidCallback? onTriggerError;

  const RequestPanel({
    super.key,
    required this.onSend,
    this.onFireDuplicateRequests,
    this.onCancelRequest,
    this.onTriggerError,
  });

  @override
  State<RequestPanel> createState() => _RequestPanelState();
}

class _RequestPanelState extends State<RequestPanel> {
  final _urlController = TextEditingController(
    text: 'https://httpbin.org/cache/60',
  );
  final _headersController = TextEditingController();

  String _selectedMethod = 'GET';
  final List<String> _methods = [
    'GET',
    'POST',
    'PUT',
    'DELETE',
    'PATCH',
    'HEAD',
  ];

  @override
  void dispose() {
    _urlController.dispose();
    _headersController.dispose();
    super.dispose();
  }

  void _handleSend() {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    final headers = <String, String>{};
    final headersText = _headersController.text.trim();
    if (headersText.isNotEmpty) {
      // Simple parsing: Key: Value, one per line
      final lines = headersText.split('\n');
      for (final line in lines) {
        final parts = line.split(':');
        if (parts.length >= 2) {
          final key = parts[0].trim();
          final value = parts.sublist(1).join(':').trim();
          if (key.isNotEmpty) {
            headers[key] = value;
          }
        }
      }
    }

    widget.onSend(_selectedMethod, url, headers);
  }

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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Request Builder',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: 140,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedMethod,
                    decoration: const InputDecoration(
                      labelText: 'Method',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                    ),
                    items: _methods.map((method) {
                      return DropdownMenuItem(
                        value: method,
                        child: Text(
                          method,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedMethod = value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      labelText: 'Request URL',
                      hintText: 'https://api.example.com/resource',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.link),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: TextFormField(
                controller: _headersController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  labelText: 'Headers (Key: Value)',
                  hintText:
                      'Authorization: Bearer token\nContent-Type: application/json',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _handleSend,
              icon: const Icon(Icons.send),
              label: const Text('Send Request'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text('Demo Actions', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (widget.onFireDuplicateRequests != null)
                  OutlinedButton.icon(
                    onPressed: widget.onFireDuplicateRequests,
                    icon: const Icon(Icons.copy_all, size: 18),
                    label: const Text('Fire 3x (Dedup)'),
                  ),
                if (widget.onCancelRequest != null)
                  OutlinedButton.icon(
                    onPressed: widget.onCancelRequest,
                    icon: const Icon(Icons.cancel, size: 18),
                    label: const Text('Cancel Request'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                if (widget.onTriggerError != null)
                  OutlinedButton.icon(
                    onPressed: widget.onTriggerError,
                    icon: const Icon(Icons.error_outline, size: 18),
                    label: const Text('Trigger Error'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
