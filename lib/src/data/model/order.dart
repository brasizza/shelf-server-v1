import 'dart:convert';

import 'package:api/src/enum/order_status.dart';

class Order {
  final int? id;
  final String name;
  final String address;
  final String orderId;
  final double orderTotal;
  final String provider;
  final String orderProviderId;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  Order({
    this.id,
    required this.name,
    required this.address,
    required this.orderId,
    required this.orderTotal,
    required this.provider,
    required this.orderProviderId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  Order copyWith({
    int? id,
    String? name,
    String? address,
    String? orderId,
    double? orderTotal,
    String? provider,
    String? orderProviderId,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Order(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      orderId: orderId ?? this.orderId,
      orderTotal: orderTotal ?? this.orderTotal,
      provider: provider ?? this.provider,
      orderProviderId: orderProviderId ?? this.orderProviderId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'address': address,
      'orderId': orderId,
      'orderTotal': orderTotal,
      'provider': provider,
      'orderProviderId': orderProviderId,
      'status': status.index,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  Map<String, dynamic> toDatabase() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'address': address,
      'order_id': orderId,
      'order_total': orderTotal,
      'provider': provider,
      'order_provider_id': orderProviderId,
      'status': status.index,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: (map['id'] == null) ? null : int.parse(map['id'].toString()),
      name: map['name'] as String,
      address: map['address'] as String,
      orderId: map['order_id'] as String,
      orderTotal: double.parse(map['order_total'].toString()),
      provider: map['provider'] as String,
      orderProviderId: map['order_provider_id'] as String,
      status: OrderStatus.values.firstWhere((orderStatus) => orderStatus.index == int.parse(map['status'].toString()), orElse: () => OrderStatus.iniciado),
      createdAt: (map['created_at'] == null) ? DateTime.now() : DateTime.parse(map['created_at']),
      updatedAt: (map['updated_at'] == null) ? DateTime.now() : DateTime.parse(map['updated_at']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Order.fromJson(String source) => Order.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Order(id: $id, name: $name, address: $address, orderId: $orderId, orderTotal: $orderTotal, provider: $provider, orderProviderId: $orderProviderId, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(covariant Order other) {
    if (identical(this, other)) return true;

    return other.id == id && other.name == name && other.address == address && other.orderId == orderId && other.orderTotal == orderTotal && other.provider == provider && other.orderProviderId == orderProviderId && other.status == status && other.createdAt == createdAt && other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ address.hashCode ^ orderId.hashCode ^ orderTotal.hashCode ^ provider.hashCode ^ orderProviderId.hashCode ^ status.hashCode ^ createdAt.hashCode ^ updatedAt.hashCode;
  }

  Order updateMap(Map<String, dynamic> data) {
    return Order(
      id: id,
      name: data['name'] ?? name,
      address: data['address'] ?? address,
      orderId: data['order_id'] ?? orderId,
      orderTotal: data['order_total'] ?? orderTotal,
      provider: data['provider'] ?? provider,
      orderProviderId: data['order_provider_id'] ?? orderProviderId,
      status: OrderStatus.values.firstWhere((orderStatus) => orderStatus.index == (int.tryParse(data['status'].toString()) ?? status.index), orElse: () => OrderStatus.iniciado),
      createdAt: data['created_at'] ?? createdAt,
      updatedAt: data['updated_at'] ?? updatedAt,
    );
  }
}
