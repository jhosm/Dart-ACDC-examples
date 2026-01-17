import 'package:dart_acdc/dart_acdc.dart' as acdc;
// ignore: implementation_imports
import 'package:dart_acdc/src/extensions/acdc_client_extensions.dart'; // Import for streamRequest
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../logging/talker_log_delegate.dart';
import '../token_provider.dart';
import 'panels/log_panel.dart';
import 'panels/request_panel.dart';
import 'panels/response_panel.dart';
import 'panels/toggles_panel.dart';

class ShowcaseHome extends StatefulWidget {
  final String title;

  const ShowcaseHome({super.key, required this.title});

  @override
  State<ShowcaseHome> createState() => _ShowcaseHomeState();
}

class _ShowcaseHomeState extends State<ShowcaseHome> {
  final Talker _talker = TalkerFlutter.init();
  late Dio _dio;
  late Future<void> _initializationFuture;

  // Shared cache store - persists across client rebuilds
  late final CacheStore _sharedCacheStore;

  // Request/Response State
  bool _isLoading = false;
  dynamic _responseData;
  String? _error;
  int? _statusCode;
  Duration? _requestDuration;
  String? _responseSource;

  // Feature Toggle State
  bool _authEnabled = false;
  String _clientId = '';
  bool _cacheEnabled = false;
  int _cacheTtl = 60;
  bool _offlineEnabled = false;
  bool _deduplicationEnabled = false;
  bool _swrEnabled = false;
  final MockTokenProvider _tokenProvider = MockTokenProvider();

  @override
  void initState() {
    super.initState();
    // Create shared cache store once - persists across rebuilds
    _sharedCacheStore = MemCacheStore(maxSize: 5 * 1024 * 1024); // 5MB
    _initializationFuture = _initializeClient();
  }

  Future<void> _initializeClient() async {
    var builder = acdc.AcdcClientBuilder()
        .withBaseUrl('') // Base URL handled in RequestPanel input
        .withLogDelegate(TalkerLogDelegate(_talker))
        .withLogLevel(acdc.LogLevel.debug); // Capture everything for log panel

    // Apply feature toggles
    if (_authEnabled && _clientId.isNotEmpty) {
      // Set the client ID as a mock token for demonstration
      await _tokenProvider.setTokens(
        accessToken: _clientId,
        accessExpiry: DateTime.now().add(const Duration(hours: 1)),
      );
      builder = builder.withTokenProvider(_tokenProvider);
    }

    if (_cacheEnabled || _swrEnabled) {
      builder = builder
          .withCache(
            acdc.CacheConfig(
              ttl: Duration(seconds: _cacheTtl),
              staleWhileRevalidate: _swrEnabled,
            ),
          )
          .withCacheStore(_sharedCacheStore);
    } else {
      builder = builder.disableCache();
    }

    if (_offlineEnabled) {
      builder = builder.withOfflineDetection(failFast: true);
    }

    if (_deduplicationEnabled) {
      builder = builder.withDeduplication();
    }

    _dio = await builder.build();

    _talker.info('ACDC Client Initialized', {
      'auth': _authEnabled,
      'cache': _cacheEnabled,
      'offline': _offlineEnabled,
      'deduplication': _deduplicationEnabled,
      'swr': _swrEnabled,
    });
  }

  Future<void> _rebuildClient() async {
    _talker.info('Rebuilding ACDC Client due to toggle change');
    await _initializeClient();
  }

  Future<void> _handleSendRequest(
    String method,
    String url,
    Map<String, String> headers,
  ) async {
    // Wait for initialization to complete
    await _initializationFuture;

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

      if (_swrEnabled && method == 'GET') {
        // Demonstrating SWR via streamRequest which is typical for observing cache-then-network
        // Note: Users can still use .request, but streamRequest makes it easy to see the two emissions.

        // We'll just take the LAST emission for this simple panel, but log both.
        // In a real SWR demo, we want to show that we got a cache hit FIRST.
        await for (final response in _dio.streamRequest(
          url,
          options: options,
        )) {
          if (!mounted) break;
          setState(() {
            _responseData = response.data;
            _statusCode = response.statusCode;
            _responseSource = response.extra['acdc_source'] ?? 'unknown';
            // We don't stop stopwatch here because another emission might come
          });

          _talker.info('SWR Emission: $method $url', {
            'status': response.statusCode,
            'source': response.extra['acdc_source'] ?? 'unknown',
          });
        }
        stopwatch.stop();
        setState(() {
          _requestDuration = stopwatch.elapsed;
        });
      } else {
        // Standard request
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
      }
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

  Future<void> _handleFireDuplicateRequests() async {
    // Wait for initialization to complete
    await _initializationFuture;

    if (!mounted) return;

    if (!_deduplicationEnabled) {
      _talker.warning('Enable Deduplication toggle to see effects!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enable Deduplication toggle first!'),
          backgroundColor: Colors.orange,
        ),
      );
      // We proceed anyway to show MULTIPLE requests logging if disabled
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _responseData = null;
      _responseData = null;
      _statusCode = null;
      _responseSource = null;
    });

    _talker.info('Firing 3 simultaneous requests to https://httpbin.org/get');

    final stopwatch = Stopwatch()..start();
    try {
      // Fire 3 requests in parallel
      final responses = await Future.wait([
        _dio.get('https://httpbin.org/get'),
        _dio.get('https://httpbin.org/get'),
        _dio.get('https://httpbin.org/get'),
      ]);

      stopwatch.stop();

      if (!mounted) return;

      setState(() {
        _responseData = {
          'message': 'fired 3 requests',
          'responses': responses.length,
          'deduplication_active': _deduplicationEnabled,
        };
        _statusCode = 200;
        _requestDuration = stopwatch.elapsed;
      });

      _talker.info('Duplicate Requests Finished', {
        'count': responses.length,
        'deduplicated':
            _deduplicationEnabled, // If true, network log should show only 1 actual request
      });
    } catch (e, st) {
      stopwatch.stop();
      setState(() {
        _error = e.toString();
      });
      _talker.handle(e, st);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  CancelToken? _cancelToken;

  Future<void> _handleCancelRequest() async {
    // Wait for initialization to complete
    await _initializationFuture;

    _cancelToken?.cancel('User cancelled previous request');
    _cancelToken = CancelToken();

    setState(() {
      _isLoading = true;
      _error = null;
      _responseData = null;
      _statusCode = null;
    });

    _talker.info('Starting (delay=3s) request... Press Cancel again to abort.');

    try {
      final response = await _dio.get(
        'https://httpbin.org/delay/3',
        cancelToken: _cancelToken,
      );

      if (mounted) {
        setState(() {
          _responseData = response.data;
          _statusCode = response.statusCode;
        });
        _talker.info('Request Completed (Not Cancelled)');
      }
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        if (mounted) {
          setState(() {
            _error = 'Request was correctly cancelled!';
            _responseData = {'status': 'cancelled'};
          });
          _talker.info('Request Cancelled Successfully');
        }
      } else {
        if (mounted) {
          setState(() {
            _error = e.message;
          });
          _talker.handle(e, StackTrace.current);
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleTriggerError() async {
    // Wait for initialization to complete
    await _initializationFuture;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Intentionally bad URL
      await _dio.get('https://httpbin.org/status/401');
    } on DioException catch (e) {
      setState(() {
        _error = 'Triggered Error: ${e.message}';
        _statusCode = e.response?.statusCode;
        _responseData = e.response?.data;
      });
      _talker.error('Caught Expected Error: ${e.message}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
            // Mobile/Narrow Layout: Tabs
            return DefaultTabController(
              length: 4,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: 'Toggles'),
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
                          child: TogglesPanel(
                            authEnabled: _authEnabled,
                            clientId: _clientId,
                            cacheEnabled: _cacheEnabled,
                            cacheTtl: _cacheTtl,
                            offlineEnabled: _offlineEnabled,
                            deduplicationEnabled: _deduplicationEnabled,
                            swrEnabled: _swrEnabled,
                            onAuthToggled: (value) {
                              setState(() => _authEnabled = value);
                              _rebuildClient();
                            },
                            onClientIdChanged: (value) {
                              setState(() => _clientId = value);
                              _rebuildClient();
                            },
                            onCacheToggled: (value) {
                              setState(() => _cacheEnabled = value);
                              _rebuildClient();
                            },
                            onCacheTtlChanged: (value) {
                              setState(() => _cacheTtl = value);
                              _rebuildClient();
                            },
                            onOfflineToggled: (value) {
                              setState(() => _offlineEnabled = value);
                              _rebuildClient();
                            },
                            onDeduplicationToggled: (value) {
                              setState(() => _deduplicationEnabled = value);
                              _rebuildClient();
                            },
                            onSwrToggled: (value) {
                              setState(() => _swrEnabled = value);
                              _rebuildClient();
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: RequestPanel(
                            onSend: _handleSendRequest,
                            onFireDuplicateRequests:
                                _handleFireDuplicateRequests,
                            onCancelRequest: _handleCancelRequest,
                            onTriggerError: _handleTriggerError,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ResponsePanel(
                            isLoading: _isLoading,
                            responseData: _responseData,
                            error: _error,
                            statusCode: _statusCode,
                            duration: _requestDuration,
                            source: _responseSource,
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
                // Left: Toggles Panel
                Expanded(
                  flex: 2,
                  child: TogglesPanel(
                    authEnabled: _authEnabled,
                    clientId: _clientId,
                    cacheEnabled: _cacheEnabled,
                    cacheTtl: _cacheTtl,
                    offlineEnabled: _offlineEnabled,
                    deduplicationEnabled: _deduplicationEnabled,
                    swrEnabled: _swrEnabled,
                    onAuthToggled: (value) {
                      setState(() => _authEnabled = value);
                      _rebuildClient();
                    },
                    onClientIdChanged: (value) {
                      setState(() => _clientId = value);
                      _rebuildClient();
                    },
                    onCacheToggled: (value) {
                      setState(() => _cacheEnabled = value);
                      _rebuildClient();
                    },
                    onCacheTtlChanged: (value) {
                      setState(() => _cacheTtl = value);
                      _rebuildClient();
                    },
                    onOfflineToggled: (value) {
                      setState(() => _offlineEnabled = value);
                      _rebuildClient();
                    },
                    onDeduplicationToggled: (value) {
                      setState(() => _deduplicationEnabled = value);
                      _rebuildClient();
                    },
                    onSwrToggled: (value) {
                      setState(() => _swrEnabled = value);
                      _rebuildClient();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Middle: Request + Response
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      RequestPanel(
                        onSend: _handleSendRequest,
                        onFireDuplicateRequests: _handleFireDuplicateRequests,
                        onCancelRequest: _handleCancelRequest,
                        onTriggerError: _handleTriggerError,
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ResponsePanel(
                          isLoading: _isLoading,
                          responseData: _responseData,
                          error: _error,
                          statusCode: _statusCode,
                          duration: _requestDuration,
                          source: _responseSource,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Right: Logs
                Expanded(flex: 2, child: LogPanel(talker: _talker)),
              ],
            ),
          );
        },
      ),
    );
  }
}
