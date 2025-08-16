# Surabhi - Donor Care Cell of Hare Krishna Movement

Surabhi is a comprehensive Flutter mobile application designed for Admins, Employees, Preachers, Approvers, and Volunteers. The app provides tailored experiences and efficient management tools for each user group.

## Features

- Role-based dashboards and navigation
- Secure authentication and session management
- Modular and scalable architecture
- Centralized theming and styling
- Clean code practices using BLoC, Provider, and Dependency Injection

## Quick Start

1. **Clone the Repository**
    ```bash
    git clone https://github.com/praveenkumargurrala/vhkmsurabhi_flutter.git
    cd vhkmsurabhi_flutter
    ```

2. **To run the app on a connected device or emulator:**
    ```bash
    flutter pub get
    flutter pub run build_runner build --delete-conflicting-outputs
    flutter run
    ```

## Project Structure

```bash
surabhi_flutter/
├── lib/                                    # Source code
│   ├── main.dart                           # App entry point
│   ├── injector.dart                       # Dependency Injection
│   ├── assets/                             # Static assets
│   │   ├── images/
│   │   ├── fonts/
│   │   └── icons/
│   ├── core/                               # Core components
│   │   ├── constants/
│   │   │   ├── api_constants.dart
│   │   ├── errors/                         # Error handling
│   │   │   ├── exceptions.dart
│   │   │   └── failure.dart
│   │   ├── network/                        # Network layer
│   │   │   ├── api_client.dart
│   │   │   └── api_interceptor.dart
│   │   └── shared_preferences/             # Local data persistence
│   │   │   ├── preferences_service.dart
│   │   ├── theme/                          # Theming and styling
│   │   │   ├── app_colors.dart
│   │   │   ├── app_themes.dart
│   │   │   └── theme_cubit.dart
│   │   ├── usecases/                       # Business logic
│   │   │   ├── usecase.dart
│   │   └── utils/                          # Utility functions
│   │   │   ├── date_utils.dart
│   │   │   └── string_utils.dart
│   │   │   └── validators.dart
│   │   └── widgets/                        # Shared UI components
│   │   │   ├── app_scaffold.dart
│   │   │   └── role_based_app_bar.dart
│   ├── features/                           # Feature modules
│   │   ├── auth/                           # Authentication module
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   ├── routes/                             # App navigation and routing
│   │   ├── app_router.dart
│   │   └── app_navigator.dart
├── test/                                   # Tests
│   ├── widget_tests/
│   ├── cubit_tests/
│   ├── bloc_tests/
│   └── service_tests/
├── android/                                # Android-specific files
├── ios/                                    # iOS-specific files
├── pubspec.yaml                            # Project dependencies and metadata
├── README.md
├── LICENSE.md
├── CONTRIBUTING.md
├── docs/                                   # Project documentation
│   ├── ARCHITECTURE.md
├── Makefile                                # Build and test automation
```

## Documentation

For a detailed overview of the project architecture, please refer to the [ARCHITECTURE.md](docs/ARCHITECTURE.md) file.

## Theming & Styling

Primary colors are defined in `lib/core/constants/colors.dart` and applied globally via `ThemeData` in `main.dart` for a consistent look and feel.

## Contribution & Code Ownership

We welcome contributions!  
Please read our [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

This project is proprietary software. All rights reserved.  
See the [LICENSE.md](LICENSE.md) file for details.

## Contact

For inquiries or support, please open an [issue](https://github.com/praveenkumargurrala/vhkmsurabhi_flutter/issues) or contact the maintainers via GitHub:

- [@praveenkumargurrala](https://github.com/praveenkumargurrala)
- [@sudama011](https://github.com/sudama011)
- [@Sdcoder123](https://github.com/Sdcoder123)