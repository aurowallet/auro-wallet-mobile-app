# Auro Wallet Mobile App

[![Flutter Version](https://img.shields.io/badge/Flutter-3.27.3-blue)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-3.6.1-blue)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android-green)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-yellow)](LICENSE)
[![Tested with BrowserStack](https://img.shields.io/badge/Tested%20with-BrowserStack-brightgreen)](https://www.browserstack.com)

Auro Wallet is a secure and user-friendly mobile application built with Flutter for the Mina Protocol, offering seamless management of digital assets, simplified staking, and self-custody of private keys.

## Introduction

Auro Wallet serves as a convenient gateway to the Mina Protocol, enabling users to manage their assets with ease, stake securely, and maintain full control over their private keys. Designed for both iOS and Android, Auro Wallet combines a friendly user interface with robust security features.

### Key Features
- **Friendly UI**: Intuitive and easy-to-navigate interface for all users.
- **Secure Local Storage**: Private keys are stored securely on the user's device.
- **Intuitive Asset Management**: Simplified tracking and management of Mina Protocol assets.
- **Simplified Staking**: Easy-to-use staking functionality for maximizing rewards.
- **Cross-Platform Support**: Available on both iOS and Android platforms.

## Getting Started

### Prerequisites

To build and run Auro Wallet, ensure you have the following installed:
- **Flutter**: Version 3.27.3 (stable)
- **Dart**: Version 3.6.1
- A compatible IDE (e.g., VS Code, Android Studio)
- A configured development environment for iOS and/or Android

### Installation

1. **Install Flutter**  
   Auro Wallet is built with [Flutter](https://flutter.dev/). Follow the [Flutter Documentation](https://flutter.dev/docs/get-started/install) to install Flutter and set up your development environment.

2. **Clone the Repository**  
   ```bash
   git clone https://github.com/aurowallet/auro-wallet-mobile-app.git
   cd auro-wallet-mobile-app
   ```

3. **Install Dependencies**  
   Run the following command to install all required packages:
   ```bash
   flutter pub get
   ```

### Mina SDK Integration
Auro Wallet uses Flutter FFI (Foreign Function Interface) with Mina's C library to derive public keys and sign transactions. Ensure the Mina SDK is properly configured in your project.

### API Configuration
1. Locate the example API configuration file at `lib/common/consts/apiConfig.example.dart`.
2. Rename it to `apiConfig.dart`:
   ```bash
   mv lib/common/consts/apiConfig.example.dart lib/common/consts/apiConfig.dart
   ```
3. Update the file with your custom API endpoints and settings.

### Running the App
To run Auro Wallet on a connected device or emulator, use:
```bash
flutter run
```
## Contributing

We welcome contributions to Auro Wallet to enhance its functionality and reach. Whether you're a translator or a developer, your efforts help make Auro Wallet better for everyone.

### Repositories
- **Mobile App**: [auro-wallet-mobile-app](https://github.com/aurowallet/auro-wallet-mobile-app)
- **Browser Extension**: [auro-wallet-browser-extension](https://github.com/aurowallet/auro-wallet-browser-extension)

### Translation Contributions

#### For Non-Developers
Help translate Auro Wallet into new languages or improve existing translations using our [Weblate platform](https://hosted.weblate.org/projects/aurowallet). To add a new language, join our [Telegram community](https://t.me/aurowallet) and contact an admin.

#### For Developers
1. Clone the repository and switch to the `feature/translate` branch:
   ```bash
   git clone https://github.com/aurowallet/auro-wallet-mobile-app.git
   cd auro-wallet-mobile-app
   git checkout feature/translate
   ```
2. Translation files are located in the `lib/l10n` directory, named as `app_{language_code}.arb` (e.g., `app_tr.arb` for Turkish). Refer to the [Flutter localization documentation](https://api.flutter.dev/flutter/flutter_localizations/GlobalMaterialLocalizations-class.html) for language code standards.
3. To update an existing translation, edit the corresponding `.arb` file. To add a new language, create a new file (e.g., `app_tr.arb`).
4. Submit a pull request (PR) to the `feature/translate` branch for review.

### General Contribution Guidelines
- Follow the [Code of Conduct](CODE_OF_CONDUCT.md).
- Ensure all changes are tested thoroughly.
- Submit pull requests to the appropriate branch with clear descriptions of changes.

## Sponsor

This project is proudly tested with [BrowserStack](https://www.browserstack.com), ensuring compatibility and performance across devices.

## License

Auro Wallet is licensed under the [MIT License](LICENSE).

## Contact

For questions, feedback, or support:
- Join our [Telegram community](https://t.me/aurowallet).
- Open an issue on [GitHub](https://github.com/aurowallet/auro-wallet-mobile-app/issues).