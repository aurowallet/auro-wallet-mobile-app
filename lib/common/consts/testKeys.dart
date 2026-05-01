import 'package:flutter/material.dart';

/// Test Key constants
/// Add these Keys to Widgets that need testing so integration tests can locate elements
/// 
/// Usage example:
/// ```dart
/// ElevatedButton(
///   key: TestKeys.createWalletButton,
///   onPressed: () => ...,
///   child: Text('Create Wallet'),
/// )
/// ```
class TestKeys {
  TestKeys._();

  // ===== Entry Page =====
  static const createWalletButton = Key('create_wallet_button');
  static const restoreWalletButton = Key('restore_wallet_button');
  
  // ===== Privacy Terms Dialog =====
  static const termsAgreeButton = Key('terms_agree_button');
  static const termsRefuseButton = Key('terms_refuse_button');
  static const termsDialog = Key('terms_dialog');

  // ===== Password Page =====
  static const passwordInput = Key('password_input');
  static const confirmPasswordInput = Key('confirm_password_input');
  static const nextButton = Key('next_button');

  // ===== Mnemonic Backup Tips Page =====
  static const backupTipsCheckbox1 = Key('backup_tips_checkbox_1');
  static const backupTipsCheckbox2 = Key('backup_tips_checkbox_2');
  static const backupTipsNextButton = Key('backup_tips_next_button');
  
  // ===== Mnemonic Display/Verify Page =====
  static const mnemonicDisplay = Key('mnemonic_display');
  static const mnemonicInput = Key('mnemonic_input');
  static const confirmBackupButton = Key('confirm_backup_button');
  static const mnemonicSavedButton = Key('mnemonic_saved_button');
  static const mnemonicWordButton = Key('mnemonic_word_button');

  // ===== Private Key Page =====
  static const privateKeyInput = Key('private_key_input');
  static const importButton = Key('import_button');

  // ===== Keystore Page =====
  static const keystoreInput = Key('keystore_input');
  static const keystorePasswordInput = Key('keystore_password_input');

  // ===== Wallet Management =====
  static const walletListItem = Key('wallet_list_item');
  static const addWalletButton = Key('add_wallet_button');
  static const walletSwitcher = Key('wallet_switcher');
  static const deleteWalletButton = Key('delete_wallet_button');
  static const walletManageIcon = Key('wallet_manage_icon');  // Wallet manage icon (top-right on home page)
  static const addAccountButton = Key('add_account_button');  // Add account button
  static const accountMoreButton = Key('account_more_button'); // Account more button
  static const walletMoreButton = Key('wallet_more_button');   // Wallet more button

  // ===== Import Success Page =====
  static const startHomeButton = Key('start_home_button');

  // ===== Home Page =====
  static const balanceDisplay = Key('balance_display');
  static const sendButton = Key('send_button');
  static const receiveButton = Key('receive_button');
  static const accountSwitcher = Key('account_switcher');

  // ===== Transfer Page =====
  static const toAddressInput = Key('to_address_input');
  static const amountInput = Key('amount_input');
  static const memoInput = Key('memo_input');
  static const confirmSendButton = Key('confirm_send_button');
  static const feeSelector = Key('fee_selector');

  // ===== Webview JS Stability =====
  static const bridgeStressButton = Key('bridge_stress_button');
  static const bridgeStressStatus = Key('bridge_stress_status');
  static const providerStatus = Key('provider_status');
  static const providerSnapshot = Key('provider_snapshot');
  static const providerDiagnostics = Key('provider_diagnostics');
  static const providerRunAutoButton = Key('provider_run_auto_button');
  static const providerReloadButton = Key('provider_reload_button');
  static const providerHandshakeProbeButton =
      Key('provider_handshake_probe_button');
  static const providerTransportProbeButton =
      Key('provider_transport_probe_button');
  static const providerReloadProbeButton = Key('provider_reload_probe_button');
  static const providerRequestAccountsButton = Key('provider_request_accounts_button');
  static const providerSignMessageButton = Key('provider_sign_message_button');
  static const providerEmitAccountsChangedButton = Key('provider_emit_accounts_changed_button');
  static const providerEmitChainChangedButton = Key('provider_emit_chain_changed_button');
  static const providerEmitNetworkChangedButton = Key('provider_emit_network_changed_button');
  static const providerClearLogButton = Key('provider_clear_log_button');

  // ===== Common =====
  static const confirmButton = Key('confirm_button');
  static const cancelButton = Key('cancel_button');
  static const backButton = Key('back_button');
  static const loadingIndicator = Key('loading_indicator');
  static const errorMessage = Key('error_message');
  static const successMessage = Key('success_message');
}
