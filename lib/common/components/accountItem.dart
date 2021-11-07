import 'package:auro_wallet/common/consts/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/wallet/wallet.dart';
import 'package:auro_wallet/store/wallet/types/walletData.dart';
import 'package:auro_wallet/store/wallet/types/accountData.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:circular_check_box/circular_check_box.dart';
import 'package:auro_wallet/common/components/roundedCard.dart';
import 'package:auro_wallet/page/account/accountManagePage.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
class WalletItem extends StatelessWidget {
  WalletItem(
      {
        required this.balance,
        required this.wallet,
        required this.account,
        required this.store,
      });
  final WalletData wallet;
  final AccountData account;
  final BigInt balance;
  final AppStore store;
  BuildContext? _context;
  void _changeCurrentAccount(bool? isChecked) async {
    if (isChecked! && account.address != store.wallet!.currentAddress) {
      await webApi.account.changeCurrentAccount(pubKey: account.address, fetchData: true);
    }
  }

  void _viewAccountInfo() {
    print('account info');
    Navigator.pushNamed(_context!, AccountManagePage.route, arguments: {
      "account": account,
      "wallet": wallet
    });
  }

  void _onTapWallet() {
    print('tab wallet');
    if(wallet.walletType == WalletStore.seedTypeNone) {
      _viewAccountInfo();
      return;
    }
    _changeCurrentAccount(account.address != store.wallet!.currentAddress);
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> i18n = I18n.of(context).main;
    final TextTheme theme = Theme.of(context).textTheme;
    String? labelText;
    bool isObserve = false;
    _context = context;
    if (wallet.source == WalletSource.outside && wallet.walletType == WalletStore.seedTypePrivateKey) {
      labelText = i18n['accountImport'];
    } else if(wallet.walletType == WalletStore.seedTypeNone) {
      labelText = i18n['watchLabel'];
      isObserve = true;
    }
    final bool isChecked = account.address == store.wallet!.currentAddress;
    return Padding(
      padding: EdgeInsets.only(top: 20, right: 30, left: 30),
      child: GestureDetector(
          onTap: _onTapWallet,
          behavior: HitTestBehavior.opaque,
          child: RoundedCard(
            padding: EdgeInsets.fromLTRB(20, 10, 10, 15),
            type: RoundedCardType.small,
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 1,
                    child:  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(padding: EdgeInsets.only(top: 5),),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                                flex: 1,
                                child: Text(
                                    Fmt.accountName(account),
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.headline4!.copyWith(
                                        color: ColorsUtil.hexColor(0x333333),
                                        fontWeight: FontWeight.w500,
                                        height: 1
                                    ))
                            ),
                            labelText != null ? Container(
                                child: Text(labelText, style: theme.headline6!.copyWith(color: Colors.white),),
                                margin: EdgeInsets.only(left: 5),
                                padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: ColorsUtil.hexColor(isObserve ? 0xFF8502: 0x02a8ff),
                                  borderRadius: BorderRadius.circular(10),
                                )
                            ): Container()
                          ],
                        ),
                        Padding(padding: EdgeInsets.only(top: 8),),
                        Text(Fmt.address(account.address), style: theme.headline5!.copyWith(color: ColorsUtil.hexColor(0xB1B3BD))),
                        Padding(padding: EdgeInsets.only(top: 8),),
                        Text(
                          Fmt.balance(balance.toString(), COIN.decimals) + ' ' + COIN.coinSymbol,
                          style: theme.headline6!.copyWith(color: ColorsUtil.hexColor(0x8F92A1), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        isObserve && !isChecked ? IconButton(icon: Icon(Icons.info, color: Colors.red, size: 30,), onPressed: _viewAccountInfo) : CircularCheckBox(
                          value: isChecked,
                          checkColor: Colors.white,
                          activeColor: ColorsUtil.hexColor(0x59c49c),
                          // inactiveColor: ColorsUtil.hexColor(0xCCCCCC),
                          onChanged: _changeCurrentAccount,
                        ),
                        Padding(padding: EdgeInsets.only(top: 10),),
                        GestureDetector(
                          child: Icon(Icons.more_horiz, size: 20,),
                          onTap: _viewAccountInfo,
                        )
                      ]
                  )
                ],
              ),
            ),
          )
      )
    );
  }
}

