import 'dart:async';

import 'package:auro_wallet/common/components/loadingCircle.dart';
import 'package:auro_wallet/common/consts/testKeys.dart';
import 'package:auro_wallet/common/consts/token.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/assets/index.dart';
import 'package:auro_wallet/page/assets/token/component/TokenItem.dart';
import 'package:auro_wallet/page/assets/token/component/TokenListView.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/service/api/apiAssets.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/assets/types/token.dart';
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
  for (final (cached, fails) in [
    (false, false),
    (false, true),
    (true, false),
    (true, true),
  ]) {
    testWidgets(
      '${cached ? 'cached' : 'new'} account dims balance during request ${fails ? 'failure' : 'success'}',
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
        if (cached) {
          store.assets!.marketPrices[ZK_DEFAULT_TOKEN_ID] = 2;
          store.assets!.updateTokenAssets([
            Token(
              tokenAssestInfo: TokenAssetInfo(
                balance: Balance(total: '7000000000', liquid: '7000000000'),
                tokenId: ZK_DEFAULT_TOKEN_ID,
                publicKey: store.wallet!.currentAddress,
              ),
            ),
            Token(
              tokenAssestInfo: TokenAssetInfo(
                balance: Balance(total: '7', liquid: '7'),
                tokenId: 'custom-token',
                publicKey: store.wallet!.currentAddress,
              ),
            ),
          ], store.wallet!.currentAddress);
          store.assets!.setAssetsLoading(false);
        }

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
        expect(
          find.byType(LoadingCircle),
          cached ? findsNothing : findsOneWidget,
        );
        expect(
          find.byType(TokenItemView),
          cached ? findsOneWidget : findsNothing,
        );
        final balanceFinder = find.byKey(TestKeys.balanceDisplay);
        expect(
          find.byType(TokenManageIcon),
          cached ? findsOneWidget : findsNothing,
        );
        expect(
          tester.widget<Text>(balanceFinder).data,
          cached ? r'$ 14' : r'$ 0',
        );
        expect(
          tester.widget<Text>(balanceFinder).style!.color,
          const Color(0xFFDDDDDD),
        );

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
        expect(store.assets!.hasCurrentTokenAssets, cached || !fails);
        expect(
          find.byType(TokenManageIcon),
          cached && fails ? findsOneWidget : findsNothing,
        );
        expect(
          tester.widget<Text>(balanceFinder).data,
          cached && fails ? r'$ 14' : r'$ 0',
        );
        expect(
          tester.widget<Text>(balanceFinder).style!.color,
          !cached && fails ? const Color(0xFFDDDDDD) : Colors.white,
        );
        final row = tester.widget<TokenItemView>(find.byType(TokenItemView));
        expect(row.isBalanceKnown, cached || !fails);
        if (fails && !cached) {
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
