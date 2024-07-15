import 'package:auro_wallet/common/consts/Currency.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/assets/token/component/TokenIcon.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/assets/types/token.dart';
import 'package:auro_wallet/store/assets/types/tokenAssetInfo.dart';
import 'package:auro_wallet/store/assets/types/tokenBaseInfo.dart';
import 'package:auro_wallet/store/assets/types/tokenNetInfo.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class TokenManagaItem extends StatefulWidget {
  TokenManagaItem({
    required this.tokenItem,
    required this.store,
  });
  final Token tokenItem;
  final AppStore store;

  @override
  _TokenManagaItemState createState() =>
      _TokenManagaItemState(tokenItem, store);
}

class _TokenManagaItemState extends State<TokenManagaItem>
    with WidgetsBindingObserver {
  _TokenManagaItemState(this.tokenItem, this.store);

  final Token tokenItem;
  final AppStore store;

  String tokenIconUrl = "";
  String tokenSymbol = "Xxxxx"; // todo need update to fast
  String tokenName = "";
  String displayBalance = "";
  String? displayAmount;
  String? delegationText;
  bool isDelegation = false;
  bool isMinaNet = false;
  bool tokenShowed = true;
  bool hideToken = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppLocalizations dic = AppLocalizations.of(context)!;

      TokenAssetInfo? tokenAssestInfo = tokenItem.tokenAssestInfo;

      TokenNetInfo? tokenNetInfo = tokenItem.tokenNetInfo;
      TokenLocalConfig? localConfig = tokenItem.localConfig;
      TokenBaseInfo? tokenBaseInfo = tokenItem.tokenBaseInfo;

      bool isMainToken = tokenBaseInfo?.isMainToken ?? false;
      bool isFungibleToken = !isMainToken;
      if (isMainToken) {
        tokenIconUrl = "assets/images/stake/icon_mina_color.svg";
        tokenSymbol = COIN.coinSymbol;
        tokenName = COIN.name;
      } else {
        tokenSymbol = tokenNetInfo?.tokenSymbol ?? "UNKNOWN";
        tokenName = Fmt.address(tokenAssestInfo?.tokenId, pad: 6);
      }

      isDelegation = tokenBaseInfo?.isDelegation ?? false;
      displayBalance = Fmt.balance(tokenBaseInfo?.showBalance.toString(), 0);

      var currency = currencyConfig
          .firstWhere((element) => element.key == store.settings!.currencyCode);
      var currencySymbol = currency.symbol;

      if (tokenBaseInfo?.showAmount != null) {
        displayAmount =
            currencySymbol + " " + tokenBaseInfo!.showAmount.toString();
      }
      isMinaNet = store.settings!.isMinaNet;
      if (isMinaNet && isMainToken) {
        delegationText = tokenBaseInfo?.isDelegation == true
            ? dic.stakingStatus_1
            : dic.stakingStatus_2;
      }

      tokenShowed = tokenBaseInfo?.tokenShowed ?? false;
      hideToken = localConfig?.hideToken ?? false;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    return new Material(
      color: Colors.white,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
              color: Colors.black.withOpacity(0.1),
              width: 0.5,
            ))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    TokenIcon(
                      iconUrl: tokenIconUrl,
                      tokenSymbol: tokenSymbol,
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              tokenSymbol,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF000000).withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Text(
                          tokenName,
                          style: TextStyle(
                              color: ColorsUtil.hexColor(0x808080),
                              fontSize: 12,
                              fontWeight: FontWeight.w400),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Text(
                          dic.balance + ": " + displayBalance,
                          style: TextStyle(
                              color: ColorsUtil.hexColor(0x808080),
                              fontSize: 12,
                              fontWeight: FontWeight.w400),
                        )
                      ],
                    ),
                  ],
                ),
                SvgPicture.asset(
                  hideToken
                      ? "assets/images/assets/icon_add.svg"
                      : "assets/images/assets/icon_hide.svg",
                  fit: BoxFit.cover,
                ),
              ],
            )),
        // )
      ),
    );
  }
}
