// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get passwordError => 'Incorrect password';

  @override
  String get createWallet => 'Create Wallet';

  @override
  String get restoreWallet => 'Restore Wallet';

  @override
  String get inputPassword => 'Enter password';

  @override
  String get createPasswordTip =>
      'The password will be used for identity verification purposes to send transactions in Auro Wallet. Auro Wallet won\'t store the password itself or retrieve it for you. Please keep your password safe.';

  @override
  String get next => 'Next';

  @override
  String get atLeastOneLowercaseLetter => 'lowercase letter';

  @override
  String get atLeastOneUppercaseLetter => 'uppercase letter';

  @override
  String get atLeastOneNumber => 'number';

  @override
  String get passwordRequires => '8 characters';

  @override
  String get passwordDifferent => 'Passwords do not match';

  @override
  String get backTips_1 => 'Backup your mnemonic phrase now!';

  @override
  String get backTips_2 =>
      'The Mnemonic phrase consists of 12 English words, which cannot be retrieved if they are lost. Make sure the mnemonic phrase is kept in a secure location.';

  @override
  String get backTips_3 =>
      'If the wallet cannot be accessed because the device is lost or for any other reason, importing the mnemonic phrase is the only way to retrieve your assets.';

  @override
  String get show_seed_content =>
      'Please write down the following mnemonic phrase and keep it in a safe place.';

  @override
  String get show_seed_button => 'Confirmed Backup';

  @override
  String get seed_error => 'Incorrect mnemonic phrase';

  @override
  String get backup_success =>
      'Congrats, You have successfully created a wallet!';

  @override
  String get backup_success_restore =>
      'Congrats, You have successfully restored a wallet!';

  @override
  String get inputSeed =>
      'Please enter 12 or 24 mnemonic phrases in order, without capitalization, punctuation symbols.';

  @override
  String get confirm => 'Confirm';

  @override
  String get wallet => 'Wallet';

  @override
  String get staking => 'Staking';

  @override
  String get setting => 'Settings';

  @override
  String get stakingStatus_1 => 'Delegated';

  @override
  String get stakingStatus_2 => 'Undelegated';

  @override
  String get send => 'Send';

  @override
  String get receive => 'Receive';

  @override
  String get history => 'HISTORY';

  @override
  String get toAddress => 'To';

  @override
  String get fromAddress => 'From';

  @override
  String get amount => 'Amount';

  @override
  String get memo => 'Memo(Optional)';

  @override
  String get memo2 => 'Memo';

  @override
  String get fee => 'Fee';

  @override
  String get fee_slow => 'Slow';

  @override
  String get fee_default => 'Default';

  @override
  String get fee_fast => 'Fast';

  @override
  String get advanceMode => 'Advanced';

  @override
  String get sendDetail => 'Transaction Overview';

  @override
  String get sendAddressError => 'Please enter a valid wallet address';

  @override
  String get amountError => 'Please enter a valid amount';

  @override
  String get balanceNotEnough => 'Insufficient Balance';

  @override
  String get txHash => 'Transaction Hash';

  @override
  String get time => 'Time';

  @override
  String get goToExplrer => 'Query Details';

  @override
  String get details => 'Details';

  @override
  String get walletAddress => 'Wallet Address';

  @override
  String get copySuccess => 'Copied';

  @override
  String get accountManage => 'Account Management';

  @override
  String get create => 'Create';

  @override
  String get import => 'Import';

  @override
  String get importLedger => 'Ledger';

  @override
  String get accountName => 'Account Name';

  @override
  String get inputAccountName => 'Please enter your account name';

  @override
  String get importAccount_2 =>
      'The imported accounts will not be associated with your originally created Auro wallet.';

  @override
  String get importAccount_3 =>
      'The imported accounts will be marked with [Imported] in the account list.';

  @override
  String get accountInfo => 'Account Details';

  @override
  String get accountAddress => 'Account Address';

  @override
  String get exportPrivateKey => 'Export Private Key';

  @override
  String get accountDelete => 'Delete Account';

  @override
  String get cancel => 'Cancel';

  @override
  String get privateKeyTip_1 =>
      'The private key consists of a string of characters, and owning the private key is equivalent to owning the asset ownership.';

  @override
  String get privateKeyTip_2 =>
      'Once the private key is lost, it cannot be retrieved. Please make sure to backup the private key and keep it in a safe place.';

  @override
  String get security => 'Security';

  @override
  String get network => 'Network';

  @override
  String get language => 'Language';

  @override
  String get currency => 'Currency';

  @override
  String get about => 'About';

  @override
  String get restoreSeed => 'Backup Mnemonic Phrase';

  @override
  String get changePassword => 'Change Password';

  @override
  String get inputOldPwd => 'Please enter the <bold>old</bold> password';

  @override
  String get inputNewPwd => 'Please enter the <bold>new</bold> password';

  @override
  String get inputNewPwdRepeat => 'Re-enter the <bold>new</bold> password';

  @override
  String get pwdChangeSuccess => 'Password changed';

  @override
  String get delete => 'Delete';

  @override
  String get urlError_1 => 'Invalid node URL';

  @override
  String get urlError_2 => 'Address already exists';

  @override
  String get urlError_3 => 'Node address already exists';

  @override
  String get prompt => 'Reminder';

  @override
  String get deleteAccountTip =>
      'A deleted account can only be restored by the Mnemonic Phrase or Private Key. Please make sure you have backed up your Mnemonic Phrase and Private Key.';

  @override
  String get isee => 'OK';

  @override
  String get walletHomeTip =>
      'The Mina network charges a one-time account creation fee of 1 MINA for spam prevention. It will be automatically deducted from the first transaction received.';

  @override
  String get startHome => 'Start';

  @override
  String get walletName => 'Auro Wallet';

  @override
  String get privateError => 'Private Key Incorrect';

  @override
  String get improtRepeat => 'Do not import repeatedly';

  @override
  String get confirmDeleteNode => 'Are you sure to delete it?';

  @override
  String get backupSuccess => 'Success';

  @override
  String get walletAbout =>
      'Auro Wallet is a non-custodial wallet developed by the community. It is simple, convenient, and fully open source. It currently supports all the functions of the Mina Protocol.';

  @override
  String get copyTipContent =>
      'Copying the private key is risky, and the clipboard is easily monitored and stolen by third-party applications.';

  @override
  String get copyTipContent2 =>
      'Please ensure that the system and network environment you are using is absolutely safe before performing this operation.';

  @override
  String get copyConfirm => 'Copy Anyway';

  @override
  String get copyCancel => 'Stop Copying';

  @override
  String get scantopay => 'Scan to pay me';

  @override
  String addressQrTip(String symbol) {
    return 'Scan the QR code and transfer <strongBlack>$symbol</strongBlack> to it';
  }

  @override
  String get goToExplorer => 'Check more transaction history';

  @override
  String get homeNoTx => 'Unknown node, unable to provide history.';

  @override
  String get followUs => 'Follow Us';

  @override
  String get createPassword => 'Create Password';

  @override
  String get epochInfo => 'Epoch Info';

  @override
  String get delegationInfo => 'Delegation Info';

  @override
  String get emptyDelegateTitle => 'You have not yet delegated';

  @override
  String get emptyDelegateDesc1 =>
      'Delegating MINA to the Block Producer node can help you obtain rewards for producing blocks. The Block Producer will distribute the rewards according to your delegated proportion, and the percentage of rewards depends on the rate setting by the Block Producer.';

  @override
  String get emptyDelegateDesc2 =>
      'Effective time of delegating and rewards distributing rules:';

  @override
  String get emptyDelegateDesc3 => 'Staking Guide';

  @override
  String get changeNode => 'Change';

  @override
  String get stakingProviderName => 'Block Producer';

  @override
  String get goStake => 'Go to staking';

  @override
  String get epochEndTime => 'Current epoch end in';

  @override
  String get searchPlaceholder => 'Block Producer name or address';

  @override
  String get inputNodeAddress => 'Please input node provider address';

  @override
  String get nodeProviders => 'Block Producer';

  @override
  String get manualAdd => 'Input Block Producer address';

  @override
  String get providerAddress => 'BP Address';

  @override
  String get copyToClipboard => 'Copy to Clipboard';

  @override
  String get loading => 'Loading';

  @override
  String get keystoreError => 'Keystore contents or password is incorrect';

  @override
  String get pleaseInputKeyPair =>
      'Please enter the contents of the Keystore file.';

  @override
  String get pleaseInputKeyPairPwd => 'Keystore Password';

  @override
  String get pleaseInputPriKey => 'Please enter Private Key.';

  @override
  String get privateKey => 'Private Key';

  @override
  String get applied => 'APPLIED';

  @override
  String get failed => 'FAILED';

  @override
  String get pending => 'PENDING';

  @override
  String get blockProducerName => 'Block Producer Name';

  @override
  String get producerName => 'Block Producer Name';

  @override
  String get blockProducerAddress => 'Block Producer Address';

  @override
  String get notValidAddress => 'Not valid MINA address';

  @override
  String get agree => 'Agree';

  @override
  String get userAgree => 'Terms and Conditions';

  @override
  String get imported => 'Imported';

  @override
  String get watchAccount => 'Watch Account';

  @override
  String get watchMode => 'Watch Mode';

  @override
  String get textWatchModeAddress => 'Enter or paste wallet address';

  @override
  String get watchLabel => 'Watch';

  @override
  String get timeout => 'Request Timeout';

  @override
  String get rootTip =>
      'Detected that the system has been Root or using the simulator. Continue to use there will be risks!';

  @override
  String get exitConfirm => 'Do you want to exit the App?';

  @override
  String get unlockBioEnable => 'Biometric Authentication';

  @override
  String get unlockBio => 'Authenticate to unlock';

  @override
  String get feeTooLarge => 'Fees are much higher than average';

  @override
  String get add => 'Add';

  @override
  String get addressbook => 'Address Book';

  @override
  String get name => 'Name';

  @override
  String get address => 'Address';

  @override
  String get repeatContact => 'Address exists';

  @override
  String get backupInOrder =>
      'To ensure you have backed up the Mnemonic Phrase, please tap the 12 words in order.';

  @override
  String get refuse => 'Refuse';

  @override
  String get termsDialogTitle => 'Terms and Privacy Policy';

  @override
  String get privacy => 'Privacy Policy';

  @override
  String get scan => 'Scan';

  @override
  String get restoreTip =>
      'If you want to import private key/keystore or connect Ledger, need to [Create Wallet] or [Restore Wallet] first.';

  @override
  String get reset => 'Reset';

  @override
  String get resetWarnContentTitle =>
      'Are you sure you want to reset your wallet?';

  @override
  String get resetWarnContent =>
      'After resetting you existing wallet all the data will be lost. You can only use the mnemonic phrase to restore. Please ensure you have backed-up the mnemonic phrase before you reset the wallet.';

  @override
  String get confirmReset => 'Reset';

  @override
  String get cancelReset => 'Cancel';

  @override
  String deleteConfirm(String tag) {
    return 'Type \'$tag\' to erase current wallet permanently';
  }

  @override
  String get edit => 'Edit';

  @override
  String get save => 'Save';

  @override
  String get watchModeWarn2 =>
      'Auro Wallet no longer support the [Watch Account] , you need to <red>delete all watch accounts</red> before you can continue to use.';

  @override
  String get deleteWatch => 'Delete watch account';

  @override
  String get allTransfer => 'Max';

  @override
  String get noMoreSupported => 'No longer supported account';

  @override
  String get password => 'Password';

  @override
  String get confirmPasswordShort => 'Confirm Password';

  @override
  String get share => 'Share';

  @override
  String get copy => 'Copy';

  @override
  String get mnemonicLost =>
      'If mnemonic phrase lost, my funds will be lost forever.';

  @override
  String get protectMnemonic =>
      'I take full responsibility for protecting the mnemonic.';

  @override
  String get scam => 'scam';

  @override
  String get hdDerivedPath => 'HD Path';

  @override
  String get emptyAddress => 'No addresses saved';

  @override
  String get speedUp => 'Speed Up';

  @override
  String get speedUpTitle => 'Speed Up Transaction';

  @override
  String get cancelTransaction => 'Cancel Transaction';

  @override
  String get speedUpTip =>
      'Normally, a transaction takes <light>3 minutes</light> to confirm. However, when the network is congested and your transaction may take longer than 3 minutes or more, you can speed up the transaction process by increasing the transaction fee.';

  @override
  String get transactionCancelTip =>
      'Cancel the transaction by sending a transaction with the same Nonce to yourself address. The fee will be greater than the current transaction fee (+0.0001 MINA) .';

  @override
  String get currentFee => 'Current Fee';

  @override
  String get stakedBalance => 'Staked';

  @override
  String get testnet => 'Testnet';

  @override
  String get myWallet => 'My Wallet';

  @override
  String get renameAccountName => 'Change Account Name';

  @override
  String get accountNameLimit => 'No more than 16 characters';

  @override
  String get github => 'Check it out on Github';

  @override
  String get noAddress => 'No Address';

  @override
  String get addaddress => 'Add Address';

  @override
  String get editaddress => 'Edit Address';

  @override
  String get deleteaddress => 'Delete Address?';

  @override
  String get addNetWork => 'Add Network';

  @override
  String get editNetWork => 'Edit Network';

  @override
  String get nodeAddress => 'Node URL';

  @override
  String get nodeAlert =>
      'Only add custom nodes you trust. Using unknown nodes can be risky.';

  @override
  String get invalidContact => 'Invalid address';

  @override
  String get submitNode => 'Submit/Update your node to this list';

  @override
  String get ledgerTip1 => 'Connect your Ledger to the phone.';

  @override
  String get ledgerTip2 =>
      'Open the Mina app in your Ledger device, Until you see <bold>Mina is ready</bold>.';

  @override
  String get ledgerTip3 =>
      'Select a hardware wallet you‘d like to use with Auro Wallet.';

  @override
  String get connectHardwareWallet => 'Connect Hardware Wallet';

  @override
  String get selectHdPath => 'Select HD Path';

  @override
  String get ledgerStatus => 'Ledger Status';

  @override
  String get ledgerAddressTip1 =>
      'Please continue the follow-up operation according to the prompt of the Ledger hardware wallet.';

  @override
  String get ledgerAddressTip3 =>
      '<lightred>Do not close this window.</lightred> Once the Ledger is complete, the page will redirect automatically.';

  @override
  String get waitingLedger => 'Waiting for confirmation…';

  @override
  String get waitingLedgerSign =>
      'Please confirm in the Ledger hardware wallet, the signature may take 1-3 minutes.';

  @override
  String get openMinaApp =>
      'Ledger device is connected, but Mina app is not open. Please open Mina app in Ledger.';

  @override
  String get unlockLedger =>
      'Failed to connect. Please make sure your Ledger device is unlocked.';

  @override
  String get ledgerPairingError =>
      'Bluetooth pairing failed. Please go to your device\'s Bluetooth settings, find your Ledger device, tap and select \"Forget This Device\", then try connecting again.';

  @override
  String get ledgerReject => 'Rejected by Ledger';

  @override
  String get ledgerSearching => 'Searching…';

  @override
  String get ledgerSupport =>
      '(<lightred>Only support Ledger Nano X</lightred>)';

  @override
  String get termsAndPrivacy_line1 =>
      'This service is provided by Auro Wallet, please take time to read carefully and understand the Terms and Conditions and Privacy Policy.';

  @override
  String get termsAndPrivacy_line2 =>
      'Please read the <conditions>Terms and Conditions</conditions> and <policy>Privacy Policy</policy> carefully. If you understand fully and agree, please click [Agree] to start using this wallet service.';

  @override
  String get contributeLanguage => 'Contribute Language';

  @override
  String get available => 'Available';

  @override
  String importSameAccount_1(String address) {
    return 'The address of the account to be created is: <theme>$address</theme>';
  }

  @override
  String importSameAccount_2(String accountName) {
    return 'An existing imported account [$accountName] is a duplicate of this address. Auro Wallet does not support the creation of duplicate account addresses. Please go to the <acmanage>Account Management</acmanage> to delete the imported account.';
  }

  @override
  String get browser => 'Browser';

  @override
  String get searchOrInputUrl => 'Search or input URL';

  @override
  String get allowSiteAddNode => 'Allow this site to add a network';

  @override
  String get removeFavorites => 'Remove from favorites';

  @override
  String get addFavorites => 'Add to favorites';

  @override
  String get copyLink => 'Copy Link';

  @override
  String get openInBrowser => 'Open in browser';

  @override
  String get connectionRequest => 'Connection Request';

  @override
  String get connectTip => 'This website would like to view account';

  @override
  String get trustedSitesTip => 'Make sure you only connect to trusted sites';

  @override
  String get signatureRequest => 'Signature Request';

  @override
  String get content => 'Content';

  @override
  String get transactionFee => 'Transaction Fee';

  @override
  String get siteSuggested => 'Site suggested';

  @override
  String get rawData => 'Raw data';

  @override
  String get showData => 'Show data';

  @override
  String get warning => 'WARNING';

  @override
  String get warningTip =>
      'You are interacting with an address or contract that has been flagged as scam. If you sign, you could lose access to all of your NFTs and any funds or other assets in your wallet.';

  @override
  String get switchNetwork => 'Switch Network';

  @override
  String get allowSwitch => 'Allow this site to switch the network?';

  @override
  String get current => 'Current';

  @override
  String get target => 'Target';

  @override
  String get recently => 'Recently';

  @override
  String get favorites => 'Favorites';

  @override
  String get browserEmptyTip => 'Your favorites and history will show up here';

  @override
  String get websiteNotFound => 'Website Not Found';

  @override
  String get ledgerNotSupportSign => 'Ledger doesn\'t support sign message';

  @override
  String get notSupportNow => 'Not supported yet';

  @override
  String get newFee => 'New Fee';

  @override
  String get addAccount => 'Add Account';

  @override
  String get createAccount => 'Create Account';

  @override
  String get hardwareWallet => 'Hardware Wallet';

  @override
  String get showTestnet => 'Show Testnet';

  @override
  String get ledgerConnected => 'Ledger Connected';

  @override
  String get ledgerNotConnected => 'Ledger not Connected';

  @override
  String get txType => 'Transaction Type';

  @override
  String get appConnection => 'App Connections';

  @override
  String get noConnectedApps => 'No connected Apps';

  @override
  String get txHistoryTip => 'Unable to provide transaction history';

  @override
  String get tokens => 'TOKENS';

  @override
  String get assetManagement => 'Asset Management';

  @override
  String newTokenFound(String count) {
    return '$count new tokens found';
  }

  @override
  String get ignore => 'Ignore';

  @override
  String get balance => 'Balance';

  @override
  String get updateTokenInfo => 'Update your token information?';

  @override
  String get noTxHistory => 'No transaction history';

  @override
  String get buildFailed => 'Packaging failed';

  @override
  String get appAccess => 'App Access';

  @override
  String get transactions => 'Transactions';

  @override
  String get unlock => 'Unlock';

  @override
  String get useBiometricAuthentication => 'Use Biometric Authentication';

  @override
  String get loginWithPassword => 'Login with Password';

  @override
  String get clickToVerification => 'Click to start verification';

  @override
  String get resetWallet => 'Reset Wallet';

  @override
  String get biometricAuth => 'Biometric Auth';

  @override
  String get tapToVerify => 'Tap to verify';

  @override
  String get zkAppTipTitle => 'You are visiting a third-party zkApp';

  @override
  String get zkAppTipContent =>
      'You are a subiect to third-party zkApp‘s User Agreement when entering this zkApp.';

  @override
  String get passwordVerification => 'Password Verification';

  @override
  String get pwdVerificationTip => 'At least one option must be selected.';

  @override
  String get selectAsset => 'Select Asset';

  @override
  String tokenPendingTip(int count) {
    return 'There are <light>$count</light> pending transactions, cancel or confirm the current action.';
  }

  @override
  String get pendingTx => 'Pending Transaction';

  @override
  String get signed => 'SIGNED';

  @override
  String get backToAppTitle => 'Return to app';

  @override
  String get backToAppDesc =>
      'Please return to the app to continue using their services.';

  @override
  String get walletConnectTitle => 'WalletConnect';

  @override
  String get noWalletConnectSession => 'No sessions';

  @override
  String get preferences => 'Preferences';

  @override
  String get response => 'Response';

  @override
  String get retry => 'Retry';

  @override
  String get scanTip => 'Support address QR code and WalletConnect';

  @override
  String get notificationTxSuccess => 'Transaction Confirmed';

  @override
  String get notificationTxSuccessBody =>
      'Your transaction has been confirmed.';

  @override
  String get renameWallet => 'Rename Wallet';

  @override
  String get deleteWallet => 'Delete Wallet';

  @override
  String get deleteWalletWarning =>
      'This action cannot be undone. Make sure you have backed up your mnemonic phrase before deleting.';

  @override
  String get hdWallet => 'HD Wallet';

  @override
  String get walletNamePlaceholder => 'Enter wallet name';

  @override
  String get accounts => 'accounts';

  @override
  String get selectWallet => 'Select Wallet';

  @override
  String get noMnemonicWallet =>
      'No HD wallet available. Please create or import a wallet first.';

  @override
  String get walletDetails => 'Wallet Details';

  @override
  String get walletNameLabel => 'Wallet Name';

  @override
  String get changeWalletName => 'Change Wallet Name';

  @override
  String get seedPhrase => 'Seed Phrase';

  @override
  String get deleteWalletConfirm =>
      'Are you sure you want to delete this wallet?';

  @override
  String get privateKeyWallet => 'Private Key';

  @override
  String get keystoreWallet => 'Keystore';

  @override
  String get ledgerWallet => 'Ledger';

  @override
  String get watchWallet => 'Watch-only';

  @override
  String get rename => 'Rename';

  @override
  String get backupMnemonic => 'Backup Mnemonic';

  @override
  String get addWallet => 'Add Wallet';

  @override
  String get importWallet => 'Import Wallet';

  @override
  String get walletManagement => 'Wallet Management';

  @override
  String get mnemonicPhrase => 'Mnemonic Phrase';

  @override
  String get mnemonicImportDesc => 'Import using 12 or 24 word mnemonic phrase';

  @override
  String get privateKeyImportDesc => 'Import using private key';

  @override
  String get keystoreImportDesc => 'Import using Keystore file';

  @override
  String get ledgerImportDesc => 'Connect via Bluetooth or USB';

  @override
  String get getStarted => 'Get Started';

  @override
  String get ledgerIntroDesc =>
      'Before you start, ensure you have the most up-to-date firmware on your Ledger device and that Ledger is set up. And the Mina App has been installed in the Ledger device.';

  @override
  String get ledgerIntroStep1 => 'Connect your Ledger to the phone.';

  @override
  String get ledgerIntroStep2 =>
      'Open the Mina app in your Ledger device, Until you see <bold>Mina is ready</bold>.';

  @override
  String get hdPathDesc =>
      'If you don\'t know what this setting below is, you don\'t need to change it. View detailed <link>instructions</link>.';

  @override
  String get currentEpoch => 'Current Epoch';

  @override
  String get earnOnMina => 'Earn on MINA';

  @override
  String get apr => 'APR';

  @override
  String get lockTime => 'Lock Time';

  @override
  String get notLocked => 'Not Locked';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get unknownNetworkStaking =>
      'Unknown network, Unable to provide history.';

  @override
  String get redelegate => 'Redelegate';

  @override
  String get stake => 'Stake';

  @override
  String get stakeInfoBanner =>
      'In Mina protocol. Stake is a delegation operation, your assets will not be locked, and you can transfer them at any time.';

  @override
  String get validator => 'Validator';

  @override
  String get fromValidator => 'From Validator';

  @override
  String get toValidator => 'To Validator';

  @override
  String get currentValidator => 'Current Validator';

  @override
  String get selectValidator => 'Select';

  @override
  String get epochEstimate => '15 days (1 epoch) est.';

  @override
  String get threeMonthsEstimate => '3 months est.';

  @override
  String get sixMonthsEstimate => '6 months est.';

  @override
  String get staked => 'Staked';

  @override
  String get networkFee => 'Network Fee';

  @override
  String get inputFeeError => 'Please enter a valid network fee';

  @override
  String get inputNonceError => 'Please enter a valid nonce';

  @override
  String get biometricUpdateFailed =>
      'Biometric data update failed. Please try again.';

  @override
  String notificationSentTitle(String amount, String symbol) {
    return 'Sent $amount $symbol';
  }

  @override
  String notificationSentBody(String address) {
    return 'To $address';
  }

  @override
  String get notificationSendFailedTitle => 'Send Failed';

  @override
  String notificationSendFailedBody(String amount, String symbol) {
    return '$amount $symbol send failed. Please try again.';
  }

  @override
  String get notificationDelegationSuccessTitle => 'Delegation Confirmed';

  @override
  String notificationDelegationSuccessBody(String address) {
    return 'Staked to $address';
  }

  @override
  String get notificationDelegationFailedTitle => 'Delegation Failed';

  @override
  String get notificationDelegationFailedBody =>
      'Your delegation failed. Please try again.';

  @override
  String get notificationZkAppSuccessTitle => 'zkApp Transaction Confirmed';

  @override
  String get notificationZkAppSuccessBody =>
      'Your zkApp transaction has been confirmed.';

  @override
  String get notificationZkAppFailedTitle => 'zkApp Transaction Failed';

  @override
  String get notificationZkAppFailedBody =>
      'Your zkApp transaction failed. Please try again.';

  @override
  String get notificationEnable => 'Notifications';
}
