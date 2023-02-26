import 'package:api/src/core/developer/developer.dart';
import 'package:dotenv/dotenv.dart';

class Env {
  static Env? _instance;
  DotEnv? env;

  Env._();

  static Env get i {
    _instance ??= Env._();
    return _instance!;
  }

  void load() {
    env = DotEnv()..load();
    Developer.logInstance(this);
  }

  String? operator [](String key) => env?[key] ?? '';
}
