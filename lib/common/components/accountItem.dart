import 'package:auro_wallet/common/consts/enums.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/wallet/wallet.dart';
import 'package:auro_wallet/store/wallet/types/walletData.dart';
import 'package:auro_wallet/store/wallet/types/accountData.dart';
import 'package:auro_wallet/page/account/accountManagePage.dart';

class WalletItem extends StatelessWidget {
  WalletItem({
    required this.balance,
    required this.wallet,
    required this.account,
    required this.store,
    this.hideOption,
    this.onSelectAccount,
  });

  final WalletData wallet;
  final AccountData account;
  final BigInt balance;
  final AppStore store;
  final bool? hideOption;
  final Function(String)? onSelectAccount;

  void _changeCurrentAccount(bool? isChecked, BuildContext context) async {
    if (isChecked! && account.address != store.wallet!.currentAddress) {
      onSelectAccount?.call(account.address);
      await webApi.account
          .changeCurrentAccount(pubKey: account.address, fetchData: true);
      store.walletConnectService?.emitAccountsChanged(account.address);
      if (hideOption != true) {
        Navigator.of(context).pop();
      }
    } else {
      onSelectAccount?.call("");
    }
  }

  void _viewAccountInfo(BuildContext context) {
    print('account info');
    Navigator.pushNamed(context, AccountManagePage.route,
        arguments: {"account": account, "wallet": wallet});
  }

  void _onTapWallet(BuildContext context) {
    print('tab wallet');
    new Future.delayed(const Duration(milliseconds: 500), () {
      if (wallet.walletType == WalletStore.seedTypeNone) {
        _viewAccountInfo(context);
        return;
      }
      _changeCurrentAccount(
          account.address != store.wallet!.currentAddress, context);
    });
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    String? labelText;
    bool isObserve = false;
    if (wallet.source == WalletSource.outside &&
        wallet.walletType == WalletStore.seedTypePrivateKey) {
      labelText = dic.imported;
    } else if (wallet.walletType == WalletStore.seedTypeNone) {
      labelText = dic.watchLabel;
      isObserve = true;
    } else if (wallet.walletType == WalletStore.seedTypeLedger) {
      labelText = "Ledger";
    }
    final bool isChecked = account.address == store.wallet!.currentAddress;
    final Color textColor = isChecked ? Colors.white : Colors.black;
    final Color addressColor = isChecked
        ? Colors.white.withValues(alpha: 0.5)
        : Colors.black.withValues(alpha: 0.3);
    return Container(
      margin: EdgeInsets.only(top: 10, right: 20, left: 20),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: Material(
        color: isChecked ? Theme.of(context).primaryColor : Color(0xFFF9FAFC),
        child: InkWell(
          onTap: () => _onTapWallet(context),
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(
                    color: isChecked
                        ? Theme.of(context).primaryColor
                        : Colors.black.withValues(alpha: 0.05),
                    width: 1),
                borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 5),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                  flex: 1,
                                  child: Text(Fmt.accountName(account),
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: textColor,
                                          fontWeight: FontWeight.w600,
                                          height: 1.2))),
                              labelText != null
                                  ? Container(
                                      child: Text(
                                        labelText,
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: isObserve
                                                ? FontWeight.w500
                                                : FontWeight.w600,
                                            color: isChecked
                                                ? Color(0xFFFFFFFF)
                                                : (isObserve
                                                    ? Colors.black
                                                    : Color(0xFFFFFFFF))),
                                      ),
                                      margin: EdgeInsets.only(left: 4),
                                      padding: EdgeInsets.symmetric(
                                          vertical: 3, horizontal: 4),
                                      decoration: BoxDecoration(
                                        color: isChecked
                                            ? Color(0x1AFFFFFF)
                                            : Color(0x1A000000),
                                        borderRadius: BorderRadius.circular(4),
                                      ))
                                  : Container()
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 0),
                          ),
                          Text(Fmt.address(account.address, pad: 10),
                              style: TextStyle(
                                  color: addressColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400)),
                          Padding(
                            padding: EdgeInsets.only(top: 8),
                          ),
                          Text(
                            Fmt.balance(balance.toString(), COIN.decimals,
                                    maxLength: COIN.decimals) +
                                ' ' +
                                COIN.coinSymbol,
                            style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    hideOption == true
                        ? Container()
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                                isObserve && !isChecked
                                    ? IconButton(
                                        icon: Icon(
                                          Icons.info,
                                          color: Colors.red,
                                          size: 30,
                                        ),
                                        onPressed: () =>
                                            _viewAccountInfo(context),
                                      )
                                    : Container(),
                                Padding(
                                  padding: EdgeInsets.only(top: 10),
                                ),
                                GestureDetector(
                                  child: Icon(
                                    Icons.more_horiz,
                                    size: 20,
                                    color: textColor,
                                  ),
                                  onTap: () => _viewAccountInfo(context),
                                )
                              ])
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
