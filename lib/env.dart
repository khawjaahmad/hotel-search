import 'package:envied/envied.dart';

part 'env.g.dart';

@envied
abstract class Env {
  @EnviedField(varName: 'SERPAPI_API_KEY')
  static const String serpapiApiKey = _Env.serpapiApiKey;
}
