import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/assets/token/component/TokenIcon.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/assets/types/token.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class TokenManagaItem extends StatelessWidget {
  TokenManagaItem({
    required this.tokenItem,
    required this.store,
  });
  final Token tokenItem;
  final AppStore store;

  onPressed() async {
    await store.assets!.updateTokenShowStatus(store.wallet!.currentAddress,
        tokenId: tokenItem.tokenAssestInfo?.tokenId ?? "");
  }

  @override
  Widget build(BuildContext context) {
    String tokenIconUrl = "";
    String tokenSymbol = "";
    String tokenName = "";
    String displayBalance = "";
    bool tokenShowed = true;
    bool hideToken = false;

    AppLocalizations dic = AppLocalizations.of(context)!;

    TokenAssetInfo? tokenAssestInfo = tokenItem.tokenAssestInfo;

    TokenNetInfo? tokenNetInfo = tokenItem.tokenNetInfo;
    TokenLocalConfig? localConfig = tokenItem.localConfig;
    TokenBaseInfo? tokenBaseInfo = tokenItem.tokenBaseInfo;

    bool isMainToken = tokenBaseInfo?.isMainToken ?? false;
    if (isMainToken) {
      tokenSymbol = COIN.coinSymbol;
      tokenName = COIN.name;
    } else {
      tokenSymbol = tokenNetInfo?.tokenSymbol ?? "UNKNOWN";
      tokenName = Fmt.address(tokenAssestInfo?.tokenId, pad: 6);
    }
    tokenIconUrl = tokenBaseInfo?.iconUrl ?? "";
    displayBalance = tokenBaseInfo?.showBalance != null
        ? Fmt.parseShowBalance(tokenBaseInfo!.showBalance!)
        : "0.0";

    tokenShowed = localConfig?.tokenShowed ?? false;
    hideToken = localConfig?.hideToken ?? false;

    return new Material(
      color: Colors.white,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
              color:
                  tokenShowed ? Colors.white : Colors.black.withOpacity(0.05),
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
                      isMainToken: isMainToken,
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
                InkWell(
                  onTap: onPressed,
                  child: SvgPicture.asset(
                    hideToken
                        ? "assets/images/assets/icon_token_show.svg"
                        : "assets/images/assets/icon_token_hide.svg",
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            )),
        // )
      ),
    );
  }
}
