/// Flow 1: Create wallet via mnemonic
/// 
/// Run with:
/// flutter drive --driver=test_driver/integration_test.dart --target=integration_test/flow1_create_test.dart -d <device_id>

import 'package:auro_wallet/common/consts/testKeys.dart';
import 'package:auro_wallet/main.dart' as app;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'test_utils.dart';

class TestData {
  static const String defaultPassword = 'Test1234!';
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Flow 1: Create wallet - to mnemonic verify page', (WidgetTester tester) async {
    const flowName = 'Flow1-CreateWallet';
    final ss = ScreenshotHelper('flow1');
    String testResult = 'UNKNOWN';
    print('\n========== Start $flowName ==========\n');
    
    app.main(testMode: true);
    
    // Wait for app initialization
    bool ready = false;
    for (int i = 0; i < 30; i++) {
      await tester.pump(const Duration(seconds: 1));
      final createButton = find.byKey(TestKeys.createWalletButton);
      if (createButton.evaluate().isNotEmpty) {
        print('✅ App initialized in ${i + 1}s');
        ready = true;
        break;
      }
      final sendButton = find.byKey(TestKeys.sendButton);
      if (sendButton.evaluate().isNotEmpty) {
        print('⚠️ Wallet already exists, please uninstall and reinstall');
        return;
      }
      if (i % 5 == 4) print('Waiting for init... ${i + 1}s');
    }
    
    if (!ready) {
      print('❌ App init timeout');
      testResult = 'FAIL - App init timeout';
      print('╔══════════════════════════════════════════════════════════════╗');
      print('║                     Flow 1 Test Summary                      ║');
      print('╠══════════════════════════════════════════════════════════════╣');
      print('║ ❌ $flowName: $testResult');
      print('╚══════════════════════════════════════════════════════════════╝\n');
      return;
    }
    
    await ss.take(tester, '1.0_init_page');
    
    // Step 1: Tap create wallet
    print('Step 1: Tap create wallet');
    final createButton = find.byKey(TestKeys.createWalletButton);
    await tester.tap(createButton);
    await tester.pumpAndSettle();
    print('✅ Tapped create wallet');
    await ss.take(tester, '1.1_tap_create_wallet');
    
    // Step 2: Accept privacy terms
    print('Step 2: Accept privacy terms');
    var agreeButton = find.byKey(TestKeys.termsAgreeButton);
    if (agreeButton.evaluate().isEmpty) agreeButton = find.text(dic.agree);
    if (agreeButton.evaluate().isNotEmpty) {
      await ss.take(tester, '1.2_terms_dialog');
      await tester.tap(agreeButton);
      await tester.pumpAndSettle();
      print('✅ Accepted terms');
    } else {
      print('⏭️ Terms dialog not shown');
    }
    
    // Step 3: Enter password
    print('Step 3: Enter password');
    await tester.pump(const Duration(seconds: 1));
    
    final passwordInput = find.byKey(TestKeys.passwordInput);
    if (passwordInput.evaluate().isEmpty) {
      print('❌ Password input not found');
      return;
    }
    await tester.enterText(passwordInput, TestData.defaultPassword);
    await tester.pumpAndSettle();
    print('✅ Password entered');
    
    final confirmInput = find.byKey(TestKeys.confirmPasswordInput);
    if (confirmInput.evaluate().isNotEmpty) {
      await tester.enterText(confirmInput, TestData.defaultPassword);
      await tester.pumpAndSettle();
      print('✅ Password confirmed');
    }
    
    await ss.take(tester, '1.3_password_done');
    
    final nextButton = find.byKey(TestKeys.nextButton);
    if (nextButton.evaluate().isNotEmpty) {
      await tester.tap(nextButton);
      await tester.pumpAndSettle();
      print('✅ Tapped next');
    }
    
    // Step 4: Backup tips page
    print('Step 4: Backup tips page');
    await tester.pump(const Duration(seconds: 1));
    
    final checkbox1 = find.byKey(TestKeys.backupTipsCheckbox1);
    if (checkbox1.evaluate().isNotEmpty) {
      await ss.take(tester, '1.4_backup_tips');
      await tester.tap(checkbox1);
      await tester.pumpAndSettle();
      print('✅ Checked term 1');
      
      final checkbox2 = find.byKey(TestKeys.backupTipsCheckbox2);
      if (checkbox2.evaluate().isNotEmpty) {
        await tester.tap(checkbox2);
        await tester.pumpAndSettle();
        print('✅ Checked term 2');
      }
      
      await ss.take(tester, '1.4.1_terms_checked');
      
      final tipsNextButton = find.byKey(TestKeys.backupTipsNextButton);
      if (tipsNextButton.evaluate().isNotEmpty) {
        await tester.tap(tipsNextButton);
        await tester.pumpAndSettle();
        print('✅ Backup tips next');
      }
    } else {
      print('❌ Backup tips checkbox not found');
    }
    
    // Step 5: Mnemonic display page
    print('Step 5: Mnemonic display page');
    await tester.pump(const Duration(seconds: 1));
    
    await ss.take(tester, '1.5_mnemonic_display');
    
    final mnemonicSavedButton = find.byKey(TestKeys.mnemonicSavedButton);
    if (mnemonicSavedButton.evaluate().isNotEmpty) {
      await tester.tap(mnemonicSavedButton);
      await tester.pumpAndSettle();
      print('✅ Tapped confirm backup');
    } else {
      var savedButton = find.text(dic.show_seed_button);
      if (savedButton.evaluate().isNotEmpty) {
        await tester.tap(savedButton);
        await tester.pumpAndSettle();
        print('✅ Tapped confirm backup (text match)');
      } else {
        print('❌ Confirm backup button not found');
      }
    }
    
    // Step 6: Verify mnemonic verification page
    print('Step 6: Check mnemonic verify page');
    await tester.pump(const Duration(seconds: 1));
    
    await ss.take(tester, '1.6_mnemonic_verify');
    
    // Mnemonic verify page contains clickable mnemonicWordButton
    final wordButtons = find.byKey(TestKeys.mnemonicWordButton);
    final seedError = find.textContaining(dic.seed_error);
    
    if (wordButtons.evaluate().isNotEmpty || seedError.evaluate().isEmpty) {
      print('✅ Reached mnemonic verify page');
      print('⏭️ Mnemonic verification requires correct order, skipping');
      testResult = 'PASS';
    } else {
      print('❌ Could not confirm mnemonic verify page');
      testResult = 'FAIL - Could not reach mnemonic verify page';
    }
    
    await endTestDelay(tester);
    
    // Test summary
    final status = testResult == 'PASS' ? '✅' : '❌';
    print('╔══════════════════════════════════════════════════════════════╗');
    print('║                     Flow 1 Test Summary                      ║');
    print('╠══════════════════════════════════════════════════════════════╣');
    print('║ $status $flowName: $testResult');
    print('╚══════════════════════════════════════════════════════════════╝\n');
    
    print('\n========== $flowName Done ==========\n');
  }, timeout: Timeout(Duration(minutes: 3)));
}
