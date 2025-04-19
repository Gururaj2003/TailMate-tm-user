import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tailmate/providers/pet_provider.dart';
import 'package:tailmate/screens/pet_form_screen.dart';
import 'package:tailmate/theme/app_theme.dart';

class PetListScreen extends StatelessWidget {
  const PetListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pets'),
      ),
      body: Consumer<PetProvider>(
        builder: (context, petProvider, child) {
          final pets = petProvider.pets;

          if (pets.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.pets,
                      size: 64,
                      color: AppTheme.greyColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No pets added yet',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add your first pet by tapping the button below',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.greyColor,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pets.length,
            itemBuilder: (context, index) {
              final pet = pets[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PetFormScreen(pet: pet),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Hero(
                          tag: 'pet_image_${pet.id}',
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                            backgroundImage: pet.imageUrl != null
                                ? NetworkImage(pet.imageUrl!)
                                : null,
                            child: pet.imageUrl == null
                                ? Text(
                                    pet.name[0].toUpperCase(),
                                    style: TextStyle(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pet.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${pet.species} • ${pet.breed}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.greyColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${pet.gender} • ${pet.weight} kg',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.greyColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PetFormScreen(pet: pet),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PetFormScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Pet'),
      ),
    );
  }
} 