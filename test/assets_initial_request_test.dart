import 'dart:async';

import 'package:auro_wallet/common/components/loadingCircle.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/assets/index.dart';
import 'package:auro_wallet/page/assets/token/component/TokenItem.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/service/api/apiAssets.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/wallet/wallet.dart';
import 'package:auro_wallet/utils/localStorage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'network_context_test.dart' as helpers;

class _Api extends Fake implements Api {
  _Api(this.graphQLClient);

  @override
  GraphQLClient graphQLClient;

  @override
  late final assets = ApiAssets(this);
}

void main() {
  for (final fails in [false, true]) {
    testWidgets(
      'new account shows loading then MINA after request ${fails ? 'failure' : 'success'}',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final store = globalAppStore;
        store.localStorage = LocalStorage();
        helpers.init(store);
        final wallet = store.wallet!.currentWallet;
        wallet.accounts.single.pubKey =
            'B62qaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
        wallet.accounts.single.name = 'Account';
        wallet.walletType = WalletStore.seedTypeMnemonic;
        store.wallet = WalletStore(store)
          ..walletList.add(wallet)
          ..currentWalletId = wallet.id;
        store.settings!.currentNode = helpers.node(
          'mina:devnet',
          'https://dev.example',
        );
        store.settings!.currentNode!.name = 'Devnet';
        await tester.runAsync(() => store.assets!.loadAccountCache());

        final response = Completer<Response>();
        webApi = _Api(
          GraphQLClient(
            link: Link.function(
              (_, [__]) => Stream.fromFuture(response.future),
            ),
            cache: GraphQLCache(),
          ),
        );
        await tester.binding.setSurfaceSize(const Size(393, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('zh'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: Assets(store)),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.byType(LoadingCircle), findsOneWidget);
        expect(find.byType(TokenItemView), findsNothing);

        response.complete(
          Response(
            response: const {},
            data: fails ? null : {'accounts': []},
            errors: fails ? [GraphQLError(message: 'offline')] : null,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(LoadingCircle), findsNothing);
        expect(find.byType(TokenItemView), findsOneWidget);
        expect(find.text('MINA'), findsOneWidget);
        expect(store.assets!.hasCurrentTokenAssets, !fails);
        final row = tester.widget<TokenItemView>(find.byType(TokenItemView));
        expect(row.isBalanceKnown, !fails);
        if (fails) {
          expect(store.assets!.tokenList, isEmpty);
          expect(
            await tester.runAsync(
              () => store.localStorage.getAccountCache(
                store.wallet!.currentAddress,
                store.assets!.cacheTokensKey,
              ),
            ),
            isNull,
          );
        }
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
}
