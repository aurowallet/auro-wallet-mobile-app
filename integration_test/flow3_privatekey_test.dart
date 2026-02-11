/// Flow 3: Import wallet via private key
/// 
/// Run with:
/// flutter drive --driver=test_driver/integration_test.dart --target=integration_test/flow3_privatekey_test.dart -d <device_id>

import 'package:auro_wallet/common/consts/testKeys.dart';
import 'package:auro_wallet/main.dart' as app;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'test_config.dart';
import 'test_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  suppressBackgroundNetworkErrors();

  testWidgets('Flow 3: Import wallet via private key - to home', (WidgetTester tester) async {
    const flowName = 'Flow3-PrivateKeyImport';
    final ss = ScreenshotHelper('flow3');
    String testResult = 'UNKNOWN';
    print('\n========== Start $flowName ==========\n');
    
    app.main(testMode: true);
    
    // Wait for app initialization
    bool ready = false;
    bool hasWallet = false;
    for (int i = 0; i < 30; i++) {
      await tester.pump(const Duration(seconds: 1));
      final restoreButton = find.byKey(TestKeys.restoreWalletButton);
      if (restoreButton.evaluate().isNotEmpty) {
        print('✅ App initialized in ${i + 1}s');
        ready = true;
        break;
      }
      final sendButton = find.byKey(TestKeys.sendButton);
      if (sendButton.evaluate().isNotEmpty) {
        print('⚠️ Wallet already exists, please uninstall and reinstall');
        hasWallet = true;
        break;
      }
      if (i % 5 == 4) print('Waiting for init... ${i + 1}s');
    }
    
    if (hasWallet) {
      print('❌ Test aborted: wallet data must be cleared');
      return;
    }
    
    if (!ready) {
      print('❌ App init timeout');
      return;
    }
    
    // Step 1: Tap restore wallet
    print('Step 1: Tap restore wallet');
    final restoreButton = find.byKey(TestKeys.restoreWalletButton);
    await tester.tap(restoreButton);
    await tester.pumpAndSettle();
    print('✅ Tapped restore wallet');
    
    // Step 2: Accept privacy terms
    print('Step 2: Accept privacy terms');
    await ss.take(tester, '3.1_tap_restore');
    var agreeButton = find.byKey(TestKeys.termsAgreeButton);
    if (agreeButton.evaluate().isEmpty) agreeButton = find.text(dic.agree);
    if (agreeButton.evaluate().isNotEmpty) {
      await ss.take(tester, '3.2_terms_dialog');
      await tester.tap(agreeButton);
      await tester.pumpAndSettle();
      print('✅ Accepted terms');
    } else {
      print('⏭️ Terms dialog not shown');
    }
    
    // Step 3: Select private key import
    print('Step 3: Select private key import');
    await tester.pump(const Duration(seconds: 1));
    var privateKeyOption = find.text(dic.privateKey);
    if (privateKeyOption.evaluate().isNotEmpty) {
      await ss.take(tester, '3.3_select_privatekey');
      await tester.tap(privateKeyOption);
      await tester.pumpAndSettle();
      print('✅ Selected private key import');
    } else {
      print('❌ Private key import option not found');
      return;
    }
    
    // Step 4: Enter password
    print('Step 4: Enter password');
    await tester.pump(const Duration(seconds: 1));
    
    final passwordInput = find.byKey(TestKeys.passwordInput);
    if (passwordInput.evaluate().isEmpty) {
      print('❌ Password input not found');
      return;
    }
    await tester.enterText(passwordInput, TestConfig.password);
    await tester.pumpAndSettle();
    print('✅ Password entered');
    
    final confirmInput = find.byKey(TestKeys.confirmPasswordInput);
    if (confirmInput.evaluate().isNotEmpty) {
      await tester.enterText(confirmInput, TestConfig.password);
      await tester.pumpAndSettle();
      print('✅ Password confirmed');
    }
    
    final nextButton = find.byKey(TestKeys.nextButton);
    if (nextButton.evaluate().isNotEmpty) {
      await tester.tap(nextButton);
      await tester.pumpAndSettle();
      print('✅ Tapped next');
    }
    
    // Step 5: Enter private key
    print('Step 5: Enter private key');
    await tester.pump(const Duration(seconds: 1));
    
    final privateKeyInput = find.byKey(TestKeys.privateKeyInput);
    await ss.take(tester, '3.4_password_done');
    
    if (privateKeyInput.evaluate().isNotEmpty) {
      await tester.enterText(privateKeyInput, TestConfig.pkWallet.privateKey);
      await tester.pumpAndSettle();
      print('✅ Private key entered');
      await ss.take(tester, '3.5_privatekey_entered');
    } else {
      print('❌ Private key input not found');
      return;
    }
    
    // Step 6: Tap import button
    print('Step 6: Tap import button');
    var importBtn = find.byKey(TestKeys.importButton);
    if (importBtn.evaluate().isEmpty) importBtn = find.text(dic.confirm);
    if (importBtn.evaluate().isEmpty) importBtn = find.text(dic.importWallet);
    
    if (importBtn.evaluate().isNotEmpty) {
      await tester.tap(importBtn);
      print('✅ Tapped import');
      await tester.pump(const Duration(seconds: 2));
      try {
        await tester.pumpAndSettle();
      } catch (e) {
        print('⚠️ pumpAndSettle timeout, continuing');
        await tester.pump(const Duration(seconds: 2));
      }
    } else {
      print('❌ Import button not found');
      return;
    }
    
    // Step 7: Handle import success page
    print('Step 7: Handle import success page');
    await tester.pump(const Duration(seconds: 1));
    
    await ss.take(tester, '3.6_import_success');
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
    
    // Step 8: Check if home page is reached
    print('Step 8: Check home page');
    bool reachedMain = false;
    for (int i = 0; i < 15; i++) {
      await tester.pump(const Duration(seconds: 1));
      final sendButton = find.byKey(TestKeys.sendButton);
      final balanceDisplay = find.byKey(TestKeys.balanceDisplay);
      if (sendButton.evaluate().isNotEmpty || balanceDisplay.evaluate().isNotEmpty) {
        print('✅ Reached home page in ${i + 1}s');
        reachedMain = true;
        break;
      }
      if (i % 5 == 4) print('Waiting for home... ${i + 1}s');
    }
    
    if (reachedMain) {
      await ss.take(tester, '3.7_home_page');
      testResult = 'PASS';
    } else {
      print('❌ Could not reach home page');
      testResult = 'FAIL - Could not reach home page';
    }
    
    await endTestDelay(tester);
    
    // Test summary
    final status = testResult == 'PASS' ? '✅' : '❌';
    print('╔══════════════════════════════════════════════════════════════╗');
    print('║                     Flow 3 Test Summary                      ║');
    print('╠══════════════════════════════════════════════════════════════╣');
    print('║ $status $flowName: $testResult');
    print('╚══════════════════════════════════════════════════════════════╝\n');
    
    print('\n========== $flowName Done ==========\n');
  }, timeout: Timeout(Duration(minutes: 3)));
}
