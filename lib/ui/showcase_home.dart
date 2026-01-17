import 'package:dart_acdc/dart_acdc.dart' as acdc;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../logging/talker_log_delegate.dart';
import 'panels/log_panel.dart';
import 'panels/request_panel.dart';
import 'panels/response_panel.dart';

class ShowcaseHome extends StatefulWidget {
  final String title;

  const ShowcaseHome({super.key, required this.title});

  @override
  State<ShowcaseHome> createState() => _ShowcaseHomeState();
}

class _ShowcaseHomeState extends State<ShowcaseHome> {
  final Talker _talker = TalkerFlutter.init();
  late Dio _dio;

  // State
  bool _isLoading = false;
  dynamic _responseData;
  String? _error;
  int? _statusCode;
  Duration? _requestDuration;

  @override
  void initState() {
    super.initState();
    _initializeClient();
  }

  Future<void> _initializeClient() async {
    _dio = await acdc.AcdcClientBuilder()
        .withBaseUrl('') // Base URL handled in RequestPanel input
        .withLogDelegate(TalkerLogDelegate(_talker))
        .withLogLevel(acdc.LogLevel.debug) // Capture everything for log panel
        .build();

    _talker.info('ACDC Client Initialized');
  }

  Future<void> _handleSendRequest(
    String method,
    String url,
    Map<String, String> headers,
  ) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _responseData = null;
      _statusCode = null;
      _requestDuration = null;
    });

    final stopwatch = Stopwatch()..start();

    try {
      final options = Options(method: method, headers: headers);

      final response = await _dio.request(url, options: options);
      stopwatch.stop();

      setState(() {
        _responseData = response.data;
        _statusCode = response.statusCode;
        _requestDuration = stopwatch.elapsed;
      });

      _talker.info('Request Success: $method $url', {
        'status': response.statusCode,
        'duration': '${stopwatch.elapsedMilliseconds}ms',
      });
    } on DioException catch (e) {
      stopwatch.stop();
      setState(() {
        _error = e.message;
        if (e.response != null) {
          _responseData = e.response?.data;
          _statusCode = e.response?.statusCode;
        }
        _requestDuration = stopwatch.elapsed;
      });
      _talker.handle(e, StackTrace.current, 'Request Failed: $method $url');
    } catch (e, st) {
      stopwatch.stop();
      setState(() {
        _error = e.toString();
        _requestDuration = stopwatch.elapsed;
      });
      _talker.handle(e, st, 'Unexpected Error');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        scrolledUnderElevation: 2,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive layout:
          // If wide (> 900): 3 panels (Left Col: Req+Resp, Right Col: Logs)
          // If medium (> 600): 2 Columns? Or Stack?
          // For now let's do a simple breakpoint.
          final isWide = constraints.maxWidth > 800;

          if (!isWide) {
            // Mobile/Narrow Layout: Tabs or Single Column
            return DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: 'Request'),
                      Tab(text: 'Response'),
                      Tab(text: 'Logs'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: RequestPanel(onSend: _handleSendRequest),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ResponsePanel(
                            isLoading: _isLoading,
                            responseData: _responseData,
                            error: _error,
                            statusCode: _statusCode,
                            duration: _requestDuration,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: LogPanel(talker: _talker),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          // Desktop/Wide Layout
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      RequestPanel(onSend: _handleSendRequest),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ResponsePanel(
                          isLoading: _isLoading,
                          responseData: _responseData,
                          error: _error,
                          statusCode: _statusCode,
                          duration: _requestDuration,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: LogPanel(talker: _talker)),
              ],
            ),
          );
        },
      ),
    );
  }
}
