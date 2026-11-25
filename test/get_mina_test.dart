import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/assets/token/component/GetMina.dart';
import 'package:auro_wallet/service/minaExchanges.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const exchange = MinaExchange(
  id: 'test',
  enabled: true,
  name: 'Exchange',
  iconUrl: 'https://example.com/icon.png',
  url: 'https://example.com/mina',
  description: {'en': 'Buy MINA', 'zh_CN': '获取 MINA'},
);
const config = MinaExchangesConfig(enabled: true, exchanges: [exchange]);

Widget app({
  String identity = 'account/mainnet/node',
  String? balance = '0',
  String network = 'mina:mainnet',
  String address = 'account',
  bool loading = false,
  MinaExchangesConfig? providers = config,
  Locale locale = const Locale('en'),
  double textScale = 1,
}) => MaterialApp(
  locale: locale,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: TextScaler.linear(textScale)),
    child: child!,
  ),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: Column(
      children: [
        GetMina(
          key: ValueKey(identity),
          config: providers,
          networkID: network,
          address: address,
          balance: balance,
          isLoading: loading,
        ),
      ],
    ),
  ),
);

void main() {
  testWidgets('waits for known zero balance and enabled providers on mainnet', (
    tester,
  ) async {
    for (final widget in [
      app(balance: null),
      app(balance: 'bad'),
      app(balance: '1'),
      app(loading: true),
      app(network: 'mina:devnet'),
      app(network: 'zeko:mainnet'),
      app(address: ''),
      app(providers: null),
      app(
        providers: const MinaExchangesConfig(
          enabled: false,
          exchanges: [exchange],
        ),
      ),
      app(providers: const MinaExchangesConfig(enabled: true, exchanges: [])),
    ]) {
      await tester.pumpWidget(widget);
      expect(find.text('Get MINA'), findsNothing);
    }
    await tester.pumpWidget(app());
    expect(find.text('Get MINA'), findsOneWidget);
    expect(tester.getSize(find.byType(GetMina)).height, 46);
  });

  testWidgets(
    'keeps the shown providers across refreshes and opens their original URL',
    (tester) async {
      final calls = <MethodCall>[];
      const channel = MethodChannel('plugins.flutter.io/url_launcher');
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
        call,
      ) async {
        calls.add(call);
        return true;
      });
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          channel,
          null,
        ),
      );
      await tester.pumpWidget(app());
      await tester.tap(find.text('Get MINA'));
      await tester.pumpAndSettle();
      expect(find.text('Get MINA From'), findsOneWidget);
      expect(find.text('Exchange'), findsOneWidget);
      await tester.pumpWidget(
        app(
          balance: '100',
          loading: true,
          providers: const MinaExchangesConfig(enabled: false, exchanges: []),
        ),
      );
      expect(find.text('Exchange'), findsOneWidget);
      final row = find.ancestor(
        of: find.text('Exchange'),
        matching: find.byType(InkWell),
      );
      // The link icon and the surrounding whitespace share the row's action.
      await tester.tapAt(tester.getRect(row).centerRight - const Offset(28, 0));
      await tester.pumpAndSettle();
      expect(
        calls.any(
          (call) =>
              call.method == 'launch' && call.arguments['url'] == exchange.url,
        ),
        isTrue,
      );
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Get MINA'));
      await tester.pumpAndSettle();
      expect(find.text('Exchange'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('repeated opening creates only one dismissible sheet', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    final button = tester.widget<InkWell>(
      find.ancestor(of: find.text('Get MINA'), matching: find.byType(InkWell)),
    );
    button.onTap!();
    button.onTap!();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
    await tester.tap(find.text('Get MINA'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets('long providers scroll on a small screen at 2x text in $locale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 420);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final providers = List.generate(
        8,
        (i) => MinaExchange(
          id: '$i',
          enabled: true,
          name: 'Exchange$i with a long provider name',
          iconUrl: exchange.iconUrl,
          url: exchange.url,
          description: i == 0
              ? {}
              : {
                  'en':
                      'Buy MINA with a long description that wraps across lines',
                },
        ),
      );
      await tester.pumpWidget(
        app(
          locale: locale,
          textScale: 2,
          providers: MinaExchangesConfig(enabled: true, exchanges: providers),
        ),
      );
      final context = tester.element(find.byType(GetMina));
      final dic = AppLocalizations.of(context)!;
      final close = MaterialLocalizations.of(context).closeButtonTooltip;
      await tester.tap(find.text(dic.getMina));
      await tester.pumpAndSettle();
      expect(find.text(providers.first.name), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(find.text(providers.last.name), 200);
      await tester.pumpAndSettle();
      expect(find.text(providers.last.name).hitTestable(), findsOneWidget);
      expect(find.byTooltip(close).hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip(close));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsNothing);
    });
  }

  testWidgets(
    'switching context before the sheet first builds removes the old sheet',
    (tester) async {
      await tester.pumpWidget(app());
      await tester.tap(find.text('Get MINA'));
      await tester.pumpWidget(app(identity: 'next-account', balance: null));
      await tester.pumpAndSettle();
      expect(find.text('Get MINA From'), findsNothing);
      expect(find.text('Exchange'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  for (final identity in [
    'other-account/mainnet/node',
    'account/devnet/node',
    'account/mainnet/other-node',
  ]) {
    testWidgets('closes and resets the entry after switching to $identity', (
      tester,
    ) async {
      await tester.pumpWidget(app());
      await tester.tap(find.text('Get MINA'));
      await tester.pumpAndSettle();
      await tester.pumpWidget(app(identity: identity, balance: null));
      await tester.pumpAndSettle();
      expect(find.text('Get MINA'), findsNothing);
      expect(find.text('Exchange'), findsNothing);
      await tester.pumpWidget(app(identity: identity));
      expect(find.text('Get MINA'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
