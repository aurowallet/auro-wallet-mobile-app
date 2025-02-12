import 'package:auro_wallet/common/components/loadingCircle.dart';
import 'package:auro_wallet/common/components/normalButton.dart';
import 'package:auro_wallet/common/components/tabPageTitle.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/staking/components/delegationInfo.dart';
import 'package:auro_wallet/page/staking/components/stakingOverview.dart';
import 'package:auro_wallet/page/staking/validatorsPage.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/assets/types/token.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:flutter/material.dart';

class Staking extends StatefulWidget {
  Staking(this.store);

  final AppStore store;
  static final String route = '/assets/staking';
  @override
  _StakingState createState() => _StakingState(store);
}

class _StakingState extends State<Staking> {
  _StakingState(this.store);

  final AppStore store;
  bool loading = true;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
    loading = !_haveCacheData();
    super.initState();
  }

  bool _haveCacheData() {
    Token mainTokenNetInfo = store.assets!.mainTokenNetInfo;
    print(store.wallet!.currentAccountPubKey);
    return mainTokenNetInfo.tokenBaseInfo != null;
  }

  Future<void> _fetchData() async {
    await Future.wait([
      webApi.staking.fetchValidators(),
      webApi.assets.fetchAllTokenAssets(),
      webApi.staking.fetchStakingOverview(),
    ]);
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  void _onPress() {
    Navigator.pushNamed(
      context,
      ValidatorsPage.route,
    );
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    Token mainTokenNetInfo = store.assets!.mainTokenNetInfo;
    bool isDelegated = mainTokenNetInfo.tokenBaseInfo?.isDelegation ?? false;
    bool isFromRoute = false;
    dynamic args = ModalRoute.of(context)!.settings.arguments;
    if (args != null && args['isFromRoute'] == true) {
      isFromRoute = true;
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: null,
        title: isFromRoute ? Text(dic.staking) : null,
        toolbarHeight: isFromRoute ? null : 0,
        centerTitle: true, 
      ),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: RefreshIndicator(
            key: globalStakingRefreshKey,
            onRefresh: _fetchData,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isFromRoute
                    ? SizedBox(
                        height: 0,
                      )
                    : TabPageTitle(title: dic.staking),
                Expanded(
                    child: ListView(
                  children: [
                    StakingOverview(
                      store: store,
                    ),
                    !loading
                        ? Wrap(
                            children: [
                              !isDelegated
                                  ? EmptyInfo(store: store)
                                  : DelegationInfo(
                                      store: store, loading: loading),
                              !isDelegated
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        NormalButton(
                                          text: dic.goStake,
                                          textStyle: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600),
                                          disabled: false,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16),
                                          onPressed: _onPress,
                                          shrink: true,
                                          height: 32,
                                        ),
                                      ],
                                    )
                                  : Container()
                            ],
                          )
                        : Container(
                            padding: EdgeInsets.only(top: 167),
                            child: LoadingCircle(),
                          )
                  ],
                ))
              ],
            )),
      ),
    );
  }
}
