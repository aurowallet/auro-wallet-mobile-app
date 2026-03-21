import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_uk.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('tr'),
    Locale('uk'),
    Locale('zh'),
  ];

  /// No description provided for @passwordError.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password'**
  String get passwordError;

  /// No description provided for @createWallet.
  ///
  /// In en, this message translates to:
  /// **'Create Wallet'**
  String get createWallet;

  /// No description provided for @restoreWallet.
  ///
  /// In en, this message translates to:
  /// **'Restore Wallet'**
  String get restoreWallet;

  /// No description provided for @inputPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get inputPassword;

  /// No description provided for @createPasswordTip.
  ///
  /// In en, this message translates to:
  /// **'The password will be used for identity verification purposes to send transactions in Auro Wallet. Auro Wallet won\'t store the password itself or retrieve it for you. Please keep your password safe.'**
  String get createPasswordTip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @atLeastOneLowercaseLetter.
  ///
  /// In en, this message translates to:
  /// **'lowercase letter'**
  String get atLeastOneLowercaseLetter;

  /// No description provided for @atLeastOneUppercaseLetter.
  ///
  /// In en, this message translates to:
  /// **'uppercase letter'**
  String get atLeastOneUppercaseLetter;

  /// No description provided for @atLeastOneNumber.
  ///
  /// In en, this message translates to:
  /// **'number'**
  String get atLeastOneNumber;

  /// No description provided for @passwordRequires.
  ///
  /// In en, this message translates to:
  /// **'8 characters'**
  String get passwordRequires;

  /// No description provided for @passwordDifferent.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordDifferent;

  /// No description provided for @backTips_1.
  ///
  /// In en, this message translates to:
  /// **'Backup your mnemonic phrase now!'**
  String get backTips_1;

  /// No description provided for @backTips_2.
  ///
  /// In en, this message translates to:
  /// **'The Mnemonic phrase consists of 12 English words, which cannot be retrieved if they are lost. Make sure the mnemonic phrase is kept in a secure location.'**
  String get backTips_2;

  /// No description provided for @backTips_3.
  ///
  /// In en, this message translates to:
  /// **'If the wallet cannot be accessed because the device is lost or for any other reason, importing the mnemonic phrase is the only way to retrieve your assets.'**
  String get backTips_3;

  /// No description provided for @show_seed_content.
  ///
  /// In en, this message translates to:
  /// **'Please write down the following mnemonic phrase and keep it in a safe place.'**
  String get show_seed_content;

  /// No description provided for @show_seed_button.
  ///
  /// In en, this message translates to:
  /// **'Confirmed Backup'**
  String get show_seed_button;

  /// No description provided for @seed_error.
  ///
  /// In en, this message translates to:
  /// **'Incorrect mnemonic phrase'**
  String get seed_error;

  /// No description provided for @backup_success.
  ///
  /// In en, this message translates to:
  /// **'Congrats, You have successfully created a wallet!'**
  String get backup_success;

  /// No description provided for @backup_success_restore.
  ///
  /// In en, this message translates to:
  /// **'Congrats, You have successfully restored a wallet!'**
  String get backup_success_restore;

  /// No description provided for @inputSeed.
  ///
  /// In en, this message translates to:
  /// **'Please enter 12 or 24 mnemonic phrases in order, without capitalization, punctuation symbols.'**
  String get inputSeed;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @wallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// No description provided for @staking.
  ///
  /// In en, this message translates to:
  /// **'Staking'**
  String get staking;

  /// No description provided for @setting.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get setting;

  /// No description provided for @stakingStatus_1.
  ///
  /// In en, this message translates to:
  /// **'Delegated'**
  String get stakingStatus_1;

  /// No description provided for @stakingStatus_2.
  ///
  /// In en, this message translates to:
  /// **'Undelegated'**
  String get stakingStatus_2;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @receive.
  ///
  /// In en, this message translates to:
  /// **'Receive'**
  String get receive;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'HISTORY'**
  String get history;

  /// No description provided for @toAddress.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get toAddress;

  /// No description provided for @fromAddress.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get fromAddress;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @memo.
  ///
  /// In en, this message translates to:
  /// **'Memo(Optional)'**
  String get memo;

  /// No description provided for @memo2.
  ///
  /// In en, this message translates to:
  /// **'Memo'**
  String get memo2;

  /// No description provided for @fee.
  ///
  /// In en, this message translates to:
  /// **'Fee'**
  String get fee;

  /// No description provided for @fee_slow.
  ///
  /// In en, this message translates to:
  /// **'Slow'**
  String get fee_slow;

  /// No description provided for @fee_default.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get fee_default;

  /// No description provided for @fee_fast.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get fee_fast;

  /// No description provided for @advanceMode.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanceMode;

  /// No description provided for @sendDetail.
  ///
  /// In en, this message translates to:
  /// **'Transaction Overview'**
  String get sendDetail;

  /// No description provided for @sendAddressError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid wallet address'**
  String get sendAddressError;

  /// No description provided for @amountError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get amountError;

  /// No description provided for @balanceNotEnough.
  ///
  /// In en, this message translates to:
  /// **'Insufficient Balance'**
  String get balanceNotEnough;

  /// No description provided for @txHash.
  ///
  /// In en, this message translates to:
  /// **'Transaction Hash'**
  String get txHash;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @goToExplrer.
  ///
  /// In en, this message translates to:
  /// **'Query Details'**
  String get goToExplrer;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @walletAddress.
  ///
  /// In en, this message translates to:
  /// **'Wallet Address'**
  String get walletAddress;

  /// No description provided for @copySuccess.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copySuccess;

  /// No description provided for @accountManage.
  ///
  /// In en, this message translates to:
  /// **'Account Management'**
  String get accountManage;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @importLedger.
  ///
  /// In en, this message translates to:
  /// **'Ledger'**
  String get importLedger;

  /// No description provided for @accountName.
  ///
  /// In en, this message translates to:
  /// **'Account Name'**
  String get accountName;

  /// No description provided for @inputAccountName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your account name'**
  String get inputAccountName;

  /// No description provided for @importAccount_2.
  ///
  /// In en, this message translates to:
  /// **'The imported accounts will not be associated with your originally created Auro wallet.'**
  String get importAccount_2;

  /// No description provided for @importAccount_3.
  ///
  /// In en, this message translates to:
  /// **'The imported accounts will be marked with [Imported] in the account list.'**
  String get importAccount_3;

  /// No description provided for @accountInfo.
  ///
  /// In en, this message translates to:
  /// **'Account Details'**
  String get accountInfo;

  /// No description provided for @accountAddress.
  ///
  /// In en, this message translates to:
  /// **'Account Address'**
  String get accountAddress;

  /// No description provided for @exportPrivateKey.
  ///
  /// In en, this message translates to:
  /// **'Export Private Key'**
  String get exportPrivateKey;

  /// No description provided for @accountDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get accountDelete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @privateKeyTip_1.
  ///
  /// In en, this message translates to:
  /// **'The private key consists of a string of characters, and owning the private key is equivalent to owning the asset ownership.'**
  String get privateKeyTip_1;

  /// No description provided for @privateKeyTip_2.
  ///
  /// In en, this message translates to:
  /// **'Once the private key is lost, it cannot be retrieved. Please make sure to backup the private key and keep it in a safe place.'**
  String get privateKeyTip_2;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @network.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get network;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @restoreSeed.
  ///
  /// In en, this message translates to:
  /// **'Backup Mnemonic Phrase'**
  String get restoreSeed;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @inputOldPwd.
  ///
  /// In en, this message translates to:
  /// **'Please enter the <bold>old</bold> password'**
  String get inputOldPwd;

  /// No description provided for @inputNewPwd.
  ///
  /// In en, this message translates to:
  /// **'Please enter the <bold>new</bold> password'**
  String get inputNewPwd;

  /// No description provided for @inputNewPwdRepeat.
  ///
  /// In en, this message translates to:
  /// **'Re-enter the <bold>new</bold> password'**
  String get inputNewPwdRepeat;

  /// No description provided for @pwdChangeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password changed'**
  String get pwdChangeSuccess;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @urlError_1.
  ///
  /// In en, this message translates to:
  /// **'Invalid node URL'**
  String get urlError_1;

  /// No description provided for @urlError_2.
  ///
  /// In en, this message translates to:
  /// **'Address already exists'**
  String get urlError_2;

  /// No description provided for @urlError_3.
  ///
  /// In en, this message translates to:
  /// **'Node address already exists'**
  String get urlError_3;

  /// No description provided for @prompt.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get prompt;

  /// No description provided for @deleteAccountTip.
  ///
  /// In en, this message translates to:
  /// **'A deleted account can only be restored by the Mnemonic Phrase or Private Key. Please make sure you have backed up your Mnemonic Phrase and Private Key.'**
  String get deleteAccountTip;

  /// No description provided for @isee.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get isee;

  /// No description provided for @walletHomeTip.
  ///
  /// In en, this message translates to:
  /// **'The Mina network charges a one-time account creation fee of 1 MINA for spam prevention. It will be automatically deducted from the first transaction received.'**
  String get walletHomeTip;

  /// No description provided for @startHome.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startHome;

  /// No description provided for @walletName.
  ///
  /// In en, this message translates to:
  /// **'Auro Wallet'**
  String get walletName;

  /// No description provided for @privateError.
  ///
  /// In en, this message translates to:
  /// **'Private Key Incorrect'**
  String get privateError;

  /// No description provided for @improtRepeat.
  ///
  /// In en, this message translates to:
  /// **'Do not import repeatedly'**
  String get improtRepeat;

  /// No description provided for @confirmDeleteNode.
  ///
  /// In en, this message translates to:
  /// **'Are you sure to delete it?'**
  String get confirmDeleteNode;

  /// No description provided for @backupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get backupSuccess;

  /// No description provided for @walletAbout.
  ///
  /// In en, this message translates to:
  /// **'Auro Wallet is a non-custodial wallet developed by the community. It is simple, convenient, and fully open source. It currently supports all the functions of the Mina Protocol.'**
  String get walletAbout;

  /// No description provided for @copyTipContent.
  ///
  /// In en, this message translates to:
  /// **'Copying the private key is risky, and the clipboard is easily monitored and stolen by third-party applications.'**
  String get copyTipContent;

  /// No description provided for @copyTipContent2.
  ///
  /// In en, this message translates to:
  /// **'Please ensure that the system and network environment you are using is absolutely safe before performing this operation.'**
  String get copyTipContent2;

  /// No description provided for @copyConfirm.
  ///
  /// In en, this message translates to:
  /// **'Copy Anyway'**
  String get copyConfirm;

  /// No description provided for @copyCancel.
  ///
  /// In en, this message translates to:
  /// **'Stop Copying'**
  String get copyCancel;

  /// No description provided for @scantopay.
  ///
  /// In en, this message translates to:
  /// **'Scan to pay me'**
  String get scantopay;

  /// No description provided for @addressQrTip.
  ///
  /// In en, this message translates to:
  /// **'Scan the QR code and transfer <strongBlack>{symbol}</strongBlack> to it'**
  String addressQrTip(String symbol);

  /// No description provided for @goToExplorer.
  ///
  /// In en, this message translates to:
  /// **'Check more transaction history'**
  String get goToExplorer;

  /// No description provided for @homeNoTx.
  ///
  /// In en, this message translates to:
  /// **'Unknown node, unable to provide history.'**
  String get homeNoTx;

  /// No description provided for @followUs.
  ///
  /// In en, this message translates to:
  /// **'Follow Us'**
  String get followUs;

  /// No description provided for @createPassword.
  ///
  /// In en, this message translates to:
  /// **'Create Password'**
  String get createPassword;

  /// No description provided for @epochInfo.
  ///
  /// In en, this message translates to:
  /// **'Epoch Info'**
  String get epochInfo;

  /// No description provided for @delegationInfo.
  ///
  /// In en, this message translates to:
  /// **'Delegation Info'**
  String get delegationInfo;

  /// No description provided for @emptyDelegateTitle.
  ///
  /// In en, this message translates to:
  /// **'You have not yet delegated'**
  String get emptyDelegateTitle;

  /// No description provided for @emptyDelegateDesc1.
  ///
  /// In en, this message translates to:
  /// **'Delegating MINA to the Block Producer node can help you obtain rewards for producing blocks. The Block Producer will distribute the rewards according to your delegated proportion, and the percentage of rewards depends on the rate setting by the Block Producer.'**
  String get emptyDelegateDesc1;

  /// No description provided for @emptyDelegateDesc2.
  ///
  /// In en, this message translates to:
  /// **'Effective time of delegating and rewards distributing rules:'**
  String get emptyDelegateDesc2;

  /// No description provided for @emptyDelegateDesc3.
  ///
  /// In en, this message translates to:
  /// **'Staking Guide'**
  String get emptyDelegateDesc3;

  /// No description provided for @changeNode.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get changeNode;

  /// No description provided for @stakingProviderName.
  ///
  /// In en, this message translates to:
  /// **'Block Producer'**
  String get stakingProviderName;

  /// No description provided for @goStake.
  ///
  /// In en, this message translates to:
  /// **'Go to staking'**
  String get goStake;

  /// No description provided for @epochEndTime.
  ///
  /// In en, this message translates to:
  /// **'Current epoch end in'**
  String get epochEndTime;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Block Producer name or address'**
  String get searchPlaceholder;

  /// No description provided for @inputNodeAddress.
  ///
  /// In en, this message translates to:
  /// **'Please input node provider address'**
  String get inputNodeAddress;

  /// No description provided for @nodeProviders.
  ///
  /// In en, this message translates to:
  /// **'Block Producer'**
  String get nodeProviders;

  /// No description provided for @manualAdd.
  ///
  /// In en, this message translates to:
  /// **'Input Block Producer address'**
  String get manualAdd;

  /// No description provided for @providerAddress.
  ///
  /// In en, this message translates to:
  /// **'BP Address'**
  String get providerAddress;

  /// No description provided for @copyToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy to Clipboard'**
  String get copyToClipboard;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @keystoreError.
  ///
  /// In en, this message translates to:
  /// **'Keystore contents or password is incorrect'**
  String get keystoreError;

  /// No description provided for @pleaseInputKeyPair.
  ///
  /// In en, this message translates to:
  /// **'Please enter the contents of the Keystore file.'**
  String get pleaseInputKeyPair;

  /// No description provided for @pleaseInputKeyPairPwd.
  ///
  /// In en, this message translates to:
  /// **'Keystore Password'**
  String get pleaseInputKeyPairPwd;

  /// No description provided for @pleaseInputPriKey.
  ///
  /// In en, this message translates to:
  /// **'Please enter Private Key.'**
  String get pleaseInputPriKey;

  /// No description provided for @privateKey.
  ///
  /// In en, this message translates to:
  /// **'Private Key'**
  String get privateKey;

  /// No description provided for @applied.
  ///
  /// In en, this message translates to:
  /// **'APPLIED'**
  String get applied;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'FAILED'**
  String get failed;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get pending;

  /// No description provided for @blockProducerName.
  ///
  /// In en, this message translates to:
  /// **'Block Producer Name'**
  String get blockProducerName;

  /// No description provided for @producerName.
  ///
  /// In en, this message translates to:
  /// **'Block Producer Name'**
  String get producerName;

  /// No description provided for @blockProducerAddress.
  ///
  /// In en, this message translates to:
  /// **'Block Producer Address'**
  String get blockProducerAddress;

  /// No description provided for @notValidAddress.
  ///
  /// In en, this message translates to:
  /// **'Not valid MINA address'**
  String get notValidAddress;

  /// No description provided for @agree.
  ///
  /// In en, this message translates to:
  /// **'Agree'**
  String get agree;

  /// No description provided for @userAgree.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get userAgree;

  /// No description provided for @imported.
  ///
  /// In en, this message translates to:
  /// **'Imported'**
  String get imported;

  /// No description provided for @watchAccount.
  ///
  /// In en, this message translates to:
  /// **'Watch Account'**
  String get watchAccount;

  /// No description provided for @watchMode.
  ///
  /// In en, this message translates to:
  /// **'Watch Mode'**
  String get watchMode;

  /// No description provided for @textWatchModeAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter or paste wallet address'**
  String get textWatchModeAddress;

  /// No description provided for @watchLabel.
  ///
  /// In en, this message translates to:
  /// **'Watch'**
  String get watchLabel;

  /// No description provided for @timeout.
  ///
  /// In en, this message translates to:
  /// **'Request Timeout'**
  String get timeout;

  /// No description provided for @rootTip.
  ///
  /// In en, this message translates to:
  /// **'Detected that the system has been Root or using the simulator. Continue to use there will be risks!'**
  String get rootTip;

  /// No description provided for @exitConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to exit the App?'**
  String get exitConfirm;

  /// No description provided for @unlockBioEnable.
  ///
  /// In en, this message translates to:
  /// **'Biometric Authentication'**
  String get unlockBioEnable;

  /// No description provided for @unlockBio.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to unlock'**
  String get unlockBio;

  /// No description provided for @feeTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Fees are much higher than average'**
  String get feeTooLarge;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @addressbook.
  ///
  /// In en, this message translates to:
  /// **'Address Book'**
  String get addressbook;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @repeatContact.
  ///
  /// In en, this message translates to:
  /// **'Address exists'**
  String get repeatContact;

  /// No description provided for @backupInOrder.
  ///
  /// In en, this message translates to:
  /// **'To ensure you have backed up the Mnemonic Phrase, please tap the 12 words in order.'**
  String get backupInOrder;

  /// No description provided for @refuse.
  ///
  /// In en, this message translates to:
  /// **'Refuse'**
  String get refuse;

  /// No description provided for @termsDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms and Privacy Policy'**
  String get termsDialogTitle;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// No description provided for @restoreTip.
  ///
  /// In en, this message translates to:
  /// **'If you want to import private key/keystore or connect Ledger, need to [Create Wallet] or [Restore Wallet] first.'**
  String get restoreTip;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @resetWarnContentTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset your wallet?'**
  String get resetWarnContentTitle;

  /// No description provided for @resetWarnContent.
  ///
  /// In en, this message translates to:
  /// **'After resetting you existing wallet all the data will be lost. You can only use the mnemonic phrase to restore. Please ensure you have backed-up the mnemonic phrase before you reset the wallet.'**
  String get resetWarnContent;

  /// No description provided for @confirmReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get confirmReset;

  /// No description provided for @cancelReset.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelReset;

  /// No description provided for @deleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Type \'{tag}\' to erase current wallet permanently'**
  String deleteConfirm(String tag);

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @watchModeWarn2.
  ///
  /// In en, this message translates to:
  /// **'Auro Wallet no longer support the [Watch Account] , you need to <red>delete all watch accounts</red> before you can continue to use.'**
  String get watchModeWarn2;

  /// No description provided for @deleteWatch.
  ///
  /// In en, this message translates to:
  /// **'Delete watch account'**
  String get deleteWatch;

  /// No description provided for @allTransfer.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get allTransfer;

  /// No description provided for @noMoreSupported.
  ///
  /// In en, this message translates to:
  /// **'No longer supported account'**
  String get noMoreSupported;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPasswordShort.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordShort;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @mnemonicLost.
  ///
  /// In en, this message translates to:
  /// **'If mnemonic phrase lost, my funds will be lost forever.'**
  String get mnemonicLost;

  /// No description provided for @protectMnemonic.
  ///
  /// In en, this message translates to:
  /// **'I take full responsibility for protecting the mnemonic.'**
  String get protectMnemonic;

  /// No description provided for @scam.
  ///
  /// In en, this message translates to:
  /// **'scam'**
  String get scam;

  /// No description provided for @hdDerivedPath.
  ///
  /// In en, this message translates to:
  /// **'HD Path'**
  String get hdDerivedPath;

  /// No description provided for @emptyAddress.
  ///
  /// In en, this message translates to:
  /// **'No addresses saved'**
  String get emptyAddress;

  /// No description provided for @speedUp.
  ///
  /// In en, this message translates to:
  /// **'Speed Up'**
  String get speedUp;

  /// No description provided for @speedUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Speed Up Transaction'**
  String get speedUpTitle;

  /// No description provided for @cancelTransaction.
  ///
  /// In en, this message translates to:
  /// **'Cancel Transaction'**
  String get cancelTransaction;

  /// No description provided for @speedUpTip.
  ///
  /// In en, this message translates to:
  /// **'Normally, a transaction takes <light>3 minutes</light> to confirm. However, when the network is congested and your transaction may take longer than 3 minutes or more, you can speed up the transaction process by increasing the transaction fee.'**
  String get speedUpTip;

  /// No description provided for @transactionCancelTip.
  ///
  /// In en, this message translates to:
  /// **'Cancel the transaction by sending a transaction with the same Nonce to yourself address. The fee will be greater than the current transaction fee (+0.0001 MINA) .'**
  String get transactionCancelTip;

  /// No description provided for @currentFee.
  ///
  /// In en, this message translates to:
  /// **'Current Fee'**
  String get currentFee;

  /// No description provided for @stakedBalance.
  ///
  /// In en, this message translates to:
  /// **'Staked'**
  String get stakedBalance;

  /// No description provided for @testnet.
  ///
  /// In en, this message translates to:
  /// **'Testnet'**
  String get testnet;

  /// No description provided for @myWallet.
  ///
  /// In en, this message translates to:
  /// **'My Wallet'**
  String get myWallet;

  /// No description provided for @renameAccountName.
  ///
  /// In en, this message translates to:
  /// **'Change Account Name'**
  String get renameAccountName;

  /// No description provided for @accountNameLimit.
  ///
  /// In en, this message translates to:
  /// **'No more than 16 characters'**
  String get accountNameLimit;

  /// No description provided for @github.
  ///
  /// In en, this message translates to:
  /// **'Check it out on Github'**
  String get github;

  /// No description provided for @noAddress.
  ///
  /// In en, this message translates to:
  /// **'No Address'**
  String get noAddress;

  /// No description provided for @addaddress.
  ///
  /// In en, this message translates to:
  /// **'Add Address'**
  String get addaddress;

  /// No description provided for @editaddress.
  ///
  /// In en, this message translates to:
  /// **'Edit Address'**
  String get editaddress;

  /// No description provided for @deleteaddress.
  ///
  /// In en, this message translates to:
  /// **'Delete Address?'**
  String get deleteaddress;

  /// No description provided for @addNetWork.
  ///
  /// In en, this message translates to:
  /// **'Add Network'**
  String get addNetWork;

  /// No description provided for @editNetWork.
  ///
  /// In en, this message translates to:
  /// **'Edit Network'**
  String get editNetWork;

  /// No description provided for @nodeAddress.
  ///
  /// In en, this message translates to:
  /// **'Node URL'**
  String get nodeAddress;

  /// No description provided for @nodeAlert.
  ///
  /// In en, this message translates to:
  /// **'Only add custom nodes you trust. Using unknown nodes can be risky.'**
  String get nodeAlert;

  /// No description provided for @invalidContact.
  ///
  /// In en, this message translates to:
  /// **'Invalid address'**
  String get invalidContact;

  /// No description provided for @submitNode.
  ///
  /// In en, this message translates to:
  /// **'Submit/Update your node to this list'**
  String get submitNode;

  /// No description provided for @ledgerTip1.
  ///
  /// In en, this message translates to:
  /// **'Connect your Ledger to the phone.'**
  String get ledgerTip1;

  /// No description provided for @ledgerTip2.
  ///
  /// In en, this message translates to:
  /// **'Open the Mina app in your Ledger device, Until you see <bold>Mina is ready</bold>.'**
  String get ledgerTip2;

  /// No description provided for @ledgerTip3.
  ///
  /// In en, this message translates to:
  /// **'Select a hardware wallet you‘d like to use with Auro Wallet.'**
  String get ledgerTip3;

  /// No description provided for @connectHardwareWallet.
  ///
  /// In en, this message translates to:
  /// **'Connect Hardware Wallet'**
  String get connectHardwareWallet;

  /// No description provided for @selectHdPath.
  ///
  /// In en, this message translates to:
  /// **'Select HD Path'**
  String get selectHdPath;

  /// No description provided for @ledgerStatus.
  ///
  /// In en, this message translates to:
  /// **'Ledger Status'**
  String get ledgerStatus;

  /// No description provided for @ledgerAddressTip1.
  ///
  /// In en, this message translates to:
  /// **'Please continue the follow-up operation according to the prompt of the Ledger hardware wallet.'**
  String get ledgerAddressTip1;

  /// No description provided for @ledgerAddressTip3.
  ///
  /// In en, this message translates to:
  /// **'<lightred>Do not close this window.</lightred> Once the Ledger is complete, the page will redirect automatically.'**
  String get ledgerAddressTip3;

  /// No description provided for @waitingLedger.
  ///
  /// In en, this message translates to:
  /// **'Waiting for confirmation…'**
  String get waitingLedger;

  /// No description provided for @waitingLedgerSign.
  ///
  /// In en, this message translates to:
  /// **'Please confirm in the Ledger hardware wallet, the signature may take 1-3 minutes.'**
  String get waitingLedgerSign;

  /// No description provided for @openMinaApp.
  ///
  /// In en, this message translates to:
  /// **'Ledger device is connected, but Mina app is not open. Please open Mina app in Ledger.'**
  String get openMinaApp;

  /// No description provided for @unlockLedger.
  ///
  /// In en, this message translates to:
  /// **'Failed to connect. Please make sure your Ledger device is unlocked.'**
  String get unlockLedger;

  /// No description provided for @ledgerReject.
  ///
  /// In en, this message translates to:
  /// **'Rejected by Ledger'**
  String get ledgerReject;

  /// No description provided for @ledgerSearching.
  ///
  /// In en, this message translates to:
  /// **'Searching…'**
  String get ledgerSearching;

  /// No description provided for @ledgerSupport.
  ///
  /// In en, this message translates to:
  /// **'(<lightred>Only support Ledger Nano X</lightred>)'**
  String get ledgerSupport;

  /// No description provided for @termsAndPrivacy_line1.
  ///
  /// In en, this message translates to:
  /// **'This service is provided by Auro Wallet, please take time to read carefully and understand the Terms and Conditions and Privacy Policy.'**
  String get termsAndPrivacy_line1;

  /// No description provided for @termsAndPrivacy_line2.
  ///
  /// In en, this message translates to:
  /// **'Please read the <conditions>Terms and Conditions</conditions> and <policy>Privacy Policy</policy> carefully. If you understand fully and agree, please click [Agree] to start using this wallet service.'**
  String get termsAndPrivacy_line2;

  /// No description provided for @contributeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Contribute Language'**
  String get contributeLanguage;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @importSameAccount_1.
  ///
  /// In en, this message translates to:
  /// **'The address of the account to be created is: <theme>{address}</theme>'**
  String importSameAccount_1(String address);

  /// No description provided for @importSameAccount_2.
  ///
  /// In en, this message translates to:
  /// **'An existing imported account [{accountName}] is a duplicate of this address. Auro Wallet does not support the creation of duplicate account addresses. Please go to the <acmanage>Account Management</acmanage> to delete the imported account.'**
  String importSameAccount_2(String accountName);

  /// No description provided for @browser.
  ///
  /// In en, this message translates to:
  /// **'Browser'**
  String get browser;

  /// No description provided for @searchOrInputUrl.
  ///
  /// In en, this message translates to:
  /// **'Search or input URL'**
  String get searchOrInputUrl;

  /// No description provided for @allowSiteAddNode.
  ///
  /// In en, this message translates to:
  /// **'Allow this site to add a network'**
  String get allowSiteAddNode;

  /// No description provided for @removeFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFavorites;

  /// No description provided for @addFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get addFavorites;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get copyLink;

  /// No description provided for @openInBrowser.
  ///
  /// In en, this message translates to:
  /// **'Open in browser'**
  String get openInBrowser;

  /// No description provided for @connectionRequest.
  ///
  /// In en, this message translates to:
  /// **'Connection Request'**
  String get connectionRequest;

  /// No description provided for @connectTip.
  ///
  /// In en, this message translates to:
  /// **'This website would like to view account'**
  String get connectTip;

  /// No description provided for @trustedSitesTip.
  ///
  /// In en, this message translates to:
  /// **'Make sure you only connect to trusted sites'**
  String get trustedSitesTip;

  /// No description provided for @signatureRequest.
  ///
  /// In en, this message translates to:
  /// **'Signature Request'**
  String get signatureRequest;

  /// No description provided for @content.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get content;

  /// No description provided for @transactionFee.
  ///
  /// In en, this message translates to:
  /// **'Transaction Fee'**
  String get transactionFee;

  /// No description provided for @siteSuggested.
  ///
  /// In en, this message translates to:
  /// **'Site suggested'**
  String get siteSuggested;

  /// No description provided for @rawData.
  ///
  /// In en, this message translates to:
  /// **'Raw data'**
  String get rawData;

  /// No description provided for @showData.
  ///
  /// In en, this message translates to:
  /// **'Show data'**
  String get showData;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'WARNING'**
  String get warning;

  /// No description provided for @warningTip.
  ///
  /// In en, this message translates to:
  /// **'You are interacting with an address or contract that has been flagged as scam. If you sign, you could lose access to all of your NFTs and any funds or other assets in your wallet.'**
  String get warningTip;

  /// No description provided for @switchNetwork.
  ///
  /// In en, this message translates to:
  /// **'Switch Network'**
  String get switchNetwork;

  /// No description provided for @allowSwitch.
  ///
  /// In en, this message translates to:
  /// **'Allow this site to switch the network?'**
  String get allowSwitch;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target;

  /// No description provided for @recently.
  ///
  /// In en, this message translates to:
  /// **'Recently'**
  String get recently;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @browserEmptyTip.
  ///
  /// In en, this message translates to:
  /// **'Your favorites and history will show up here'**
  String get browserEmptyTip;

  /// No description provided for @websiteNotFound.
  ///
  /// In en, this message translates to:
  /// **'Website Not Found'**
  String get websiteNotFound;

  /// No description provided for @ledgerNotSupportSign.
  ///
  /// In en, this message translates to:
  /// **'Ledger doesn\'t support sign message'**
  String get ledgerNotSupportSign;

  /// No description provided for @notSupportNow.
  ///
  /// In en, this message translates to:
  /// **'Not supported yet'**
  String get notSupportNow;

  /// No description provided for @newFee.
  ///
  /// In en, this message translates to:
  /// **'New Fee'**
  String get newFee;

  /// No description provided for @addAccount.
  ///
  /// In en, this message translates to:
  /// **'Add Account'**
  String get addAccount;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @hardwareWallet.
  ///
  /// In en, this message translates to:
  /// **'Hardware Wallet'**
  String get hardwareWallet;

  /// No description provided for @showTestnet.
  ///
  /// In en, this message translates to:
  /// **'Show Testnet'**
  String get showTestnet;

  /// No description provided for @ledgerConnected.
  ///
  /// In en, this message translates to:
  /// **'Ledger Connected'**
  String get ledgerConnected;

  /// No description provided for @ledgerNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Ledger not Connected'**
  String get ledgerNotConnected;

  /// No description provided for @txType.
  ///
  /// In en, this message translates to:
  /// **'Transaction Type'**
  String get txType;

  /// No description provided for @appConnection.
  ///
  /// In en, this message translates to:
  /// **'App Connections'**
  String get appConnection;

  /// No description provided for @noConnectedApps.
  ///
  /// In en, this message translates to:
  /// **'No connected Apps'**
  String get noConnectedApps;

  /// No description provided for @txHistoryTip.
  ///
  /// In en, this message translates to:
  /// **'Unable to provide transaction history'**
  String get txHistoryTip;

  /// No description provided for @tokens.
  ///
  /// In en, this message translates to:
  /// **'TOKENS'**
  String get tokens;

  /// No description provided for @assetManagement.
  ///
  /// In en, this message translates to:
  /// **'Asset Management'**
  String get assetManagement;

  /// No description provided for @newTokenFound.
  ///
  /// In en, this message translates to:
  /// **'{count} new tokens found'**
  String newTokenFound(String count);

  /// No description provided for @ignore.
  ///
  /// In en, this message translates to:
  /// **'Ignore'**
  String get ignore;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @updateTokenInfo.
  ///
  /// In en, this message translates to:
  /// **'Update your token information?'**
  String get updateTokenInfo;

  /// No description provided for @noTxHistory.
  ///
  /// In en, this message translates to:
  /// **'No transaction history'**
  String get noTxHistory;

  /// No description provided for @buildFailed.
  ///
  /// In en, this message translates to:
  /// **'Packaging failed'**
  String get buildFailed;

  /// No description provided for @appAccess.
  ///
  /// In en, this message translates to:
  /// **'App Access'**
  String get appAccess;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @unlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// No description provided for @useBiometricAuthentication.
  ///
  /// In en, this message translates to:
  /// **'Use Biometric Authentication'**
  String get useBiometricAuthentication;

  /// No description provided for @loginWithPassword.
  ///
  /// In en, this message translates to:
  /// **'Login with Password'**
  String get loginWithPassword;

  /// No description provided for @clickToVerification.
  ///
  /// In en, this message translates to:
  /// **'Click to start verification'**
  String get clickToVerification;

  /// No description provided for @resetWallet.
  ///
  /// In en, this message translates to:
  /// **'Reset Wallet'**
  String get resetWallet;

  /// No description provided for @biometricAuth.
  ///
  /// In en, this message translates to:
  /// **'Biometric Auth'**
  String get biometricAuth;

  /// No description provided for @tapToVerify.
  ///
  /// In en, this message translates to:
  /// **'Tap to verify'**
  String get tapToVerify;

  /// No description provided for @zkAppTipTitle.
  ///
  /// In en, this message translates to:
  /// **'You are visiting a third-party zkApp'**
  String get zkAppTipTitle;

  /// No description provided for @zkAppTipContent.
  ///
  /// In en, this message translates to:
  /// **'You are a subiect to third-party zkApp‘s User Agreement when entering this zkApp.'**
  String get zkAppTipContent;

  /// No description provided for @passwordVerification.
  ///
  /// In en, this message translates to:
  /// **'Password Verification'**
  String get passwordVerification;

  /// No description provided for @pwdVerificationTip.
  ///
  /// In en, this message translates to:
  /// **'At least one option must be selected.'**
  String get pwdVerificationTip;

  /// No description provided for @selectAsset.
  ///
  /// In en, this message translates to:
  /// **'Select Asset'**
  String get selectAsset;

  /// No description provided for @tokenPendingTip.
  ///
  /// In en, this message translates to:
  /// **'There are <light>{count}</light> pending transactions, cancel or confirm the current action.'**
  String tokenPendingTip(int count);

  /// No description provided for @pendingTx.
  ///
  /// In en, this message translates to:
  /// **'Pending Transaction'**
  String get pendingTx;

  /// No description provided for @signed.
  ///
  /// In en, this message translates to:
  /// **'SIGNED'**
  String get signed;

  /// No description provided for @backToAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Return to app'**
  String get backToAppTitle;

  /// No description provided for @backToAppDesc.
  ///
  /// In en, this message translates to:
  /// **'Please return to the app to continue using their services.'**
  String get backToAppDesc;

  /// No description provided for @walletConnectTitle.
  ///
  /// In en, this message translates to:
  /// **'WalletConnect'**
  String get walletConnectTitle;

  /// No description provided for @noWalletConnectSession.
  ///
  /// In en, this message translates to:
  /// **'No sessions'**
  String get noWalletConnectSession;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @response.
  ///
  /// In en, this message translates to:
  /// **'Response'**
  String get response;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @scanTip.
  ///
  /// In en, this message translates to:
  /// **'Support address QR code and WalletConnect'**
  String get scanTip;

  /// No description provided for @notificationTxSuccess.
  ///
  /// In en, this message translates to:
  /// **'Transaction Successful'**
  String get notificationTxSuccess;

  /// No description provided for @notificationTxFailed.
  ///
  /// In en, this message translates to:
  /// **'Transaction Failed'**
  String get notificationTxFailed;

  /// No description provided for @notificationTxSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'Your transaction has been confirmed.'**
  String get notificationTxSuccessBody;

  /// No description provided for @notificationTxSuccessBodyWithAmount.
  ///
  /// In en, this message translates to:
  /// **'Your transaction of {amount} {symbol} has been confirmed.'**
  String notificationTxSuccessBodyWithAmount(String amount, String symbol);

  /// No description provided for @notificationTxFailedBody.
  ///
  /// In en, this message translates to:
  /// **'Your transaction failed. Please try again.'**
  String get notificationTxFailedBody;

  /// No description provided for @renameWallet.
  ///
  /// In en, this message translates to:
  /// **'Rename Wallet'**
  String get renameWallet;

  /// No description provided for @deleteWallet.
  ///
  /// In en, this message translates to:
  /// **'Delete Wallet'**
  String get deleteWallet;

  /// No description provided for @deleteWalletWarning.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. Make sure you have backed up your mnemonic phrase before deleting.'**
  String get deleteWalletWarning;

  /// No description provided for @hdWallet.
  ///
  /// In en, this message translates to:
  /// **'HD Wallet'**
  String get hdWallet;

  /// No description provided for @walletNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter wallet name'**
  String get walletNamePlaceholder;

  /// No description provided for @accounts.
  ///
  /// In en, this message translates to:
  /// **'accounts'**
  String get accounts;

  /// No description provided for @selectWallet.
  ///
  /// In en, this message translates to:
  /// **'Select Wallet'**
  String get selectWallet;

  /// No description provided for @noMnemonicWallet.
  ///
  /// In en, this message translates to:
  /// **'No HD wallet available. Please create or import a wallet first.'**
  String get noMnemonicWallet;

  /// No description provided for @walletDetails.
  ///
  /// In en, this message translates to:
  /// **'Wallet Details'**
  String get walletDetails;

  /// No description provided for @walletNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Wallet Name'**
  String get walletNameLabel;

  /// No description provided for @changeWalletName.
  ///
  /// In en, this message translates to:
  /// **'Change Wallet Name'**
  String get changeWalletName;

  /// No description provided for @seedPhrase.
  ///
  /// In en, this message translates to:
  /// **'Seed Phrase'**
  String get seedPhrase;

  /// No description provided for @deleteWalletConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this wallet?'**
  String get deleteWalletConfirm;

  /// No description provided for @walletDeleted.
  ///
  /// In en, this message translates to:
  /// **'Wallet deleted successfully'**
  String get walletDeleted;

  /// No description provided for @walletRenamed.
  ///
  /// In en, this message translates to:
  /// **'Wallet renamed successfully'**
  String get walletRenamed;

  /// No description provided for @privateKeyWallet.
  ///
  /// In en, this message translates to:
  /// **'Private Key'**
  String get privateKeyWallet;

  /// No description provided for @keystoreWallet.
  ///
  /// In en, this message translates to:
  /// **'Keystore'**
  String get keystoreWallet;

  /// No description provided for @ledgerWallet.
  ///
  /// In en, this message translates to:
  /// **'Ledger'**
  String get ledgerWallet;

  /// No description provided for @watchWallet.
  ///
  /// In en, this message translates to:
  /// **'Watch-only'**
  String get watchWallet;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @backupMnemonic.
  ///
  /// In en, this message translates to:
  /// **'Backup Mnemonic'**
  String get backupMnemonic;

  /// No description provided for @addWallet.
  ///
  /// In en, this message translates to:
  /// **'Add Wallet'**
  String get addWallet;

  /// No description provided for @importWallet.
  ///
  /// In en, this message translates to:
  /// **'Import Wallet'**
  String get importWallet;

  /// No description provided for @walletManagement.
  ///
  /// In en, this message translates to:
  /// **'Wallet Management'**
  String get walletManagement;

  /// No description provided for @mnemonicPhrase.
  ///
  /// In en, this message translates to:
  /// **'Mnemonic Phrase'**
  String get mnemonicPhrase;

  /// No description provided for @mnemonicImportDesc.
  ///
  /// In en, this message translates to:
  /// **'Import using 12 or 24 word mnemonic phrase'**
  String get mnemonicImportDesc;

  /// No description provided for @privateKeyImportDesc.
  ///
  /// In en, this message translates to:
  /// **'Import using private key'**
  String get privateKeyImportDesc;

  /// No description provided for @keystoreImportDesc.
  ///
  /// In en, this message translates to:
  /// **'Import using Keystore file'**
  String get keystoreImportDesc;

  /// No description provided for @ledgerImportDesc.
  ///
  /// In en, this message translates to:
  /// **'Connect via Bluetooth or USB'**
  String get ledgerImportDesc;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @ledgerIntroDesc.
  ///
  /// In en, this message translates to:
  /// **'Before you start, ensure you have the most up-to-date firmware on your Ledger device and that Ledger is set up. And the Mina App has been installed in the Ledger device.'**
  String get ledgerIntroDesc;

  /// No description provided for @ledgerIntroStep1.
  ///
  /// In en, this message translates to:
  /// **'Connect your Ledger to the phone.'**
  String get ledgerIntroStep1;

  /// No description provided for @ledgerIntroStep2.
  ///
  /// In en, this message translates to:
  /// **'Open the Mina app in your Ledger device, Until you see <bold>Mina is ready</bold>.'**
  String get ledgerIntroStep2;

  /// No description provided for @hdPathDesc.
  ///
  /// In en, this message translates to:
  /// **'If you don\'t know what this setting below is, you don\'t need to change it. View detailed <link>instructions</link>.'**
  String get hdPathDesc;

  /// No description provided for @currentEpoch.
  ///
  /// In en, this message translates to:
  /// **'Current Epoch'**
  String get currentEpoch;

  /// No description provided for @earnOnMina.
  ///
  /// In en, this message translates to:
  /// **'Earn on MINA'**
  String get earnOnMina;

  /// No description provided for @apr.
  ///
  /// In en, this message translates to:
  /// **'APR'**
  String get apr;

  /// No description provided for @lockTime.
  ///
  /// In en, this message translates to:
  /// **'Lock Time'**
  String get lockTime;

  /// No description provided for @notLocked.
  ///
  /// In en, this message translates to:
  /// **'Not Locked'**
  String get notLocked;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @unknownNetworkStaking.
  ///
  /// In en, this message translates to:
  /// **'Unknown network, Unable to provide history.'**
  String get unknownNetworkStaking;

  /// No description provided for @redelegate.
  ///
  /// In en, this message translates to:
  /// **'Redelegate'**
  String get redelegate;

  /// No description provided for @stake.
  ///
  /// In en, this message translates to:
  /// **'Stake'**
  String get stake;

  /// No description provided for @stakeInfoBanner.
  ///
  /// In en, this message translates to:
  /// **'In Mina protocol. Stake is a delegation operation, your assets will not be locked, and you can transfer them at any time.'**
  String get stakeInfoBanner;

  /// No description provided for @validator.
  ///
  /// In en, this message translates to:
  /// **'Validator'**
  String get validator;

  /// No description provided for @fromValidator.
  ///
  /// In en, this message translates to:
  /// **'From Validator'**
  String get fromValidator;

  /// No description provided for @toValidator.
  ///
  /// In en, this message translates to:
  /// **'To Validator'**
  String get toValidator;

  /// No description provided for @currentValidator.
  ///
  /// In en, this message translates to:
  /// **'Current Validator'**
  String get currentValidator;

  /// No description provided for @selectValidator.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get selectValidator;

  /// No description provided for @epochEstimate.
  ///
  /// In en, this message translates to:
  /// **'15 days (1 epoch) est.'**
  String get epochEstimate;

  /// No description provided for @threeMonthsEstimate.
  ///
  /// In en, this message translates to:
  /// **'3 months est.'**
  String get threeMonthsEstimate;

  /// No description provided for @sixMonthsEstimate.
  ///
  /// In en, this message translates to:
  /// **'6 months est.'**
  String get sixMonthsEstimate;

  /// No description provided for @staked.
  ///
  /// In en, this message translates to:
  /// **'Staked'**
  String get staked;

  /// No description provided for @networkFee.
  ///
  /// In en, this message translates to:
  /// **'Network Fee'**
  String get networkFee;

  /// No description provided for @inputFeeError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid transaction fee'**
  String get inputFeeError;

  /// No description provided for @inputNonceError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid nonce'**
  String get inputNonceError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'tr', 'uk', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
    case 'uk':
      return AppLocalizationsUk();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
