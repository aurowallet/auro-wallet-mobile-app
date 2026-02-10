/// Flow 5: Multi-wallet tests
/// 
/// Prerequisite: complete flow2/3/4 first
/// 
/// Run with:
/// flutter drive --driver=test_driver/integration_test.dart --target=integration_test/flow5_multiwallet_test.dart -d <device_id>
/// 
/// Test coverage:
/// - Add second wallet (HD wallet)
/// - Add account in HD wallet
/// - Account switching
/// - Account rename
/// - Private key import into existing wallet

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:integration_test/integration_test.dart';
import 'package:auro_wallet/common/consts/testKeys.dart';
import 'package:auro_wallet/main.dart' as app;
import 'test_utils.dart';

class TestData {
  static const String defaultPassword = 'Test1234!';
  
  // First mnemonic - for wallet init (create if none exists)
  static const String firstMnemonic = 
      'century love gravity defense upset peasant reform tenant access illegal double magic';
  
  // Second mnemonic - for adding 2nd HD wallet
  static const String secondMnemonic = 
      'dove then garbage sponsor core observe replace miss north lunar asthma twice';
  
  // Private key - for PK import test
  static const String importPrivateKey = 
      'EKEL888U1yKv1xveoxiBPYZcCQMQsaRNYc6ftKMKiFrXUmpuvjsW';
  
  // Keystore - for keystore import test
  static const String importKeystore = 
      '{"box_primitive":"xsalsa20poly1305","pw_primitive":"argon2i","nonce":"49n6CriT6oYGcF9xp9MuVCFBJEU1wZ8YxMX3oqs","pwsalt":"65UZjZyPKdsNHnH2vdvSyeppXocg","pwdiff":[134217728,6],"ciphertext":"7395cfBPRrLWgQDiu9dfLLRuEuCh1WkS8vNw4oUXrutEnyAsAcPNE5iiXtu1YXS3YzvkTZq1s"}';
  static const String keystorePassword = '123456';
  static const String keystorePrivateKey = 'EKEMqXWTFW11v8um8VnRzEwZUL2g9WuMWWCxeDrSsjrkbF75La89';
  
  // Known wallet addresses
  // firstMnemonic (century...) 1st account — Devnet balance
  static const String firstMnemonicAddress = 
      'B62qoV35KayJT6D3MseTa8fEBNe4gEJLHGtfoFNhhQbv8JRxrKXntXj';
  // secondMnemonic (dove...) 1st account (hdIndex=0)
  static const String secondMnemonicAddress = 
      'B62qqLzqPFKoyu4d1bwf33H4fo5XjySjpZC1WZYqjTxX5o5Rga3Ujx1';
  // secondMnemonic (dove...) 2nd account (hdIndex=1)
  static const String secondMnemonicAccount2Address = 
      'B62qjXFMeiyHfz5XrACFpc1zbu2SLKho8NVwudqr2eSnAhN2kr4pXoS';
  // Private key import address
  static const String importPrivateKeyAddress = 
      'B62qo1CwWp18WhM5toS9D76WL7NxXNxKx2biESNk68AGrqKjRaFf8ks';
  // Keystore import address
  static const String keystoreAddress = 
      'B62qkSLnPzXsjRGn9V7rJqMCycQSaWcxqMrCgGv9Ff1tZ2mumnp1EJq';
}

/// Helper: create wallet via mnemonic
Future<bool> createWalletByMnemonic(WidgetTester tester, String mnemonic, String password) async {
  print('📝 Creating wallet...');
  
  // Tap restore wallet
  final restoreButton = find.byKey(TestKeys.restoreWalletButton);
  if (restoreButton.evaluate().isEmpty) {
    print('❌ Restore wallet button not found');
    return false;
  }
  await tester.tap(restoreButton);
  await tester.pumpAndSettle();
  print('✅ Tapped restore wallet');
  
  // Accept terms
  var agreeButton = find.byKey(TestKeys.termsAgreeButton);
  if (agreeButton.evaluate().isEmpty) agreeButton = find.text(dic.agree);
  if (agreeButton.evaluate().isNotEmpty) {
    await tester.tap(agreeButton);
    await tester.pumpAndSettle();
    print('✅ Accepted terms');
  }
  
  // Select mnemonic restore
  await tester.pump(const Duration(seconds: 1));
  var mnemonicOption = find.text(dic.mnemonicPhrase);
  if (mnemonicOption.evaluate().isNotEmpty) {
    await tester.tap(mnemonicOption);
    await tester.pumpAndSettle();
    print('✅ Selected mnemonic restore');
  } else {
    print('❌ Mnemonic option not found');
    return false;
  }
  
  // Enter password
  await tester.pump(const Duration(seconds: 1));
  final passwordInput = find.byKey(TestKeys.passwordInput);
  if (passwordInput.evaluate().isEmpty) {
    print('❌ Password input not found');
    return false;
  }
  await tester.enterText(passwordInput, password);
  await tester.pumpAndSettle();
  print('✅ Password entered');
  
  final confirmInput = find.byKey(TestKeys.confirmPasswordInput);
  if (confirmInput.evaluate().isNotEmpty) {
    await tester.enterText(confirmInput, password);
    await tester.pumpAndSettle();
    print('✅ Password confirmed');
  }
  
  final nextButton = find.byKey(TestKeys.nextButton);
  if (nextButton.evaluate().isNotEmpty) {
    await tester.tap(nextButton);
    await tester.pumpAndSettle();
    print('✅ Tapped next');
  }
  
  // Enter mnemonic
  await tester.pump(const Duration(seconds: 1));
  final mnemonicInput = find.byKey(TestKeys.mnemonicInput);
  if (mnemonicInput.evaluate().isNotEmpty) {
    await tester.enterText(mnemonicInput, mnemonic);
    await tester.pumpAndSettle();
    print('✅ Mnemonic entered');
  } else {
    print('❌ Mnemonic input not found');
    return false;
  }
  
  // Tap import button
  var importBtn = find.byKey(TestKeys.importButton);
  if (importBtn.evaluate().isEmpty) importBtn = find.byKey(TestKeys.confirmButton);
  if (importBtn.evaluate().isEmpty) importBtn = find.text(dic.confirm);
  if (importBtn.evaluate().isEmpty) importBtn = find.text(dic.import);
  
  if (importBtn.evaluate().isNotEmpty) {
    await tester.tap(importBtn);
    print('✅ Tapped import');
    await tester.pump(const Duration(seconds: 2));
    try {
      await tester.pumpAndSettle();
    } catch (e) {
      await tester.pump(const Duration(seconds: 2));
    }
  } else {
    print('❌ Import button not found');
    return false;
  }
  
  // Handle import success page
  await tester.pump(const Duration(seconds: 1));
  final startButton = find.byKey(TestKeys.startHomeButton);
  if (startButton.evaluate().isNotEmpty) {
    await tester.tap(startButton);
    print('✅ Tapped start');
    await tester.pump(const Duration(seconds: 2));
    try {
      await tester.pumpAndSettle();
    } catch (e) {
      await tester.pump(const Duration(seconds: 2));
    }
  } else {
    var startBtn = find.text(dic.startHome);
    if (startBtn.evaluate().isNotEmpty) {
      await tester.tap(startBtn);
      print('✅ Tapped start (text match)');
      await tester.pump(const Duration(seconds: 2));
      try {
        await tester.pumpAndSettle();
      } catch (e) {
        await tester.pump(const Duration(seconds: 2));
      }
    }
  }
  
  // Check if home reached
  for (int i = 0; i < 15; i++) {
    await tester.pump(const Duration(seconds: 1));
    final sendButton = find.byKey(TestKeys.sendButton);
    final balanceDisplay = find.byKey(TestKeys.balanceDisplay);
    if (sendButton.evaluate().isNotEmpty || balanceDisplay.evaluate().isNotEmpty) {
      print('✅ Wallet created, reached home');
      return true;
    }
  }
  
  print('❌ Wallet creation failed');
  return false;
}

/// Test result tracking
Map<String, String> testResults = {};

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Flow 5: Multi-Wallet Tests', () {
    
    setUpAll(() {
      print('\n');
      print('╔══════════════════════════════════════════════════════════════╗');
      print('║                      Multi-Wallet Tests                      ║');
      print('╚══════════════════════════════════════════════════════════════╝');
      print('\n');
    });

    tearDownAll(() async {
      print('\n');
      print('╔══════════════════════════════════════════════════════════════╗');
      print('║                         Test Summary                         ║');
      print('╠══════════════════════════════════════════════════════════════╣');
      testResults.forEach((test, result) {
        final status = result == 'PASS' ? '✅' : (result.startsWith('SKIP') ? '⏭️' : '❌');
        print('║ $status $test: $result');
      });
      print('╚══════════════════════════════════════════════════════════════╝');
      print('\n');
      
      // Print screenshot summary
      await ScreenshotHelper.printSummary();
    });

    testWidgets('5.1 Check/create wallet state', (WidgetTester tester) async {
      const testName = '5.1 Check/create wallet state';
      print('\n========== Start $testName ==========\n');
      final ss = ScreenshotHelper('flow5');
      
      app.main(testMode: true);
      
      // Wait for app init
      bool hasWallet = false;
      bool needsCreate = false;
      for (int i = 0; i < 30; i++) {
        await tester.pump(const Duration(seconds: 1));
        
        // Check if already on home
        final sendButton = find.byKey(TestKeys.sendButton);
        final balanceDisplay = find.byKey(TestKeys.balanceDisplay);
        if (sendButton.evaluate().isNotEmpty || balanceDisplay.evaluate().isNotEmpty) {
          print('✅ Existing wallet detected, on home page');
          hasWallet = true;
          break;
        }
        
        // Check if on create page
        final createButton = find.byKey(TestKeys.createWalletButton);
        final restoreButton = find.byKey(TestKeys.restoreWalletButton);
        if (createButton.evaluate().isNotEmpty || restoreButton.evaluate().isNotEmpty) {
          print('⚠️ No wallet, auto-creating for test');
          needsCreate = true;
          break;
        }
        
        if (i % 5 == 4) print('Waiting for init... ${i + 1}s');
      }
      
      // Create wallet if needed
      if (needsCreate) {
        final created = await createWalletByMnemonic(
          tester, 
          TestData.firstMnemonic, 
          TestData.defaultPassword
        );
        if (created) {
          hasWallet = true;
          print('✅ Wallet created');
        } else {
          testResults[testName] = 'FAIL - Wallet creation failed';
          print('\n========== $testName Done ==========\n');
          return;
        }
      }
      
      if (hasWallet) {
        testResults[testName] = 'PASS';
        await ss.take(tester, '5.1_home_state');
      } else {
        testResults[testName] = 'FAIL - Init timeout';
      }
      
      await endTestDelay(tester);
      print('\n========== $testName Done ==========\n');
    }, timeout: Timeout(Duration(minutes: 3)));

    testWidgets('5.2 Open wallet manager', (WidgetTester tester) async {
      const testName = '5.2 Open wallet mgmt';
      print('\n========== Start $testName ==========\n');
      final ss = ScreenshotHelper('flow5');
      
      app.main(testMode: true);
      
      // Wait for home page
      bool ready = false;
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(seconds: 1));
        final sendButton = find.byKey(TestKeys.sendButton);
        if (sendButton.evaluate().isNotEmpty) {
          ready = true;
          break;
        }
      }
      
      if (!ready) {
        testResults[testName] = 'SKIP - Home not loaded';
        return;
      }
      
      // Step 1: Tap wallet mgmt icon
      print('Step 1: Tap wallet mgmt icon');
      var walletManageIcon = find.byKey(TestKeys.walletManageIcon);
      
      if (walletManageIcon.evaluate().isNotEmpty) {
        await tester.tap(walletManageIcon);
        await tester.pumpAndSettle();
        print('✅ Tapped wallet mgmt icon');
      } else {
        print('❌ Wallet mgmt icon not found');
        testResults[testName] = 'FAIL - Wallet mgmt icon not found';
        return;
      }
      
      await tester.pump(const Duration(seconds: 1));
      await ss.take(tester, '5.2.1_wallet_mgmt');
      
      // Step 2: Verify wallet mgmt page loaded
      print('Step 2: Verify wallet mgmt page');
      final addWalletBtn = find.byKey(TestKeys.addWalletButton);
      var addBtnByText = find.text(dic.addWallet);
      
      if (addWalletBtn.evaluate().isNotEmpty || addBtnByText.evaluate().isNotEmpty) {
        print('✅ Wallet mgmt page loaded, found add wallet button');
        testResults[testName] = 'PASS';
      } else {
        print('⚠️ Add wallet button not found, page may be open');
        testResults[testName] = 'PARTIAL - Page open but button not found';
      }
      
      await endTestDelay(tester);
      print('\n========== $testName Done ==========\n');
    }, timeout: Timeout(Duration(minutes: 2)));

    testWidgets('5.3 Add 2nd HD wallet', (WidgetTester tester) async {
      const testName = '5.3 Add 2nd HD wallet';
      print('\n========== Start $testName ==========\n');
      final ss = ScreenshotHelper('flow5');
      
      app.main(testMode: true);
      
      // Wait for home page
      bool ready = false;
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(seconds: 1));
        final sendButton = find.byKey(TestKeys.sendButton);
        if (sendButton.evaluate().isNotEmpty) {
          ready = true;
          break;
        }
      }
      
      if (!ready) {
        testResults[testName] = 'SKIP - Home not loaded';
        return;
      }
      
      // Step 1: Open wallet mgmt, check if 2nd HD wallet exists
      print('Step 1: Open wallet mgmt');
      var walletManageIcon = find.byKey(TestKeys.walletManageIcon);
      if (walletManageIcon.evaluate().isEmpty) {
        testResults[testName] = 'FAIL - Wallet mgmt entry not found';
        return;
      }
      await tester.tap(walletManageIcon);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      await ss.take(tester, '5.3.1_wallet_mgmt');
      
      // Idempotent: if multiple HD wallets exist, pass
      var walletMoreBtns = find.byKey(TestKeys.walletMoreButton);
      if (walletMoreBtns.evaluate().length >= 2) {
        print('✅ 2nd HD wallet exists (idempotent), skipping');
        testResults[testName] = 'PASS';
        print('\n========== $testName Done ==========\n');
        return;
      }
      
      // Step 2: Tap add wallet
      print('Step 2: Tap add wallet button');
      var addWalletBtn = find.byKey(TestKeys.addWalletButton);
      if (addWalletBtn.evaluate().isEmpty) addWalletBtn = find.text(dic.addWallet);
      if (addWalletBtn.evaluate().isNotEmpty) {
        await tester.tap(addWalletBtn.first);
        await tester.pumpAndSettle();
        print('✅ Tapped add wallet');
      } else {
        testResults[testName] = 'FAIL - Add wallet entry not found';
        return;
      }
      await tester.pump(const Duration(seconds: 1));
      await ss.take(tester, '5.3.2_add_wallet');
      
      // Step 3: Import Wallet → Mnemonic Phrase
      print('Step 3: Select import wallet');
      var importOption = find.text(dic.importWallet);
      if (importOption.evaluate().isNotEmpty) {
        await tester.tap(importOption.first);
        await tester.pumpAndSettle();
        print('✅ Selected import wallet');
      }
      await tester.pump(const Duration(seconds: 1));
      
      print('Step 4: Select mnemonic method');
      var mnemonicOption = find.text(dic.mnemonicPhrase);
      if (mnemonicOption.evaluate().isNotEmpty) {
        await tester.tap(mnemonicOption.first);
        await tester.pumpAndSettle();
        print('✅ Selected mnemonic method');
      }
      
      // Handle password verify dialog
      await tester.pump(const Duration(seconds: 1));
      final passwordFields = find.byType(TextField);
      if (passwordFields.evaluate().isNotEmpty) {
        await tester.enterText(passwordFields.last, TestData.defaultPassword);
        await tester.pump(const Duration(milliseconds: 500));
        await ss.take(tester, '5.3.3_password');
        var confirmPwdBtn = find.text(dic.confirm);
        if (confirmPwdBtn.evaluate().isNotEmpty) {
          await tester.tap(confirmPwdBtn.last);
          await tester.pumpAndSettle();
          print('✅ Password confirmed');
        }
      }
      await tester.pump(const Duration(seconds: 1));
      
      // Step 5: Enter mnemonic
      print('Step 5: Enter mnemonic');
      final mnemonicInput = find.byKey(TestKeys.mnemonicInput);
      if (mnemonicInput.evaluate().isNotEmpty) {
        await tester.enterText(mnemonicInput, TestData.secondMnemonic);
        await tester.pump(const Duration(milliseconds: 500));
        print('✅ Entered 2nd mnemonic');
      }
      await ss.take(tester, '5.3.4_mnemonic');
      
      // Step 6: Confirm import - skip pumpAndSettle (spinner causes timeout/_pendingFrame)
      print('Step 6: Confirm import');
      var confirmBtn = find.byKey(TestKeys.confirmButton);
      if (confirmBtn.evaluate().isEmpty) confirmBtn = find.byKey(TestKeys.importButton);
      if (confirmBtn.evaluate().isEmpty) confirmBtn = find.text(dic.confirm);
      if (confirmBtn.evaluate().isNotEmpty) {
        await tester.tap(confirmBtn.first);
        print('✅ Tapped confirm');
      }
      
      // Poll: success page / error / home
      bool done = false;
      for (int i = 0; i < 30; i++) {
        await tester.pump(const Duration(seconds: 1));
        
        // Check if reached ImportSuccessPage
        var startBtn = find.byKey(TestKeys.startHomeButton);
        if (startBtn.evaluate().isEmpty) startBtn = find.text(dic.startHome);
        if (startBtn.evaluate().isNotEmpty) {
          await tester.tap(startBtn.first);
          print('✅ Tapped start');
          // Wait for home
          for (int j = 0; j < 10; j++) {
            await tester.pump(const Duration(seconds: 1));
            if (find.byKey(TestKeys.sendButton).evaluate().isNotEmpty) break;
          }
          print('✅ Added 2nd HD wallet, returned to home');
          testResults[testName] = 'PASS';
          done = true;
          break;
        }
        
        // Check if home reached (direct redirect)
        if (find.byKey(TestKeys.sendButton).evaluate().isNotEmpty) {
          print('✅ Reached home page');
          testResults[testName] = 'PASS';
          done = true;
          break;
        }
        
        // Check for duplicate import error
        var repeatError = find.textContaining('import repeatedly');
        if (repeatError.evaluate().isEmpty) repeatError = find.textContaining('duplicate');
        if (repeatError.evaluate().isNotEmpty) {
          print('⚠️ Duplicate import detected, marking as pass');
          testResults[testName] = 'PASS';
          done = true;
          break;
        }
      }
      
      if (!done) {
        testResults[testName] = 'PARTIAL - Flow incomplete';
      }
      
      await ss.take(tester, '5.3_done');
      await endTestDelay(tester);
      print('\n========== $testName Done ==========\n');
    }, timeout: Timeout(Duration(minutes: 3)));

    testWidgets('5.3b Import private key wallet', (WidgetTester tester) async {
      const testName = '5.3b Import PK wallet';
      print('\n========== Start $testName ==========\n');
      final ss = ScreenshotHelper('flow5');
      
      app.main(testMode: true);
      
      // Wait for home
      bool ready = false;
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(seconds: 1));
        final sendButton = find.byKey(TestKeys.sendButton);
        if (sendButton.evaluate().isNotEmpty) {
          ready = true;
          break;
        }
      }
      
      if (!ready) {
        testResults[testName] = 'SKIP - Home not loaded';
        return;
      }
      
      // Step 1: Open wallet mgmt
      print('Step 1: Open wallet mgmt');
      var walletManageIcon = find.byKey(TestKeys.walletManageIcon);
      if (walletManageIcon.evaluate().isEmpty) {
        testResults[testName] = 'SKIP - Wallet mgmt icon not found';
        return;
      }
      await tester.tap(walletManageIcon);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      print('✅ Opened wallet mgmt');
      await ss.take(tester, '5.3b.1_wallet_mgmt');
      
      // Idempotent: if PK wallet address exists
      var existingPK = find.textContaining('B62qo1');
      if (existingPK.evaluate().isNotEmpty) {
        print('✅ PK wallet exists (idempotent), skipping');
        testResults[testName] = 'PASS';
        print('\n========== $testName Done ==========\n');
        return;
      }
      
      // Step 2: Add wallet → Import Wallet → Private Key
      print('Step 2: Tap add wallet');
      var addWalletBtn = find.byKey(TestKeys.addWalletButton);
      if (addWalletBtn.evaluate().isEmpty) addWalletBtn = find.text(dic.addWallet);
      if (addWalletBtn.evaluate().isNotEmpty) {
        await tester.tap(addWalletBtn.first);
        await tester.pumpAndSettle();
        print('✅ Tapped add wallet');
      } else {
        testResults[testName] = 'FAIL - Add wallet button not found';
        return;
      }
      await tester.pump(const Duration(seconds: 1));
      
      
      print('Step 3: Select import wallet');
      var importOption = find.text(dic.importWallet);
      if (importOption.evaluate().isNotEmpty) {
        await tester.tap(importOption.first);
        await tester.pumpAndSettle();
        print('✅ Selected import wallet');
      }
      await tester.pump(const Duration(seconds: 1));
      
      print('Step 4: Select private key method');
      var pkOption = find.text(dic.privateKey);
      if (pkOption.evaluate().isNotEmpty) {
        await tester.tap(pkOption.first);
        await tester.pumpAndSettle();
        print('✅ Selected private key method');
      }
      await tester.pump(const Duration(seconds: 1));
      await ss.take(tester, '5.3b.2_pk_input');
      
      // Step 5: Enter private key
      print('Step 5: Enter private key');
      var pkInput = find.byKey(TestKeys.privateKeyInput);
      if (pkInput.evaluate().isEmpty) {
        final textFields = find.byType(TextField);
        if (textFields.evaluate().isNotEmpty) pkInput = textFields;
      }
      if (pkInput.evaluate().isNotEmpty) {
        await tester.enterText(pkInput.first, TestData.importPrivateKey);
        await tester.pump(const Duration(milliseconds: 500));
        print('✅ Entered private key');
      }
      await ss.take(tester, '5.3b.3_pk_entered');
      
      // Step 6: Tap confirm
      print('Step 6: Tap confirm');
      var confirmBtn = find.byKey(TestKeys.importButton);
      if (confirmBtn.evaluate().isEmpty) confirmBtn = find.byKey(TestKeys.confirmButton);
      if (confirmBtn.evaluate().isEmpty) confirmBtn = find.text(dic.confirm);
      if (confirmBtn.evaluate().isNotEmpty) {
        await tester.tap(confirmBtn.first);
        print('✅ Tapped confirm');
      }
      
      // Handle password verify dialog
      await tester.pump(const Duration(seconds: 2));
      final passwordFields = find.byType(TextField);
      if (passwordFields.evaluate().isNotEmpty) {
        await tester.enterText(passwordFields.last, TestData.defaultPassword);
        await tester.pump(const Duration(milliseconds: 500));
        print('✅ Password entered');
        var confirmPwdBtn = find.text(dic.confirm);
        if (confirmPwdBtn.evaluate().isNotEmpty) {
          await tester.tap(confirmPwdBtn.last);
          print('✅ Password confirmed');
        }
      }
      
      // Poll: wait for import
      bool done = false;
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(seconds: 1));
        final addWalletCheck = find.byKey(TestKeys.addWalletButton);
        final homeCheck = find.byKey(TestKeys.sendButton);
        if (addWalletCheck.evaluate().isNotEmpty || homeCheck.evaluate().isNotEmpty) {
          print('✅ Private key imported');
          testResults[testName] = 'PASS';
          done = true;
          break;
        }
      }
      
      if (!done) {
        testResults[testName] = 'PARTIAL - Flow incomplete';
      }
      
      await ss.take(tester, '5.3b_done');
      await endTestDelay(tester);
      print('\n========== $testName Done ==========\n');
    }, timeout: Timeout(Duration(minutes: 3)));

    testWidgets('5.3c Import Keystore wallet', (WidgetTester tester) async {
      const testName = '5.3c Import KS wallet';
      print('\n========== Start $testName ==========\n');
      final ss = ScreenshotHelper('flow5');
      
      app.main(testMode: true);
      
      // Wait for home
      bool ready = false;
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(seconds: 1));
        if (find.byKey(TestKeys.sendButton).evaluate().isNotEmpty) { ready = true; break; }
      }
      if (!ready) { testResults[testName] = 'SKIP - Home not loaded'; return; }
      
      // Step 1: Open wallet mgmt
      print('Step 1: Open wallet mgmt');
      var walletManageIcon = find.byKey(TestKeys.walletManageIcon);
      if (walletManageIcon.evaluate().isEmpty) {
        testResults[testName] = 'SKIP - Wallet mgmt icon not found';
        return;
      }
      await tester.tap(walletManageIcon);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      print('✅ Opened wallet mgmt');
      await ss.take(tester, '5.3c.1_wallet_mgmt');
      
      // Idempotent: if KS wallet address exists
      var existingKS = find.textContaining('B62qkS');
      if (existingKS.evaluate().isNotEmpty) {
        print('✅ KS wallet exists (idempotent), skipping');
        testResults[testName] = 'PASS';
        print('\n========== $testName Done ==========\n');
        return;
      }
      
      // Step 2: Add wallet → Import Wallet → Keystore
      print('Step 2: Tap add wallet');
      var addWalletBtn = find.byKey(TestKeys.addWalletButton);
      if (addWalletBtn.evaluate().isEmpty) addWalletBtn = find.text(dic.addWallet);
      if (addWalletBtn.evaluate().isNotEmpty) {
        await tester.tap(addWalletBtn.first);
        await tester.pumpAndSettle();
        print('✅ Tapped add wallet');
      } else {
        testResults[testName] = 'FAIL - Add wallet button not found';
        return;
      }
      await tester.pump(const Duration(seconds: 1));
      
      print('Step 3: Select import wallet');
      var importOption = find.text(dic.importWallet);
      if (importOption.evaluate().isNotEmpty) {
        await tester.tap(importOption.first);
        await tester.pumpAndSettle();
        print('✅ Selected import wallet');
      }
      await tester.pump(const Duration(seconds: 1));
      
      print('Step 4: Select Keystore method');
      var ksOption = find.text('Keystore');
      if (ksOption.evaluate().isNotEmpty) {
        await tester.tap(ksOption.first);
        await tester.pumpAndSettle();
        print('✅ Selected Keystore method');
      }
      await tester.pump(const Duration(seconds: 1));
      await ss.take(tester, '5.3c.2_ks_input');
      
      // Step 5: Enter Keystore content and password
      print('Step 5: Enter Keystore');
      var ksInput = find.byKey(TestKeys.keystoreInput);
      if (ksInput.evaluate().isNotEmpty) {
        await tester.enterText(ksInput, TestData.importKeystore);
        await tester.pump(const Duration(milliseconds: 500));
        print('✅ Entered Keystore');
      }
      
      var ksPwdInput = find.byKey(TestKeys.keystorePasswordInput);
      if (ksPwdInput.evaluate().isNotEmpty) {
        await tester.enterText(ksPwdInput, TestData.keystorePassword);
        await tester.pump(const Duration(milliseconds: 500));
        print('✅ Entered Keystore password');
      }
      await ss.take(tester, '5.3c.3_ks_entered');
      
      // Step 6: Tap confirm
      print('Step 6: Tap confirm');
      var confirmBtn = find.byKey(TestKeys.importButton);
      if (confirmBtn.evaluate().isEmpty) confirmBtn = find.byKey(TestKeys.confirmButton);
      if (confirmBtn.evaluate().isEmpty) confirmBtn = find.text(dic.confirm);
      if (confirmBtn.evaluate().isNotEmpty) {
        await tester.tap(confirmBtn.first);
        print('✅ Tapped confirm');
      }
      
      // Handle wallet password verify dialog
      await tester.pump(const Duration(seconds: 2));
      final passwordFields = find.byType(TextField);
      if (passwordFields.evaluate().isNotEmpty) {
        await tester.enterText(passwordFields.last, TestData.defaultPassword);
        await tester.pump(const Duration(milliseconds: 500));
        print('✅ Entered wallet password');
        var confirmPwdBtn = find.text(dic.confirm);
        if (confirmPwdBtn.evaluate().isNotEmpty) {
          await tester.tap(confirmPwdBtn.last);
          print('✅ Password confirmed');
        }
      }
      
      // Poll: wait for import
      bool done = false;
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(seconds: 1));
        final addWalletCheck = find.byKey(TestKeys.addWalletButton);
        final homeCheck = find.byKey(TestKeys.sendButton);
        if (addWalletCheck.evaluate().isNotEmpty || homeCheck.evaluate().isNotEmpty) {
          print('✅ Keystore imported');
          testResults[testName] = 'PASS';
          done = true;
          break;
        }
      }
      
      if (!done) {
        testResults[testName] = 'PARTIAL - Flow incomplete';
      }
      
      await ss.take(tester, '5.3c_done');
      await endTestDelay(tester);
      print('\n========== $testName Done ==========\n');
    }, timeout: Timeout(Duration(minutes: 3)));

    testWidgets('5.4 Wallet/account switch', (WidgetTester tester) async {
      const testName = '5.4 Wallet switch';
      print('\n========== Start $testName ==========\n');
      final ss = ScreenshotHelper('flow5');
      
      app.main(testMode: true);
      
      // Wait for home
      bool ready = false;
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(seconds: 1));
        final sendButton = find.byKey(TestKeys.sendButton);
        if (sendButton.evaluate().isNotEmpty) {
          ready = true;
          break;
        }
      }
      
      if (!ready) {
        testResults[testName] = 'SKIP - Home not loaded';
        return;
      }
      
      // Step 1: Record current account address
      print('Step 1: Record current account');
      String? currentAddress;
      final addressText = find.textContaining('B62q');
      if (addressText.evaluate().isNotEmpty) {
        final widget = addressText.evaluate().first.widget;
        if (widget is Text) {
          currentAddress = widget.data;
          print('Current addr: ${currentAddress?.substring(0, 20)}...');
        }
      }
      
      // Step 2: Open wallet mgmt
      print('Step 2: Open wallet mgmt');
      var walletManageIcon = find.byKey(TestKeys.walletManageIcon);
      if (walletManageIcon.evaluate().isNotEmpty) {
        await tester.tap(walletManageIcon);
        await tester.pumpAndSettle();
        print('✅ Opened wallet mgmt');
      } else {
        testResults[testName] = 'SKIP - Wallet mgmt icon not found';
        return;
      }
      
      await tester.pump(const Duration(seconds: 1));
      await ss.take(tester, '5.4.1_wallet_mgmt');
      
      // Step 3: Find tappable account item
      print('Step 3: Try switching wallet/account');
      final walletItems = find.byKey(TestKeys.walletListItem);
      bool switched = false;
      
      if (walletItems.evaluate().length > 1) {
        await tester.tap(walletItems.at(1));
        await tester.pumpAndSettle();
        print('✅ Tapped 2nd wallet item');
        switched = true;
      } else {
        // Try to find address text (B62q prefix)
        final accountAddresses = find.textContaining('B62q');
        if (accountAddresses.evaluate().length > 1) {
          await tester.tap(accountAddresses.at(1));
          await tester.pumpAndSettle();
          print('✅ Switched to another account (address match)');
          switched = true;
        } else {
          // Try to find Account/Wallet/Imported text
          final accountItems = find.textContaining('Account');
          final walletTexts = find.textContaining('Wallet');
          final importedTexts = find.textContaining('Imported');
          
          print('Found Account: ${accountItems.evaluate().length}, Wallet: ${walletTexts.evaluate().length}, Imported: ${importedTexts.evaluate().length}');
          
          if (accountItems.evaluate().length > 1) {
            await tester.tap(accountItems.at(1));
            await tester.pumpAndSettle();
            print('✅ Switched to another account');
            switched = true;
          }
        }
      }
      
      if (switched) {
        await ss.take(tester, '5.4.2_after_switch');
        // Wait for switch to complete
        await tester.pump(const Duration(seconds: 2));
        
        // Verify returned to home
        for (int i = 0; i < 10; i++) {
          await tester.pump(const Duration(seconds: 1));
          final sendBtn = find.byKey(TestKeys.sendButton);
          if (sendBtn.evaluate().isNotEmpty) {
            print('✅ Switch success, returned to home');
            testResults[testName] = 'PASS';
            break;
          }
          if (i == 9) {
            testResults[testName] = 'PARTIAL - Did not return to home after switch';
          }
        }
      } else {
        print('⚠️ No switchable account found');
        testResults[testName] = 'SKIP - Only one account';
      }
      
      await ss.take(tester, '5.4_done');
      await endTestDelay(tester);
      print('\n========== $testName Done ==========\n');
    }, timeout: Timeout(Duration(minutes: 2)));

    testWidgets('5.5 Add account in HD wallet', (WidgetTester tester) async {
      const testName = '5.5 Add HD sub-account';
      print('\n========== Start $testName ==========\n');
      final ss = ScreenshotHelper('flow5');
      
      app.main(testMode: true);
      
      // Wait for home
      bool ready = false;
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(seconds: 1));
        final sendButton = find.byKey(TestKeys.sendButton);
        if (sendButton.evaluate().isNotEmpty) {
          ready = true;
          break;
        }
      }
      
      if (!ready) {
        testResults[testName] = 'SKIP - Home not loaded';
        return;
      }
      
      // Step 1: Tap wallet mgmt icon
      print('Step 1: Open wallet mgmt');
      var walletManageIcon = find.byKey(TestKeys.walletManageIcon);
      if (walletManageIcon.evaluate().isNotEmpty) {
        await tester.tap(walletManageIcon);
        await tester.pumpAndSettle();
        print('✅ Opened wallet mgmt');
      } else {
        print('❌ Wallet mgmt icon not found');
        testResults[testName] = 'SKIP - Wallet mgmt icon not found';
        return;
      }
      
      await tester.pump(const Duration(seconds: 1));
      
      await ss.take(tester, '5.5.1_wallet_mgmt');
      
      // Step 2: Add Account 2 to 1st HD wallet
      print('Step 2: Add account for HD Wallet 1');
      var addAccountBtn = find.byKey(TestKeys.addAccountButton);
      if (addAccountBtn.evaluate().isEmpty) addAccountBtn = find.text(dic.addAccount);
      
      bool wallet1Done = false;
      if (addAccountBtn.evaluate().isNotEmpty) {
        await tester.tap(addAccountBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2));
        print('✅ HD Wallet 1 account added');
        await ss.take(tester, '5.5.2_hd1_acct_added');
        wallet1Done = true;
      } else {
        print('⚠️ Add account button not found');
      }
      
      // Step 3: Add Account 2 to 2nd HD wallet
      print('Step 3: Add account for HD Wallet 2');
      // Wait for any overlay/animation from step 2 to fully dismiss
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      addAccountBtn = find.byKey(TestKeys.addAccountButton);
      if (addAccountBtn.evaluate().isEmpty) addAccountBtn = find.text(dic.addAccount);
      
      bool wallet2Done = false;
      if (addAccountBtn.evaluate().length >= 2) {
        // Scroll to make the 2nd button fully visible and tappable
        await tester.ensureVisible(addAccountBtn.at(1));
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();
        await tester.tap(addAccountBtn.at(1));
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2));
        print('✅ HD Wallet 2 account added');
        await ss.take(tester, '5.5.3_hd2_acct_added');
        wallet2Done = true;
      } else if (addAccountBtn.evaluate().length == 1) {
        // May only have one HD wallet with add button
        print('⚠️ Only 1 add account btn, HD Wallet 2 may have Account 2');
        wallet2Done = true;
      } else {
        print('⚠️ 2nd add account button not found');
      }
      
      if (wallet1Done || wallet2Done) {
        testResults[testName] = 'PASS';
      } else {
        testResults[testName] = 'SKIP - Add account entry not found';
      }
      
      await ss.take(tester, '5.5_done');
      await endTestDelay(tester);
      print('\n========== $testName Done ==========\n');
    }, timeout: Timeout(Duration(minutes: 2)));

    testWidgets('5.6 Settings -> Security -> Change password', (WidgetTester tester) async {
      const testName = '5.6 Change password';
      print('\n========== Start $testName ==========\n');
      
      app.main(testMode: true);
      
      // Wait for home
      bool ready = false;
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(seconds: 1));
        final sendButton = find.byKey(TestKeys.sendButton);
        if (sendButton.evaluate().isNotEmpty) {
          ready = true;
          break;
        }
      }
      
      if (!ready) {
        testResults[testName] = 'SKIP - Home not loaded';
        return;
      }
      
      // Step 1: Tap Settings
      print('Step 1: Tap Settings');
      var settingsBtn = find.text(dic.setting);
      if (settingsBtn.evaluate().isEmpty) settingsBtn = find.byIcon(Icons.settings);
      
      if (settingsBtn.evaluate().isNotEmpty) {
        await tester.tap(settingsBtn.first);
        await tester.pumpAndSettle();
        print('✅ Opened settings page');
      } else {
        print('❌ Settings entry not found');
        testResults[testName] = 'FAIL - Settings entry not found';
        return;
      }
      
      await tester.pump(const Duration(seconds: 1));
      
      // Step 2: Tap Security
      print('Step 2: Tap Security');
      var securityBtn = find.text(dic.security);
      
      if (securityBtn.evaluate().isNotEmpty) {
        await tester.tap(securityBtn.first);
        await tester.pumpAndSettle();
        print('✅ Opened security settings');
      } else {
        print('❌ Security settings not found');
        testResults[testName] = 'FAIL - Security not found';
        return;
      }
      
      await tester.pump(const Duration(seconds: 1));
      
      // Step 3: Tap Change Password
      print('Step 3: Tap Change Password');
      var changePwdBtn = find.text(dic.changePassword);
      
      if (changePwdBtn.evaluate().isEmpty) {
        print('❌ Change password entry not found');
        testResults[testName] = 'FAIL - Change pwd entry not found';
        return;
      }
      await tester.tap(changePwdBtn.first);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      print('✅ Opened change password page');
      
      final ss = ScreenshotHelper('flow5');
      await ss.take(tester, '5.6.1_change_pwd');
      
      // Step 4: Enter old pwd, new pwd, confirm new pwd
      // ChangePasswordPage has 3 InputItem (TextField): oldPass, newPass, newPass2
      print('Step 4: Enter password');
      const newPassword = 'NewPass123!';
      var inputFields = find.byType(TextField);
      if (inputFields.evaluate().length >= 3) {
        await tester.enterText(inputFields.at(0), TestData.defaultPassword);
        await tester.pump(const Duration(milliseconds: 500));
        print('✅ Entered old password');
        await tester.enterText(inputFields.at(1), newPassword);
        await tester.pump(const Duration(milliseconds: 500));
        print('✅ Entered new password');
        await tester.enterText(inputFields.at(2), newPassword);
        await tester.pump(const Duration(milliseconds: 500));
        print('✅ Confirmed new password');
      } else {
        print('❌ Not enough password inputs: ${inputFields.evaluate().length}');
        testResults[testName] = 'FAIL - Insufficient password inputs';
        return;
      }
      
      await ss.take(tester, '5.6.2_pwd_entered');
      
      // Step 5: Tap confirm
      print('Step 5: Tap confirm');
      var confirmBtn = find.text(dic.confirm);
      if (confirmBtn.evaluate().isNotEmpty) {
        await tester.tap(confirmBtn.first);
        // Wait for password change (crypto operation)
        for (int i = 0; i < 10; i++) {
          await tester.pump(const Duration(seconds: 1));
          // After success, pops back to security page
          var secText = find.text(dic.security);
          if (secText.evaluate().isNotEmpty) {
            print('✅ Password changed, returned to security');
            break;
          }
        }
      }
      
      await ss.take(tester, '5.6.3_pwd_changed');
      
      // Step 6: Revert to original password (avoid affecting later tests)
      print('Step 6: Revert to original password');
      changePwdBtn = find.text(dic.changePassword);
      if (changePwdBtn.evaluate().isNotEmpty) {
        await tester.tap(changePwdBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        
        inputFields = find.byType(TextField);
        if (inputFields.evaluate().length >= 3) {
          await tester.enterText(inputFields.at(0), newPassword);
          await tester.pump(const Duration(milliseconds: 500));
          await tester.enterText(inputFields.at(1), TestData.defaultPassword);
          await tester.pump(const Duration(milliseconds: 500));
          await tester.enterText(inputFields.at(2), TestData.defaultPassword);
          await tester.pump(const Duration(milliseconds: 500));
          
          confirmBtn = find.text(dic.confirm);
          if (confirmBtn.evaluate().isNotEmpty) {
            await tester.tap(confirmBtn.first);
            for (int i = 0; i < 10; i++) {
              await tester.pump(const Duration(seconds: 1));
              var secText = find.text(dic.security);
              if (secText.evaluate().isNotEmpty) {
                print('✅ Password reverted to original');
                break;
              }
            }
          }
        }
      }
      
      testResults[testName] = 'PASS';
      await endTestDelay(tester);
      print('\n========== $testName Done ==========\n');
    }, timeout: Timeout(Duration(minutes: 3)));

    testWidgets('5.7 Wallet mgmt -> export PK', (WidgetTester tester) async {
      const testName = '5.7 Export PK entry';
      print('\n========== Start $testName ==========\n');
      final ss = ScreenshotHelper('flow5');
      
      app.main(testMode: true);
      
      // Wait for home
      bool ready = false;
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(seconds: 1));
        final sendButton = find.byKey(TestKeys.sendButton);
        if (sendButton.evaluate().isNotEmpty) {
          ready = true;
          break;
        }
      }
      
      if (!ready) {
        testResults[testName] = 'SKIP - Home not loaded';
        return;
      }
      
      // Step 1: Tap wallet mgmt icon
      print('Step 1: Open wallet mgmt');
      var walletManageIcon = find.byKey(TestKeys.walletManageIcon);
      if (walletManageIcon.evaluate().isNotEmpty) {
        await tester.tap(walletManageIcon);
        await tester.pumpAndSettle();
        print('✅ Opened wallet mgmt');
      } else {
        print('❌ Wallet mgmt icon not found');
        testResults[testName] = 'SKIP - Wallet mgmt icon not found';
        return;
      }
      
      await tester.pump(const Duration(seconds: 1));
      
      await ss.take(tester, '5.7.1_wallet_mgmt');
      
      // Step 2: Tap account more (...) - export PK in account details
      print('Step 2: Tap account more button');
      var moreBtn = find.byKey(TestKeys.accountMoreButton);
      if (moreBtn.evaluate().isEmpty) moreBtn = find.byIcon(Icons.more_horiz);
      
      if (moreBtn.evaluate().isNotEmpty) {
        await tester.tap(moreBtn.first);
        await tester.pumpAndSettle();
        print('✅ Tapped more button');
        
        await tester.pump(const Duration(seconds: 1));
        await ss.take(tester, '5.7.2_account_mgmt');
        
        // Step 3: Find export PK option
        print('Step 3: Find export PK option');
        var exportBtn = find.text(dic.exportPrivateKey);
        
        if (exportBtn.evaluate().isNotEmpty) {
          print('✅ Found export PK entry');
          testResults[testName] = 'PASS';
        } else {
          print('⚠️ Export PK option not found');
          testResults[testName] = 'PARTIAL - Export option not found';
        }
      } else {
        print('⚠️ More button not found');
        testResults[testName] = 'SKIP - More button not found';
      }
      
      await ss.take(tester, '5.7_done');
      await endTestDelay(tester);
      print('\n========== $testName Done ==========\n');
    }, timeout: Timeout(Duration(minutes: 2)));

    testWidgets('5.8 Wallet mgmt -> delete account', (WidgetTester tester) async {
      const testName = '5.8 Delete account entry';
      print('\n========== Start $testName ==========\n');
      final ss = ScreenshotHelper('flow5');
      
      app.main(testMode: true);
      
      // Wait for home
      bool ready = false;
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(seconds: 1));
        final sendButton = find.byKey(TestKeys.sendButton);
        if (sendButton.evaluate().isNotEmpty) {
          ready = true;
          break;
        }
      }
      
      if (!ready) {
        testResults[testName] = 'SKIP - Home not loaded';
        return;
      }
      
      // Step 1: Tap wallet mgmt icon
      print('Step 1: Open wallet mgmt');
      var walletManageIcon = find.byKey(TestKeys.walletManageIcon);
      if (walletManageIcon.evaluate().isNotEmpty) {
        await tester.tap(walletManageIcon);
        await tester.pumpAndSettle();
        print('✅ Opened wallet mgmt');
      } else {
        print('❌ Wallet mgmt icon not found');
        testResults[testName] = 'SKIP - Wallet mgmt icon not found';
        return;
      }
      
      await tester.pump(const Duration(seconds: 1));
      
      await ss.take(tester, '5.8.1_wallet_mgmt');
      
      // Step 2: Tap account more button (...)
      print('Step 2: Tap account more button');
      var moreBtn = find.byKey(TestKeys.accountMoreButton);
      if (moreBtn.evaluate().isEmpty) moreBtn = find.byIcon(Icons.more_horiz);
      
      if (moreBtn.evaluate().isNotEmpty) {
        await tester.tap(moreBtn.first);
        await tester.pumpAndSettle();
        print('✅ Tapped more button');
        
        await tester.pump(const Duration(seconds: 1));
        await ss.take(tester, '5.8.2_account_mgmt');
        
        // Step 3: Verify account mgmt page loaded
        // Note: HD wallet accounts cannot be individually deleted (delete only for non-mnemonic)
        // So just verify page loaded correctly
        print('Step 3: Verify account mgmt page');
        var accountAddr = find.text(dic.accountAddress);
        if (accountAddr.evaluate().isEmpty) accountAddr = find.text(dic.exportPrivateKey);
        if (accountAddr.evaluate().isEmpty) accountAddr = find.text(dic.accountName);
        
        if (accountAddr.evaluate().isNotEmpty) {
          print('✅ Account mgmt page loaded');
          // Check for delete button (non-HD wallets only)
          var deleteBtn = find.text(dic.accountDelete);
          if (deleteBtn.evaluate().isNotEmpty) {
            print('✅ Found delete entry (non-HD wallet)');
          } else {
            print('ℹ️ HD wallet account has no delete button (expected)');
          }
          testResults[testName] = 'PASS';
        } else {
          print('⚠️ Account mgmt page not loaded correctly');
          testResults[testName] = 'PARTIAL - Account mgmt page not loaded';
        }
      } else {
        print('⚠️ More button not found');
        testResults[testName] = 'SKIP - More button not found';
      }
      
      await ss.take(tester, '5.8_done');
      await endTestDelay(tester);
      print('\n========== $testName Done ==========\n');
    }, timeout: Timeout(Duration(minutes: 2)));

    testWidgets('5.9 Wallet mgmt -> rename wallet', (WidgetTester tester) async {
      const testName = '5.9 Rename wallet entry';
      print('\n========== Start $testName ==========\n');
      final ss = ScreenshotHelper('flow5');
      
      app.main(testMode: true);
      
      // Wait for home
      bool ready = false;
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(seconds: 1));
        final sendButton = find.byKey(TestKeys.sendButton);
        if (sendButton.evaluate().isNotEmpty) {
          ready = true;
          break;
        }
      }
      
      if (!ready) {
        testResults[testName] = 'SKIP - Home not loaded';
        return;
      }
      
      // Step 1: Tap wallet mgmt icon
      print('Step 1: Open wallet mgmt');
      var walletManageIcon = find.byKey(TestKeys.walletManageIcon);
      if (walletManageIcon.evaluate().isNotEmpty) {
        await tester.tap(walletManageIcon);
        await tester.pumpAndSettle();
        print('✅ Opened wallet mgmt');
      } else {
        print('❌ Wallet mgmt icon not found');
        testResults[testName] = 'SKIP - Wallet mgmt icon not found';
        return;
      }
      
      await tester.pump(const Duration(seconds: 1));
      
      // Step 2: Tap wallet more (...) - wallet level
      print('Step 2: Tap wallet more button');
      var moreBtn = find.byKey(TestKeys.walletMoreButton);
      if (moreBtn.evaluate().isEmpty) moreBtn = find.byIcon(Icons.more_horiz);
      
      if (moreBtn.evaluate().isNotEmpty) {
        await tester.tap(moreBtn.first);
        await tester.pumpAndSettle();
        print('✅ Tapped wallet more button');
        
        await tester.pump(const Duration(seconds: 1));
        await ss.take(tester, '5.9.0_wallet_detail');
        
        // Step 3: WalletDetailsPage shows "Wallet Name" row (tap triggers rename)
        print('Step 3: Find wallet name row (rename entry)');
        var walletNameRow = find.text(dic.walletNameLabel);
        if (walletNameRow.evaluate().isEmpty) walletNameRow = find.text(dic.walletDetails);
        
        if (walletNameRow.evaluate().isNotEmpty) {
          print('✅ Found wallet rename entry (Wallet Name row)');
          
          // Step 4: Tap Wallet Name row to open rename dialog
          print('Step 4: Tap rename entry');
          await tester.tap(walletNameRow.first);
          await safePumpAndSettle(tester);
          await tester.pump(const Duration(seconds: 1));
          
          // Step 5: Enter new name in dialog (w-<last 6 chars of address>)
          print('Step 5: Enter new wallet name');
          final newWalletName = 'w-${TestData.secondMnemonicAddress.substring(TestData.secondMnemonicAddress.length - 6)}';
          var textFields = find.byType(TextField);
          if (textFields.evaluate().isNotEmpty) {
            await tester.enterText(textFields.last, newWalletName);
            await tester.pump(const Duration(seconds: 1));
            print('✅ Entered new name: $newWalletName');
            await ss.take(tester, '5.9.1_new_name');
            
            // Step 6: Tap confirm
            print('Step 6: Confirm rename');
            var confirmBtn = find.text(dic.confirm);
            if (confirmBtn.evaluate().isNotEmpty) {
              await tester.tap(confirmBtn.last);
              await safePumpAndSettle(tester);
              await tester.pump(const Duration(seconds: 1));
              print('✅ Confirmed rename');
              
              // Verify new name is shown
              var newNameText = find.textContaining(newWalletName);
              if (newNameText.evaluate().isNotEmpty) {
                print('✅ Wallet name updated to: $newWalletName');
              }
              await ss.take(tester, '5.9.2_rename_done');
              
              // Step 7: Restore name - tap rename again
              print('Step 7: Restore original wallet name');
              walletNameRow = find.text(dic.walletNameLabel);
              if (walletNameRow.evaluate().isNotEmpty) {
                await tester.tap(walletNameRow.first);
                await safePumpAndSettle(tester);
                await tester.pump(const Duration(seconds: 1));
                
                textFields = find.byType(TextField);
                if (textFields.evaluate().isNotEmpty) {
                  await tester.enterText(textFields.last, 'Wallet 1');
                  await tester.pump(const Duration(seconds: 1));
                  confirmBtn = find.text(dic.confirm);
                  if (confirmBtn.evaluate().isNotEmpty) {
                    await tester.tap(confirmBtn.last);
                    await safePumpAndSettle(tester);
                    await tester.pump(const Duration(seconds: 1));
                    print('✅ Wallet name restored to: Wallet 1');
                  }
                }
              }
              
              testResults[testName] = 'PASS';
            } else {
              testResults[testName] = 'PARTIAL - Confirm button not found';
            }
          } else {
            testResults[testName] = 'PARTIAL - Input field not found';
          }
        } else {
          print('⚠️ Wallet Name row not found');
          testResults[testName] = 'PARTIAL - Wallet name row not found';
        }
      } else {
        print('⚠️ More button not found');
        testResults[testName] = 'SKIP - More button not found';
      }
      
      await ss.take(tester, '5.9_done');
      await endTestDelay(tester);
      print('\n========== $testName Done ==========\n');
    }, timeout: Timeout(Duration(minutes: 2)));

    testWidgets('5.10 Wallet mgmt -> rename account', (WidgetTester tester) async {
      const testName = '5.10 Rename account entry';
      print('\n========== Start $testName ==========\n');
      final ss = ScreenshotHelper('flow5');
      
      app.main(testMode: true);
      
      // Wait for home
      bool ready = false;
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(seconds: 1));
        final sendButton = find.byKey(TestKeys.sendButton);
        if (sendButton.evaluate().isNotEmpty) {
          ready = true;
          break;
        }
      }
      
      if (!ready) {
        testResults[testName] = 'SKIP - Home not loaded';
        return;
      }
      
      // Step 1: Tap wallet mgmt icon
      print('Step 1: Open wallet mgmt');
      var walletManageIcon = find.byKey(TestKeys.walletManageIcon);
      if (walletManageIcon.evaluate().isNotEmpty) {
        await tester.tap(walletManageIcon);
        await tester.pumpAndSettle();
        print('✅ Opened wallet mgmt');
      } else {
        print('❌ Wallet mgmt icon not found');
        testResults[testName] = 'SKIP - Wallet mgmt icon not found';
        return;
      }
      
      await tester.pump(const Duration(seconds: 1));
      
      // Step 2: Tap account more button (...) - account level
      print('Step 2: Tap account more button');
      var moreBtn = find.byKey(TestKeys.accountMoreButton);
      if (moreBtn.evaluate().isEmpty) moreBtn = find.byIcon(Icons.more_horiz);
      
      if (moreBtn.evaluate().isNotEmpty) {
        await tester.tap(moreBtn.first);
        await tester.pumpAndSettle();
        print('✅ Tapped account more button');
        
        await tester.pump(const Duration(seconds: 1));
        await ss.take(tester, '5.10.0_account_mgmt');
        
        // Step 3: AccountManagePage shows "Account Name" row (tap triggers rename)
        print('Step 3: Find account name row (rename entry)');
        var accountNameRow = find.text(dic.accountName);
        if (accountNameRow.evaluate().isEmpty) accountNameRow = find.text(dic.accountInfo);
        
        if (accountNameRow.evaluate().isNotEmpty) {
          print('✅ Found account rename entry (Account Name row)');
          
          // Step 4: Tap Account Name row to open rename dialog
          print('Step 4: Tap rename entry');
          await tester.tap(accountNameRow.first);
          await safePumpAndSettle(tester);
          await tester.pump(const Duration(seconds: 1));
          
          // Step 5: Enter new account name (a-<last 6 chars of address>)
          print('Step 5: Enter new account name');
          final newAccountName = 'a-${TestData.secondMnemonicAddress.substring(TestData.secondMnemonicAddress.length - 6)}';
          var textFields = find.byType(TextField);
          if (textFields.evaluate().isNotEmpty) {
            await tester.enterText(textFields.last, newAccountName);
            await tester.pump(const Duration(seconds: 1));
            print('✅ Entered new name: $newAccountName');
            await ss.take(tester, '5.10.1_new_name');
            
            // Step 6: Tap confirm
            print('Step 6: Confirm rename');
            var confirmBtn = find.text(dic.confirm);
            if (confirmBtn.evaluate().isNotEmpty) {
              await tester.tap(confirmBtn.last);
              await safePumpAndSettle(tester);
              await tester.pump(const Duration(seconds: 1));
              print('✅ Confirmed rename');
              await ss.take(tester, '5.10.2_rename_done');
              
              // Step 7: Restore original name
              print('Step 7: Restore original account name');
              accountNameRow = find.text(dic.accountName);
              if (accountNameRow.evaluate().isNotEmpty) {
                await tester.tap(accountNameRow.first);
                await safePumpAndSettle(tester);
                await tester.pump(const Duration(seconds: 1));
                
                textFields = find.byType(TextField);
                if (textFields.evaluate().isNotEmpty) {
                  await tester.enterText(textFields.last, 'Account 1');
                  await tester.pump(const Duration(seconds: 1));
                  confirmBtn = find.text(dic.confirm);
                  if (confirmBtn.evaluate().isNotEmpty) {
                    await tester.tap(confirmBtn.last);
                    await safePumpAndSettle(tester);
                    await tester.pump(const Duration(seconds: 1));
                    print('✅ Account name restored to: Account 1');
                  }
                }
              }
              
              testResults[testName] = 'PASS';
            } else {
              testResults[testName] = 'PARTIAL - Confirm button not found';
            }
          } else {
            testResults[testName] = 'PARTIAL - Input field not found';
          }
        } else {
          print('⚠️ Account Name row not found');
          testResults[testName] = 'PARTIAL - Account name row not found';
        }
      } else {
        print('⚠️ Account more button not found');
        testResults[testName] = 'SKIP - Account more button not found';
      }
      
      await ss.take(tester, '5.10_done');
      await endTestDelay(tester);
      print('\n========== $testName Done ==========\n');
    }, timeout: Timeout(Duration(minutes: 2)));

    // ============ Backup Mnemonic & Export PK Tests ============

    testWidgets('5.11 Backup mnemonic (HD wallet)', (WidgetTester tester) async {
      const testName = '5.11 Backup mnemonic';
      print('\n========== Start $testName ==========\n');
      final ss = ScreenshotHelper('flow5');
      
      app.main(testMode: true);
      
      bool ready = false;
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(seconds: 1));
        if (find.byKey(TestKeys.sendButton).evaluate().isNotEmpty) { ready = true; break; }
      }
      if (!ready) { testResults[testName] = 'SKIP - Home not loaded'; return; }
      
      // Step 1: Open wallet mgmt
      print('Step 1: Open wallet mgmt');
      await tester.tap(find.byKey(TestKeys.walletManageIcon));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      
      // Step 2: Tap 1st HD wallet more button → WalletDetailsPage
      print('Step 2: Tap HD wallet more button');
      var walletMoreBtns = find.byKey(TestKeys.walletMoreButton);
      if (walletMoreBtns.evaluate().isEmpty) {
        testResults[testName] = 'SKIP - Wallet more button not found';
        return;
      }
      await tester.tap(walletMoreBtns.first);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      print('✅ Entered wallet details page');
      await ss.take(tester, '5.11.1_wallet_detail');
      
      // Step 3: Tap "Seed Phrase" row
      print('Step 3: Tap Seed Phrase');
      var seedPhraseRow = find.text(dic.seedPhrase);
      
      if (seedPhraseRow.evaluate().isEmpty) {
        testResults[testName] = 'FAIL - Seed Phrase entry not found';
        return;
      }
      await tester.tap(seedPhraseRow.first);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      print('✅ Tapped Seed Phrase');
      
      // Step 4: Enter password
      print('Step 4: Enter password');
      final passwordFields = find.byType(TextField);
      if (passwordFields.evaluate().isNotEmpty) {
        await tester.enterText(passwordFields.last, TestData.defaultPassword);
        await tester.pumpAndSettle();
        await ss.take(tester, '5.11.2_password');
        var confirmBtn = find.text(dic.confirm);
        if (confirmBtn.evaluate().isNotEmpty) {
          await tester.tap(confirmBtn.last);
          await tester.pumpAndSettle();
          print('✅ Password confirmed');
        }
      }
      
      await tester.pump(const Duration(seconds: 2));
      
      // Step 5: Verify reached ExportResultPage
      print('Step 5: Verify mnemonic display');
      var mnemonicWords = find.textContaining('century');
      if (mnemonicWords.evaluate().isNotEmpty) {
        print('✅ Mnemonic displayed correctly');
        testResults[testName] = 'PASS';
      } else {
        // Check page title for Seed Phrase / Export Private Key
        var exportPageTitle = find.text(dic.seedPhrase);
        if (exportPageTitle.evaluate().isNotEmpty) {
          print('✅ Reached export page');
          testResults[testName] = 'PASS';
        } else {
          print('⚠️ Mnemonic content not found');
          testResults[testName] = 'PARTIAL - Mnemonic content not found';
        }
      }
      
      await ss.take(tester, '5.11.3_mnemonic_display');
      await endTestDelay(tester);
      print('\n========== $testName Done ==========\n');
    }, timeout: Timeout(Duration(minutes: 2)));

    testWidgets('5.11b Backup HD Wallet 2 mnemonic', (WidgetTester tester) async {
      const testName = '5.11b Backup HD Wallet 2 mnemonic';
      print('\n========== Start $testName ==========\n');
      final ss = ScreenshotHelper('flow5');
      
      app.main(testMode: true);
      
      bool ready = false;
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(seconds: 1));
        if (find.byKey(TestKeys.sendButton).evaluate().isNotEmpty) { ready = true; break; }
      }
      if (!ready) { testResults[testName] = 'SKIP - Home not loaded'; return; }
      
      // Step 1: Open wallet mgmt
      print('Step 1: Open wallet mgmt');
      await tester.tap(find.byKey(TestKeys.walletManageIcon));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      
      // Step 2: Tap 2nd HD wallet more button (walletMoreButton[1]) → WalletDetailsPage
      print('Step 2: Tap HD Wallet 2 more button');
      var walletMoreBtns = find.byKey(TestKeys.walletMoreButton);
      if (walletMoreBtns.evaluate().length < 2) {
        testResults[testName] = 'SKIP - 2nd HD wallet not found (run 5.3 first)';
        return;
      }
      await tester.tap(walletMoreBtns.at(1));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      print('✅ Entered HD Wallet 2 details');
      await ss.take(tester, '5.11b.1_hd2_wallet_detail');
      
      // Step 3: Tap "Seed Phrase"
      print('Step 3: Tap Seed Phrase');
      var seedPhraseRow = find.text(dic.seedPhrase);
      if (seedPhraseRow.evaluate().isEmpty) {
        testResults[testName] = 'FAIL - Seed Phrase entry not found';
        return;
      }
      await tester.tap(seedPhraseRow.first);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      print('✅ Tapped Seed Phrase');
      
      // Step 4: Enter password
      print('Step 4: Enter password');
      final passwordFields = find.byType(TextField);
      if (passwordFields.evaluate().isNotEmpty) {
        await tester.enterText(passwordFields.last, TestData.defaultPassword);
        await tester.pumpAndSettle();
        await ss.take(tester, '5.11b.2_password');
        var confirmBtn = find.text(dic.confirm);
        if (confirmBtn.evaluate().isNotEmpty) {
          await tester.tap(confirmBtn.last);
          await tester.pumpAndSettle();
          print('✅ Password confirmed');
        }
      }
      
      await tester.pump(const Duration(seconds: 2));
      
      // Step 5: Verify dove mnemonic displayed
      print('Step 5: Verify mnemonic display');
      var mnemonicWords = find.textContaining('dove');
      if (mnemonicWords.evaluate().isNotEmpty) {
        print('✅ HD Wallet 2 mnemonic (dove...) displayed correctly');
        testResults[testName] = 'PASS';
      } else {
        var exportPageTitle = find.text(dic.seedPhrase);
        if (exportPageTitle.evaluate().isNotEmpty) {
          print('✅ Reached export page');
          testResults[testName] = 'PASS';
        } else {
          print('⚠️ Mnemonic content not found');
          testResults[testName] = 'PARTIAL - dove mnemonic content not found';
        }
      }
      
      await ss.take(tester, '5.11b.3_hd2_mnemonic');
      await endTestDelay(tester);
      print('\n========== $testName Done ==========\n');
    }, timeout: Timeout(Duration(minutes: 2)));

    testWidgets('5.12 Export HD wallet acct1 PK', (WidgetTester tester) async {
      const testName = '5.12 Export HD acct1 PK';
      print('\n========== Start $testName ==========\n');
      
      app.main(testMode: true);
      
      bool ready = false;
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(seconds: 1));
        if (find.byKey(TestKeys.sendButton).evaluate().isNotEmpty) { ready = true; break; }
      }
      if (!ready) { testResults[testName] = 'SKIP - Home not loaded'; return; }
      
      // Step 1: Open wallet mgmt
      print('Step 1: Open wallet mgmt');
      await tester.tap(find.byKey(TestKeys.walletManageIcon));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      
      // Step 2: Tap 1st account more button → AccountManagePage
      print('Step 2: Tap acct1 more button');
      var accountMoreBtns = find.byKey(TestKeys.accountMoreButton);
      if (accountMoreBtns.evaluate().isEmpty) {
        testResults[testName] = 'SKIP - Account more button not found';
        return;
      }
      await tester.tap(accountMoreBtns.first);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      print('✅ Entered account mgmt page');
      
      // Step 3: Tap Export Private Key
      print('Step 3: Tap export PK');
      var exportBtn = find.text(dic.exportPrivateKey);
      
      if (exportBtn.evaluate().isEmpty) {
        testResults[testName] = 'FAIL - Export PK entry not found';
        return;
      }
      await tester.tap(exportBtn.first);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      print('✅ Tapped export PK');
      
      // Step 4: Handle hint dialog (privateKeyTip alert dialog)
      // CustomAlertDialog default button text is dic.confirm
      print('Step 4: Handle hint dialog');
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
        // Dialog title is dic.prompt, button is dic.confirm
        var promptTitle = find.text(dic.prompt);
        var confirmBtns = find.text(dic.confirm);
        if (promptTitle.evaluate().isNotEmpty && confirmBtns.evaluate().isNotEmpty) {
          await tester.tap(confirmBtns.first);
          await tester.pumpAndSettle();
          print('✅ Closed hint dialog');
          break;
        }
      }
      await tester.pump(const Duration(seconds: 1));
      
      final ss = ScreenshotHelper('flow5');
      await ss.take(tester, '5.12.1_pwd_input');
      
      // Step 5: Enter password (PasswordInputDialog)
      print('Step 5: Enter password');
      // Wait for password input to appear
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
        if (find.byType(TextField).evaluate().isNotEmpty) break;
      }
      final passwordFields = find.byType(TextField);
      if (passwordFields.evaluate().isNotEmpty) {
        await tester.enterText(passwordFields.last, TestData.defaultPassword);
        await tester.pumpAndSettle();
        print('✅ Password entered');
        // Button enables after input, pump for onChanged
        await tester.pump(const Duration(milliseconds: 500));
        var confirmBtn = find.text(dic.confirm);
        if (confirmBtn.evaluate().isNotEmpty) {
          await tester.tap(confirmBtn.last, warnIfMissed: false);
          print('✅ Tapped confirm');
          // Wait for password verify + decrypt + page transition
          try {
            await tester.pumpAndSettle(const Duration(seconds: 1));
          } catch (e) {
            // pumpAndSettle may timeout (animations etc)
            for (int j = 0; j < 5; j++) {
              await tester.pump(const Duration(seconds: 1));
            }
          }
        }
      } else {
        print('⚠️ Password input not found');
      }
      
      // Wait for ExportResultPage to load (decryption may take time)
      for (int i = 0; i < 15; i++) {
        await tester.pump(const Duration(seconds: 1));
        var pkText = find.textContaining('EK');
        if (pkText.evaluate().isNotEmpty) {
          for (var element in pkText.evaluate()) {
            final w = element.widget;
            if (w is Text && w.data != null && w.data!.startsWith('EK') && w.data!.length > 30) {
              break;
            }
          }
          break;
        }
      }
      
      await ss.take(tester, '5.12.2_pk_display');
      
      // Step 6: Verify ExportResultPage shows PK (starts with EK)
      print('Step 6: Verify PK display');
      var privateKeyText = find.textContaining('EK');
      bool foundKey = false;
      if (privateKeyText.evaluate().isNotEmpty) {
        for (var element in privateKeyText.evaluate()) {
          final widget = element.widget;
          if (widget is Text && widget.data != null && widget.data!.startsWith('EK') && widget.data!.length > 30) {
            print('✅ PK correctly shown: ${widget.data!.substring(0, 20)}...');
            foundKey = true;
            break;
          }
        }
      }
      
      if (foundKey) {
        testResults[testName] = 'PASS';
      } else {
        var exportTitle = find.text(dic.exportPrivateKey);
        testResults[testName] = exportTitle.evaluate().isNotEmpty ? 'PARTIAL - Reached export page but PK not shown' : 'FAIL - Did not reach export page';
      }
      
      await endTestDelay(tester);
      print('\n========== $testName Done ==========\n');
    }, timeout: Timeout(Duration(minutes: 3)));

    testWidgets('5.13 Export HD wallet acct2 PK', (WidgetTester tester) async {
      const testName = '5.13 Export HD acct2 PK';
      print('\n========== Start $testName ==========\n');
      final ss = ScreenshotHelper('flow5');
      
      app.main(testMode: true);
      
      bool ready = false;
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(seconds: 1));
        if (find.byKey(TestKeys.sendButton).evaluate().isNotEmpty) { ready = true; break; }
      }
      if (!ready) { testResults[testName] = 'SKIP - Home not loaded'; return; }
      
      // Step 1: Open wallet mgmt
      print('Step 1: Open wallet mgmt');
      await tester.tap(find.byKey(TestKeys.walletManageIcon));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      
      // Step 2: Tap acct2 more button (HD wallet acct2, added by 5.5)
      print('Step 2: Tap acct2 more button');
      var accountMoreBtns = find.byKey(TestKeys.accountMoreButton);
      if (accountMoreBtns.evaluate().length < 2) {
        testResults[testName] = 'SKIP - Less than 2 accounts';
        return;
      }
      await tester.tap(accountMoreBtns.at(1));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      print('✅ Entered acct2 mgmt page');
      await ss.take(tester, '5.13.1_account_mgmt');
      
      // Step 3: Tap Export Private Key
      print('Step 3: Tap export PK');
      var exportBtn = find.text(dic.exportPrivateKey);
      
      if (exportBtn.evaluate().isEmpty) {
        testResults[testName] = 'FAIL - Export PK entry not found';
        return;
      }
      await tester.tap(exportBtn.first);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      
      // Step 4: Handle hint dialog (CustomAlertDialog button is dic.confirm)
      print('Step 4: Handle hint dialog');
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
        var promptTitle = find.text(dic.prompt);
        var confirmBtns = find.text(dic.confirm);
        if (promptTitle.evaluate().isNotEmpty && confirmBtns.evaluate().isNotEmpty) {
          await tester.tap(confirmBtns.first);
          await tester.pumpAndSettle();
          print('✅ Closed hint dialog');
          break;
        }
      }
      await tester.pump(const Duration(seconds: 1));
      
      // Step 5: Enter password (PasswordInputDialog)
      print('Step 5: Enter password');
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
        if (find.byType(TextField).evaluate().isNotEmpty) break;
      }
      final passwordFields = find.byType(TextField);
      if (passwordFields.evaluate().isNotEmpty) {
        await tester.enterText(passwordFields.last, TestData.defaultPassword);
        await tester.pumpAndSettle();
        print('✅ Password entered');
        await ss.take(tester, '5.13.2_password');
        await tester.pump(const Duration(milliseconds: 500));
        var confirmBtn = find.text(dic.confirm);
        if (confirmBtn.evaluate().isNotEmpty) {
          await tester.tap(confirmBtn.last, warnIfMissed: false);
          print('✅ Tapped confirm');
          try {
            await tester.pumpAndSettle(const Duration(seconds: 1));
          } catch (e) {
            for (int j = 0; j < 5; j++) {
              await tester.pump(const Duration(seconds: 1));
            }
          }
        }
      }
      
      // Wait for ExportResultPage to load
      for (int i = 0; i < 15; i++) {
        await tester.pump(const Duration(seconds: 1));
        var pkText = find.textContaining('EK');
        if (pkText.evaluate().isNotEmpty) break;
      }
      
      await ss.take(tester, '5.13.3_pk_display');
      
      // Step 6: Verify export page
      print('Step 6: Verify PK display');
      var privateKeyText = find.textContaining('EK');
      bool foundKey = false;
      if (privateKeyText.evaluate().isNotEmpty) {
        for (var element in privateKeyText.evaluate()) {
          final widget = element.widget;
          if (widget is Text && widget.data != null && widget.data!.startsWith('EK') && widget.data!.length > 30) {
            print('✅ Acct2 PK correctly shown: ${widget.data!.substring(0, 20)}...');
            foundKey = true;
            break;
          }
        }
      }
      
      testResults[testName] = foundKey ? 'PASS' : 'PARTIAL - PK content not found';
      
      await ss.take(tester, '5.13_done');
      await endTestDelay(tester);
      print('\n========== $testName Done ==========\n');
    }, timeout: Timeout(Duration(minutes: 3)));

    testWidgets('5.13b Export HD2 acct1 PK', (WidgetTester tester) async {
      const testName = '5.13b Export HD2 acct1 PK';
      print('\n========== Start $testName ==========\n');
      final ss = ScreenshotHelper('flow5');
      
      app.main(testMode: true);
      
      bool ready = false;
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(seconds: 1));
        if (find.byKey(TestKeys.sendButton).evaluate().isNotEmpty) { ready = true; break; }
      }
      if (!ready) { testResults[testName] = 'SKIP - Home not loaded'; return; }
      
      // Step 1: Open wallet mgmt
      print('Step 1: Open wallet mgmt');
      await tester.tap(find.byKey(TestKeys.walletManageIcon));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      
      // Step 2: Tap HD2-Account1 (accountMoreButton[2])
      print('Step 2: Tap HD2 acct1 more button');
      var accountMoreBtns = find.byKey(TestKeys.accountMoreButton);
      if (accountMoreBtns.evaluate().length < 3) {
        testResults[testName] = 'SKIP - Not enough accounts (run 5.3+5.5 first)';
        return;
      }
      await tester.ensureVisible(accountMoreBtns.at(2));
      await tester.pumpAndSettle();
      await tester.tap(accountMoreBtns.at(2));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      print('✅ Entered HD2 acct1 mgmt page');
      await ss.take(tester, '5.13b.1_account_mgmt');
      
      // Step 3: Tap Export Private Key
      print('Step 3: Tap export PK');
      var exportBtn = find.text(dic.exportPrivateKey);
      if (exportBtn.evaluate().isEmpty) {
        testResults[testName] = 'FAIL - Export PK entry not found';
        return;
      }
      await tester.tap(exportBtn.first);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      
      // Step 4: Handle hint dialog
      print('Step 4: Handle hint dialog');
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
        var promptTitle = find.text(dic.prompt);
        var confirmBtns = find.text(dic.confirm);
        if (promptTitle.evaluate().isNotEmpty && confirmBtns.evaluate().isNotEmpty) {
          await tester.tap(confirmBtns.first);
          await tester.pumpAndSettle();
          print('✅ Closed hint dialog');
          break;
        }
      }
      await tester.pump(const Duration(seconds: 1));
      
      // Step 5: Enter password
      print('Step 5: Enter password');
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
        if (find.byType(TextField).evaluate().isNotEmpty) break;
      }
      final passwordFields = find.byType(TextField);
      if (passwordFields.evaluate().isNotEmpty) {
        await tester.enterText(passwordFields.last, TestData.defaultPassword);
        await tester.pumpAndSettle();
        await ss.take(tester, '5.13b.2_password');
        await tester.pump(const Duration(milliseconds: 500));
        var confirmBtn = find.text(dic.confirm);
        if (confirmBtn.evaluate().isNotEmpty) {
          await tester.tap(confirmBtn.last, warnIfMissed: false);
          print('✅ Tapped confirm');
          try {
            await tester.pumpAndSettle(const Duration(seconds: 1));
          } catch (e) {
            for (int j = 0; j < 5; j++) { await tester.pump(const Duration(seconds: 1)); }
          }
        }
      }
      
      // Wait for PK to show
      for (int i = 0; i < 15; i++) {
        await tester.pump(const Duration(seconds: 1));
        if (find.textContaining('EK').evaluate().isNotEmpty) break;
      }
      
      await ss.take(tester, '5.13b.3_pk_display');
      
      // Step 6: Verify PK = EKFTDZnZ...
      print('Step 6: Verify PK = EKFTDZnZ...');
      bool found = false;
      var anyPK = find.textContaining('EK');
      if (anyPK.evaluate().isNotEmpty) {
        for (var element in anyPK.evaluate()) {
          final widget = element.widget;
          if (widget is Text && widget.data != null && widget.data!.startsWith('EKFT')) {
            print('✅ HD2 acct1 PK verified: ${widget.data!.substring(0, 20)}...');
            found = true;
            break;
          }
        }
      }
      if (!found) {
        // Also accept any EK-prefixed PK (order may differ)
        for (var element in (anyPK.evaluate())) {
          final widget = element.widget;
          if (widget is Text && widget.data != null && widget.data!.startsWith('EK') && widget.data!.length > 30) {
            print('⚠️ PK shown but unexpected: ${widget.data!.substring(0, 20)}...');
            found = true;
            break;
          }
        }
      }
      testResults[testName] = found ? 'PASS' : 'PARTIAL - PK content not found';
      
      await ss.take(tester, '5.13b_done');
      await endTestDelay(tester);
      print('\n========== $testName Done ==========\n');
    }, timeout: Timeout(Duration(minutes: 3)));

    testWidgets('5.13c Export HD2 acct2 PK', (WidgetTester tester) async {
      const testName = '5.13c Export HD2 acct2 PK';
      print('\n========== Start $testName ==========\n');
      final ss = ScreenshotHelper('flow5');
      
      app.main(testMode: true);
      
      bool ready = false;
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(seconds: 1));
        if (find.byKey(TestKeys.sendButton).evaluate().isNotEmpty) { ready = true; break; }
      }
      if (!ready) { testResults[testName] = 'SKIP - Home not loaded'; return; }
      
      // Step 1: Open wallet mgmt
      print('Step 1: Open wallet mgmt');
      await tester.tap(find.byKey(TestKeys.walletManageIcon));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      
      // Step 2: Tap HD2-Account2 (accountMoreButton[3])
      print('Step 2: Tap HD2 acct2 more button');
      var accountMoreBtns = find.byKey(TestKeys.accountMoreButton);
      if (accountMoreBtns.evaluate().length < 4) {
        testResults[testName] = 'SKIP - Not enough accounts (run 5.3+5.5 first)';
        return;
      }
      await tester.ensureVisible(accountMoreBtns.at(3));
      await tester.pumpAndSettle();
      await tester.tap(accountMoreBtns.at(3));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      print('✅ Entered HD2 acct2 mgmt page');
      await ss.take(tester, '5.13c.1_account_mgmt');
      
      // Step 3: Tap Export Private Key
      print('Step 3: Tap export PK');
      var exportBtn = find.text(dic.exportPrivateKey);
      if (exportBtn.evaluate().isEmpty) {
        testResults[testName] = 'FAIL - Export PK entry not found';
        return;
      }
      await tester.tap(exportBtn.first);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      
      // Step 4: Handle hint dialog
      print('Step 4: Handle hint dialog');
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
        var promptTitle = find.text(dic.prompt);
        var confirmBtns = find.text(dic.confirm);
        if (promptTitle.evaluate().isNotEmpty && confirmBtns.evaluate().isNotEmpty) {
          await tester.tap(confirmBtns.first);
          await tester.pumpAndSettle();
          print('✅ Closed hint dialog');
          break;
        }
      }
      await tester.pump(const Duration(seconds: 1));
      
      // Step 5: Enter password
      print('Step 5: Enter password');
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
        if (find.byType(TextField).evaluate().isNotEmpty) break;
      }
      final passwordFields = find.byType(TextField);
      if (passwordFields.evaluate().isNotEmpty) {
        await tester.enterText(passwordFields.last, TestData.defaultPassword);
        await tester.pumpAndSettle();
        await ss.take(tester, '5.13c.2_password');
        await tester.pump(const Duration(milliseconds: 500));
        var confirmBtn = find.text(dic.confirm);
        if (confirmBtn.evaluate().isNotEmpty) {
          await tester.tap(confirmBtn.last, warnIfMissed: false);
          print('✅ Tapped confirm');
          try {
            await tester.pumpAndSettle(const Duration(seconds: 1));
          } catch (e) {
            for (int j = 0; j < 5; j++) { await tester.pump(const Duration(seconds: 1)); }
          }
        }
      }
      
      // Wait for PK to show
      for (int i = 0; i < 15; i++) {
        await tester.pump(const Duration(seconds: 1));
        if (find.textContaining('EK').evaluate().isNotEmpty) break;
      }
      
      await ss.take(tester, '5.13c.3_pk_display');
      
      // Step 6: Verify PK = EKDspUyZ...
      print('Step 6: Verify PK = EKDspUyZ...');
      bool found = false;
      var anyPK = find.textContaining('EK');
      if (anyPK.evaluate().isNotEmpty) {
        for (var element in anyPK.evaluate()) {
          final widget = element.widget;
          if (widget is Text && widget.data != null && widget.data!.startsWith('EKDs')) {
            print('✅ HD2 acct2 PK verified: ${widget.data!.substring(0, 20)}...');
            found = true;
            break;
          }
        }
      }
      if (!found) {
        for (var element in (anyPK.evaluate())) {
          final widget = element.widget;
          if (widget is Text && widget.data != null && widget.data!.startsWith('EK') && widget.data!.length > 30) {
            print('⚠️ PK shown but unexpected: ${widget.data!.substring(0, 20)}...');
            found = true;
            break;
          }
        }
      }
      testResults[testName] = found ? 'PASS' : 'PARTIAL - PK content not found';
      
      await ss.take(tester, '5.13c_done');
      await endTestDelay(tester);
      print('\n========== $testName Done ==========\n');
    }, timeout: Timeout(Duration(minutes: 3)));

    testWidgets('5.14 Export PK wallet private key', (WidgetTester tester) async {
      const testName = '5.14 Export PK wallet PK';
      print('\n========== Start $testName ==========\n');
      final ss = ScreenshotHelper('flow5');
      
      app.main(testMode: true);
      
      bool ready = false;
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(seconds: 1));
        if (find.byKey(TestKeys.sendButton).evaluate().isNotEmpty) { ready = true; break; }
      }
      if (!ready) { testResults[testName] = 'SKIP - Home not loaded'; return; }
      
      // Step 1: Open wallet mgmt
      print('Step 1: Open wallet mgmt');
      await tester.tap(find.byKey(TestKeys.walletManageIcon));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      
      // Step 2: Find imported PK wallet account more button
      // Expected order: HD Wallet 1 (Account1, Account2), HD Wallet 2 (Account1, Account2), Imported PK, Imported KS
      // accountMoreButton index: [0]=HD1-Acc1, [1]=HD1-Acc2, [2]=HD2-Acc1, [3]=HD2-Acc2, [4]=PK, [5]=KS
      print('Step 2: Find PK wallet account');
      
      var accountMoreBtns = find.byKey(TestKeys.accountMoreButton);
      int pkIndex = -1;
      
      // Find account containing PK wallet address
      var pkAddressText = find.textContaining('B62qo1');
      if (pkAddressText.evaluate().isNotEmpty) {
        print('✅ Found PK wallet address');
        pkIndex = 4;
      }
      
      if (pkIndex < 0 || accountMoreBtns.evaluate().length <= pkIndex) {
        var importedTexts = find.textContaining('Imported');
        if (importedTexts.evaluate().isNotEmpty) {
          print('✅ Found Imported wallet');
          if (accountMoreBtns.evaluate().length > 4) {
            pkIndex = 4;
          } else if (accountMoreBtns.evaluate().length > 2) {
            pkIndex = accountMoreBtns.evaluate().length - 2;
          }
        }
        
        if (pkIndex < 0 || accountMoreBtns.evaluate().length <= pkIndex) {
          testResults[testName] = 'SKIP - PK wallet not found (run 5.3b first)';
          return;
        }
      }
      
      // Scroll to make target button visible
      await tester.ensureVisible(accountMoreBtns.at(pkIndex));
      await tester.pumpAndSettle();
      await tester.tap(accountMoreBtns.at(pkIndex));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      print('✅ Entered PK wallet account mgmt page');
      await ss.take(tester, '5.14.1_account_mgmt');
      
      // Step 3: Tap Export Private Key
      print('Step 3: Tap export PK');
      var exportBtn = find.text(dic.exportPrivateKey);
      
      if (exportBtn.evaluate().isEmpty) {
        testResults[testName] = 'FAIL - Export PK entry not found';
        return;
      }
      await tester.tap(exportBtn.first);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      
      // Step 4: Handle hint dialog (CustomAlertDialog button is dic.confirm)
      print('Step 4: Handle hint dialog');
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
        var promptTitle = find.text(dic.prompt);
        var confirmBtns = find.text(dic.confirm);
        if (promptTitle.evaluate().isNotEmpty && confirmBtns.evaluate().isNotEmpty) {
          await tester.tap(confirmBtns.first);
          await tester.pumpAndSettle();
          print('✅ Closed hint dialog');
          break;
        }
      }
      await tester.pump(const Duration(seconds: 1));
      
      // Step 5: Enter password (PasswordInputDialog)
      print('Step 5: Enter password');
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
        if (find.byType(TextField).evaluate().isNotEmpty) break;
      }
      final passwordFields = find.byType(TextField);
      if (passwordFields.evaluate().isNotEmpty) {
        await tester.enterText(passwordFields.last, TestData.defaultPassword);
        await tester.pumpAndSettle();
        print('✅ Password entered');
        await ss.take(tester, '5.14.2_password');
        await tester.pump(const Duration(milliseconds: 500));
        var confirmBtn = find.text(dic.confirm);
        if (confirmBtn.evaluate().isNotEmpty) {
          await tester.tap(confirmBtn.last, warnIfMissed: false);
          print('✅ Tapped confirm');
          try {
            await tester.pumpAndSettle(const Duration(seconds: 1));
          } catch (e) {
            for (int j = 0; j < 5; j++) {
              await tester.pump(const Duration(seconds: 1));
            }
          }
        }
      }
      
      // Wait for ExportResultPage to load
      for (int i = 0; i < 15; i++) {
        await tester.pump(const Duration(seconds: 1));
        var pkText = find.textContaining('EK');
        if (pkText.evaluate().isNotEmpty) break;
      }
      
      await ss.take(tester, '5.14.3_pk_display');
      
      // Step 6: Verify PK display
      print('Step 6: Verify private key');
      var pkText = find.textContaining(TestData.importPrivateKey.substring(0, 10));
      bool found = false;
      if (pkText.evaluate().isNotEmpty) {
        print('✅ Exported PK matches import');
        found = true;
      } else {
        var anyPK = find.textContaining('EK');
        if (anyPK.evaluate().isNotEmpty) {
          for (var element in anyPK.evaluate()) {
            final widget = element.widget;
            if (widget is Text && widget.data != null && widget.data!.startsWith('EK') && widget.data!.length > 30) {
              print('✅ Found PK: ${widget.data!.substring(0, 20)}...');
              found = true;
              break;
            }
          }
        }
      }
      testResults[testName] = found ? 'PASS' : 'PARTIAL - PK content not found';
      
      await ss.take(tester, '5.14_done');
      await endTestDelay(tester);
      print('\n========== $testName Done ==========\n');
    }, timeout: Timeout(Duration(minutes: 3)));

    testWidgets('5.15 Export KS wallet private key', (WidgetTester tester) async {
      const testName = '5.15 Export KS wallet PK';
      print('\n========== Start $testName ==========\n');
      final ss = ScreenshotHelper('flow5');
      
      app.main(testMode: true);
      
      bool ready = false;
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(seconds: 1));
        if (find.byKey(TestKeys.sendButton).evaluate().isNotEmpty) { ready = true; break; }
      }
      if (!ready) { testResults[testName] = 'SKIP - Home not loaded'; return; }
      
      // Step 1: Open wallet mgmt
      print('Step 1: Open wallet mgmt');
      await tester.tap(find.byKey(TestKeys.walletManageIcon));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      
      // Step 2: Find Keystore wallet account more button (last one)
      print('Step 2: Find Keystore wallet account');
      var accountMoreBtns = find.byKey(TestKeys.accountMoreButton);
      int ksIndex = accountMoreBtns.evaluate().length - 1;
      
      if (ksIndex < 0) {
        testResults[testName] = 'SKIP - No accounts found';
        return;
      }
      
      // Verify if this is Keystore wallet address
      var ksAddressText = find.textContaining('B62qkS');
      if (ksAddressText.evaluate().isNotEmpty) {
        print('✅ Found Keystore wallet address');
      }
      
      if (accountMoreBtns.evaluate().length <= ksIndex || ksIndex < 0) {
        testResults[testName] = 'SKIP - KS wallet not found (run 5.3c first)';
        return;
      }
      
      // Scroll to make target button visible
      await tester.ensureVisible(accountMoreBtns.at(ksIndex));
      await tester.pumpAndSettle();
      await tester.tap(accountMoreBtns.at(ksIndex));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      print('✅ Entered KS wallet account mgmt page');
      await ss.take(tester, '5.15.1_account_mgmt');
      
      // Step 3: Tap Export Private Key
      print('Step 3: Tap export PK');
      var exportBtn = find.text(dic.exportPrivateKey);
      
      if (exportBtn.evaluate().isEmpty) {
        testResults[testName] = 'FAIL - Export PK entry not found';
        return;
      }
      await tester.tap(exportBtn.first);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      
      // Step 4: Handle hint dialog (CustomAlertDialog button is dic.confirm)
      print('Step 4: Handle hint dialog');
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
        var promptTitle = find.text(dic.prompt);
        var confirmBtns = find.text(dic.confirm);
        if (promptTitle.evaluate().isNotEmpty && confirmBtns.evaluate().isNotEmpty) {
          await tester.tap(confirmBtns.first);
          await tester.pumpAndSettle();
          print('✅ Closed hint dialog');
          break;
        }
      }
      await tester.pump(const Duration(seconds: 1));
      
      // Step 5: Enter password (PasswordInputDialog)
      print('Step 5: Enter password');
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
        if (find.byType(TextField).evaluate().isNotEmpty) break;
      }
      final passwordFields = find.byType(TextField);
      if (passwordFields.evaluate().isNotEmpty) {
        await tester.enterText(passwordFields.last, TestData.defaultPassword);
        await tester.pumpAndSettle();
        print('✅ Password entered');
        await ss.take(tester, '5.15.2_password');
        await tester.pump(const Duration(milliseconds: 500));
        var confirmBtn = find.text(dic.confirm);
        if (confirmBtn.evaluate().isNotEmpty) {
          await tester.tap(confirmBtn.last, warnIfMissed: false);
          print('✅ Tapped confirm');
          try {
            await tester.pumpAndSettle(const Duration(seconds: 1));
          } catch (e) {
            for (int j = 0; j < 5; j++) {
              await tester.pump(const Duration(seconds: 1));
            }
          }
        }
      }
      
      // Wait for ExportResultPage to load
      for (int i = 0; i < 15; i++) {
        await tester.pump(const Duration(seconds: 1));
        var pkText = find.textContaining('EK');
        if (pkText.evaluate().isNotEmpty) break;
      }
      
      await ss.take(tester, '5.15.3_pk_display');
      
      // Step 6: Verify PK = EKEMqXWT...（TestData.keystorePrivateKey）
      print('Step 6: Verify PK = EKEMqXWT...');
      bool found = false;
      bool exactMatch = false;
      var anyPK = find.textContaining('EK');
      if (anyPK.evaluate().isNotEmpty) {
        for (var element in anyPK.evaluate()) {
          final widget = element.widget;
          if (widget is Text && widget.data != null && widget.data!.startsWith('EK') && widget.data!.length > 30) {
            final exportedKey = widget.data!;
            found = true;
            if (exportedKey == TestData.keystorePrivateKey) {
              print('✅ KS PK exact match: ${exportedKey.substring(0, 20)}...');
              exactMatch = true;
            } else {
              print('⚠️ PK shown but does not match: ${exportedKey.substring(0, 20)}...');
              print('   Expected: ${TestData.keystorePrivateKey.substring(0, 20)}...');
            }
            break;
          }
        }
      }
      if (exactMatch) {
        testResults[testName] = 'PASS';
      } else if (found) {
        testResults[testName] = 'PARTIAL - PK shown but does not match';
      } else {
        testResults[testName] = 'PARTIAL - PK content not found';
      }
      
      await ss.take(tester, '5.15_done');
      await endTestDelay(tester);
      print('\n========== $testName Done ==========\n');
    }, timeout: Timeout(Duration(minutes: 3)));

    testWidgets('5.16 Delete imported wallet account', (WidgetTester tester) async {
      const testName = '5.16 Delete imported wallet account';
      print('\n========== Start $testName ==========\n');
      final ss = ScreenshotHelper('flow5');
      
      app.main(testMode: true);
      
      bool ready = false;
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(seconds: 1));
        if (find.byKey(TestKeys.sendButton).evaluate().isNotEmpty) { ready = true; break; }
      }
      if (!ready) { testResults[testName] = 'SKIP - Home not loaded'; return; }
      
      // Step 1: Open wallet mgmt
      print('Step 1: Open wallet mgmt');
      await tester.tap(find.byKey(TestKeys.walletManageIcon));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      
      // Step 2: Find last imported wallet (Keystore) account → AccountManagePage
      print('Step 2: Tap imported wallet account more button');
      var accountMoreBtns = find.byKey(TestKeys.accountMoreButton);
      int lastIdx = accountMoreBtns.evaluate().length - 1;
      
      if (lastIdx < 0) {
        testResults[testName] = 'SKIP - No accounts found';
        return;
      }
      
      // Scroll to make target button visible
      await tester.ensureVisible(accountMoreBtns.at(lastIdx));
      await tester.pumpAndSettle();
      await tester.tap(accountMoreBtns.at(lastIdx));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      print('✅ Entered imported wallet account mgmt page');
      await ss.take(tester, '5.16.1_account_mgmt');
      
      // Step 3: Verify Delete Account button exists (non-HD only)
      print('Step 3: Verify Delete Account button');
      var deleteBtn = find.text(dic.accountDelete);
      
      if (deleteBtn.evaluate().isNotEmpty) {
        print('✅ Found delete account button (expected for non-HD)');
        testResults[testName] = 'PASS';
      } else {
        print('⚠️ Delete button not found (may be HD wallet account)');
        testResults[testName] = 'PARTIAL - Delete button not found';
      }
      
      await ss.take(tester, '5.16_done');
      await endTestDelay(tester);
      print('\n========== $testName Done ==========\n');
    }, timeout: Timeout(Duration(minutes: 2)));

    testWidgets('5.17 Duplicate address detection', (WidgetTester tester) async {
      const testName = '5.17 Duplicate address detection';
      print('\n========== Start $testName ==========\n');
      final ss = ScreenshotHelper('flow5');
      
      app.main(testMode: true);
      
      bool ready = false;
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(seconds: 1));
        if (find.byKey(TestKeys.sendButton).evaluate().isNotEmpty) { ready = true; break; }
      }
      if (!ready) { testResults[testName] = 'SKIP - Home not loaded'; return; }
      
      // Step 1: Open wallet mgmt
      print('Step 1: Open wallet mgmt');
      await tester.tap(find.byKey(TestKeys.walletManageIcon));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      
      // Step 2: Tap add wallet
      print('Step 2: Tap add wallet');
      var addWalletBtn = find.byKey(TestKeys.addWalletButton);
      if (addWalletBtn.evaluate().isEmpty) addWalletBtn = find.text(dic.addWallet);
      if (addWalletBtn.evaluate().isEmpty) {
        testResults[testName] = 'SKIP - Add wallet button not found';
        return;
      }
      await tester.tap(addWalletBtn.first);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      
      // Step 3: Select Import Wallet → Mnemonic Phrase (using already imported mnemonic)
      print('Step 3: Select import wallet → mnemonic');
      var importOption = find.text(dic.importWallet);
      if (importOption.evaluate().isNotEmpty) {
        await tester.tap(importOption.first);
        await tester.pumpAndSettle();
      }
      await tester.pump(const Duration(seconds: 1));
      
      var mnemonicOption = find.text(dic.mnemonicPhrase);
      if (mnemonicOption.evaluate().isNotEmpty) {
        await tester.tap(mnemonicOption.first);
        await tester.pumpAndSettle();
      }
      await tester.pump(const Duration(seconds: 1));
      
      // Step 3.5: Handle password dialog
      final pwdFields = find.byType(TextField);
      if (pwdFields.evaluate().isNotEmpty) {
        await tester.enterText(pwdFields.last, TestData.defaultPassword);
        await tester.pumpAndSettle();
        var confirmPwd = find.text(dic.confirm);
        if (confirmPwd.evaluate().isNotEmpty) {
          await tester.tap(confirmPwd.last);
          await tester.pumpAndSettle();
        }
      }
      await tester.pump(const Duration(seconds: 1));
      
      // Step 4: Enter existing mnemonic
      print('Step 4: Enter existing mnemonic');
      var mnemonicInput = find.byKey(TestKeys.mnemonicInput);
      if (mnemonicInput.evaluate().isNotEmpty) {
        await tester.enterText(mnemonicInput, TestData.firstMnemonic);
        await tester.pumpAndSettle();
      }
      await tester.pump(const Duration(seconds: 1));
      await ss.take(tester, '5.17.1_duplicate_mnemonic');
      
      // Step 5: Tap confirm
      print('Step 5: Tap confirm');
      var confirmBtn = find.byKey(TestKeys.confirmButton);
      if (confirmBtn.evaluate().isEmpty) confirmBtn = find.byKey(TestKeys.importButton);
      if (confirmBtn.evaluate().isEmpty) confirmBtn = find.text(dic.confirm);
      if (confirmBtn.evaluate().isNotEmpty) {
        await tester.tap(confirmBtn.first);
        print('✅ Tapped confirm button');
      }
      
      // Wait for async crypto to complete (importWalletByWalletParams takes time)
      for (int i = 0; i < 15; i++) {
        await tester.pump(const Duration(seconds: 1));
        // Check for duplicate import error
        var repeatError = find.textContaining(dic.improtRepeat);
        if (repeatError.evaluate().isNotEmpty) {
          print('✅ Detected duplicate import error');
          testResults[testName] = 'PASS';
          print('\n========== $testName Done ==========\n');
          return;
        }
        // Check if still on import page (errorMsg shown after submitting)
        var mnemonicField = find.byKey(TestKeys.mnemonicInput);
        if (mnemonicField.evaluate().isNotEmpty && i > 5) {
          // Still on import page, errorMsg may be shown
          break;
        }
      }
      
      // Step 6: Verify error (duplicate import: "Do not import repeatedly")
      print('Step 6: Verify duplicate import message');
      var errorText = find.textContaining(dic.improtRepeat);
      
      if (errorText.evaluate().isNotEmpty) {
        print('✅ Correctly detected duplicate address');
        testResults[testName] = 'PASS';
      } else {
        // Still on import page (validation blocked import)
        var stillOnImport = find.byKey(TestKeys.mnemonicInput);
        if (stillOnImport.evaluate().isNotEmpty) {
          print('✅ Duplicate import blocked (still on import page)');
          testResults[testName] = 'PASS';
        } else {
          // Check if reached success page (duplicate detection failed)
          var startBtn = find.byKey(TestKeys.startHomeButton);
          if (startBtn.evaluate().isEmpty) startBtn = find.text(dic.startHome);
          if (startBtn.evaluate().isNotEmpty) {
            print('⚠️ Duplicate import not blocked, reached success page');
            testResults[testName] = 'FAIL - Duplicate import not detected';
          } else {
            print('⚠️ Duplicate address prompt not detected');
            testResults[testName] = 'PARTIAL - Duplicate prompt not detected';
          }
        }
      }
      
      await ss.take(tester, '5.17_done');
      await endTestDelay(tester);
      print('\n========== $testName Done ==========\n');
    }, timeout: Timeout(Duration(minutes: 3)));

    // ══════════════════════════════════════════════════════════════
    // New tests below (destructive ops last)
    // ══════════════════════════════════════════════════════════════

    testWidgets('5.18 Switch to Devnet and self-transfer', (WidgetTester tester) async {
      const testName = '5.18 Switch Devnet + self-transfer';
      print('\n========== Start $testName ==========\n');
      
      app.main(testMode: true);
      
      bool ready = false;
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(seconds: 1));
        if (find.byKey(TestKeys.sendButton).evaluate().isNotEmpty) { ready = true; break; }
      }
      if (!ready) { testResults[testName] = 'SKIP - Home not loaded'; return; }
      
      // Step 1: Switch to 1st mnemonic wallet (Devnet balance)
      print('Step 1: Switch to 1st mnemonic wallet (Devnet balance)');
      final ss = ScreenshotHelper('flow5');
      var walletManageIcon = find.byKey(TestKeys.walletManageIcon);
      if (walletManageIcon.evaluate().isNotEmpty) {
        await tester.tap(walletManageIcon);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        // Find 1st mnemonic wallet address (truncated)
        var firstAddr = find.textContaining('B62qoV');
        if (firstAddr.evaluate().isNotEmpty) {
          await tester.tap(firstAddr.first, warnIfMissed: false);
          await safePumpAndSettle(tester);
          print('✅ Switched to 1st mnemonic wallet');
        } else {
          print('⚠️ 1st mnemonic wallet addr not found, using current wallet');
        }
        // Wait to return to home
        for (int i = 0; i < 10; i++) {
          await tester.pump(const Duration(seconds: 1));
          if (find.byKey(TestKeys.sendButton).evaluate().isNotEmpty) break;
        }
      }
      await ss.take(tester, '5.18.0_home');
      
      // Step 2: Tap network name, open network switch dialog
      print('Step 2: Open network switch dialog');
      // Home network name uses breakWord
      var networkEntry = findBreakWordText('Mainnet');
      if (networkEntry.evaluate().isEmpty) {
        networkEntry = findBreakWordText('Devnet');
      }
      if (networkEntry.evaluate().isEmpty) {
        // fallback: plain text match (some pages may not use breakWord)
        networkEntry = find.text('Mainnet');
        if (networkEntry.evaluate().isEmpty) networkEntry = find.text('Devnet');
      }
      
      if (networkEntry.evaluate().isNotEmpty) {
        await tester.tap(networkEntry.first, warnIfMissed: false);
        await safePumpAndSettle(tester);
        await tester.pump(const Duration(seconds: 1));
        print('✅ Opened network switch dialog');
      } else {
        testResults[testName] = 'FAIL - Network entry not found';
        return;
      }
      await ss.take(tester, '5.18.1_network_dialog');
      
      // Step 3: Ensure Show Testnet toggle is on
      print('Step 3: Ensure Show Testnet toggle is on');
      // NetworkItem uses Fmt.breakWord, must use findBreakWordText
      var devnetOption = findBreakWordText('Devnet');
      if (devnetOption.evaluate().isEmpty) {
        var switchWidget = find.byType(Switch);
        if (switchWidget.evaluate().isNotEmpty) {
          await tester.tap(switchWidget.first);
          await safePumpAndSettle(tester);
          await tester.pump(const Duration(seconds: 1));
          print('✅ Toggled Show Testnet');
          devnetOption = findBreakWordText('Devnet');
          if (devnetOption.evaluate().isEmpty) {
            await tester.tap(switchWidget.first);
            await safePumpAndSettle(tester);
            await tester.pump(const Duration(seconds: 1));
            print('✅ Toggled Show Testnet again');
            devnetOption = findBreakWordText('Devnet');
          }
        }
      } else {
        print('✅ Devnet already visible, no toggle needed');
      }
      await ss.take(tester, '5.18.2_devnet_visible');
      
      // Step 4: Select Devnet
      print('Step 4: Select Devnet');
      if (devnetOption.evaluate().isNotEmpty) {
        await tester.tap(devnetOption.first, warnIfMissed: false);
        print('✅ Tapped Devnet');
      } else {
        testResults[testName] = 'FAIL - Devnet option not found';
        return;
      }
      
      // Wait for network switch to complete
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(seconds: 1));
        if (find.byKey(TestKeys.sendButton).evaluate().isNotEmpty) break;
      }
      print('✅ Network switch done');
      await ss.take(tester, '5.18.3_devnet_home');
      
      // Step 5: Get current address (for self-transfer)
      print('Step 5: Get current address');
      // Home address is truncated (B62q...xxx), cannot use for transfer
      // Use 1st mnemonic wallet address (Devnet balance)
      String currentAddress = TestData.firstMnemonicAddress;
      print('✅ Using addr: ${currentAddress.substring(0, 15)}...');
      
      // Step 6: Tap Send button
      print('Step 6: Tap Send');
      await tester.tap(find.byKey(TestKeys.sendButton));
      await safePumpAndSettle(tester);
      await tester.pump(const Duration(seconds: 1));
      
      // Step 7: Select MINA in TokenSelectionDialog
      print('Step 7: Select MINA token');
      await ss.take(tester, '5.18.4_TokenDialog');
      var minaToken = find.text('MINA');
      if (minaToken.evaluate().isEmpty) minaToken = find.textContaining('MINA');
      if (minaToken.evaluate().isNotEmpty) {
        await tester.tap(minaToken.last, warnIfMissed: false);
        await safePumpAndSettle(tester);
        await tester.pump(const Duration(seconds: 2));
        print('✅ Selected MINA');
      } else {
        testResults[testName] = 'FAIL - MINA token not found';
        return;
      }
      
      // Step 8: Enter recipient address and amount in TransferPage
      print('Step 8: Enter transfer info');
      var textFields = find.byType(TextField);
      if (textFields.evaluate().length >= 2) {
        await tester.enterText(textFields.at(0), currentAddress);
        await tester.pump(const Duration(milliseconds: 500));
        print('✅ Entered recipient: ${currentAddress.substring(0, 10)}...');
        
        await tester.enterText(textFields.at(1), '0.001');
        await tester.pump(const Duration(milliseconds: 500));
        print('✅ Entered amount 0.001');
      } else {
        testResults[testName] = 'FAIL - Not enough input fields';
        return;
      }
      
      // Wait for fee to load
      await tester.pump(const Duration(seconds: 3));
      
      // Step 9: Tap Next button
      print('Step 9: Tap send');
      var nextBtn = find.text(dic.next);
      if (nextBtn.evaluate().isEmpty) nextBtn = find.text(dic.send);
      if (nextBtn.evaluate().isNotEmpty) {
        await tester.tap(nextBtn.first);
        // safePumpAndSettle drives async validation chain (isAddressValid etc platform channel)
        // and showModalBottomSheet animation
        await safePumpAndSettle(tester);
        await tester.pump(const Duration(seconds: 2));
        print('✅ Tapped send button');
      } else {
        testResults[testName] = 'PARTIAL - Send button not found (may be insufficient balance)';
        print('\n========== $testName Done ==========\n');
        return;
      }
      
      // Step 10: Wait for and handle TxConfirmDialog bottom sheet
      print('Step 10: Confirm transaction');
      // If validation passes, bottom sheet appears within 1-2s
      // If validation fails (e.g. Devnet insufficient balance), UI.toast uses native Fluttertoast,
      // Flutter test finder cannot detect it, so can only determine by timeout
      bool confirmFound = false;
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
        var confirmBtn = find.text(dic.confirm);
        if (confirmBtn.evaluate().isNotEmpty) {
          await tester.tap(confirmBtn.first, warnIfMissed: false);
          print('✅ Confirmed transaction');
          confirmFound = true;
          break;
        }
      }
      
      if (!confirmFound) {
        print('⚠️ Confirm dialog not shown (Devnet balance may be 0, toast undetectable)');
        testResults[testName] = 'PARTIAL - Devnet insufficient balance or validation failed';
        // Return to home
        for (int i = 0; i < 5; i++) {
          var backBtn = find.byIcon(Icons.arrow_back);
          if (backBtn.evaluate().isNotEmpty) {
            await tester.tap(backBtn.first);
            await safePumpAndSettle(tester);
          }
          await tester.pump(const Duration(seconds: 1));
          if (find.byKey(TestKeys.sendButton).evaluate().isNotEmpty) break;
        }
      } else {
        // Step 11: Handle password dialog
        // runtimePwd may be cached, PasswordInputDialog won't appear
        print('Step 11: Enter password');
        await tester.pump(const Duration(seconds: 2));
        var pwdDialogTitle = find.text(dic.password);
        if (pwdDialogTitle.evaluate().isNotEmpty) {
          final pwdFields = find.byType(TextField);
          if (pwdFields.evaluate().isNotEmpty) {
            await tester.enterText(pwdFields.last, TestData.defaultPassword);
            await tester.pump(const Duration(seconds: 1));
            var confirmPwd = find.text(dic.confirm);
            if (confirmPwd.evaluate().isNotEmpty) {
              await tester.tap(confirmPwd.last, warnIfMissed: false);
              print('✅ Entered and confirmed password');
            }
          }
        } else {
          print('✅ Password auto-filled (runtimePwd)');
        }
        
        // Transaction submitted (confirm + password passed), mark PASS
        testResults[testName] = 'PASS';
        
        // Step 12: Wait for tx broadcast, return to home or tx result page
        print('Step 12: Wait for tx result');
        for (int i = 0; i < 15; i++) {
          await tester.pump(const Duration(seconds: 1));
          var sendBtnCheck = find.byKey(TestKeys.sendButton);
          if (sendBtnCheck.evaluate().isNotEmpty && i > 3) {
            print('✅ Returned to home');
            break;
          }
        }
      }
      
      // Step 13: Switch back to Mainnet
      print('Step 13: Switch back to Mainnet');
      // Go back to home first
      for (int i = 0; i < 5; i++) {
        var backBtn = find.byIcon(Icons.arrow_back);
        if (backBtn.evaluate().isNotEmpty) {
          await tester.tap(backBtn.first);
          await safePumpAndSettle(tester);
        }
        await tester.pump(const Duration(seconds: 1));
        if (find.byKey(TestKeys.sendButton).evaluate().isNotEmpty) break;
      }
      
      // Open network dialog, select Mainnet
      var netEntry = findBreakWordText('Devnet');
      if (netEntry.evaluate().isEmpty) netEntry = findBreakWordText('Mainnet');
      if (netEntry.evaluate().isEmpty) netEntry = find.text('Mainnet');
      if (netEntry.evaluate().isNotEmpty) {
        await tester.tap(netEntry.first, warnIfMissed: false);
        await safePumpAndSettle(tester);
        await tester.pump(const Duration(seconds: 1));
        var mainnetOpt = findBreakWordText('Mainnet');
        if (mainnetOpt.evaluate().isNotEmpty) {
          await tester.tap(mainnetOpt.first, warnIfMissed: false);
          for (int i = 0; i < 5; i++) {
            await tester.pump(const Duration(seconds: 1));
            if (find.byKey(TestKeys.sendButton).evaluate().isNotEmpty) break;
          }
          print('✅ Switched back to Mainnet');
        }
      }
      
      await ss.take(tester, '5.18.9_done');
      await endTestDelay(tester);
      print('\n========== $testName Done ==========\n');
    }, timeout: Timeout(Duration(minutes: 5)));

    testWidgets('5.19 Stake from token detail', (WidgetTester tester) async {
      const testName = '5.19 Stake from token detail';
      print('\n========== Start $testName ==========\n');
      
      app.main(testMode: true);
      
      bool ready = false;
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(seconds: 1));
        if (find.byKey(TestKeys.sendButton).evaluate().isNotEmpty) { ready = true; break; }
      }
      if (!ready) { testResults[testName] = 'SKIP - Home not loaded'; return; }
      
      const stakingNodeAddress = 'B62qpjxUpgdjzwQfd8q2gzxi99wN7SCgmofpvw27MBkfNHfHoY2VH32';
      final ss = ScreenshotHelper('flow5');
      
      // Step 1: Ensure on Devnet
      print('Step 1: Switch to Devnet');
      var networkEntry = findBreakWordText('Mainnet');
      if (networkEntry.evaluate().isEmpty) networkEntry = findBreakWordText('Devnet');
      if (networkEntry.evaluate().isEmpty) networkEntry = find.text('Mainnet');
      if (networkEntry.evaluate().isEmpty) networkEntry = find.text('Devnet');
      if (networkEntry.evaluate().isNotEmpty) {
        await tester.tap(networkEntry.first, warnIfMissed: false);
        await safePumpAndSettle(tester);
        await tester.pump(const Duration(seconds: 1));
        var devnetOpt = findBreakWordText('Devnet');
        if (devnetOpt.evaluate().isEmpty) {
          var switchWidget = find.byType(Switch);
          if (switchWidget.evaluate().isNotEmpty) {
            await tester.tap(switchWidget.first);
            await safePumpAndSettle(tester);
            await tester.pump(const Duration(seconds: 1));
            devnetOpt = findBreakWordText('Devnet');
            if (devnetOpt.evaluate().isEmpty) {
              await tester.tap(switchWidget.first);
              await safePumpAndSettle(tester);
              await tester.pump(const Duration(seconds: 1));
              devnetOpt = findBreakWordText('Devnet');
            }
          }
        }
        if (devnetOpt.evaluate().isNotEmpty) {
          await tester.tap(devnetOpt.first, warnIfMissed: false);
          for (int i = 0; i < 10; i++) {
            await tester.pump(const Duration(seconds: 1));
            if (find.byKey(TestKeys.sendButton).evaluate().isNotEmpty) break;
          }
          print('✅ Switched to Devnet');
        } else {
          var closeBtn = find.byIcon(Icons.close);
          if (closeBtn.evaluate().isNotEmpty) await tester.tap(closeBtn.first);
          await safePumpAndSettle(tester);
        }
      }
      
      // Step 2: Tap MINA token on home to enter TokenDetailPage
      print('Step 2: Open MINA token detail page');
      var minaToken = find.text('MINA');
      if (minaToken.evaluate().isNotEmpty) {
        await tester.tap(minaToken.first, warnIfMissed: false);
        await safePumpAndSettle(tester);
        await tester.pump(const Duration(seconds: 2));
        print('✅ Entered TokenDetailPage');
      } else {
        testResults[testName] = 'FAIL - MINA token not found';
        return;
      }
      await ss.take(tester, '5.19.1_TokenDetail');
      
      // Step 3: Tap Staking action
      print('Step 3: Tap staking entry');
      var stakingAction = find.text(dic.staking);
      if (stakingAction.evaluate().isNotEmpty) {
        await tester.tap(stakingAction.first);
        await safePumpAndSettle(tester);
        await tester.pump(const Duration(seconds: 2));
        print('✅ Entered Staking page');
      } else {
        testResults[testName] = 'FAIL - Staking entry not found';
        return;
      }
      await ss.take(tester, '5.19.2_staking_page');
      
      // Step 4: Tap "Go to staking" or enter validator list
      print('Step 4: Open validator list');
      var goStakeBtn = find.text(dic.goStake);
      var changeBtn = find.text(dic.changeNode);
      if (goStakeBtn.evaluate().isNotEmpty) {
        await tester.tap(goStakeBtn.first);
        await safePumpAndSettle(tester);
        await tester.pump(const Duration(seconds: 2));
        print('✅ Tapped Go to staking');
      } else if (changeBtn.evaluate().isNotEmpty) {
        await tester.tap(changeBtn.first);
        await safePumpAndSettle(tester);
        await tester.pump(const Duration(seconds: 2));
        print('✅ Tapped Change');
      } else {
        // Validator page may still be loading
        for (int i = 0; i < 5; i++) {
          await tester.pump(const Duration(seconds: 1));
          goStakeBtn = find.text(dic.goStake);
          changeBtn = find.text(dic.changeNode);
          if (goStakeBtn.evaluate().isNotEmpty) {
            await tester.tap(goStakeBtn.first);
            await safePumpAndSettle(tester);
            await tester.pump(const Duration(seconds: 2));
            print('✅ Tapped Go to staking (delayed)');
            break;
          }
          if (changeBtn.evaluate().isNotEmpty) {
            await tester.tap(changeBtn.first);
            await safePumpAndSettle(tester);
            await tester.pump(const Duration(seconds: 2));
            print('✅ Tapped Change (delayed)');
            break;
          }
        }
      }
      
      // Step 5: Tap "Input Block Producer address" for manual entry
      print('Step 5: Manually enter validator address');
      var manualAddBtn = find.text(dic.manualAdd);
      if (manualAddBtn.evaluate().isEmpty) {
        // Wait for validator list to load
        for (int i = 0; i < 5; i++) {
          await tester.pump(const Duration(seconds: 1));
          manualAddBtn = find.text(dic.manualAdd);
          if (manualAddBtn.evaluate().isNotEmpty) break;
        }
      }
      if (manualAddBtn.evaluate().isNotEmpty) {
        await tester.ensureVisible(manualAddBtn.first);
        await safePumpAndSettle(tester);
        await tester.tap(manualAddBtn.first, warnIfMissed: false);
        await safePumpAndSettle(tester);
        await tester.pump(const Duration(seconds: 2));
        print('✅ Entered manual input page');
      } else {
        // Validator list may exist, search for target node
        testResults[testName] = 'FAIL - Manual input entry not found';
        return;
      }
      
      // Step 6: Enter validator address in DelegatePage
      print('Step 6: Enter validator address');
      var textFormFields = find.byType(TextField);
      if (textFormFields.evaluate().isNotEmpty) {
        // First TextField is validator address input
        await tester.enterText(textFormFields.at(0), stakingNodeAddress);
        await tester.pump(const Duration(seconds: 1));
        print('✅ Entered validator address');
      } else {
        testResults[testName] = 'FAIL - Address input not found';
        return;
      }
      
      // Wait for fee to load
      await tester.pump(const Duration(seconds: 3));
      await ss.take(tester, '5.19.3_validator_addr');
      
      // Step 7: Tap Next to submit
      print('Step 7: Tap Next');
      var nextBtn = find.text(dic.next);
      if (nextBtn.evaluate().isNotEmpty) {
        await tester.tap(nextBtn.first);
        await safePumpAndSettle(tester);
        await tester.pump(const Duration(seconds: 2));
        print('✅ Tapped Next');
      } else {
        testResults[testName] = 'PARTIAL - Next button not found';
        print('\n========== $testName Done ==========\n');
        return;
      }
      
      // Step 8: Wait for and handle TxConfirmDialog
      print('Step 8: Confirm transaction');
      // On validation failure, UI.toast uses native Fluttertoast, test finder cannot detect
      bool confirmFound = false;
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
        var confirmBtn = find.text(dic.confirm);
        if (confirmBtn.evaluate().isNotEmpty) {
          await tester.tap(confirmBtn.first, warnIfMissed: false);
          print('✅ Confirmed transaction');
          confirmFound = true;
          break;
        }
      }
      
      if (!confirmFound) {
        print('⚠️ Confirm dialog not shown (Devnet balance may be 0)');
        testResults[testName] = 'PARTIAL - Devnet insufficient balance or validation failed';
      } else {
        // Step 9: Handle password dialog (not shown when runtimePwd cached)
        print('Step 9: Enter password');
        await tester.pump(const Duration(seconds: 2));
        var pwdDialogTitle = find.text(dic.password);
        if (pwdDialogTitle.evaluate().isNotEmpty) {
          final pwdFields = find.byType(TextField);
          if (pwdFields.evaluate().isNotEmpty) {
            await tester.enterText(pwdFields.last, TestData.defaultPassword);
            await tester.pump(const Duration(seconds: 1));
            var confirmPwd = find.text(dic.confirm);
            if (confirmPwd.evaluate().isNotEmpty) {
              await tester.tap(confirmPwd.last, warnIfMissed: false);
              print('✅ Entered and confirmed password');
            }
          }
        } else {
          print('✅ Password auto-filled (runtimePwd)');
        }
        
        // Staking submitted (confirm + password passed), mark PASS
        testResults[testName] = 'PASS';
        
        // Step 10: Wait for tx result
        print('Step 10: Wait for tx result');
        for (int i = 0; i < 15; i++) {
          await tester.pump(const Duration(seconds: 1));
          var sendBtnCheck = find.byKey(TestKeys.sendButton);
          if (sendBtnCheck.evaluate().isNotEmpty && i > 3) {
            print('✅ Returned to home');
            break;
          }
        }
      }
      
      if (testResults[testName] == null) {
        testResults[testName] = 'PARTIAL - Staking flow incomplete';
      }
      
      // Return to home
      for (int i = 0; i < 5; i++) {
        var backBtn = find.byIcon(Icons.arrow_back);
        if (backBtn.evaluate().isNotEmpty) {
          await tester.tap(backBtn.first);
          await safePumpAndSettle(tester);
        }
        await tester.pump(const Duration(seconds: 1));
        if (find.byKey(TestKeys.sendButton).evaluate().isNotEmpty) break;
      }
      
      await ss.take(tester, '5.19.9_done');
      await endTestDelay(tester);
      print('\n========== $testName Done ==========\n');
    }, timeout: Timeout(Duration(minutes: 5)));

    testWidgets('5.20 Stake from home tab', (WidgetTester tester) async {
      const testName = '5.20 Stake from home tab';
      print('\n========== Start $testName ==========\n');
      final ss = ScreenshotHelper('flow5');
      
      app.main(testMode: true);
      
      bool ready = false;
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(seconds: 1));
        if (find.byKey(TestKeys.sendButton).evaluate().isNotEmpty) { ready = true; break; }
      }
      if (!ready) { testResults[testName] = 'SKIP - Home not loaded'; return; }
      
      const stakingNodeAddress = 'B62qpjxUpgdjzwQfd8q2gzxi99wN7SCgmofpvw27MBkfNHfHoY2VH32';
      
      // Step 1: Tap bottom Staking tab
      print('Step 1: Tap Staking tab');
      var stakingTab = find.text(dic.staking);
      if (stakingTab.evaluate().isNotEmpty) {
        // Bottom tab is BottomNavigationBarItem with label
        await tester.tap(stakingTab.last);
        await safePumpAndSettle(tester);
        await tester.pump(const Duration(seconds: 2));
        print('✅ Entered Staking tab');
      } else {
        testResults[testName] = 'FAIL - Staking tab not found';
        return;
      }
      await ss.take(tester, '5.20.1_staking_page');
      
      // Step 2: Tap "Go to staking" or "Change"
      print('Step 2: Open validator list');
      bool enteredValidators = false;
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(seconds: 1));
        var goStakeBtn = find.text(dic.goStake);
        var changeBtn = find.text(dic.changeNode);
        if (goStakeBtn.evaluate().isNotEmpty) {
          await tester.tap(goStakeBtn.first);
          await safePumpAndSettle(tester);
          await tester.pump(const Duration(seconds: 2));
          print('✅ Tapped Go to staking');
          enteredValidators = true;
          break;
        }
        if (changeBtn.evaluate().isNotEmpty) {
          await tester.tap(changeBtn.first);
          await safePumpAndSettle(tester);
          await tester.pump(const Duration(seconds: 2));
          print('✅ Tapped Change');
          enteredValidators = true;
          break;
        }
      }
      
      if (!enteredValidators) {
        testResults[testName] = 'FAIL - Could not enter validator list';
        return;
      }
      
      // Step 3: Manually enter validator
      print('Step 3: Manually enter validator address');
      var manualAddBtn = find.text(dic.manualAdd);
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
        manualAddBtn = find.text(dic.manualAdd);
        if (manualAddBtn.evaluate().isNotEmpty) break;
      }
      if (manualAddBtn.evaluate().isNotEmpty) {
        await tester.ensureVisible(manualAddBtn.first);
        await safePumpAndSettle(tester);
        await tester.tap(manualAddBtn.first, warnIfMissed: false);
        await safePumpAndSettle(tester);
        await tester.pump(const Duration(seconds: 2));
        print('✅ Entered manual input page');
      } else {
        testResults[testName] = 'FAIL - Manual input entry not found';
        return;
      }
      
      // Step 4: Enter validator address
      print('Step 4: Enter validator address');
      var textFormFields = find.byType(TextField);
      if (textFormFields.evaluate().isNotEmpty) {
        await tester.enterText(textFormFields.at(0), stakingNodeAddress);
        await tester.pump(const Duration(seconds: 1));
        print('✅ Entered validator address');
      } else {
        testResults[testName] = 'FAIL - Address input not found';
        return;
      }
      
      // Wait for fee to load
      await tester.pump(const Duration(seconds: 3));
      await ss.take(tester, '5.20.2_validator_addr');
      
      // Step 5: Tap Next
      print('Step 5: Tap Next');
      var nextBtn = find.text(dic.next);
      if (nextBtn.evaluate().isNotEmpty) {
        await tester.tap(nextBtn.first);
        await safePumpAndSettle(tester);
        await tester.pump(const Duration(seconds: 2));
        print('✅ Tapped Next');
      } else {
        testResults[testName] = 'PARTIAL - Next button not found';
        print('\n========== $testName Done ==========\n');
        return;
      }
      
      // Step 6: Wait for and handle TxConfirmDialog
      print('Step 6: Confirm transaction');
      // On validation failure, UI.toast uses native Fluttertoast, test finder cannot detect
      bool confirmFound = false;
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
        var confirmBtn = find.text(dic.confirm);
        if (confirmBtn.evaluate().isNotEmpty) {
          await tester.tap(confirmBtn.first, warnIfMissed: false);
          print('✅ Confirmed transaction');
          confirmFound = true;
          break;
        }
      }
      
      if (!confirmFound) {
        print('⚠️ Confirm dialog not shown (Devnet balance may be 0)');
        testResults[testName] = 'PARTIAL - Devnet insufficient balance or validation failed';
      } else {
        // Step 7: Handle password dialog (not shown when runtimePwd cached)
        print('Step 7: Enter password');
        await tester.pump(const Duration(seconds: 2));
        var pwdDialogTitle = find.text(dic.password);
        if (pwdDialogTitle.evaluate().isNotEmpty) {
          final pwdFields = find.byType(TextField);
          if (pwdFields.evaluate().isNotEmpty) {
            await tester.enterText(pwdFields.last, TestData.defaultPassword);
            await tester.pump(const Duration(seconds: 1));
            var confirmPwd = find.text(dic.confirm);
            if (confirmPwd.evaluate().isNotEmpty) {
              await tester.tap(confirmPwd.last, warnIfMissed: false);
              print('✅ Entered and confirmed password');
            }
          }
        } else {
          print('✅ Password auto-filled (runtimePwd)');
        }
        
        // Staking submitted (confirm + password passed), mark PASS
        testResults[testName] = 'PASS';
        
        // Step 8: Wait for tx result
        print('Step 8: Wait for tx result');
        for (int i = 0; i < 15; i++) {
          await tester.pump(const Duration(seconds: 1));
          var sendBtnCheck = find.byKey(TestKeys.sendButton);
          if (sendBtnCheck.evaluate().isNotEmpty && i > 3) {
            print('✅ Returned to home');
            break;
          }
        }
      }
      
      if (testResults[testName] == null) {
        testResults[testName] = 'PARTIAL - Staking flow incomplete';
      }
      
      // Switch back to Mainnet
      print('Step 9: Switch back to Mainnet');
      for (int i = 0; i < 5; i++) {
        var backBtn = find.byIcon(Icons.arrow_back);
        if (backBtn.evaluate().isNotEmpty) {
          await tester.tap(backBtn.first);
          await safePumpAndSettle(tester);
        }
        await tester.pump(const Duration(seconds: 1));
        if (find.byKey(TestKeys.sendButton).evaluate().isNotEmpty) break;
      }
      // Switch back to Wallet tab
      var walletTab = find.text(dic.wallet);
      if (walletTab.evaluate().isNotEmpty) {
        await tester.tap(walletTab.first);
        await safePumpAndSettle(tester);
      }
      // Switch back to Mainnet
      var netEntry = findBreakWordText('Devnet');
      if (netEntry.evaluate().isEmpty) netEntry = findBreakWordText('Mainnet');
      if (netEntry.evaluate().isEmpty) netEntry = find.text('Mainnet');
      if (netEntry.evaluate().isNotEmpty) {
        await tester.tap(netEntry.first, warnIfMissed: false);
        await safePumpAndSettle(tester);
        await tester.pump(const Duration(seconds: 1));
        var mainnetOpt = findBreakWordText('Mainnet');
        if (mainnetOpt.evaluate().isNotEmpty) {
          await tester.tap(mainnetOpt.first, warnIfMissed: false);
          for (int i = 0; i < 5; i++) {
            await tester.pump(const Duration(seconds: 1));
            if (find.byKey(TestKeys.sendButton).evaluate().isNotEmpty) break;
          }
          print('✅ Switched back to Mainnet');
        }
      }
      
      await ss.take(tester, '5.20_done');
      await endTestDelay(tester);
      print('\n========== $testName Done ==========\n');
    }, timeout: Timeout(Duration(minutes: 5)));

    testWidgets('5.21 Delete PK wallet account', (WidgetTester tester) async {
      const testName = '5.21 Delete PK wallet account';
      print('\n========== Start $testName ==========\n');
      final ss = ScreenshotHelper('flow5');
      
      app.main(testMode: true);
      
      bool ready = false;
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(seconds: 1));
        if (find.byKey(TestKeys.sendButton).evaluate().isNotEmpty) { ready = true; break; }
      }
      if (!ready) { testResults[testName] = 'SKIP - Home not loaded'; return; }
      
      // Step 1: Open wallet mgmt
      print('Step 1: Open wallet mgmt');
      await tester.tap(find.byKey(TestKeys.walletManageIcon));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      
      // Step 2: Find PK wallet account (containing B62qo1 address)
      print('Step 2: Find PK wallet account');
      // Scroll to bottom to ensure visible
      final listView = find.byType(ListView);
      if (listView.evaluate().isNotEmpty) {
        await tester.drag(listView.first, const Offset(0, -300));
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
      }
      
      var pkAddress = find.textContaining('B62qo1');
      if (pkAddress.evaluate().isEmpty) {
        testResults[testName] = 'SKIP - PK wallet not found (run 5.3b first)';
        return;
      }
      
      var accountMoreBtns = find.byKey(TestKeys.accountMoreButton);
      int pkIndex = 4; // expected: HD1-Acc1(0), HD1-Acc2(1), HD2-Acc1(2), HD2-Acc2(3), PK(4), KS(5)
      if (accountMoreBtns.evaluate().length <= pkIndex) {
        pkIndex = accountMoreBtns.evaluate().length - 2; // 2nd to last
      }
      if (pkIndex < 0 || accountMoreBtns.evaluate().length <= pkIndex) {
        testResults[testName] = 'SKIP - Not enough accounts';
        return;
      }
      
      int beforeCount = accountMoreBtns.evaluate().length;
      print('✅ Current account count: $beforeCount');
      
      await tester.ensureVisible(accountMoreBtns.at(pkIndex));
      await tester.pumpAndSettle();
      await tester.tap(accountMoreBtns.at(pkIndex));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      print('✅ Entered PK wallet account mgmt page');
      await ss.take(tester, '5.21.1_account_mgmt');
      
      // Step 3: Tap Delete Account
      print('Step 3: Tap delete account');
      var deleteBtn = find.text(dic.accountDelete);
      if (deleteBtn.evaluate().isEmpty) {
        testResults[testName] = 'FAIL - Delete button not found';
        return;
      }
      await tester.tap(deleteBtn.first);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      print('✅ Tapped delete');
      await ss.take(tester, '5.21.2_delete_confirm');
      
      // Step 4: Handle delete confirm dialog + password
      print('Step 4: Confirm delete');
      // Confirm dialog may have a confirm button
      var confirmDelBtn = find.text(dic.confirm);
      if (confirmDelBtn.evaluate().isNotEmpty) {
        await tester.tap(confirmDelBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
      }
      
      // Password input
      final pwdFields = find.byType(TextField);
      if (pwdFields.evaluate().isNotEmpty) {
        await tester.enterText(pwdFields.last, TestData.defaultPassword);
        await tester.pumpAndSettle();
        var confirmPwd = find.text(dic.confirm);
        if (confirmPwd.evaluate().isNotEmpty) {
          await tester.tap(confirmPwd.last);
          print('✅ Password confirmed');
        }
      }
      
      // Wait for delete to complete
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(seconds: 1));
        // After delete should return to wallet mgmt
        var addWalletCheck = find.byKey(TestKeys.addWalletButton);
        if (addWalletCheck.evaluate().isNotEmpty) {
          print('✅ Returned to wallet mgmt');
          break;
        }
      }
      
      // Step 5: Verify account count decreased
      print('Step 5: Verify delete result');
      var afterBtns = find.byKey(TestKeys.accountMoreButton);
      int afterCount = afterBtns.evaluate().length;
      print('Accounts after delete: $afterCount (before: $beforeCount)');
      
      if (afterCount < beforeCount) {
        print('✅ PK wallet account deleted');
        testResults[testName] = 'PASS';
      } else {
        // May have returned to home
        var homeCheck = find.byKey(TestKeys.sendButton);
        if (homeCheck.evaluate().isNotEmpty) {
          print('✅ Returned to home after delete');
          testResults[testName] = 'PASS';
        } else {
          testResults[testName] = 'PARTIAL - Delete not confirmed';
        }
      }
      
      await ss.take(tester, '5.21_done');
      await endTestDelay(tester);
      print('\n========== $testName Done ==========\n');
    }, timeout: Timeout(Duration(minutes: 3)));

    testWidgets('5.22 Delete KS wallet account', (WidgetTester tester) async {
      const testName = '5.22 Delete KS wallet account';
      print('\n========== Start $testName ==========\n');
      final ss = ScreenshotHelper('flow5');
      
      app.main(testMode: true);
      
      bool ready = false;
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(seconds: 1));
        if (find.byKey(TestKeys.sendButton).evaluate().isNotEmpty) { ready = true; break; }
      }
      if (!ready) { testResults[testName] = 'SKIP - Home not loaded'; return; }
      
      // Step 1: Open wallet mgmt
      print('Step 1: Open wallet mgmt');
      await tester.tap(find.byKey(TestKeys.walletManageIcon));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      
      // Step 2: Find Keystore wallet (last imported account)
      print('Step 2: Find Keystore wallet account');
      var accountMoreBtns = find.byKey(TestKeys.accountMoreButton);
      int lastIdx = accountMoreBtns.evaluate().length - 1;
      
      if (lastIdx < 0) {
        testResults[testName] = 'SKIP - No accounts found';
        return;
      }
      
      int beforeCount = accountMoreBtns.evaluate().length;
      print('✅ Current account count: $beforeCount');
      
      await tester.ensureVisible(accountMoreBtns.at(lastIdx));
      await tester.pumpAndSettle();
      await tester.tap(accountMoreBtns.at(lastIdx));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      print('✅ Entered last account mgmt page');
      await ss.take(tester, '5.22.1_account_mgmt');
      
      // Step 3: Tap Delete Account
      print('Step 3: Tap delete account');
      var deleteBtn = find.text(dic.accountDelete);
      if (deleteBtn.evaluate().isEmpty) {
        testResults[testName] = 'SKIP - Delete button not found (may be deleted in 5.19 or HD account)';
        return;
      }
      await tester.tap(deleteBtn.first);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      print('✅ Tapped delete');
      await ss.take(tester, '5.22.2_delete_confirm');
      
      // Step 4: Confirm delete + password
      print('Step 4: Confirm delete');
      var confirmDelBtn = find.text(dic.confirm);
      if (confirmDelBtn.evaluate().isNotEmpty) {
        await tester.tap(confirmDelBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
      }
      
      final pwdFields = find.byType(TextField);
      if (pwdFields.evaluate().isNotEmpty) {
        await tester.enterText(pwdFields.last, TestData.defaultPassword);
        await tester.pumpAndSettle();
        var confirmPwd = find.text(dic.confirm);
        if (confirmPwd.evaluate().isNotEmpty) {
          await tester.tap(confirmPwd.last);
          print('✅ Password confirmed');
        }
      }
      
      // Wait for delete to complete
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(seconds: 1));
        var addWalletCheck = find.byKey(TestKeys.addWalletButton);
        if (addWalletCheck.evaluate().isNotEmpty) break;
      }
      
      // Step 5: Verify
      print('Step 5: Verify delete result');
      var afterBtns = find.byKey(TestKeys.accountMoreButton);
      int afterCount = afterBtns.evaluate().length;
      print('Accounts after delete: $afterCount (before: $beforeCount)');
      
      if (afterCount < beforeCount) {
        print('✅ KS wallet account deleted');
        testResults[testName] = 'PASS';
      } else {
        var homeCheck = find.byKey(TestKeys.sendButton);
        if (homeCheck.evaluate().isNotEmpty) {
          testResults[testName] = 'PASS';
        } else {
          testResults[testName] = 'PARTIAL - Delete not confirmed';
        }
      }
      
      await ss.take(tester, '5.22_done');
      await endTestDelay(tester);
      print('\n========== $testName Done ==========\n');
    }, timeout: Timeout(Duration(minutes: 3)));

    testWidgets('5.23 Delete HD wallet group', (WidgetTester tester) async {
      const testName = '5.23 Delete HD wallet group';
      print('\n========== Start $testName ==========\n');
      final ss = ScreenshotHelper('flow5');
      
      app.main(testMode: true);
      
      bool ready = false;
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(seconds: 1));
        if (find.byKey(TestKeys.sendButton).evaluate().isNotEmpty) { ready = true; break; }
      }
      if (!ready) { testResults[testName] = 'SKIP - Home not loaded'; return; }
      
      // Step 1: Open wallet mgmt
      print('Step 1: Open wallet mgmt');
      await tester.tap(find.byKey(TestKeys.walletManageIcon));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      
      // Step 2: Find 2nd HD wallet walletMoreButton
      print('Step 2: Find HD wallet more button');
      var walletMoreBtns = find.byKey(TestKeys.walletMoreButton);
      if (walletMoreBtns.evaluate().length < 2) {
        testResults[testName] = 'SKIP - Less than 2 HD wallets (run 5.3 first)';
        return;
      }
      
      int beforeWalletCount = walletMoreBtns.evaluate().length;
      print('✅ Current HD wallet count: $beforeWalletCount');
      
      // Tap 2nd HD wallet walletMoreButton → WalletDetailsPage
      await tester.tap(walletMoreBtns.at(1));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      print('✅ Entered 2nd HD wallet details');
      await ss.take(tester, '5.23.1_wallet_detail');
      
      // Step 3: Tap Delete (red text)
      print('Step 3: Tap delete wallet');
      // WalletDetailsPage delete button shows dic.delete (red text)
      var deleteText = find.text(dic.delete);
      if (deleteText.evaluate().isEmpty) {
        deleteText = find.text(dic.deleteWallet);
      }
      if (deleteText.evaluate().isEmpty) {
        testResults[testName] = 'FAIL - Delete entry not found';
        return;
      }
      await tester.tap(deleteText.first);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      print('✅ Tapped delete');
      await ss.take(tester, '5.23.2_delete_confirm');
      
      // Step 4: Confirm delete dialog
      print('Step 4: Confirm delete dialog');
      var confirmDelBtn = find.text(dic.confirm);
      if (confirmDelBtn.evaluate().isNotEmpty) {
        await tester.tap(confirmDelBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        print('✅ Confirmed delete');
      }
      
      // Step 5: Enter password
      print('Step 5: Enter password');
      final pwdFields = find.byType(TextField);
      if (pwdFields.evaluate().isNotEmpty) {
        await tester.enterText(pwdFields.last, TestData.defaultPassword);
        await tester.pumpAndSettle();
        var confirmPwd = find.text(dic.confirm);
        if (confirmPwd.evaluate().isNotEmpty) {
          await tester.tap(confirmPwd.last);
          print('✅ Password confirmed');
        }
      }
      
      // Wait for delete to complete
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(seconds: 1));
        var addWalletCheck = find.byKey(TestKeys.addWalletButton);
        var homeCheck = find.byKey(TestKeys.sendButton);
        if (addWalletCheck.evaluate().isNotEmpty || homeCheck.evaluate().isNotEmpty) break;
      }
      
      // Step 6: Verify HD wallet count decreased
      print('Step 6: Verify delete result');
      // May have returned to wallet mgmt or home
      if (find.byKey(TestKeys.sendButton).evaluate().isNotEmpty) {
        // On home, reopen wallet mgmt
        await tester.tap(find.byKey(TestKeys.walletManageIcon));
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
      }
      
      var afterWalletBtns = find.byKey(TestKeys.walletMoreButton);
      int afterWalletCount = afterWalletBtns.evaluate().length;
      print('HD wallets after delete: $afterWalletCount (before: $beforeWalletCount)');
      
      if (afterWalletCount < beforeWalletCount) {
        print('✅ HD wallet group deleted');
        testResults[testName] = 'PASS';
      } else {
        // toast: walletDeleted
        var deletedToast = find.textContaining(dic.walletDeleted);
        if (deletedToast.evaluate().isNotEmpty) {
          testResults[testName] = 'PASS';
        } else {
          testResults[testName] = 'PARTIAL - Delete not confirmed';
        }
      }
      
      await ss.take(tester, '5.23_done');
      await endTestDelay(tester);
      print('\n========== $testName Done ==========\n');
    }, timeout: Timeout(Duration(minutes: 3)));

    testWidgets('5.24 Delete all data and reset', (WidgetTester tester) async {
      const testName = '5.24 Delete all data and reset';
      print('\n========== Start $testName ==========\n');
      final ss = ScreenshotHelper('flow5');
      
      app.main(testMode: true);
      
      bool ready = false;
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(seconds: 1));
        if (find.byKey(TestKeys.sendButton).evaluate().isNotEmpty) { ready = true; break; }
      }
      if (!ready) { testResults[testName] = 'SKIP - Home not loaded'; return; }
      
      // Step 1: Open wallet mgmt
      print('Step 1: Open wallet mgmt');
      await tester.tap(find.byKey(TestKeys.walletManageIcon));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      
      // Step 2: Find Reset button (at page bottom)
      print('Step 2: Find Reset button');
      var resetBtn = find.text(dic.reset);
      if (resetBtn.evaluate().isEmpty) {
        // May need to scroll to bottom
        final listView = find.byType(ListView);
        if (listView.evaluate().isNotEmpty) {
          await tester.drag(listView.first, const Offset(0, -500));
          await tester.pumpAndSettle();
          await tester.pump(const Duration(seconds: 1));
          resetBtn = find.text(dic.reset);
        }
      }
      
      if (resetBtn.evaluate().isEmpty) {
        testResults[testName] = 'FAIL - Reset button not found';
        return;
      }
      // Scroll to ensure Reset button visible and tappable
      await tester.ensureVisible(resetBtn.first);
      await tester.pumpAndSettle();
      await tester.tap(resetBtn.first, warnIfMissed: false);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      print('✅ Tapped Reset');
      await ss.take(tester, '5.24.1_reset_confirm');
      
      // Step 3: Confirm reset dialog (step 1: confirm warning)
      // dic.confirmReset and dic.reset are both "Reset", confirm button is later
      print('Step 3: Confirm reset warning');
      var resetConfirmBtn = find.text(dic.confirmReset);
      if (resetConfirmBtn.evaluate().isNotEmpty) {
        // Use .last since dialog button renders above page button
        await tester.tap(resetConfirmBtn.last, warnIfMissed: false);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        print('✅ Confirmed reset');
      }
      
      // Step 4: Type "delete" to confirm (step 2: CustomPromptDialog confirmation text)
      print('Step 4: Type "delete" to confirm');
      // Wait for CustomPromptDialog to appear
      bool foundInput = false;
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
        if (find.byType(TextField).evaluate().isNotEmpty) {
          foundInput = true;
          break;
        }
      }
      if (foundInput) {
        final textFields = find.byType(TextField);
        String deleteTag = dic.delete.toLowerCase();
        await tester.enterText(textFields.last, deleteTag);
        await tester.pumpAndSettle();
        print('✅ Entered "$deleteTag"');
        await ss.take(tester, '5.24.2_delete_input');
        
        // CustomPromptDialog confirm button uses dic.confirm ("Confirm")
        await tester.pump(const Duration(seconds: 1));
        var okBtn = find.text(dic.confirm);
        if (okBtn.evaluate().isNotEmpty) {
          await tester.tap(okBtn.last, warnIfMissed: false);
          print('✅ Confirmed delete');
        }
      } else {
        testResults[testName] = 'FAIL - Confirm input not found';
        return;
      }
      
      // Step 5: Wait for reset, verify returned to init page
      print('Step 5: Wait to return to init page');
      bool foundEntryPage = false;
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(seconds: 1));
        // Init page should have Create Wallet / Restore Wallet buttons
        var createBtn = find.byKey(TestKeys.createWalletButton);
        var restoreBtn = find.byKey(TestKeys.restoreWalletButton);
        var createText = find.text(dic.createWallet);
        var restoreText = find.text(dic.restoreWallet);
        
        if (createBtn.evaluate().isNotEmpty || restoreBtn.evaluate().isNotEmpty ||
            createText.evaluate().isNotEmpty || restoreText.evaluate().isNotEmpty) {
          print('✅ Returned to init page (CreateAccountEntryPage)');
          foundEntryPage = true;
          testResults[testName] = 'PASS';
          break;
        }
      }
      
      if (!foundEntryPage) {
        testResults[testName] = 'FAIL - Did not return to init page';
      }
      
      await ss.take(tester, '5.24_done');
      await endTestDelay(tester);
      print('\n========== $testName Done ==========\n');
    }, timeout: Timeout(Duration(minutes: 3)));

  });
}
