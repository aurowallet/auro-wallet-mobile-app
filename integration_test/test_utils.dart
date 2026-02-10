/// Integration test shared utilities
/// 
/// Includes screenshot, i18n, text finder helpers

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:auro_wallet/l10n/app_localizations_en.dart';

/// i18n dictionary instance (English)
final dic = AppLocalizationsEn();

/// Strip zero-width spaces inserted by Fmt.breakWord
String stripBreakWord(String text) => text.replaceAll('\u200B', '');

/// Wait for a Finder to appear, up to maxWait seconds
/// Returns true if found, false if timed out
Future<bool> waitForWidget(WidgetTester tester, Finder finder, {int maxWait = 10}) async {
  for (int i = 0; i < maxWait; i++) {
    await tester.pump(const Duration(seconds: 1));
    if (finder.evaluate().isNotEmpty) return true;
  }
  return false;
}

/// Find text processed by Fmt.breakWord (\u200B zero-width space between chars)
/// Used to match network names and other breakWord-processed UI text
Finder findBreakWordText(String plainText) {
  return find.byWidgetPredicate(
    (widget) {
      if (widget is Text && widget.data != null) {
        return widget.data!.replaceAll('\u200B', '') == plainText;
      }
      if (widget is RichText) {
        final text = widget.text.toPlainText().replaceAll('\u200B', '');
        return text == plainText;
      }
      return false;
    },
    description: 'breakWord text "$plainText"',
  );
}

/// Delay before test ends so final state is visible
Future<void> endTestDelay(WidgetTester tester, {int seconds = 3}) async {
  await tester.pump(Duration(seconds: seconds));
}

/// Safe pumpAndSettle that won't hang on continuous animations (e.g. TimerManager)
/// Falls back to manual pump if pumpAndSettle times out
Future<void> safePumpAndSettle(WidgetTester tester, {int fallbackPumps = 3, int timeoutSeconds = 5}) async {
  try {
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      Duration(seconds: timeoutSeconds),
    );
  } catch (e) {
    for (int i = 0; i < fallbackPumps; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
  }
}

/// Screenshot root directory (Mac host /tmp/, writable from simulator)
const String _screenshotRoot = '/tmp/auro_test_screenshots';

/// Screenshot helper
/// 
/// Usage:
/// ```dart
/// final screenshotHelper = ScreenshotHelper('flow1');
/// await screenshotHelper.take(tester, '1.1_tap_create_wallet');
/// ```
class ScreenshotHelper {
  final String flowName;
  late String _baseDir;
  int _autoIndex = 0;

  ScreenshotHelper(this.flowName) {
    // Save to Mac host /tmp/ (writable from simulator, persists across app uninstall)
    _baseDir = '$_screenshotRoot/$flowName';
    try {
      final dir = Directory(_baseDir);
      if (!dir.existsSync()) dir.createSync(recursive: true);
      // Verify writable
      final testFile = File('$_baseDir/.write_test');
      testFile.writeAsStringSync('ok');
      testFile.deleteSync();
    } catch (e) {
      // Fallback to app sandbox tmp
      final tmpDir = Directory.systemTemp.path;
      _baseDir = '$tmpDir/auro_test_screenshots/$flowName';
      print('⚠️ /tmp/ not writable, fallback to: $_baseDir');
    }
  }

  String get baseDir => _baseDir;

  /// Take a screenshot of the current page
  Future<void> take(
    WidgetTester tester,
    String stepName, {
    String? description,
  }) async {
    try {
      final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
      
      // Ensure rendering is complete
      await tester.pump(const Duration(milliseconds: 500));
      
      // Generate safe filename
      final safeName = stepName
          .replaceAll(RegExp(r'[^\w\u4e00-\u9fff\-\.]'), '_')
          .replaceAll(RegExp(r'_+'), '_');
      
      final fileName = '${safeName}.png';
      
      // Create directory
      final dir = Directory(_baseDir);
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
      
      // Capture screenshot
      final List<int> screenshot = await binding.takeScreenshot(safeName);
      
      // Write to file
      final file = File('$_baseDir/$fileName');
      await file.writeAsBytes(screenshot);
      
      final desc = description != null ? ' ($description)' : '';
      print('📸 Screenshot saved: $_baseDir/$fileName$desc');
    } catch (e) {
      print('⚠️ Screenshot failed: $stepName - $e');
    }
  }

  /// Auto-numbered screenshot
  Future<void> takeAuto(
    WidgetTester tester,
    String description,
  ) async {
    _autoIndex++;
    final stepName = '${_autoIndex.toString().padLeft(2, '0')}_$description';
    await take(tester, stepName, description: description);
  }

  /// Print screenshot summary
  /// run_tests.sh will copy screenshots to project dir after tests
  static Future<void> printSummary() async {
    try {
      final srcDir = Directory(_screenshotRoot);
      if (!srcDir.existsSync()) {
        print('⚠️ Screenshot source dir not found: $_screenshotRoot');
        return;
      }
      int count = 0;
      for (var entity in srcDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.png')) count++;
      }
      print('\n📸📸📸 Screenshots saved to: $_screenshotRoot');
      print('📸 Total: $count screenshots');
    } catch (e) {
      print('📸 Screenshots at: $_screenshotRoot');
    }
  }
}
