import 'package:tailmate/models/pet.dart';
import 'package:tailmate/models/service.dart';

enum BookingStatus {
  pending,
  confirmed,
  completed,
  cancelled
}

class Booking {
  final String id;
  final Service service;
  final Pet pet;
  final DateTime dateTime;
  final BookingStatus status;
  final String? notes;

  Booking({
    required this.id,
    required this.service,
    required this.pet,
    required this.dateTime,
    this.status = BookingStatus.pending,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serviceId': service.id,
      'petId': pet.id,
      'dateTime': dateTime.toIso8601String(),
      'status': status.toString(),
      'notes': notes,
    };
  }

  factory Booking.fromMap(Map<String, dynamic> map, Service service, Pet pet) {
    return Booking(
      id: map['id'],
      service: service,
      pet: pet,
      dateTime: DateTime.parse(map['dateTime']),
      status: BookingStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => BookingStatus.pending,
      ),
      notes: map['notes'],
    );
  }

  Booking copyWith({
    String? id,
    Service? service,
    Pet? pet,
    DateTime? dateTime,
    BookingStatus? status,
    String? notes,
  }) {
    return Booking(
      id: id ?? this.id,
      service: service ?? this.service,
      pet: pet ?? this.pet,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
} 