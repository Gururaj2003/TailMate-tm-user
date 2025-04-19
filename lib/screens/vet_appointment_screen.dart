import 'package:flutter/material.dart';
import 'package:tailmate/models/vet_provider.dart';
import 'package:tailmate/widgets/provider_card.dart';

class VetAppointmentScreen extends StatelessWidget {
  const VetAppointmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<VetProvider> vetProviders = [
      VetProvider(
        name: 'Happy Paws Veterinary',
        rating: 4.8,
        location: '123 Pet Street, City',
        imageUrl: 'https://picsum.photos/200',
        reviews: 128,
      ),
      VetProvider(
        name: 'Pet Care Clinic',
        rating: 4.6,
        location: '456 Animal Avenue, City',
        imageUrl: 'https://picsum.photos/201',
        reviews: 95,
      ),
      VetProvider(
        name: 'Animal Wellness Center',
        rating: 4.9,
        location: '789 Vet Lane, City',
        imageUrl: 'https://picsum.photos/202',
        reviews: 156,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vet Appointments'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: vetProviders.length,
        itemBuilder: (context, index) {
          return ProviderCard(
            provider: vetProviders[index],
            onBook: () {
              // Navigate to booking screen
            },
          );
        },
      ),
    );
  }
} 