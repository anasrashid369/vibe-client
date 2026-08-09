enum Environment { dev, staging, prod }

/// App-wide environment configuration. Values are compiled in via
/// --dart-define, never hardcoded secrets — the BFF owns all secrets,
/// per the spec's "secrets never touch the client" principle.
class EnvConfig {
  const EnvConfig({
    required this.environment,
    required this.bffBaseUrl,
  });

  final Environment environment;
  final String bffBaseUrl;

  factory EnvConfig.fromDartDefines() {
    const envName = String.fromEnvironment('ENV', defaultValue: 'dev');
    const bffBaseUrl = String.fromEnvironment(
      'BFF_BASE_URL',
      // LocalStack API Gateway default — replace per environments/*.tfvars.
      defaultValue: 'http://localhost:4566',
    );

    final environment = switch (envName) {
      'staging' => Environment.staging,
      'prod' => Environment.prod,
      _ => Environment.dev,
    };

    return EnvConfig(environment: environment, bffBaseUrl: bffBaseUrl);
  }
}
