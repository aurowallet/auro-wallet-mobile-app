import 'package:auro_wallet/common/components/appTextScale.dart';
import 'package:auro_wallet/common/consts/testKeys.dart';
import 'package:auro_wallet/common/theme.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/account/createAccountEntryPage.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'tablet_layout_test.dart' as helpers;

void main() {
  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    for (final scenario in [
      (
        name: 'phone 360',
        window: const Size(360, 800),
        display: const Size(360, 800),
      ),
      (
        name: 'phone 375',
        window: const Size(375, 812),
        display: const Size(375, 812),
      ),
      (
        name: 'phone 393',
        window: const Size(393, 852),
        display: const Size(393, 852),
      ),
      (
        name: 'phone 430',
        window: const Size(430, 932),
        display: const Size(430, 932),
      ),
      (
        name: 'tablet',
        window: const Size(800, 1280),
        display: const Size(800, 1280),
      ),
    ]) {
      for (final locale in AppLocalizations.supportedLocales) {
        testWidgets(
          '$platform ${scenario.name} welcome and import in $locale',
          (tester) async {
            helpers.viewport(
              tester,
              scenario.window,
              displaySize: scenario.display,
            );
            final settings = SettingsStore(AppStore())..termsAgreed = true;
            await tester.pumpWidget(
              MaterialApp(
                theme: appTheme.copyWith(platform: platform),
                locale: locale,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                builder: (_, child) => AppTextScale(child: child!),
                home: CreateAccountEntryPage(settings, (_, __) {}),
              ),
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            for (final key in [
              TestKeys.createWalletButton,
              TestKeys.restoreWalletButton,
            ]) {
              await tester.ensureVisible(find.byKey(key));
              await tester.pumpAndSettle();
              expect(find.byKey(key).hitTestable(), findsOneWidget);
            }
            await tester.tap(find.byKey(TestKeys.restoreWalletButton));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            final sheet = find.byType(BottomSheet);
            expect(sheet, findsOneWidget);
            final strings = AppLocalizations.of(tester.element(sheet))!;
            for (final text in [
              strings.mnemonicPhrase,
              strings.privateKey,
              strings.keystoreWallet,
            ]) {
              final option = find.descendant(
                of: sheet,
                matching: find.text(text),
              );
              await tester.ensureVisible(option);
              await tester.pumpAndSettle();
              expect(option.hitTestable(), findsOneWidget);
            }
            expect(helpers.clippedText(tester), isEmpty);
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
    testWidgets('$platform high DPI phone and tablet classification', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 3;
      tester.view.display.devicePixelRatio = 3;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.display.resetDevicePixelRatio);
      addTearDown(tester.view.display.resetSize);
      for (final scenario in [
        (
          window: const Size(360, 800),
          display: const Size(360, 800),
          tablet: false,
        ),
        (
          window: const Size(800, 1280),
          display: const Size(800, 1280),
          tablet: true,
        ),
      ]) {
        tester.view.physicalSize = scenario.window * 3;
        tester.view.display.size = scenario.display * 3;
        await tester.pumpWidget(
          MaterialApp(
            theme: appTheme.copyWith(platform: platform),
            home: AppTextScale(
              child: Builder(
                builder: (context) {
                  return Text(
                    '${AppTextScale.isTablet(context)}:${MediaQuery.textScalerOf(context).scale(16)}',
                  );
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('${scenario.tablet}:16.0'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  }
}
