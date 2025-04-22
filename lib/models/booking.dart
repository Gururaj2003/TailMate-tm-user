import 'package:tailmate/models/pet.dart';
import 'package:tailmate/models/service.dart';

enum BookingStatus {
  pending,
  confirmed,
  completed,
  cancelled
}

enum PaymentStatus {
  pending,
  paid,
  refunded
}

class Booking {
  final String id;
  final String userId;
  final String providerId;
  final String serviceId;
  final String petId;
  final DateTime dateTime;
  final BookingStatus status;
  final PaymentStatus paymentStatus;
  final double amount;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Booking({
    required this.id,
    required this.userId,
    required this.providerId,
    required this.serviceId,
    required this.petId,
    required this.dateTime,
    this.status = BookingStatus.pending,
    this.paymentStatus = PaymentStatus.pending,
    required this.amount,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'provider_id': providerId,
      'service_id': serviceId,
      'pet_id': petId,
      'booking_date': dateTime.toIso8601String().split('T')[0],
      'booking_time': dateTime.toIso8601String().split('T')[1].substring(0, 5),
      'status': status.toString().split('.').last,
      'payment_status': paymentStatus.toString().split('.').last,
      'amount': amount,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Booking.fromMap(Map<String, dynamic> map) {
    final date = DateTime.parse(map['booking_date']);
    final time = map['booking_time'].toString().split(':');
    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(time[0]),
      int.parse(time[1]),
    );

    return Booking(
      id: map['id'],
      userId: map['user_id'],
      providerId: map['provider_id'],
      serviceId: map['service_id'],
      petId: map['pet_id'],
      dateTime: dateTime,
      status: BookingStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => BookingStatus.pending,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['payment_status'],
        orElse: () => PaymentStatus.pending,
      ),
      amount: map['amount'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Booking copyWith({
    String? id,
    String? userId,
    String? providerId,
    String? serviceId,
    String? petId,
    DateTime? dateTime,
    BookingStatus? status,
    PaymentStatus? paymentStatus,
    double? amount,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      providerId: providerId ?? this.providerId,
      serviceId: serviceId ?? this.serviceId,
      petId: petId ?? this.petId,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      amount: amount ?? this.amount,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 