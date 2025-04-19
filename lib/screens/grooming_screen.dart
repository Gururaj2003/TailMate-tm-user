import 'package:flutter/material.dart';
import 'package:tailmate/models/vet_provider.dart';
import 'package:tailmate/widgets/provider_card.dart';

class GroomingScreen extends StatelessWidget {
  const GroomingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<VetProvider> groomingServices = [
      VetProvider(
        name: 'Pampered Paws Grooming',
        rating: 4.7,
        location: '123 Pet Street, City',
        imageUrl: 'https://picsum.photos/203',
        reviews: 89,
      ),
      VetProvider(
        name: 'Furry Friends Spa',
        rating: 4.9,
        location: '456 Animal Avenue, City',
        imageUrl: 'https://picsum.photos/204',
        reviews: 112,
      ),
      VetProvider(
        name: 'Pet Beauty Salon',
        rating: 4.5,
        location: '789 Grooming Lane, City',
        imageUrl: 'https://picsum.photos/205',
        reviews: 76,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grooming Services'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: groomingServices.length,
        itemBuilder: (context, index) {
          return ProviderCard(
            provider: groomingServices[index],
            onBook: () {
              // Navigate to booking screen
            },
          );
        },
      ),
    );
  }
} 