/// Flow 4: Import wallet via Keystore
/// 
/// Run with:
/// flutter drive --driver=test_driver/integration_test.dart --target=integration_test/flow4_keystore_test.dart -d <device_id>

import 'package:auro_wallet/common/consts/testKeys.dart';
import 'package:auro_wallet/main.dart' as app;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'test_config.dart';
import 'test_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  suppressBackgroundNetworkErrors();

  testWidgets('Flow 4: Import wallet via Keystore - to home', (WidgetTester tester) async {
    const flowName = 'Flow4-KeystoreImport';
    final ss = ScreenshotHelper('flow4');
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
    await ss.take(tester, '4.1_tap_restore');
    var agreeButton = find.byKey(TestKeys.termsAgreeButton);
    if (agreeButton.evaluate().isEmpty) agreeButton = find.text(dic.agree);
    if (agreeButton.evaluate().isNotEmpty) {
      await ss.take(tester, '4.2_terms_dialog');
      await tester.tap(agreeButton);
      await tester.pumpAndSettle();
      print('✅ Accepted terms');
    } else {
      print('⏭️ Terms dialog not shown');
    }
    
    // Step 3: Select Keystore import
    print('Step 3: Select Keystore import');
    await tester.pump(const Duration(seconds: 1));
    final keystoreOption = find.text('Keystore');
    if (keystoreOption.evaluate().isNotEmpty) {
      await ss.take(tester, '4.3_select_keystore');
      await tester.tap(keystoreOption);
      await tester.pumpAndSettle();
      print('✅ Selected Keystore import');
    } else {
      print('❌ Keystore import option not found');
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
    
    // Step 5: Enter Keystore content
    print('Step 5: Enter Keystore content');
    await tester.pump(const Duration(seconds: 1));
    
    final keystoreInput = find.byKey(TestKeys.keystoreInput);
    await ss.take(tester, '4.4_password_done');
    
    if (keystoreInput.evaluate().isNotEmpty) {
      await tester.enterText(keystoreInput, TestConfig.ksWallet.keystoreJson);
      await tester.pumpAndSettle();
      print('✅ Keystore content entered');
    } else {
      print('❌ Keystore input not found');
      return;
    }
    
    // Step 6: Enter Keystore password
    print('Step 6: Enter Keystore password');
    final keystorePasswordInput = find.byKey(TestKeys.keystorePasswordInput);
    if (keystorePasswordInput.evaluate().isNotEmpty) {
      await tester.enterText(keystorePasswordInput, TestConfig.ksWallet.keystorePassword);
      await tester.pumpAndSettle();
      print('✅ Keystore password entered');
    } else {
      print('❌ Keystore password input not found');
      return;
    }
    
    await ss.take(tester, '4.5_keystore_done');
    
    // Step 7: Tap import button
    print('Step 7: Tap import button');
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
    
    // Step 8: Handle import success page
    print('Step 8: Handle import success page');
    await tester.pump(const Duration(seconds: 1));
    
    await ss.take(tester, '4.6_import_success');
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
    
    // Step 9: Check if home page is reached
    print('Step 9: Check home page');
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
      await ss.take(tester, '4.7_home_page');
      testResult = 'PASS';
    } else {
      print('❌ Could not reach home page');
      testResult = 'FAIL - Could not reach home page';
    }
    
    await endTestDelay(tester);
    
    // Test summary
    final status = testResult == 'PASS' ? '✅' : '❌';
    print('╔══════════════════════════════════════════════════════════════╗');
    print('║                     Flow 4 Test Summary                      ║');
    print('╠══════════════════════════════════════════════════════════════╣');
    print('║ $status $flowName: $testResult');
    print('╚══════════════════════════════════════════════════════════════╝\n');
    
    print('\n========== $flowName Done ==========\n');
  }, timeout: Timeout(Duration(minutes: 3)));
}
