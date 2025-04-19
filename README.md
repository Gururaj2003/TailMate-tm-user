# TailMate - Pet Care & Service Booking App

TailMate is a modern Flutter mobile application designed for pet owners to discover and book various pet care services. The app provides a beautiful and intuitive interface for managing pet care needs.

## Features

- 🏠 Modern Home Screen with service categories
- 🏥 Vet Appointment Booking
- ✂️ Grooming Services
- 🏨 Pet Boarding
- 🐕 Pet Profile Management
- 💬 In-app Chat Support
- 💳 Payment Processing
- 🗺️ Nearby Services Map
- 🌙 Dark Mode Support
- ⚙️ User Settings & Preferences

## Getting Started

### Prerequisites

- Flutter SDK (latest version)
- Dart SDK (latest version)
- Android Studio / VS Code
- Android/iOS emulator or physical device

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/tailmate.git
```

2. Navigate to the project directory:
```bash
cd tailmate
```

3. Install dependencies:
```bash
flutter pub get
```

4. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart
├── models/
│   ├── pet.dart
│   └── vet_provider.dart
├── providers/
│   └── theme_provider.dart
├── screens/
│   ├── add_pet_screen.dart
│   ├── boarding_screen.dart
│   ├── chat_screen.dart
│   ├── grooming_screen.dart
│   ├── home_screen.dart
│   ├── map_screen.dart
│   ├── payment_screen.dart
│   ├── pet_detail_screen.dart
│   ├── pets_screen.dart
│   ├── profile_screen.dart
│   ├── settings_screen.dart
│   └── vet_appointment_screen.dart
├── theme/
│   └── app_theme.dart
└── widgets/
    ├── provider_card.dart
    └── service_card.dart
```

## Dependencies

- flutter: SDK
- google_fonts: ^6.1.0
- flutter_svg: ^2.0.9
- provider: ^6.1.1
- google_maps_flutter: ^2.5.3
- flutter_animate: ^4.5.0
- cached_network_image: ^3.3.1
- intl: ^0.19.0

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Flutter team for the amazing framework
- All contributors and maintainers
- The pet care community for inspiration 