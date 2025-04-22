class _ServicesScreenState extends State<ServicesScreen> {
  @override
  void initState() {
    super.initState();
    print('Initializing ServicesScreen');
    _loadServices();
  }

  Future<void> _loadServices() async {
    try {
      print('Loading services...');
      await context.read<ServiceProvider>().loadServices();
      final services = context.read<ServiceProvider>().services;
      print('Loaded ${services.length} services');
      for (var service in services) {
        print('Service: ${service.title} (ID: ${service.id})');
      }
    } catch (e) {
      print('Error loading services: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Services'),
      ),
      body: Consumer<ServiceProvider>(
        builder: (context, serviceProvider, child) {
          print('Building services list');
          final services = serviceProvider.services;
          print('Found ${services.length} services to display');

          if (services.isEmpty) {
            return const Center(
              child: Text('No services available'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              print('Building service card for: ${service.title}');
              return _ServiceCard(service: service);
            },
          );
        },
      ),
    );
  }
} 