import 'package:flutter/material.dart';
import 'package:talker_flutter/talker_flutter.dart';

class LogPanel extends StatefulWidget {
  final Talker talker;

  const LogPanel({super.key, required this.talker});

  @override
  State<LogPanel> createState() => _LogPanelState();
}

class _LogPanelState extends State<LogPanel> {
  final List<TalkerData> _logs = [];
  LogLevel? _filterLevel;

  @override
  void initState() {
    super.initState();
    _logs.addAll(widget.talker.history);
    widget.talker.stream.listen((data) {
      if (mounted) {
        setState(() {
          _logs.add(data);
        });
      }
    });
  }

  void _clearLogs() {
    widget.talker.cleanHistory();
    setState(() {
      _logs.clear();
    });
  }

  List<TalkerData> get _filteredLogs {
    if (_filterLevel == null) return _logs;
    return _logs.where((log) => log.logLevel == _filterLevel).toList();
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                Text(
                  'Logs',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<LogLevel>(
                  hint: const Text('All Levels'),
                  value: _filterLevel,
                  underline: const SizedBox(),
                  items: [
                    const DropdownMenuItem<LogLevel>(
                      value: null,
                      child: Text('All Levels'),
                    ),
                    ...LogLevel.values.map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.name.toUpperCase()),
                      ),
                    ),
                  ],
                  onChanged: (val) => setState(() => _filterLevel = val),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Clear Logs',
                  onPressed: _clearLogs,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredLogs.length,
              itemBuilder: (context, index) {
                // Show newest at top
                final log = _filteredLogs[_filteredLogs.length - 1 - index];
                return _buildLogItem(log);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogItem(TalkerData log) {
    Color color = Colors.grey;
    IconData icon = Icons.info_outline;

    switch (log.logLevel) {
      case LogLevel.error:
      case LogLevel.critical:
        color = Colors.red;
        icon = Icons.error_outline;
        break;
      case LogLevel.warning:
        color = Colors.orange;
        icon = Icons.warning_amber;
        break;
      case LogLevel.verbose:
      case LogLevel.debug:
        color = Colors.grey;
        break;
      case LogLevel.info:
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
        break;
    }

    return ListTile(
      dense: true,
      leading: Icon(icon, color: color, size: 20),
      title: Text(
        log.message?.toString() ?? '',
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
      subtitle: log.exception != null
          ? Text(
              log.exception.toString(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: Text(
        log.displayTime(),
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
