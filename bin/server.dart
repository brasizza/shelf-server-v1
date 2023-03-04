import 'dart:io';

import 'package:api/src/core/config.dart';
import 'package:api/src/core/consts.dart';
import 'package:api/src/core/database/database.dart';
import 'package:api/src/core/database/mysql_database.dart';
import 'package:api/src/modules/order/order_route.dart';
import 'package:get_it/get_it.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

void main(List<String> args) async {
  final Env env = Env.i..load();
  GetIt.I.registerSingleton(env);

  final MysqlDatabase mysql = await MysqlDatabase.i.openDatabase(
    {
      'host': env['host'] ?? '',
      'port': env['port'] ?? '',
      'userName': env['userName'] ?? '',
      'password': env['password'] ?? '',
      'databaseName': env['databaseName'] ?? '',
      'secure': env['secure'] ?? '',
    },
  );
  GetIt.I.registerSingleton<Database>(mysql, instanceName: Consts.mysqlInstance);
  final ip = InternetAddress.anyIPv4;
  final Router router = Router();
  router.add('get', '/', _healthCheck);
  final handler = Pipeline().addMiddleware(logRequests()).addHandler(OrderRoute.routes(
        router,
      ));
  final port = int.parse(env['server_port'] ?? '8080');
  final server = await serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}

Response _healthCheck(Request req) {
  return Response.ok('');
}
