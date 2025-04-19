import 'package:flutter/material.dart';
import 'package:tailmate/models/pet.dart';
import 'package:intl/intl.dart';

class PetDetailScreen extends StatelessWidget {
  final Pet pet;

  const PetDetailScreen({super.key, required this.pet});

  String _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    final age = now.difference(birthDate).inDays ~/ 365;
    return age.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pet.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Hero(
                tag: 'pet_${pet.name}',
                child: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  backgroundImage: pet.imageUrl != null ? NetworkImage(pet.imageUrl!) : null,
                  child: pet.imageUrl == null
                      ? Icon(
                          Icons.pets,
                          size: 80,
                          color: Theme.of(context).primaryColor,
                        )
                      : null,
                  radius: 80,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoCard(
              context,
              'Basic Information',
              [
                _buildInfoRow('Species', pet.species),
                _buildInfoRow('Breed', pet.breed),
                _buildInfoRow('Age', '${_calculateAge(pet.birthDate)} years'),
                _buildInfoRow('Weight', '${pet.weight} kg'),
                _buildInfoRow('Gender', pet.gender),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              'Medical History',
              [
                _buildInfoRow('Last Checkup', 'Not available'),
                _buildInfoRow('Vaccinations', 'Not available'),
                _buildInfoRow('Allergies', 'Not available'),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              'Care Instructions',
              [
                _buildInfoRow('Diet', 'Not available'),
                _buildInfoRow('Exercise', 'Not available'),
                _buildInfoRow('Special Needs', 'Not available'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
} 