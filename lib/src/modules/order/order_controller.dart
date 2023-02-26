import 'dart:convert';

import 'package:api/src/core/developer/developer.dart';
import 'package:api/src/data/model/order.dart';
import 'package:api/src/service/order_service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class OrderController {
  final OrderService _service;
  OrderController({
    required OrderService service,
  }) : _service = service;

  Future<Response> getAll(Request request) async {
    final orders = await _service.getAll();
    final list = [];
    if (orders != null) {
      for (var order in orders) {
        list.add(order.toMap());
      }
      var body = json.encode(list);
      return Response.ok(body, headers: {'Content-Type': 'text/json'});
    }
    return Response.notFound('Orders not found', headers: {'Content-Type': 'text/json'});
  }

  Future<Response> getById(Request request) async {
    try {
      final id = int.parse(request.params['id'].toString());
      final order = await _service.getById(id);
      if (order != null) {
        return Response.ok(order.toJson(), headers: {'Content-Type': 'text/json'});
      } else {
        return Response.notFound('Order $id not found', headers: {'Content-Type': 'text/json'});
      }
    } catch (e, s) {
      Developer.logError(errorText: 'Error to process', error: e, stackTrace: s, errorName: runtimeType.toString());

      return Response.internalServerError(body: "id not found");
    }
  }

  Future<Response> save(Request request) async {
    final data = await request.readAsString();
    final order = Order.fromJson(data);
    final orderSaved = await _service.save(order);
    if (orderSaved == null) {
      return Response.internalServerError(body: "Error to save");
    }
    return Response.ok(orderSaved.toJson(), headers: {'Content-Type': 'text/json'});
  }

  Future<Response> delete(Request request) async {
    final id = int.parse(request.params['id'].toString());
    final orderDeleted = await _service.delete(id);
    if (orderDeleted == null) {
      return Response.internalServerError(body: "Error to delete");
    }
    return Response.ok(orderDeleted.toJson(), headers: {'Content-Type': 'text/json'});
  }

  Future<Response> update(Request request) async {
    final body = await (request.readAsString());
    final id = int.parse(request.params['id'].toString());
    final order = await _service.update(id, data: json.decode(body));
    return Response.ok(order?.toJson());
  }
}
