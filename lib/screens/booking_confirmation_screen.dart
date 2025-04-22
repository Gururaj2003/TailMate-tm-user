import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tailmate/models/booking.dart';
import 'package:tailmate/models/service.dart';
import 'package:tailmate/models/service_provider_model.dart';
import 'package:tailmate/screens/booking_details_screen.dart';
import 'package:tailmate/theme/app_theme.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final Booking booking;
  final Service service;
  final ServiceProviderModel provider;

  const BookingConfirmationScreen({
    super.key,
    required this.booking,
    required this.service,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Icon
              Icon(
                Icons.check_circle,
                size: 100,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 24),

              // Success Message
              Text(
                'Booking Confirmed!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your booking has been successfully created.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),

              // Booking Summary Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Booking Summary',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      _DetailRow(
                        label: 'Service',
                        value: service.title,
                      ),
                      const SizedBox(height: 8),
                      _DetailRow(
                        label: 'Provider',
                        value: provider.name,
                      ),
                      const SizedBox(height: 8),
                      _DetailRow(
                        label: 'Date',
                        value: DateFormat('MMMM d, y').format(booking.dateTime),
                      ),
                      const SizedBox(height: 8),
                      _DetailRow(
                        label: 'Time',
                        value: DateFormat('h:mm a').format(booking.dateTime),
                      ),
                      const SizedBox(height: 8),
                      _DetailRow(
                        label: 'Amount',
                        value: '\$${booking.amount.toStringAsFixed(2)}',
                      ),
                      if (booking.notes != null) ...[
                        const SizedBox(height: 8),
                        _DetailRow(
                          label: 'Notes',
                          value: booking.notes!,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookingDetailsScreen(
                              booking: booking,
                            ),
                          ),
                        );
                      },
                      child: const Text('View Details'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.popUntil(
                          context,
                          (route) => route.isFirst,
                        );
                      },
                      child: const Text('Back to Home'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
} 