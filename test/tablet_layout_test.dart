import 'dart:math';

import 'package:auro_wallet/common/components/appTextScale.dart';
import 'package:auro_wallet/common/components/customConfirmDialog.dart';
import 'package:auro_wallet/common/components/customDropdownButton.dart';
import 'package:auro_wallet/common/components/customPromptDialog.dart';
import 'package:auro_wallet/common/components/feeSelector.dart';
import 'package:auro_wallet/common/components/inputErrorTip.dart';
import 'package:auro_wallet/common/components/menuItem.dart';
import 'package:auro_wallet/common/components/mnemonicGrid.dart';
import 'package:auro_wallet/common/components/normalButton.dart';
import 'package:auro_wallet/common/components/scamTag.dart';
import 'package:auro_wallet/common/consts/testKeys.dart';
import 'package:auro_wallet/common/theme.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/account/addWalletPage.dart';
import 'package:auro_wallet/page/account/createAccountEntryPage.dart';
import 'package:auro_wallet/page/browser/components/browserTab.dart';
import 'package:auro_wallet/page/settings/currenciesPage.dart';
import 'package:auro_wallet/page/settings/localesPage.dart';
import 'package:auro_wallet/page/settings/security/exportMnemonicResultPage.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/assets/types/fees.dart';
import 'package:auro_wallet/store/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(
  Widget child, {
  bool legacy = false,
  Locale locale = const Locale('en'),
  Object? arguments,
}) {
  return MaterialApp(
    theme: appTheme,
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) {
      final media = MediaQuery.of(context);
      return legacy
          ? MediaQuery(
              data: media.copyWith(
                textScaler: TextScaler.linear(
                  max(min(media.size.width / 375, 2.0), 1.0),
                ),
              ),
              child: child!,
            )
          : AppTextScale(child: child!);
    },
    onGenerateRoute: (_) => MaterialPageRoute<void>(
      settings: RouteSettings(arguments: arguments),
      builder: (_) => child,
    ),
  );
}

void viewport(WidgetTester tester, Size size, {Size? displaySize}) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  tester.view.display.size = displaySize ?? size;
  tester.view.display.devicePixelRatio = 1;
  addTearDown(tester.view.display.resetSize);
  addTearDown(tester.view.display.resetDevicePixelRatio);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}

List<String> clippedText(WidgetTester tester) {
  final clipped = <String>[];
  for (final element in find.byType(RichText).evaluate()) {
    final paragraph = element.renderObject! as RenderParagraph;
    if (paragraph.text.toPlainText().isEmpty) continue;
    final painter = TextPainter(
      text: paragraph.text,
      textDirection: paragraph.textDirection,
      textScaler: paragraph.textScaler,
      maxLines: paragraph.maxLines,
      ellipsis: paragraph.overflow == TextOverflow.ellipsis ? '\u2026' : null,
      strutStyle: paragraph.strutStyle,
      textHeightBehavior: paragraph.textHeightBehavior,
    )..layout(maxWidth: paragraph.size.width);
    if (paragraph.size.height + 0.1 < painter.height) {
      clipped.add(paragraph.text.toPlainText());
    }
    painter.dispose();
  }
  return clipped;
}

Widget controls({TextEditingController? validationController}) => Scaffold(
  body: SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(
      children: [
        ScamTag(),
        if (validationController != null)
          InputErrorTip(
            ctrl: validationController,
            message: 'Password required',
          ),
        FeeSelector(fees: Fees.fromDefault(), value: 0.0101, onChoose: (_) {}),
        CustomDropdownButton(
          items: [DropdownItem(text: 'Mainnet', value: 'mainnet')],
          onChoose: (_) {},
          value: 'mainnet',
        ),
        MenuItem(text: 'Language', value: 'English', onTap: () {}),
        NormalButton(text: 'Continue', onPressed: () {}),
        SizedBox(
          height: 100,
          child: BrowserTab(
            tabTitles: const ['Recent', 'Favorites'],
            tabContents: const [Text('Recent sites'), Text('Saved sites')],
          ),
        ),
      ],
    ),
  ),
);

List<Rect> textRects(WidgetTester tester) =>
    find.byType(RichText).evaluate().map((element) {
      final box = element.renderObject! as RenderBox;
      return box.localToGlobal(Offset.zero) & box.size;
    }).toList();

void main() {
  testWidgets('high-DPI phones retain their original text scale', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    tester.view.display.size = const Size(1170, 2532);
    tester.view.display.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.display.resetSize);
    addTearDown(tester.view.display.resetDevicePixelRatio);
    await tester.pumpWidget(
      app(
        Builder(
          builder: (context) {
            expect(AppTextScale.isTablet(context), isFalse);
            expect(MediaQuery.textScalerOf(context).scale(16), 16 * 390 / 375);
            return const SizedBox();
          },
        ),
      ),
    );
  });
  testWidgets(
    'iPad typography stays stable on rotation, split view and keyboard',
    (tester) async {
      viewport(
        tester,
        const Size(820, 1180),
        displaySize: const Size(820, 1180),
      );
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpWidget(
        app(
          Builder(
            builder: (context) =>
                Text(MediaQuery.textScalerOf(context).scale(16).toString()),
          ),
        ),
      );
      for (final size in [
        const Size(1180, 820),
        const Size(375, 1024),
        const Size(507, 1024),
      ]) {
        tester.view.physicalSize = size;
        tester.view.viewInsets = const FakeViewPadding(bottom: 320);
        await tester.pumpAndSettle();
        expect(find.text('16.0'), findsOneWidget);
      }
    },
  );
  testWidgets('tablet validation messages fit in a narrow split window', (
    tester,
  ) async {
    viewport(tester, const Size(375, 1024), displaySize: const Size(820, 1180));
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      app(
        Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: InputErrorTip(
              ctrl: controller,
              isError: true,
              message:
                  'Please check the password and enter the matching confirmation password.',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(clippedText(tester), isEmpty);
    expect(tester.takeException(), isNull);
  });
  for (final size in [
    const Size(320, 568),
    const Size(375, 812),
    const Size(430, 932),
    const Size(932, 430),
  ]) {
    test('phone text scaling stays unchanged at $size', () {
      final previous = max(min(size.width / 375, 2.0), 1.0);
      for (final fontSize in [12.0, 14.0, 16.0, 18.0, 24.0]) {
        expect(AppTextScale.forSize(size).scale(fontSize), previous * fontSize);
      }
    });
  }
  for (final size in [const Size(375, 812), const Size(430, 932)]) {
    testWidgets(
      'phone welcome page retains its logo and fixed layout at $size',
      (tester) async {
        viewport(tester, size);
        await tester.pumpWidget(
          app(CreateAccountEntryPage(SettingsStore(AppStore()), (_, __) {})),
        );
        await tester.pumpAndSettle();
        expect(
          tester.getSize(find.byType(Image)),
          Size(size.width * 245 / 375, size.width * 245 / 375 * 221 / 245),
        );
        // Reference positions captured before the mobile label-wrap fix.
        // Regular phone layouts keep their button positions and 48px height.
        final createTop = size.width == 375 ? 562.0 : 677.0;
        final restoreTop = size.width == 375 ? 630.0 : 745.0;
        expect(
          tester.getRect(find.byKey(TestKeys.createWalletButton)),
          Rect.fromLTWH(38, createTop, size.width - 76, 48),
        );
        expect(
          tester.getRect(find.byKey(TestKeys.restoreWalletButton)),
          Rect.fromLTWH(38, restoreTop, size.width - 76, 48),
        );
        expect(find.byType(CustomScrollView), findsNothing);
        expect(
          find.byKey(TestKeys.createWalletButton).hitTestable(),
          findsOneWidget,
        );
        expect(
          find.byKey(TestKeys.restoreWalletButton).hitTestable(),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
    testWidgets('phone mnemonic grid geometry stays unchanged at $size', (
      tester,
    ) async {
      viewport(tester, size);
      final words = List.generate(
        12,
        (index) => Text('${index + 1}. testword'),
      );
      await tester.pumpWidget(
        app(
          Scaffold(
            body: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 20,
              childAspectRatio: 3.4666,
              children: words,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final before = textRects(tester);
      await tester.pumpWidget(
        app(Scaffold(body: MnemonicGrid(mainAxisSpacing: 20, children: words))),
      );
      await tester.pumpAndSettle();
      expect(textRects(tester), before);
      expect(tester.takeException(), isNull);
    });
    testWidgets('phone control geometry stays unchanged at $size', (
      tester,
    ) async {
      viewport(tester, size);
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        app(controls(validationController: controller), legacy: true),
      );
      await tester.pumpAndSettle();
      final previous = textRects(tester);
      await tester.pumpWidget(app(controls(validationController: controller)));
      await tester.pumpAndSettle();
      expect(textRects(tester), previous);
      expect(tester.takeException(), isNull);
    });
  }
  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets(
      'welcome actions remain reachable in a short tablet window in $locale',
      (tester) async {
        viewport(
          tester,
          const Size(507, 400),
          displaySize: const Size(820, 1180),
        );
        await tester.pumpWidget(
          app(
            CreateAccountEntryPage(SettingsStore(AppStore()), (_, __) {}),
            locale: locale,
          ),
        );
        await tester.pumpAndSettle();
        for (final key in [
          TestKeys.createWalletButton,
          TestKeys.restoreWalletButton,
        ]) {
          await tester.ensureVisible(find.byKey(key));
          await tester.pumpAndSettle();
          expect(find.byKey(key).hitTestable(), findsOneWidget);
        }
        expect(clippedText(tester), isEmpty);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets('tablet text fits existing fixed-height token headers', (
    tester,
  ) async {
    viewport(tester, const Size(820, 1180));
    const content = Scaffold(
      body: Center(
        child: SizedBox(
          height: 20,
          child: Text('MINA', style: TextStyle(fontSize: 14)),
        ),
      ),
    );
    await tester.pumpWidget(app(content, legacy: true));
    await tester.pumpAndSettle();
    expect(clippedText(tester), isNotEmpty);
    await tester.pumpWidget(app(content));
    await tester.pumpAndSettle();
    expect(clippedText(tester), isEmpty);
  });
  for (final size in [
    const Size(375, 1024),
    const Size(600, 1024),
    const Size(768, 1024),
    const Size(820, 1180),
    const Size(1180, 820),
    const Size(1024, 1366),
  ]) {
    for (final locale in AppLocalizations.supportedLocales) {
      testWidgets('tablet controls fit at $size in $locale', (tester) async {
        viewport(tester, size, displaySize: const Size(820, 1180));
        await tester.pumpWidget(app(controls(), locale: locale));
        await tester.pumpAndSettle();
        expect(clippedText(tester), isEmpty);
        expect(tester.takeException(), isNull);
      });
    }
  }
  for (final size in [
    const Size(375, 1024),
    const Size(507, 1024),
    const Size(820, 1180),
    const Size(1180, 820),
  ]) {
    testWidgets('settings and account pages fit at $size', (tester) async {
      viewport(tester, size, displaySize: const Size(820, 1180));
      final store = AppStore();
      final settings = SettingsStore(store);
      for (final page in [
        CreateAccountEntryPage(settings, (_, __) {}),
        AddWalletPage(store),
        LocalesPage(settings, (_, __) {}),
        CurrenciesPage(settings),
      ]) {
        await tester.pumpWidget(app(page));
        await tester.pumpAndSettle();
        expect(
          clippedText(tester),
          isEmpty,
          reason: page.runtimeType.toString(),
        );
        expect(tester.takeException(), isNull);
      }
    });
    testWidgets('confirmation and input dialogs fit with keyboard at $size', (
      tester,
    ) async {
      viewport(tester, size, displaySize: const Size(820, 1180));
      tester.view.viewInsets = const FakeViewPadding(bottom: 320);
      addTearDown(tester.view.resetViewInsets);
      for (final dialog in [
        CustomConfirmDialog(
          title: 'Confirm transaction',
          contents: const ['Review the recipient address before confirming.'],
        ),
        CustomPromptDialog(title: 'Account name'),
      ]) {
        await tester.pumpWidget(app(Scaffold(body: dialog)));
        await tester.pumpAndSettle();
        expect(clippedText(tester), isEmpty);
        expect(tester.takeException(), isNull);
      }
    });
    testWidgets('exported recovery words and actions fit at $size', (
      tester,
    ) async {
      viewport(tester, size, displaySize: const Size(820, 1180));
      await tester.pumpWidget(
        app(
          ExportMnemonicResultPage(),
          arguments: <String, String>{
            // Synthetic layout fixture, not a real wallet seed.
            'key': List.filled(12, 'testword').join(' '),
          },
        ),
      );
      await tester.pumpAndSettle();
      expect(clippedText(tester), isEmpty);
      expect(tester.takeException(), isNull);
    });
  }
}
