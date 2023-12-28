# Auro Wallet Mobile App

Auro Wallet built with Flutter for mina protocol



### Introduction

Auro Wallet provide one-stop management for mina protocol, convenient staking, and the private key is self-owned.


Auro Wallet is aiming to provide a more convenient entrance of the mina network.

- Friendly UI.
- Secure local accounts storage.
- Intuitive Assets management.
- Simplified staking.
- Available for both iOS and Android.

### Building

#### Dependencies

- `Flutter 2.0.4 statble`
- `Dart 2.12.2`

#### Install Flutter 
`Auro Wallet` is built with [Flutter](https://flutter.dev/), you need to have `Flutter` dev tools
installed on your computer to compile the project. check [Flutter Documentation](https://flutter.dev/docs)
 to learn how to install `Flutter` and initialize a Flutter App.

#### mina sdk
we use flutter ffi and mina c file to derive public key and sign transactions.

### api config 
```lib/common/consts/apiConfig.example.dart``` is a api config for Auro Wallet, you can remove the ```.example ```
and fill your custom api

#### run auro App
```
flutter run --no-sound-null-safety
```
some packages has not migrate to null safety, so we have to add --no-sound-null-safety arguments.


### Contributing for Translation
We are thrilled that you like to contribute to Auro Wallet. Your contribution is essential for keeping Auro Wallet great. We currently have [auro-wallet-mobile-app](https://github.com/aurowallet/auro-wallet-mobile-app) and [auro-wallet-browser-extension](https://github.com/aurowallet/auro-wallet-browser-extension).

#### File structure
Our languages are stored in `lib/l10n` directory. The naming rule of the language is `app_{language_code}.arb` . [language code standard](https://api.flutter.dev/flutter/flutter_localizations/GlobalMaterialLocalizations-class.html).

#### For all people
You can use weblate to add new translations to [Auro Wallet](https://hosted.weblate.org/projects/aurowallet) or update existing translations. if you want to add more languages, please join [telegram](https://t.me/aurowallet) and ping admin.

#### For developer
You need to pull the code from github first, and then switch to the `feature/translate` branch. If you need to update the existing translation, directly edit the content of the target file. If you need to add a new language file, please add a new language file according to the language encoding requirements, such as `app_tr.arb`. After completion, you need to submit a PR to the `feature/translate` branch for merging.