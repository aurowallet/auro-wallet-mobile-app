import 'package:flutter/material.dart';
import 'package:auro_wallet/page/staking/components/delegationInfo.dart';
import 'package:auro_wallet/page/staking/components/stakingOverview.dart';
import 'package:auro_wallet/common/components/loadingPanel.dart';
import 'package:auro_wallet/page/staking/validatorsPage.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/UI.dart';
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
    WidgetsBinding.instance!.addPostFrameCallback((_) {
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
        title: Text(i18n['staking']!, style: TextStyle(color: Colors.white, fontSize: 20),),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: primaryColor,
      ),
      body: SafeArea(
        child: RefreshIndicator(
        key: globalStakingRefreshKey,
        onRefresh: _fetchData,
            child:ListView(
              children: [
                StakingOverview(store: store,),
                DelegationInfo(store: store, loading: loading),
                !loading && !isDelegated ? Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: GestureDetector(
                        onTap: _onPress,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(i18n['goStake']!, style: theme.headline5!.copyWith(
                                  color: ColorsUtil.hexColor(0x7055FF),
                                )),
                                Container(width: 8),
                                SvgPicture.asset(
                                    'assets/images/public/next.svg',
                                    width: 16,
                                    color: ColorsUtil.hexColor(0x7055FF)
                                ),
                              ],
                            )
                        )
                    )
                ) : Container()
              ],
            )
        ),
      ),
    );
  }
}
