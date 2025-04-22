import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tailmate/models/booking.dart';
import 'package:tailmate/models/service.dart';
import 'package:tailmate/models/service_provider_model.dart';
import 'package:tailmate/providers/service_provider.dart';
import 'package:tailmate/theme/app_theme.dart';
import 'package:intl/intl.dart';

class ServicesTab extends StatefulWidget {
  const ServicesTab({super.key});

  @override
  State<ServicesTab> createState() => _ServicesTabState();
}

class _ServicesTabState extends State<ServicesTab> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    print('ServicesTab: Initializing...');
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    if (!mounted) return;
    print('ServicesTab: Starting to load bookings...');
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('ServicesTab: Getting ServiceProvider instance...');
      final serviceProvider = context.read<ServiceProvider>();
      
      print('ServicesTab: Loading bookings from ServiceProvider...');
      await serviceProvider.loadBookings();
      
      print('ServicesTab: Bookings loaded successfully');
      print('ServicesTab: Total bookings: ${serviceProvider.bookings.length}');
      print('ServicesTab: Pending bookings: ${serviceProvider.getBookingsByStatus(BookingStatus.pending).length}');
      print('ServicesTab: Confirmed bookings: ${serviceProvider.getBookingsByStatus(BookingStatus.confirmed).length}');
      
      // Force a rebuild of the UI
      if (mounted) {
        setState(() {});
      }
    } catch (e, stackTrace) {
      print('ServicesTab: Error loading bookings: $e');
      print('ServicesTab: Stack trace: $stackTrace');
      
      String errorMessage = 'Failed to load bookings';
      if (e.toString().contains('No user logged in')) {
        errorMessage = 'Please sign in to view your bookings';
      } else if (e.toString().contains('Unable to connect to the server')) {
        errorMessage = 'Unable to connect to the server. Please check your internet connection';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Please check your internet connection and try again';
      }
      
      if (mounted) {
        setState(() {
          _error = errorMessage;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('ServicesTab: Building UI...');
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Bookings'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                print('ServicesTab: Manual refresh triggered');
                _loadBookings();
              },
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: 'Pending (${_getBookingCount(context, BookingStatus.pending)})'),
              Tab(text: 'Confirmed (${_getBookingCount(context, BookingStatus.confirmed)})'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            print('ServicesTab: Retry button pressed');
                            _loadBookings();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again'),
                        ),
                      ],
                    ),
                  )
                : Consumer<ServiceProvider>(
                    builder: (context, serviceProvider, child) {
                      print('ServicesTab: Consumer rebuild - Total bookings: ${serviceProvider.bookings.length}');
                      return RefreshIndicator(
                        onRefresh: () {
                          print('ServicesTab: Pull to refresh triggered');
                          return _loadBookings();
                        },
                        child: TabBarView(
                          children: [
                            _BookingList(
                              status: BookingStatus.pending,
                              onCancel: (booking) => _cancelBooking(context, booking),
                            ),
                            _BookingList(
                              status: BookingStatus.confirmed,
                              onCancel: (booking) => _cancelBooking(context, booking),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  int _getBookingCount(BuildContext context, BookingStatus status) {
    final serviceProvider = Provider.of<ServiceProvider>(context);
    final count = serviceProvider.getBookingsByStatus(status).length;
    print('ServicesTab: Booking count for $status: $count');
    return count;
  }

  Future<void> _cancelBooking(BuildContext context, Booking booking) async {
    print('ServicesTab: Cancelling booking ${booking.id}');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        print('ServicesTab: Confirmed cancellation, proceeding...');
        await context.read<ServiceProvider>().cancelBooking(booking.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Booking cancelled successfully')),
          );
        }
      } catch (e) {
        print('ServicesTab: Error cancelling booking: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to cancel booking')),
          );
        }
      }
    }
  }
}

class _BookingList extends StatelessWidget {
  final BookingStatus status;
  final Function(Booking) onCancel;

  const _BookingList({
    required this.status,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceProvider>(
      builder: (context, serviceProvider, child) {
        final bookings = serviceProvider.getBookingsByStatus(status);
        print('_BookingList: Building list for $status - Found ${bookings.length} bookings');
        print('_BookingList: All bookings: $bookings');

        if (bookings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  status == BookingStatus.pending ? Icons.pending : Icons.check_circle,
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
            print('_BookingList: Processing booking ${booking.id}');
            print('_BookingList: Booking data: $booking');

            // Get service and provider with null checks
            Service? service;
            ServiceProviderModel? provider;
            try {
              service = serviceProvider.getServiceById(booking.serviceId);
              provider = serviceProvider.getProviderById(booking.providerId);
              print('_BookingList: Found service: ${service?.title}');
              print('_BookingList: Found provider: ${provider?.name}');
            } catch (e) {
              print('_BookingList: Error getting service/provider: $e');
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            service?.title ?? 'Unknown Service',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            status.toString().split('.').last.toUpperCase(),
                            style: TextStyle(
                              color: _getStatusColor(status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider?.name ?? 'Unknown Provider',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
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
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${booking.amount.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        if (status == BookingStatus.pending)
                          TextButton(
                            onPressed: () => onCancel(booking),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Cancel'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.blue;
      case BookingStatus.completed:
        return Colors.green;
      case BookingStatus.cancelled:
        return Colors.red;
    }
  }
} 