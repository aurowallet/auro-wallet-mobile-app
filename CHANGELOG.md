# Changelog
All notable changes to this project will be documented in this file.


## [Un-Released]
## [2.3.0]
### Enhancements
- Upgrade Flutter version to 3.38.8
- Upgrade Dart version to 3.10.7
- Upgrade dependencies:
  - mobile_scanner: 6.0.10 → 7.1.4
  - fluttertoast: 8.2.12 → 9.0.0
  - permission_handler: 11.4.0 → 12.0.1
  - share_plus: 10.1.4 → 12.0.1
  - styled_text: 8.1.0 → 9.0.0
  - freezed: 2.5.8 → 3.2.4
  - sodium_libs: 3.4.3+2 → 3.4.6+4
- Update deprecated APIs (WillPopScope → PopScope, textScaleFactor → textScaler, etc.)
- Update Android build configuration (AGP 8.7.3, Gradle 8.13, compileSdk 36)
- Support Android 16kb
- Add notification support
- Add test cases to wallet
- Support multi-wallet
- Add integration test
- Ledger process
- Restore process
- Update API of staking APR
- Upgrade network fee config
- Update Advance UI
- Update transaction history fetch
- Refactor token/staking refresh handling
- Biometric authentication improvements
- Password verification page improvements
- App lock improvements
- Support load transaction detail by hash
- Improve transaction password/runtime password handling and prompts
- Improve change-password UX
- Use `Decimal` for staking balance calculations to avoid precision issues
- WebView bridge: propagate JS errors as exceptions to callers (completeError)
- Await seed storage operations to ensure persistence reliability
- Enforce HTTPS-only for custom node URLs across all entry points (add/edit/DApp/API)
- iOS: disable ATS arbitrary loads (`NSAllowsArbitraryLoads`, `NSAllowsArbitraryLoadsInWebContent`, `NSAllowsLocalNetworking` → false)
- Android: disable cleartext HTTP traffic (`usesCleartextTraffic=false`, `network_security_config`)
- Android: exclude all app data from backup and device-transfer (`backup_rules`, `data_extraction_rules`)
- iOS Keychain accessibility tightened to prevent cross-device recovery (ThisDeviceOnly)
- Auto-fallback to Mainnet if current node is insecure HTTP on startup
- Block switching to HTTP custom nodes; show HTTP nodes as disabled (greyed-out with HTTP tag) in node list
- Hide HTTP custom nodes from home page network picker
- Use `Decimal` for transfer/fee conversions to avoid precision/rounding issues

### Fixed
- fetchScamInfo catch
- Token decimal
- TxList amount display
- Fix node URL validation
- Use `BigInt` for token amounts
- Fix WalletConnect bottom-tip dialog context handling


## [2.2.2]
### Enhancements
- Update delegation UI

## [2.2.1]
### Enhancements
- Upgrade mina-signer to 3.1.0
- WalletConnect of iOS
- External URL open

### Fixed
- URL validation

## [2.2.0]
### Enhancements
- Update Applinks URL
- Mnemonic phrase prompt when restore an account
- Open useMaterial3
- Add password verification when closing AppAccess
- Token management item click area
- Update Zeko transaction fee

### Fixed
- The link issue on AboutPage
- PreferencesPage update delay
- AccountName update delay
- AccountManage balance (Zeko)


## [2.1.2]
### Enhancements
- BrowserWrapperPage UI
- Add support for WalletConnect
- Add support for revoke permissions
- Add timed refresh to StakingPage
- Update Zeko network icon
- Update transaction request
- Update Zeko browser link
- Update queryRequestTimeout to 60s
- Add devPage
- Android targetSdkVersion to 35

### Fixed
- Biometric authentication


## [2.1.1]
### Enhancements
- Sort of SendPage address 
- Add refresh after stake
- Upgrade Flutter version to 3.27.3
- Input enhance BrowserSearchPage
- Add support for Android build zkApp

### Fixed
- Staking back router
- Small amount token transfer
- Terms link


## [2.1.0]
- Enhancements
    - Add token support
    - Add App Links(iOS/Android)
    - Add support for Zeko Testnet
    - Upgrade biometric authentication
    - Update transaction history
    - zkApp recommends fee/nonce
    - Remove support for Berkeley network

- Fixed。、，
    - Trans、fer all balance
    - Webview localServer
    - Origin of postMessage


## [2.0.2]    
- Enhancements
    - Website use URL as the default title
    - Upgrade mina-signer to 3.0.7
    - Remove webview_flutter
    - Add support to return signed zk.
    - zkApp approve
    - Upgrade network config
    - Transaction history
- Fixed
    - Nonce issue after zkApp signJsonMessage switch chain
    - Fortmat issue of signJsonMessage
    - Cache load slow
    - zkApp transaction cancel

## [2.0.1]
- Enhancements
    - Tx history sort
    - Tx explorer display
    - Remove unused libs (flutter_switch, flutter_rust_bridge, dio)
- Fixed
    - Crash of iOS version less than 17
    - zkApp without icon connect issue

## [2.0.0]
- Add support for Berkeley network
- Add support for zkApp
- Update Signature to mina-signer-js
- Add language: Russian
- UI enhancements
    - Account Management
    - Network Management
- Bug fixes

## [1.1.9]
- Add language:ukrainian
- Add currency:UAH
- UI enhancements
- Optimize reset wallet

## [1.1.8]
- UI enhancements
- add language:Turkish
- fix txDetail explorer click issue
- update networkPage

## [1.1.7]
- Add internal transfer
- Add transaction speed-up and cancel
- Fix duplicate import
- UI enhancements

## [1.1.6]
- Ledger enhancements
- Optimize Ledger UX
- Bug fix

## [1.1.5]
- Add scam-address match

## [1.0.1]
- fix epoch cache bug
- fix transaction detail status bug

## [1.0.0]
- Transfer
- Delegation
- Account Import
- Mnemonic Support
