import 'package:api/src/core/consts.dart';
import 'package:api/src/core/database/database.dart';
import 'package:api/src/data/repository/order_repository.dart';
import 'package:api/src/data/repository/order_repository_impl.dart';
import 'package:api/src/modules/order/order_controller.dart';
import 'package:api/src/service/order_service.dart';
import 'package:api/src/service/order_service_impl.dart';
import 'package:get_it/get_it.dart';
import 'package:shelf_router/shelf_router.dart';

class OrderRoute {
  OrderRoute._();

  static Router routes(Router router) {
    GetIt.I.registerSingleton<OrderRepository>(
      OrderRepositoryImpl(database: GetIt.I.get<Database>(instanceName: Consts.mysqlInstance)),
      instanceName: Consts.orderRepository,
    );

    GetIt.I.registerSingleton<OrderService>(
      OrderServiceImpl(repository: GetIt.I.get<OrderRepository>(instanceName: Consts.orderRepository)),
      instanceName: Consts.orderService,
    );
    final orderController = OrderController(service: GetIt.I.get<OrderService>(instanceName: Consts.orderService));
    router.add('get', '/orders', orderController.getAll);
    router.add('get', '/order/<id>', orderController.getById);
    router.add('post', '/order', orderController.save);
    router.add('put', '/order/<id>', orderController.update);
    router.add('delete', '/order/<id>', orderController.delete);
    return router;
  }
}
