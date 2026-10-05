import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env', obfuscate: true)
abstract class Env {
  @EnviedField(varName: 'BASE_URL')
  static final String baseUrl = _Env.baseUrl;

  @EnviedField(varName: 'API_KEY')
  static final String apiKey = _Env.apiKey;

  @EnviedField(varName: 'API_PATH')
  static final String apiPath = _Env.apiPath;

  @EnviedField(varName: 'API_MAIN_PATH')
  static final String apiMainPath = _Env.apiMainPath;

  @EnviedField(varName: 'API_AUTH_MAIN_PATH')
  static final String apiAuthMainPath = _Env.apiAuthMainPath;

  @EnviedField(varName: 'API_RPC_PATH')
  static final String apiRPCPath = _Env.apiRPCPath;

  @EnviedField(varName: 'TEST_EMAIL')
  static final String testEmail = _Env.testEmail;

  @EnviedField(varName: 'TEST_PASSWORD')
  static final String testPassword = _Env.testPassword;

}
