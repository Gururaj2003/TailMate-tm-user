import 'package:flutter/material.dart';
import 'package:tailmate/models/pet.dart';
import 'package:intl/intl.dart';

class PetDetailScreen extends StatelessWidget {
  final Pet pet;

  const PetDetailScreen({super.key, required this.pet});

  String _calculateAge(DateTime? birthDate) {
    if (birthDate == null) return 'Unknown';
    final now = DateTime.now();
    final age = now.year - birthDate.year;
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      return (age - 1).toString();
    }
    return age.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pet.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Implement edit functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (pet.imageUrl != null)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    pet.imageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
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
                _buildInfoRow('Weight', pet.weight?.toString() ?? 'Unknown'),
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

  Widget _buildInfoRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
} 