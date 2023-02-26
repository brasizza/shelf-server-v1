// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:api/src/data/model/order.dart';
import 'package:api/src/data/repository/order_repository.dart';

import './order_service.dart';

class OrderServiceImpl implements OrderService {
  final OrderRepository _repository;
  OrderServiceImpl({
    required OrderRepository repository,
  }) : _repository = repository;

  @override
  Future<Order?> delete(int id) async {
    final order = await getById(id);
    if (order == null) {
      return null;
    }

    final deleted = await _repository.delete(id);

    if (!deleted) {
      return null;
    }
    return order;
  }

  @override
  Future<List<Order>?> getAll() async {
    return _repository.getAll();
  }

  @override
  Future<Order?> getById(int id) async {
    return await _repository.getById(id);
  }

  @override
  Future<Order?> save(Order order) async {
    final saved = await _repository.save(order);
    if (saved == null) {
      return null;
    }
    return getById(saved);
  }

  @override
  Future<Order?> update(int id, {required Map<String, dynamic> data}) async {
    final order = await getById(id);
    if (order == null) {
      return null;
    }
    final newOrder = order.updateMap(data).copyWith(updatedAt: DateTime.now());
    final updated = await _repository.update(id, newOrder);
    if (!updated) {
      return null;
    }
    return getById(id);
  }
}
