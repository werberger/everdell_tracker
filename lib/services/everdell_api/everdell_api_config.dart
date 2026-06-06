class EverdellApiConfig {
  static const String productionBaseUrl = 'https://www.budgit.lol';

  static const String baseUrl = String.fromEnvironment(
    'EVERDELL_API_BASE_URL',
    defaultValue: productionBaseUrl,
  );

  static const String apiPrefix = '/api/everdell';
}
