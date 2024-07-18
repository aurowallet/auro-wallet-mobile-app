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

class TokenItemView extends StatelessWidget {
  TokenItemView(
      {required this.tokenItem,
      required this.store,
      this.onClickTokenItem,
      this.isInModal});
  final Token tokenItem;
  final AppStore store;
  final Function? onClickTokenItem;
  final bool? isInModal;

  @override
  Widget build(BuildContext context) {
    String tokenIconUrl = "";
    String tokenSymbol = "";
    String tokenName = "";
    String displayBalance = "";
    String? displayAmount;
    String? delegationText;
    bool isDelegation = false;
    bool isMinaNet = false;
    AppLocalizations dic = AppLocalizations.of(context)!;

    TokenAssetInfo? tokenAssestInfo = tokenItem.tokenAssestInfo;

    TokenNetInfo? tokenNetInfo = tokenItem.tokenNetInfo;
    TokenBaseInfo? tokenBaseInfo = tokenItem.tokenBaseInfo;
    bool isMainToken = tokenBaseInfo?.isMainToken ?? false;
    if (isMainToken) {
      tokenIconUrl = "assets/images/stake/icon_mina_color.svg";
      tokenSymbol = COIN.coinSymbol;
      tokenName = COIN.name;
    } else {
      tokenSymbol = tokenNetInfo?.tokenSymbol ?? "UNKNOWN";
      tokenName = Fmt.address(tokenAssestInfo?.tokenId, pad: 6);
    }
    isDelegation = tokenBaseInfo?.isDelegation ?? false;

    displayBalance = tokenBaseInfo?.showBalance != null
        ? Fmt.parseShowBalance(tokenBaseInfo!.showBalance!)
        : "0.0";

    var currency = currencyConfig
        .firstWhere((element) => element.key == store.settings!.currencyCode);
    var currencySymbol = currency.symbol;

    if (tokenBaseInfo?.showAmount != null) {
      displayAmount =
          currencySymbol + " " + tokenBaseInfo!.showAmount.toString();
    }
    isMinaNet = store.settings!.isMinaNet;
    if (isMinaNet && isMainToken && isInModal != true) {
      delegationText = tokenBaseInfo?.isDelegation == true
          ? dic.stakingStatus_1
          : dic.stakingStatus_2;
    }
    return new Material(
      color: Colors.white,
      child: InkWell(
          onTap: () {
            if (onClickTokenItem != null) {
              onClickTokenItem!(tokenItem);
            }
          },
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
                                delegationText != null
                                    ? Container(
                                        alignment: Alignment.center,
                                        child: Center(
                                          child: Text(
                                            delegationText,
                                            strutStyle: StrutStyle(
                                              fontSize: 12,
                                              leading: 0,
                                              height: 1.1,
                                              forceStrutHeight: true,
                                            ),
                                            style: TextStyle(
                                                color: Colors.white,
                                                height: 1.1,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                        margin: EdgeInsets.only(left: 5),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: isDelegation
                                              ? Color(0xFF594AF1)
                                              : Colors.black.withOpacity(0.3),
                                          borderRadius:
                                              BorderRadius.circular(29),
                                        ))
                                    : Container()
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
                            )
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          displayBalance,
                          style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF000000).withOpacity(0.8),
                              fontWeight: FontWeight.w500),
                        ),
                        displayAmount != null
                            ? Text(
                                displayAmount!,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: ColorsUtil.hexColor(0x808080),
                                    fontWeight: FontWeight.w500),
                              )
                            : Container(),
                      ],
                    )
                  ],
                )),
          )),
    );
  }
}
