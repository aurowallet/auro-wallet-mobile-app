import 'package:auro_wallet/common/components/copyContainer.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/staking/staking.dart';
import 'package:auro_wallet/store/staking/types/validatorData.dart';
import 'package:auro_wallet/store/assets/types/accountInfo.dart';
import 'package:auro_wallet/common/components/formPanel.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:auro_wallet/common/components/loadingPanel.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/page/staking/validatorsPage.dart';
import 'package:auro_wallet/common/components/browserLink.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:collection/collection.dart';

class DelegationInfo extends StatelessWidget {
  DelegationInfo({required this.store, required this.loading});
  final AppStore store;
  final bool loading;
  @override
  Widget build(BuildContext context) {
    final Map<String, String> i18n = I18n.of(context).main;
    AccountInfo? acc = store.assets!.accountsInfo[store.wallet!.currentAccountPubKey];
    bool isDelegated = acc != null ? acc.isDelegated : false;
    String? delegate = isDelegated ? acc.delegate : null;
    var theme = Theme.of(context).textTheme;
    var languageCode = store.settings!.localeCode.isNotEmpty ? store.settings!.localeCode : I18n.of(context).locale.languageCode.toLowerCase();
    var url = languageCode == 'zh' ? store.settings!.aboutus!.stakingGuideCN : store.settings!.aboutus!.stakingGuide;

    return Container(
      margin: EdgeInsets.only(top: 30, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SvgPicture.asset( 'assets/images/stake/icon_delegation.svg', width: 16, color: Colors.black,),
                  Container(
                    width: 8,
                  ),
                  Text(i18n['delegationInfo']!, style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w600), )
                ],
              ),
              BrowserLink(url, text: i18n['emptyDelegateDesc3']!, showIcon: false,)
            ],
          ),
          Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Color(0xFFF9FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black.withOpacity(0.05), width: 0.5)
              ),
              margin: EdgeInsets.only(top: 10),
              child: loading ? LoadingBox() : (!isDelegated ? EmptyInfo(store: store) : DelegateInfo(delegate: delegate!, store: store))
          ),
        ],
      )
    );
  }
}
class DelegateInfo extends StatelessWidget {
  DelegateInfo({required this.delegate,required this.store});
  final String delegate;
  final AppStore store;

  void _onChangeNode(context) {
    Navigator.pushNamed(context, ValidatorsPage.route,);
  }
  Widget _buildDelegateInfo(BuildContext context) {
    final Map<String, String> i18n = I18n.of(context).main;
    final ValidatorData? validatorInfo = store.staking!.validatorsInfo.firstWhereOrNull((e)=>e.address == delegate);
    if (validatorInfo == null) {
      return Container(
          constraints: BoxConstraints(
              minHeight: 100
          ),
          child: Column(
            children: [
              Row(
                  children: [
                    DelegateInfoItem(
                      labelText: i18n['blockProducerAddress']!,
                      value: Fmt.address(delegate, pad: 8),
                      noBottom: false,
                    )
                  ]
              ),

            ],
          )
      );
    } else {
      return Container(
          child: Column(
            children: [
              Row(
                  children: [
                    Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: 100),
                          child: DelegateInfoItem(
                              labelText: i18n['blockProducerName']!,
                              value: validatorInfo.name  ?? Fmt.address(validatorInfo.address, pad: 8)
                          ),
                        )
                    )
                  ]
              ),
              Row(
                  children: [
                    DelegateInfoItem(
                      labelText: i18n['blockProducerAddress']!,
                      value: Fmt.address(validatorInfo.address, pad: 10),
                      copyValue: validatorInfo.address,
                    )
                  ]
              ),
              Row(
                  children: [
                    DelegateInfoItem(
                        labelText: i18n['producerTotalStake']!,
                        value: Fmt.balance(validatorInfo.totalStake.toString(), COIN.decimals) + ' ' + COIN.coinSymbol
                    )
                  ]
              ),
              Row(
                  children: [
                    DelegateInfoItem(
                        labelText: i18n['producerTotalDelegations']!,
                        value: validatorInfo.delegations.toString()
                    )
                  ]
              ),
            ],
          )
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    final Map<String, String> i18n = I18n.of(context).main;
    var theme = Theme.of(context).textTheme;

    return Stack(
      children: [
        _buildDelegateInfo(context),
        Positioned(
          right: 0,
          bottom: 0,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 10),
                backgroundColor: Color(0xFF594AF1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: Size(0, 32),
                elevation: 0,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap
            ),
            child: Text(i18n['changeNode']!, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),),
            onPressed: (){
              _onChangeNode(context);
            },
          )
        ),
      ],
    );
  }
}
class DelegateInfoItem extends StatelessWidget {
  DelegateInfoItem({required this.labelText,required this.value, this.copyValue, this.noBottom = false});
  final String labelText;
  final String value;
  final String? copyValue;
  final bool noBottom;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelText,
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.5), height: 1.42, fontWeight: FontWeight.w500),
          ),
          Padding(
            padding: EdgeInsets.only(top: 0, bottom: noBottom ? 0 : 10),
            child: CopyContainer(
              child: Text(
                value,
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 14, color: Colors.black, height: 1.16, fontWeight: FontWeight.w500),
              ),
              text: copyValue,
              showIcon: true,
            ),
          )
        ]
    );
  }
}
class EmptyInfo extends StatelessWidget {
  EmptyInfo({required this.store});
  final AppStore store;
  @override
  Widget build(BuildContext context) {
    final Map<String, String> i18n = I18n.of(context).main;
    var theme = Theme.of(context).textTheme;
    var languageCode = store.settings!.localeCode.isNotEmpty ? store.settings!.localeCode : I18n.of(context).locale.languageCode.toLowerCase();
    return Container(
      margin: EdgeInsets.only(top: 109, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                    padding: EdgeInsets.only(top: 3),
                    child:
                    Text(i18n['emptyDelegateTitle']!, style: theme.headline4?.copyWith(
                      color: Colors.black,
                      fontSize: 16
                    )))
              ]),
          Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                i18n['emptyDelegateDesc1']!,
                style: theme.headline5!.copyWith(
                    color: Colors.black.withOpacity(0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w400
                ),
              )
          ),
          Padding(
              padding: EdgeInsets.only(top: 14, bottom: 20),
              child: Wrap(
                children: [
                  new RichText(
                    textScaleFactor: MediaQuery.of(context).textScaleFactor,
                    text: TextSpan(
                        children: [
                          new TextSpan(
                            text: i18n['emptyDelegateDesc2']!,
                            style: theme.headline5!.copyWith(
                                color: Colors.black.withOpacity(0.5),
                                fontSize: 12,
                                fontWeight: FontWeight.w400
                            ),
                          ),
                          new TextSpan(
                            text: i18n['emptyDelegateDesc3']!,
                            style: theme.headline5!.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w400
                            ),
                            recognizer: new TapGestureRecognizer()
                              ..onTap = () {
                                var url = languageCode == 'zh' ? store.settings!.aboutus!.stakingGuideCN : store.settings!.aboutus!.stakingGuide;
                                print('url' + url);
                                launch(url);
                              },
                          ),
                        ]
                    ),
                  ),
                ],
              )
          )
        ],
      ),
    );
  }
}