import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tailmate/models/service.dart';
import 'package:tailmate/models/service_provider_model.dart';
import 'package:tailmate/providers/service_provider.dart';
import 'package:tailmate/screens/service_details_screen.dart';
import 'package:tailmate/theme/app_theme.dart';

class ServiceProvidersScreen extends StatefulWidget {
  final Service service;

  const ServiceProvidersScreen({
    Key? key,
    required this.service,
  }) : super(key: key);

  @override
  State<ServiceProvidersScreen> createState() => _ServiceProvidersScreenState();
}

class _ServiceProvidersScreenState extends State<ServiceProvidersScreen> {
  @override
  void initState() {
    super.initState();
    print('Initializing ServiceProvidersScreen for service: ${widget.service.title}');
    _loadProviders();
  }

  Future<void> _loadProviders() async {
    try {
      print('Loading providers for service: ${widget.service.title}');
      await context.read<ServiceProvider>().loadServiceProviders();
      final providers = context.read<ServiceProvider>().getProvidersForService(widget.service.id);
      print('Found ${providers.length} providers for service ${widget.service.title}');
      if (providers.isEmpty) {
        print('No providers found for service ${widget.service.title}');
      } else {
        print('Provider details:');
        for (var provider in providers) {
          print('- ${provider.name} (ID: ${provider.id})');
          print('  Service IDs: ${provider.serviceIds}');
          print('  Specialties: ${provider.specialties}');
        }
      }
    } catch (e) {
      print('Error loading providers: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.service.title} Providers'),
      ),
      body: Consumer<ServiceProvider>(
        builder: (context, serviceProvider, child) {
          print('Building providers list for service: ${widget.service.id}');
          final providers = serviceProvider.getProvidersForService(widget.service.id);
          print('Retrieved ${providers.length} providers for display');

          if (providers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: AppTheme.greyColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No providers available',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please try again later',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.greyColor,
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: providers.length,
            itemBuilder: (context, index) {
              final provider = providers[index];
              return _ProviderCard(
                provider: provider,
                service: widget.service,
              );
            },
          );
        },
      ),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  final ServiceProviderModel provider;
  final Service service;

  const _ProviderCard({
    required this.provider,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    final finalPrice = service.price * provider.priceMultiplier;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ServiceDetailsScreen(
                service: service,
                provider: provider,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (provider.profileImage != null)
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(provider.profileImage!),
                    )
                  else
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      child: Text(
                        provider.name[0],
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
                        Row(
                          children: [
                            Text(
                              provider.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            if (provider.isVerified)
                              const SizedBox(width: 4),
                            if (provider.isVerified)
                              Icon(
                                Icons.verified,
                                size: 16,
                                color: AppTheme.primaryColor,
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          provider.address,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.greyColor,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/chat',
                                arguments: provider,
                              );
                            },
                            icon: Icon(
                              Icons.chat_bubble_outline,
                              size: 20,
                              color: AppTheme.primaryColor,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            tooltip: 'Chat with provider',
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            provider.rating.toString(),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      Text(
                        '(${provider.totalRatings})',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.greyColor,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                provider.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: provider.specialties.map((specialty) {
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
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${finalPrice.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ServiceDetailsScreen(
                            service: service,
                            provider: provider,
                          ),
                        ),
                      );
                    },
                    child: const Text('Book Now'),
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