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
    print('Creating Booking from map: $map');
    
    DateTime dateTime;
    try {
      if (map['booking_date'] != null && map['booking_time'] != null) {
        final date = DateTime.parse(map['booking_date']);
        final time = map['booking_time'].toString().split(':');
        dateTime = DateTime(
          date.year,
          date.month,
          date.day,
          int.parse(time[0]),
          int.parse(time[1]),
        );
        print('Parsed dateTime from booking_date and booking_time: $dateTime');
      } else {
        print('Warning: booking_date or booking_time is null, using created_at');
        dateTime = DateTime.parse(map['created_at']);
        print('Parsed dateTime from created_at: $dateTime');
      }
    } catch (e) {
      print('Error parsing date/time: $e');
      print('Using current time as fallback');
      dateTime = DateTime.now();
    }

    print('Status from map: ${map['status']}');
    print('Payment status from map: ${map['payment_status']}');

    BookingStatus status;
    try {
      status = BookingStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => BookingStatus.pending,
      );
      print('Parsed status: $status');
    } catch (e) {
      print('Error parsing status: $e');
      status = BookingStatus.pending;
    }

    PaymentStatus paymentStatus;
    try {
      paymentStatus = PaymentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['payment_status'],
        orElse: () => PaymentStatus.pending,
      );
      print('Parsed payment status: $paymentStatus');
    } catch (e) {
      print('Error parsing payment status: $e');
      paymentStatus = PaymentStatus.pending;
    }

    double amount;
    try {
      amount = (map['amount'] as num).toDouble();
      print('Parsed amount: $amount');
    } catch (e) {
      print('Error parsing amount: $e');
      amount = 0.0;
    }

    return Booking(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      providerId: map['provider_id']?.toString() ?? '',
      serviceId: map['service_id']?.toString() ?? '',
      petId: map['pet_id']?.toString() ?? '',
      dateTime: dateTime,
      status: status,
      paymentStatus: paymentStatus,
      amount: amount,
      notes: map['notes']?.toString(),
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