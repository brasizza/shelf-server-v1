// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:api/src/core/database/database.dart';
import 'package:api/src/data/model/order.dart';

import './order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final Database _database;
  OrderRepositoryImpl({
    required Database database,
  }) : _database = database;

  @override
  Future<List<Order>?> getAll() async {
    final data = await _database.getData("Select * from orders");
    if (data != null) {
      return data.map<Order>((o) => Order.fromMap(o)).toList();
    }
    return null;
  }

  @override
  Future<Order?> getById(int id) async {
    final data = await _database.getUnique("Select * from orders where id = $id");
    if (data != null) {
      return Order.fromMap(data);
    }
    return null;
  }

  @override
  Future<int?> save(Order order) async {
    final data = await _database.insert(
      tableName: 'orders',
      value: order.toDatabase(),
    );
    if (data != 0) {
      return data;
    }
    return null;
  }

  @override
  Future<bool> delete(int id) async {
    final deleted = await _database.delete(
      tableName: 'orders',
      value: {'id': id},
    );
    return deleted;
  }

  @override
  Future<bool> update(int id, Order order) async {
    final updated = await _database.update(tableName: 'orders', value: order.toDatabase());
    return updated;
  }
}
