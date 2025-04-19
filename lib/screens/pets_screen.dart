import 'package:flutter/material.dart';
import 'package:tailmate/models/pet.dart';
import 'package:tailmate/screens/pet_detail_screen.dart';

class PetsScreen extends StatelessWidget {
  const PetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for pets
    final List<Pet> pets = [
      Pet(
        name: 'Max',
        type: 'Dog',
        breed: 'Golden Retriever',
        age: 3,
        imageUrl: 'https://picsum.photos/209',
      ),
      Pet(
        name: 'Luna',
        type: 'Cat',
        breed: 'Siamese',
        age: 2,
        imageUrl: 'https://picsum.photos/210',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to add pet screen
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pets.length,
        itemBuilder: (context, index) {
          final pet = pets[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(pet.imageUrl),
                radius: 30,
              ),
              title: Text(
                pet.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              subtitle: Text('${pet.type} • ${pet.breed} • ${pet.age} years'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PetDetailScreen(pet: pet),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
} 