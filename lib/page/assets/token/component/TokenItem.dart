import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auro_wallet/common/consts/Currency.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/page/assets/token/component/TokenIcon.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/assets/types/token.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:auro_wallet/utils/index.dart';
import 'package:flutter/material.dart';

class TokenItemView extends StatelessWidget {
  TokenItemView(
      {required this.tokenItem,
      required this.store,
      this.onClickTokenItem,
      this.isBalanceKnown = true,
      this.isInModal});
  final Token tokenItem;
  final AppStore store;
  final Function? onClickTokenItem;
  final bool isBalanceKnown;
  final bool? isInModal;

  @override
  Widget build(BuildContext context) {
    String tokenIconUrl = "";
    String tokenSymbol = "";
    String tokenName = "";
    String displayBalance = "";
    String? displayAmount;
    bool isMinaNet = false;
    TokenAssetInfo? tokenAssestInfo = tokenItem.tokenAssestInfo;

    TokenNetInfo? tokenNetInfo = tokenItem.tokenNetInfo;
    TokenBaseInfo? tokenBaseInfo = tokenItem.tokenBaseInfo;
    bool isMainToken = tokenBaseInfo?.isMainToken ?? false;
    if (isMainToken) {
      tokenSymbol = COIN.coinSymbol;
      tokenName = COIN.name;
    } else {
      tokenSymbol = getTokenSymbol(tokenNetInfo);
      tokenName = Fmt.address(tokenAssestInfo?.tokenId, pad: 6);
    }
    tokenIconUrl = tokenBaseInfo?.iconUrl ?? "";
    final balance = tokenBaseInfo?.showBalance;
    if (!isBalanceKnown) {
      displayBalance = '--';
    } else if (balance != null) {
      displayBalance = Fmt.parseShowBalance(balance);
    } else {
      displayBalance = "0.0";
    }

    var currency = currencyConfig
        .firstWhere((element) => element.key == store.settings!.currencyCode);
    var currencySymbol = currency.symbol;

    if (isBalanceKnown && tokenBaseInfo?.showAmount != null) {
      displayAmount =
          currencySymbol + " " + tokenBaseInfo!.showAmount.toString();
    }
    isMinaNet = store.settings!.isMinaNet;
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
                  color: Colors.black.withValues(alpha: 0.1),
                  width: 0.5,
                ))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Row(
                      children: [
                        TokenIcon(
                          iconUrl: tokenIconUrl,
                          tokenSymbol: tokenSymbol,
                          isMainToken: isMainToken,
                        ),
                        SizedBox(
                          width: 16,
                        ),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              runSpacing: 4,
                              children: [
                                Text(
                                  tokenSymbol,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF000000)
                                        .withValues(alpha: 0.8),
                                  ),
                                ),
                                if (isMinaNet && isMainToken && isInModal != true)
                                  Container(
                                    margin: const EdgeInsets.only(left: 4),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF2F2F2),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(child: Text(
                                          AppLocalizations.of(context)!.earn,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF594AF1),
                                          ),
                                        )),
                                        const SizedBox(width: 4),
                                        SvgPicture.asset(
                                          'assets/images/assets/icon_earn.svg',
                                          width: 12,
                                          height: 12,
                                        ),
                                      ],
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
                            )
                          ],
                        )),
                      ],
                    )),
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          displayBalance,
                          style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF000000).withValues(alpha: 0.8),
                              fontWeight: FontWeight.w500),
                        ),
                        displayAmount != null
                            ? Text(
                                displayAmount,
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
