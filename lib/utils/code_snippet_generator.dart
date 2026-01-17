/// Generates live code snippets showing AcdcClientBuilder configuration
/// based on current feature toggle states.
class CodeSnippetGenerator {
  /// Generates the AcdcClientBuilder code snippet based on toggle states.
  ///
  /// Parameters:
  /// - [authEnabled]: Whether authentication is enabled
  /// - [clientId]: The client ID for authentication (used if authEnabled is true)
  /// - [cacheEnabled]: Whether caching is enabled
  /// - [cacheTtl]: Cache TTL in seconds (used if cacheEnabled is true)
  /// - [offlineEnabled]: Whether offline detection is enabled
  static String generateBuilderCode({
    required bool authEnabled,
    required String clientId,
    required bool cacheEnabled,
    required int cacheTtl,
    required bool offlineEnabled,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('final client = await AcdcClientBuilder()');
    buffer.writeln('  .withBaseUrl(\'https://api.example.com\')');

    if (authEnabled && clientId.isNotEmpty) {
      buffer.writeln('  .withTokenProvider(');
      buffer.writeln('    MockTokenProvider(), // Set token: \'$clientId\'');
      buffer.writeln('  )');
    }

    if (cacheEnabled) {
      buffer.writeln('  .withCache(');
      buffer.writeln('    CacheConfig(ttl: Duration(seconds: $cacheTtl)),');
      buffer.writeln('  )');
    }

    if (offlineEnabled) {
      buffer.writeln('  .withOfflineDetection(failFast: true)');
    }

    buffer.writeln('  .withLogDelegate(TalkerLogDelegate(talker))');
    buffer.writeln('  .withLogLevel(LogLevel.debug)');
    buffer.writeln('  .build();');

    return buffer.toString();
  }
}
