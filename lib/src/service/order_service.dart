
import 'package:api/src/data/model/order.dart';

abstract class OrderService {
  Future<List<Order>?> getAll();
  Future<Order?> getById(int id);
  Future<Order?> save(Order order);
  Future<Order?> delete(int id);
  Future<Order?> update(int id, {required Map<String, dynamic> data});
}
