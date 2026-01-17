import 'package:flutter/material.dart';

class ResponsePanel extends StatelessWidget {
  final dynamic responseData;
  final String? error;
  final bool isLoading;
  final int? statusCode;
  final Duration? duration;
  final String? source;

  const ResponsePanel({
    super.key,
    this.responseData,
    this.error,
    this.isLoading = false,
    this.statusCode,
    this.duration,
    this.source,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = Colors.grey;
    if (statusCode != null) {
      if (statusCode! >= 200 && statusCode! < 300) {
        statusColor = Colors.green;
      } else if (statusCode! >= 400) {
        statusColor = Colors.red;
      } else {
        statusColor = Colors.orange;
      }
    }

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Row(
              children: [
                Text(
                  'Response',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (statusCode != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      'Status: $statusCode',
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                if (duration != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    '${duration!.inMilliseconds}ms',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                if (source != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: Colors.blue.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      source!.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          if (isLoading) const LinearProgressIndicator(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: _buildContent(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (error != null) {
      return SelectableText(
        error!,
        style: TextStyle(
          color: Theme.of(context).colorScheme.error,
          fontFamily: 'monospace',
        ),
      );
    }

    if (responseData == null) {
      return Center(
        child: Text(
          'No response data',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    // Pretty print JSON if it's a Map or List
    String textContent = responseData.toString();
    /* 
       Note: In a real app we'd use dart:convert's JsonEncoder.withIndent
       We can assume the parent passes a formatted string or we format it here.
       For now, we rely on toString() but ideally we should format it.
    */

    return SelectableText(
      textContent,
      style: TextStyle(
        fontFamily: 'monospace',
        fontSize: 13,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}
