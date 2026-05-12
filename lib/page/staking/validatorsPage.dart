import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/staking/components/validatorItem.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/assets/types/token.dart';
import 'package:auro_wallet/store/staking/types/validatorData.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';

import '../../common/components/browserLink.dart';
import '../../service/api/api.dart';

class ValidatorsPage extends StatefulWidget {
  ValidatorsPage(this.store);

  static final String route = '/staking/validators';

  final AppStore store;

  @override
  _ValidatorsPageState createState() => _ValidatorsPageState(store);
}

class _ValidatorsPageState extends State<ValidatorsPage>
    with SingleTickerProviderStateMixin {
  _ValidatorsPageState(this.store);

  final AppStore store;
  List<ValidatorData> activeList = [];
  List<ValidatorData> inactiveList = [];
  late ReactionDisposer monitorActiveDisposer;
  late ReactionDisposer monitorInactiveDisposer;

  @override
  void initState() {
    super.initState();
    activeList = store.staking!.validatorsInfo;
    inactiveList = store.staking!.inactiveValidatorsInfo;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      monitorActiveDisposer =
          reaction((_) => store.staking!.validatorsInfo, _onActiveListChange);
      monitorInactiveDisposer =
          reaction((_) => store.staking!.inactiveValidatorsInfo, _onInactiveListChange);
    });
  }

  @override
  void dispose() {
    monitorActiveDisposer();
    monitorInactiveDisposer();
    super.dispose();
  }

  void _onActiveListChange(List<ValidatorData> vs) {
    setState(() {
      activeList = vs;
    });
  }

  void _onInactiveListChange(List<ValidatorData> vs) {
    setState(() {
      inactiveList = vs;
    });
  }

  Future<void> onRefresh() async {
    await webApi.staking.fetchValidators();
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(top: 8, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    Token mainTokenNetInfo = store.assets!.mainTokenNetInfo;
    bool isDelegated = mainTokenNetInfo.tokenBaseInfo?.isDelegation ?? false;
    String? delegate = isDelegated
        ? mainTokenNetInfo.tokenAssestInfo?.delegateAccount?.publicKey
        : null;
    
    dynamic args = ModalRoute.of(context)?.settings.arguments;
    String? selectedValidatorAddress;
    if (args is Map) {
      selectedValidatorAddress = args['selectedValidatorAddress'] as String?;
    }
    
    String? displaySelectedAddress = selectedValidatorAddress ?? delegate;
    
    return RefreshIndicator(
        onRefresh: onRefresh,
        backgroundColor: Colors.white,
        color: Theme.of(context).primaryColor,
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text(
                dic.nodeProviders,
              ),
              centerTitle: true,
              elevation: 0.0,
              surfaceTintColor: Colors.white,
            ),
            resizeToAvoidBottomInset: false,
            body: SafeArea(
                maintainBottomViewPadding: true,
                child: ListView(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, bottom: 20, top: 0),
                      children: [
                        if (activeList.isNotEmpty) ...[
                          _buildSectionHeader(dic.active),
                          ...activeList.map((validator) => ValidatorItem(
                              data: validator,
                              showSelected: displaySelectedAddress == validator.address)),
                        ],
                        if (inactiveList.isNotEmpty) ...[
                          _buildSectionHeader(dic.inactive),
                          ...inactiveList.map((validator) => ValidatorItem(
                              data: validator,
                              showSelected: displaySelectedAddress == validator.address)),
                        ],
                        ManualAddValidatorButton(),
                        SubmitNodeButton(),
                      ],
                    ))));
  }
}

class ManualAddValidatorButton extends StatelessWidget {
  ManualAddValidatorButton();

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    return Padding(
        padding: EdgeInsets.only(top: 20),
        child: GestureDetector(
            onTap: () {
              Navigator.pop(context, 'manual_add');
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(dic.manualAdd,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).primaryColor,
                    )),
              ],
            ))));
  }
}

class SubmitNodeButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    return Padding(
        padding: EdgeInsets.only(top: 10, bottom: 0),
        child: Container(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BrowserLink(
                'https://github.com/aurowallet/launch/tree/master/validators',
                showIcon: false,
                text: dic.submitNode,
                textStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0x4D000000),
                )),
          ],
        )));
  }
}
