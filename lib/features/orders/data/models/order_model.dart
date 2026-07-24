import '../../domain/entities/order.dart';

class OrderItemModel extends OrderItem {
  const OrderItemModel({
    required super.name,
    required super.price,
    required super.quantity,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }

  factory OrderItemModel.fromEntity(OrderItem entity) {
    return OrderItemModel(
      name: entity.name,
      price: entity.price,
      quantity: entity.quantity,
    );
  }
}

class OrderModel extends Order {
  final List<OrderItemModel> orderItems;

  const OrderModel({
    required super.id,
    required super.date,
    required this.orderItems,
    required super.total,
    required super.status,
    required super.shippingAddress,
    required super.billingAddress,
    required super.deliveryMethod,
    required super.paymentMethod,
    required super.orderNotes,
  }) : super(items: orderItems);

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final list = json['items'] as List? ?? const [];
    return OrderModel(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      orderItems: list.map((i) => OrderItemModel.fromJson(Map<String, dynamic>.from(i as Map))).toList(),
      total: (json['total'] as num).toDouble(),
      status: json['status'] as String,
      shippingAddress: json['shippingAddress'] as String,
      billingAddress: json['billingAddress'] as String,
      deliveryMethod: json['deliveryMethod'] as String,
      paymentMethod: json['paymentMethod'] as String,
      orderNotes: json['orderNotes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'items': orderItems.map((i) => i.toJson()).toList(),
      'total': total,
      'status': status,
      'shippingAddress': shippingAddress,
      'billingAddress': billingAddress,
      'deliveryMethod': deliveryMethod,
      'paymentMethod': paymentMethod,
      'orderNotes': orderNotes,
    };
  }

  factory OrderModel.fromEntity(Order entity) {
    return OrderModel(
      id: entity.id,
      date: entity.date,
      orderItems: entity.items.map((i) => OrderItemModel.fromEntity(i)).toList(),
      total: entity.total,
      status: entity.status,
      shippingAddress: entity.shippingAddress,
      billingAddress: entity.billingAddress,
      deliveryMethod: entity.deliveryMethod,
      paymentMethod: entity.paymentMethod,
      orderNotes: entity.orderNotes,
    );
  }
}
