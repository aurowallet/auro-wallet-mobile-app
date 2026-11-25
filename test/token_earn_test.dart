import 'package:auro_wallet/common/consts/token.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/assets/token/component/TokenItem.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/assets/types/token.dart';
import 'package:auro_wallet/store/settings/settings.dart';
import 'package:auro_wallet/store/settings/types/customNode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  testWidgets(
    'earn tag only appears on the main token outside selection dialogs',
    (tester) async {
      final store = AppStore();
      store.settings = SettingsStore(store);
      var tokenClicks = 0;
      Future<void> render({
        String network = 'mina:mainnet',
        bool modal = false,
        bool mainToken = true,
        Locale locale = const Locale('en'),
      }) async {
        store.settings!.currentNode = CustomNode(
          name: network,
          networkID: network,
          url: 'https://example.com',
        );
        final token = Token.fromJson(defaultMINAAssets);
        token.tokenBaseInfo!.isMainToken = mainToken;
        await tester.pumpWidget(
          MaterialApp(
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: TokenItemView(
                tokenItem: token,
                store: store,
                isInModal: modal,
                onClickTokenItem: (_) => tokenClicks++,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      await tester.binding.setSurfaceSize(const Size(360, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await render();
      expect(find.text('Earn'), findsOneWidget);
      await tester.tap(find.text('Earn'));
      expect(tokenClicks, 1);
      final earnIcon = find.byWidgetPredicate((widget) =>
        widget is SvgPicture && widget.width == 12 && widget.height == 12);
      await tester.tap(earnIcon);
      expect(tokenClicks, 2);
      await tester.tap(find.text('MINA'));
      expect(tokenClicks, 3);
      await render(modal: true);
      expect(find.text('Earn'), findsNothing);
      await render(network: 'zeko:mainnet');
      expect(find.text('Earn'), findsNothing);
      await render(mainToken: false);
      expect(find.text('Earn'), findsNothing);
      for (final locale in AppLocalizations.supportedLocales) {
        await render(locale: locale);
        expect(tester.takeException(), isNull);
      }
    },
  );
}
