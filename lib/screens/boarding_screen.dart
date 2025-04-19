import 'package:flutter/material.dart';
import 'package:tailmate/models/vet_provider.dart';
import 'package:tailmate/widgets/provider_card.dart';

class BoardingScreen extends StatelessWidget {
  const BoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<VetProvider> boardingProviders = [
      VetProvider(
        name: 'Happy Tails Boarding',
        rating: 4.8,
        location: '123 Pet Street, City',
        imageUrl: 'https://picsum.photos/206',
        reviews: 145,
      ),
      VetProvider(
        name: 'Pet Paradise Resort',
        rating: 4.9,
        location: '456 Animal Avenue, City',
        imageUrl: 'https://picsum.photos/207',
        reviews: 203,
      ),
      VetProvider(
        name: 'Cozy Paws Hotel',
        rating: 4.7,
        location: '789 Boarding Lane, City',
        imageUrl: 'https://picsum.photos/208',
        reviews: 98,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Boarding'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: boardingProviders.length,
        itemBuilder: (context, index) {
          return ProviderCard(
            provider: boardingProviders[index],
            onBook: () {
              // Navigate to booking screen
            },
          );
        },
      ),
    );
  }
} 