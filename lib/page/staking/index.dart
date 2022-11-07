import 'package:auro_wallet/common/components/loadingCircle.dart';
import 'package:auro_wallet/common/components/normalButton.dart';
import 'package:auro_wallet/common/components/tabPageTitle.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/page/staking/components/delegationInfo.dart';
import 'package:auro_wallet/page/staking/components/stakingOverview.dart';
import 'package:auro_wallet/page/staking/validatorsPage.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auro_wallet/store/assets/types/accountInfo.dart';

class Staking extends StatefulWidget {
  Staking(this.store);

  final AppStore store;

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
    AccountInfo? acc = store.assets!.accountsInfo[store.wallet!.currentAccountPubKey];
    return acc != null && store.staking!.validatorsInfo.length > 0;
  }
  Future<void> _fetchData() async {
    await Future.wait([
      webApi.staking.fetchValidators(),
      webApi.assets.fetchAccountInfo(),
      webApi.staking.fetchStakingOverview(),
    ]);
    if (mounted) {
      setState((){
        loading = false;
      });
    }
  }

  void _onPress () {
    Navigator.pushNamed(context, ValidatorsPage.route,);
  }
  @override
  Widget build(BuildContext context) {
    final Map<String, String> i18n = I18n.of(context).main;
    Color primaryColor = Theme.of(context).primaryColor;
    AccountInfo? acc = store.assets!.accountsInfo[store.wallet!.currentAccountPubKey];
    bool isDelegated = acc != null ? acc.isDelegated : false;
    var theme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: null,
        title: null,
        toolbarHeight: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
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
                TabPageTitle(title: i18n['staking']!),
                Expanded(child:  ListView(
                  children: [
                    StakingOverview(store: store,),
                    !loading ? Wrap(
                      children: [
                        !isDelegated ? EmptyInfo(store: store) : DelegationInfo(store: store, loading: loading),
                        !isDelegated ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            NormalButton(
                              text: i18n['goStake']!,
                              disabled: false,
                              onPressed: _onPress,
                              shrink: true,
                              height: 32,
                            ),
                          ],
                        ) : Container()
                      ],
                    ): Container(
                      padding: EdgeInsets.only(top: 167),
                      child: LoadingCircle(),
                    )
                  ],
                )
                )

              ],
            )
        ),
      ),
    );
  }
}
