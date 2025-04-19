import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tailmate/models/booking.dart';
import 'package:tailmate/models/service.dart';
import 'package:tailmate/models/service_provider_model.dart';
import 'package:tailmate/providers/pet_provider.dart';
import 'package:tailmate/providers/service_provider.dart';
import 'package:tailmate/theme/app_theme.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class ServiceDetailsScreen extends StatefulWidget {
  final Service service;
  final ServiceProviderModel provider;

  const ServiceDetailsScreen({
    Key? key,
    required this.service,
    required this.provider,
  }) : super(key: key);

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedPetId;
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _bookService() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedDate == null || _selectedTime == null || _selectedPetId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all required fields')),
        );
        return;
      }

      final petProvider = Provider.of<PetProvider>(context, listen: false);
      final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
      final pet = petProvider.pets.firstWhere((pet) => pet.id == _selectedPetId);

      final dateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final booking = Booking(
        id: const Uuid().v4(),
        service: widget.service,
        pet: pet,
        dateTime: dateTime,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      serviceProvider.addBooking(booking);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service booked successfully!')),
      );

      Navigator.pop(context);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final finalPrice = widget.service.price * widget.provider.priceMultiplier;
    final pets = Provider.of<PetProvider>(context).pets;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.service.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                ),
                child: Icon(
                  _getServiceIcon(),
                  size: 64,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Provider Info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                        child: Text(
                          widget.provider.name[0],
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.provider.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: AppTheme.greyColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.provider.location,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppTheme.greyColor,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.provider.rating.toString(),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          Text(
                            '(${widget.provider.reviewCount})',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.greyColor,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Service Info
                  Text(
                    widget.service.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.service.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.access_time, color: AppTheme.greyColor),
                      const SizedBox(width: 8),
                      Text(
                        'Duration: ${_formatDuration(widget.service.duration)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.attach_money, color: AppTheme.greyColor),
                      const SizedBox(width: 8),
                      Text(
                        'Price: \$${finalPrice.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Specialties
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.provider.specialties.map((specialty) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          specialty,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  // Booking Form
                  Text(
                    'Book Service',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DropdownButtonFormField<String>(
                          value: _selectedPetId,
                          decoration: const InputDecoration(
                            labelText: 'Select Pet',
                            prefixIcon: Icon(Icons.pets),
                          ),
                          items: pets.map((pet) {
                            return DropdownMenuItem(
                              value: pet.id,
                              child: Text('${pet.name} (${pet.species})'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedPetId = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a pet';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: () => _selectDate(context),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Select Date',
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(
                              _selectedDate == null
                                  ? 'Choose a date'
                                  : DateFormat('MMM dd, yyyy').format(_selectedDate!),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: () => _selectTime(context),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Select Time',
                              prefixIcon: Icon(Icons.access_time),
                            ),
                            child: Text(
                              _selectedTime == null
                                  ? 'Choose a time'
                                  : _selectedTime!.format(context),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _notesController,
                          decoration: const InputDecoration(
                            labelText: 'Additional Notes',
                            prefixIcon: Icon(Icons.note),
                            hintText: 'Any special requirements or instructions',
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _bookService,
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Confirm Booking'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getServiceIcon() {
    switch (widget.service.category.toLowerCase()) {
      case 'walking':
        return Icons.directions_walk;
      case 'sitting':
        return Icons.home;
      case 'grooming':
        return Icons.cut;
      case 'healthcare':
        return Icons.local_hospital;
      default:
        return Icons.pets;
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours > 1 ? 's' : ''}';
    } else {
      return '${duration.inMinutes} minutes';
    }
  }
} 