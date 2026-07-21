import 'package:auro_wallet/common/consts/token.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/assets/assets.dart';
import 'package:auro_wallet/store/assets/types/transferData.dart';
import 'package:auro_wallet/store/wallet/types/accountData.dart';
import 'package:auro_wallet/store/wallet/types/walletData.dart';
import 'package:auro_wallet/store/wallet/wallet.dart';
import 'package:flutter_test/flutter_test.dart';

TransferData _pendingTx({
  required int nonce,
  required String hash,
  String type = 'payment',
  String status = 'pending',
}) {
  return TransferData()
    ..nonce = nonce
    ..hash = hash
    ..type = type
    ..sender = 'sender'
    ..receiver = 'receiver'
    ..amount = '1'
    ..fee = '0.1'
    ..status = status
    ..success = status != 'pending';
}

void _initWallet(AppStore appStore, String address) {
  final account = AccountData()
    ..pubKey = address
    ..name = 'Account 1'
    ..accountIndex = 0
    ..walletId = 'wallet-1';
  final wallet = WalletData()
    ..id = 'wallet-1'
    ..walletType = WalletStore.seedTypeMnemonic
    ..currentAccountIndex = 0
    ..accounts = [account];
  appStore.wallet = WalletStore(appStore)
    ..currentWalletId = wallet.id
    ..walletList.add(wallet);
}

void main() {
  group('Pending transaction speed up eligibility', () {
    test(
      'only the lowest nonce transaction can be sped up across main and token pending txs',
      () {
        final appStore = AppStore();
        final assets = AssetsStore(appStore);

        final mainTx = _pendingTx(nonce: 1, hash: 'main');
        final tokenTx = _pendingTx(nonce: 2, hash: 'token', type: 'zkApp');

        assets.pendingTxs.add(mainTx);
        assets.pendingZkTxs.add(tokenTx);

        assets.getTotalPendingTxs(ZK_DEFAULT_TOKEN_ID);

        expect(mainTx.showSpeedUp, isTrue);
        expect(tokenTx.showSpeedUp, isFalse);
      },
    );

    test(
      'token pending tx can be the only speed-up candidate when it has the lowest nonce',
      () {
        final appStore = AppStore();
        final assets = AssetsStore(appStore);

        final mainTx = _pendingTx(nonce: 3, hash: 'main');
        final tokenTx = _pendingTx(nonce: 2, hash: 'token', type: 'zkApp');

        mainTx.showSpeedUp = true;
        assets.pendingTxs.add(mainTx);
        assets.pendingZkTxs.add(tokenTx);

        assets.getTotalPendingTxs(ZK_DEFAULT_TOKEN_ID);

        expect(mainTx.showSpeedUp, isFalse);
        expect(tokenTx.showSpeedUp, isTrue);
      },
    );

    test(
      'token pending tx becomes speed-up candidate when main pending txs are cleared',
      () async {
        const address = 'sender';
        final appStore = AppStore();
        _initWallet(appStore, address);
        final assets = AssetsStore(appStore);

        final mainTx = _pendingTx(nonce: 1, hash: 'main');
        final tokenTx = _pendingTx(nonce: 2, hash: 'token', type: 'zkApp');

        assets.pendingTxs.add(mainTx);
        assets.pendingZkTxs.add(tokenTx);
        assets.getTotalPendingTxs(ZK_DEFAULT_TOKEN_ID);

        expect(mainTx.showSpeedUp, isTrue);
        expect(tokenTx.showSpeedUp, isFalse);

        await assets.addPendingTxs(null, address);

        expect(assets.pendingTxs, isEmpty);
        expect(tokenTx.showSpeedUp, isTrue);
      },
    );

    test('token build tx does not participate in speed-up eligibility', () {
      final appStore = AppStore();
      final assets = AssetsStore(appStore);

      final mainTx = _pendingTx(nonce: 2, hash: 'main');
      final buildTx = _pendingTx(nonce: 1, hash: 'build', type: 'zkApp');

      assets.pendingTxs.add(mainTx);
      assets.tokenBuildTxList['token-address'] = [buildTx];

      assets.getTotalPendingTxs(ZK_DEFAULT_TOKEN_ID);

      expect(mainTx.showSpeedUp, isTrue);
      expect(buildTx.showSpeedUp, isFalse);
    });

    test(
      'signed tx does not block the lowest actionable pending tx from speed-up',
      () {
        final appStore = AppStore();
        final assets = AssetsStore(appStore);

        final signedTx = _pendingTx(nonce: 1, hash: 'signed', status: 'signed');
        final pendingTx = _pendingTx(nonce: 2, hash: 'pending');

        assets.pendingTxs.addAll([pendingTx, signedTx]);
        assets.getTotalPendingTxs(ZK_DEFAULT_TOKEN_ID);

        expect(signedTx.showSpeedUp, isFalse);
        expect(pendingTx.showSpeedUp, isTrue);
      },
    );

    test(
      'zkapp token tx does not block the lowest actionable pending tx from speed-up',
      () {
        final appStore = AppStore();
        final assets = AssetsStore(appStore);

        final hiddenActionTx = _pendingTx(
          nonce: 1,
          hash: 'zkapp-token',
          type: 'zkapp_token',
        );
        final pendingTx = _pendingTx(nonce: 2, hash: 'pending');

        assets.pendingTxs.addAll([pendingTx, hiddenActionTx]);
        assets.getTotalPendingTxs(ZK_DEFAULT_TOKEN_ID);

        expect(hiddenActionTx.showSpeedUp, isFalse);
        expect(pendingTx.showSpeedUp, isTrue);
      },
    );

    test(
      'clears stale speed-up flags when no actionable pending tx remains',
      () {
        final appStore = AppStore();
        final assets = AssetsStore(appStore);

        final signedTx = _pendingTx(nonce: 1, hash: 'signed', status: 'signed')
          ..showSpeedUp = true;

        assets.pendingTxs.add(signedTx);
        assets.getTotalPendingTxs(ZK_DEFAULT_TOKEN_ID);

        expect(signedTx.showSpeedUp, isFalse);
      },
    );
  });
}
