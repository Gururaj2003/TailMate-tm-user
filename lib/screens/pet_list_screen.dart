import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tailmate/providers/pet_provider.dart';
import 'package:tailmate/screens/pet_form_screen.dart';
import 'package:tailmate/screens/pet_detail_screen.dart';
import 'package:tailmate/theme/app_theme.dart';

class PetListScreen extends StatefulWidget {
  const PetListScreen({super.key});

  @override
  State<PetListScreen> createState() => _PetListScreenState();
}

class _PetListScreenState extends State<PetListScreen> {
  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  Future<void> _loadPets() async {
    try {
      await Provider.of<PetProvider>(context, listen: false).loadPets();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading pets: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PetFormScreen(),
                ),
              );
            },
          ),
        ],
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
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: pet.imageUrl != null
                        ? NetworkImage(pet.imageUrl!)
                        : null,
                    child: pet.imageUrl == null
                        ? const Icon(Icons.pets)
                        : null,
                  ),
                  title: Text(
                    pet.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  subtitle: Text('${pet.species} • ${pet.breed}'),
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
          );
        },
      ),
    );
  }
} 