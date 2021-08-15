import 'package:flutter/cupertino.dart';
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
import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:auro_wallet/common/components/loadingPanel.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/page/staking/validatorsPage.dart';
import 'package:auro_wallet/common/components/browserLink.dart';
import 'package:url_launcher/url_launcher.dart';

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
    return Container(
      margin: EdgeInsets.only(top: 10, left: 28, right: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            i18n['delegationInfo']!,
            textAlign: TextAlign.left,
            style: theme.headline4!.copyWith(color: ColorsUtil.hexColor(0x020028), fontWeight: FontWeight.w600),
          ),
          FormPanel(
            margin: EdgeInsets.only(top: 14),
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
    ValidatorData? validatorInfo = (store.staking!.validatorsInfo as List<ValidatorData?>).firstWhere((e)=>e!.address == delegate, orElse: ()=> null);
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
                        value: Fmt.address(validatorInfo.address, pad: 10)
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
              Row(
                  children: [
                    DelegateInfoItem(
                        labelText: i18n['blocksProduced']!,
                        value: validatorInfo.blocksCreated.toString()
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
    var languageCode = store.settings!.localeCode.isNotEmpty ? store.settings!.localeCode : I18n.of(context).locale.languageCode.toLowerCase();
    var url = languageCode == 'zh' ? store.settings!.aboutus!.stakingGuideCN : store.settings!.aboutus!.stakingGuide;

    return Stack(
      children: [
        _buildDelegateInfo(context),
        Positioned(
          right: 0,
          top: 0,
          child: FlatButton(
            height: 30,
            minWidth: 70,
            color: Theme.of(context).primaryColor,
            shape: new RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Text(i18n['changeNode']!, style: theme.headline5!.copyWith(color: Colors.white)),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onPressed: (){
              _onChangeNode(context);
            },
          )
        ),
        Positioned(
          right: 0,
            bottom: 0,
            child: BrowserLink(url, text: i18n['emptyDelegateDesc3']!,)
        )
      ],
    );
  }
}
class DelegateInfoItem extends StatelessWidget {
  DelegateInfoItem({required this.labelText,required this.value});
  final String labelText;
  final String value;
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelText,
            textAlign: TextAlign.left,
            style: theme.headline6!.copyWith(color: ColorsUtil.hexColor(0x96969a), height: 1.5, fontWeight: FontWeight.w400),
          ),
          Padding(
            padding: EdgeInsets.only(top: 2, bottom: 8),
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: theme.headline5!.copyWith(color: ColorsUtil.hexColor(0x000000), height: 1.2, fontWeight: FontWeight.w500),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
            crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.exclamationmark_circle_fill,
              size: 20,
              color: ColorsUtil.hexColor(0xFFC633)
            ),
            Expanded(child: Padding(
                padding: EdgeInsets.only(top: 3, left: 5),
                child: Text(
                    i18n['emptyDelegateTitle']!,
                    style: theme.headline4
                )
            ),)
          ]
        ),
        Padding(
          padding: EdgeInsets.only(top: 14),
          child: Text(
            i18n['emptyDelegateDesc1']!,
            style: theme.headline5!.copyWith(
                color: ColorsUtil.hexColor(0x666666)
            ),
          )
        ),
        Padding(
            padding: EdgeInsets.only(top: 14, bottom: 20),
            child: Wrap(
    children: [
      new RichText(
        text: TextSpan(
          children: [
            new TextSpan(
              text: i18n['emptyDelegateDesc2']!,
              style: theme.headline5!.copyWith(
                  color: ColorsUtil.hexColor(0x666666)
              ),
            ),
            new TextSpan(
              text: i18n['emptyDelegateDesc3']!,
              style: theme.headline5!.copyWith(color: Theme.of(context).primaryColor),
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
    );
  }
}