import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tailmate/models/booking.dart';
import 'package:tailmate/providers/service_provider.dart';
import 'package:tailmate/theme/app_theme.dart';
import 'package:intl/intl.dart';

class ServicesTab extends StatelessWidget {
  const ServicesTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Bookings'),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Pending (${_getBookingCount(context, BookingStatus.pending)})'),
              Tab(text: 'Confirmed (${_getBookingCount(context, BookingStatus.confirmed)})'),
              Tab(text: 'Completed (${_getBookingCount(context, BookingStatus.completed)})'),
              Tab(text: 'Cancelled (${_getBookingCount(context, BookingStatus.cancelled)})'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _BookingList(status: BookingStatus.pending),
            _BookingList(status: BookingStatus.confirmed),
            _BookingList(status: BookingStatus.completed),
            _BookingList(status: BookingStatus.cancelled),
          ],
        ),
      ),
    );
  }

  int _getBookingCount(BuildContext context, BookingStatus status) {
    final serviceProvider = Provider.of<ServiceProvider>(context);
    return serviceProvider.getBookingsByStatus(status).length;
  }
}

class _BookingList extends StatelessWidget {
  final BookingStatus status;

  const _BookingList({
    Key? key,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceProvider>(
      builder: (context, serviceProvider, child) {
        final bookings = serviceProvider.getBookingsByStatus(status);

        if (bookings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getStatusIcon(),
                  size: 64,
                  color: AppTheme.greyColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'No ${status.toString().split('.').last} bookings',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getServiceIcon(booking.service.category),
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            booking.service.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _buildStatusChip(context, booking.status),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.pets, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          booking.pet.name,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MMM dd, yyyy').format(booking.dateTime),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.access_time, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('hh:mm a').format(booking.dateTime),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    if (booking.notes != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Notes: ${booking.notes}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.greyColor,
                        ),
                      ),
                    ],
                    if (status == BookingStatus.pending) ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              serviceProvider.cancelBooking(booking.id);
                            },
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              serviceProvider.updateBookingStatus(
                                booking.id,
                                BookingStatus.confirmed,
                              );
                            },
                            child: const Text('Confirm'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  IconData _getStatusIcon() {
    switch (status) {
      case BookingStatus.pending:
        return Icons.pending;
      case BookingStatus.confirmed:
        return Icons.check_circle;
      case BookingStatus.completed:
        return Icons.done_all;
      case BookingStatus.cancelled:
        return Icons.cancel;
    }
  }

  IconData _getServiceIcon(String category) {
    switch (category.toLowerCase()) {
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

  Widget _buildStatusChip(BuildContext context, BookingStatus status) {
    Color color;
    switch (status) {
      case BookingStatus.pending:
        color = Colors.orange;
        break;
      case BookingStatus.confirmed:
        color = Colors.blue;
        break;
      case BookingStatus.completed:
        color = Colors.green;
        break;
      case BookingStatus.cancelled:
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toString().split('.').last,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
} 