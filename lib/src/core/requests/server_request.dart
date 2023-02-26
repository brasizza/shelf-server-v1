import 'package:api/src/modules/order/order_route.dart';
import 'package:shelf_router/shelf_router.dart';

class ServerRequest {
  Router load() {
    final router = Router();
    OrderRoute.routes(router);
    return router;
  }
}
