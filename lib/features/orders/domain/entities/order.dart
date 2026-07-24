import 'package:equatable/equatable.dart';

class OrderItem extends Equatable {
  final String name;
  final double price;
  final int quantity;

  const OrderItem({
    required this.name,
    required this.price,
    required this.quantity,
  });

  @override
  List<Object?> get props => [name, price, quantity];
}

class Order extends Equatable {
  final String id;
  final DateTime date;
  final List<OrderItem> items;
  final double total;
  final String status;
  final String shippingAddress;
  final String billingAddress;
  final String deliveryMethod;
  final String paymentMethod;
  final String orderNotes;

  const Order({
    required this.id,
    required this.date,
    required this.items,
    required this.total,
    required this.status,
    required this.shippingAddress,
    required this.billingAddress,
    required this.deliveryMethod,
    required this.paymentMethod,
    required this.orderNotes,
  });

  Order copyWith({
    String? id,
    DateTime? date,
    List<OrderItem>? items,
    double? total,
    String? status,
    String? shippingAddress,
    String? billingAddress,
    String? deliveryMethod,
    String? paymentMethod,
    String? orderNotes,
  }) {
    return Order(
      id: id ?? this.id,
      date: date ?? this.date,
      items: items ?? this.items,
      total: total ?? this.total,
      status: status ?? this.status,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      billingAddress: billingAddress ?? this.billingAddress,
      deliveryMethod: deliveryMethod ?? this.deliveryMethod,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      orderNotes: orderNotes ?? this.orderNotes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        date,
        items,
        total,
        status,
        shippingAddress,
        billingAddress,
        deliveryMethod,
        paymentMethod,
        orderNotes,
      ];
}
