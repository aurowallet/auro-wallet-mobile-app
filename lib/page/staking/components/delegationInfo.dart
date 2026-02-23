import 'package:auro_wallet/common/components/loadingCircle.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/staking/validatorsPage.dart';
import 'package:auro_wallet/page/staking/delegatePage.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/assets/types/token.dart';
import 'package:auro_wallet/store/staking/types/validatorData.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:auro_wallet/page/staking/components/validatorItem.dart';

class DelegationInfo extends StatelessWidget {
  DelegationInfo({required this.store, required this.loading});

  final AppStore store;
  final bool loading;

  bool get _isMinaNet => store.settings!.isMinaNet;

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    Token mainTokenNetInfo = store.assets!.mainTokenNetInfo;
    bool isDelegated = mainTokenNetInfo.tokenBaseInfo?.isDelegation ?? false;
    String? delegate = isDelegated
        ? mainTokenNetInfo.tokenAssestInfo?.delegateAccount?.publicKey
        : null;
    var languageCode = store.settings!.localeCode.isNotEmpty
        ? store.settings!.localeCode
        : dic.localeName.toLowerCase();
    var url = languageCode == 'zh'
        ? store.settings!.aboutus!.stakingGuideCN
        : store.settings!.aboutus!.stakingGuide;

    // Unknown network (not Mina network) - show only unknown network view
    
    if (!_isMinaNet) {
      return UnknownNetworkView(guideUrl: url);
    }

    return Container(
        margin: EdgeInsets.only(top: 20, left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EarnOnMinaHeader(
              onInfoTap: () {
                launchUrl(Uri.parse(url),
                    mode: LaunchMode.inAppBrowserView);
              },
            ),
            Container(
                margin: EdgeInsets.only(top: 10),
                child: loading
                    ? StakingLoadingView()
                    : EarnOnMinaCard(store: store)),
            if (!loading && isDelegated)
              ActiveDelegationSection(delegate: delegate!, store: store),
            if (!loading)
              StakeActionButton(store: store, isDelegated: isDelegated),
          ],
        ));
  }
}

 
class EarnOnMinaHeader extends StatelessWidget {
  EarnOnMinaHeader({super.key, this.onInfoTap});

  final VoidCallback? onInfoTap;

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SvgPicture.asset('assets/images/stake/icon_delegation.svg',
                width: 16,
                colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn)),
            Container(width: 8),
            Text(
              dic.earnOnMina,
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w600),
            )
          ],
        ),
        if (onInfoTap != null)
          InkWell(
              child: SvgPicture.asset(
                'assets/images/public/icon_info_staking.svg',
                width: 30,
                height: 30,
              ),
              onTap: onInfoTap)
      ],
    );
  }
}

class StakingLoadingView extends StatelessWidget {
  StakingLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Container(
        margin: EdgeInsets.only(top: 80),
        constraints: BoxConstraints(minHeight: 150),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                child: Center(
                  child: LoadingCircle(),
                ),
              )
          ],
        ),
      ),
    );
  }
}

class UnknownNetworkView extends StatelessWidget {
  UnknownNetworkView({super.key, required this.guideUrl});

  final String guideUrl;

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    return Container(
      margin: EdgeInsets.only(top: 20, left: 20, right: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EarnOnMinaHeader(
            onInfoTap: () {
              launchUrl(Uri.parse(guideUrl),
                  mode: LaunchMode.inAppBrowserView);
            },
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: 50),
            padding: EdgeInsets.symmetric(vertical: 60, horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: Colors.black.withValues(alpha: 0.05),
                  width: 0.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/images/setting/empty_contact.svg',
                  width: 100,
                  height: 100,
                ),
                SizedBox(height: 16),
                Text(
                  dic.unknownNetworkStaking,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black.withValues(alpha: 0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EarnOnMinaCard extends StatelessWidget {
  EarnOnMinaCard({super.key, required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;

    return Observer(builder: (_) {
      Token mainTokenNetInfo = store.assets!.mainTokenNetInfo;
      double showBalance = mainTokenNetInfo.tokenBaseInfo?.showBalance ?? 0.0;
      double? stakingAPY = store.staking!.stakingAPY;
      return Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Color(0xFFF9FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: Colors.black.withValues(alpha: 0.05),
                width: 0.5)),
        child: Column(
          children: [
            _buildInfoRow(
              dic.available,
              '${showBalance.toStringAsFixed(4)} ${COIN.coinSymbol}',
            ),
            SizedBox(height: 12),
            _buildInfoRow(
              dic.apr,
              stakingAPY != null ? '${stakingAPY.toStringAsFixed(2)}%' : '--',
            ),
            SizedBox(height: 12),
            _buildInfoRow(
              dic.lockTime,
              dic.notLocked,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black.withValues(alpha: 0.5),
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
 
class ActiveDelegationSection extends StatelessWidget {
  ActiveDelegationSection({super.key, required this.delegate, required this.store});

  final String delegate;
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;

    return Observer(builder: (_) {
      final ValidatorData? validatorItem = store.staking!.allValidators
          .firstWhereOrNull((e) => e.address == delegate);
      Token mainTokenNetInfo = store.assets!.mainTokenNetInfo;
      double showBalance = mainTokenNetInfo.tokenBaseInfo?.showBalance ?? 0.0;
      return Container(
        margin: EdgeInsets.only(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dic.active,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFF9FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.05),
                  width: 0.5,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildValidatorLogo(validatorItem, delegate),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          validatorItem?.name ?? Fmt.address(delegate, pad: 8),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dic.staked,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black.withValues(alpha: 0.5),
                        ),
                      ),
                      Text(
                        '${showBalance.toStringAsFixed(4)} ${COIN.coinSymbol}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildValidatorLogo(ValidatorData? validator, String delegateAddress) {
    return ItemLogo(
      name: validator?.name,
      logo: validator?.logo ?? '',
      radius: 20,
      address: validator?.address ?? delegateAddress,
    );
  }
}

class StakeActionButton extends StatelessWidget {
  StakeActionButton({super.key, required this.store, required this.isDelegated});

  final AppStore store;
  final bool isDelegated;

  bool get _isMainnet => store.settings!.isMainnet;

  void _onTap(BuildContext context) {
    if (isDelegated) {
      ValidatorData? targetValidator;
      if (_isMainnet && store.staking!.validatorsInfo.isNotEmpty) {
        targetValidator = store.staking!.validatorsInfo.first;
      }
      Navigator.pushNamed(
        context,
        DelegatePage.route,
        arguments: DelegateParams(
          manualAddValidator: false,
          validatorData: targetValidator,
          isRedelegate: true,
        ),
      );
    } else {
      if (_isMainnet) {
        ValidatorData? firstValidator;
        if (store.staking!.validatorsInfo.isNotEmpty) {
          firstValidator = store.staking!.validatorsInfo.first;
        }
        Navigator.pushNamed(
          context,
          DelegatePage.route,
          arguments: DelegateParams(
            manualAddValidator: false,
            validatorData: firstValidator,
            isRedelegate: false,
          ),
        );
      } else {
        // Non-mainnet: Go to validators list first
        Navigator.pushNamed(
          context,
          ValidatorsPage.route,
          arguments: {'isRedelegate': false},
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    // Use border-bottom style like Chrome extension's actionLinkBordered
    return Container(
      margin: EdgeInsets.only(top: 16, left: 10, right: 10),
      padding: EdgeInsets.symmetric(vertical: 4,horizontal: 6),
      decoration: BoxDecoration(
        border: isDelegated
            ? null
            : Border(
                bottom: BorderSide(
                  color: Colors.black.withValues(alpha: 0.05),
                  width: 0.5,
                ),
              ),
      ),
      child: InkWell(
        onTap: () => _onTap(context),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isDelegated ? dic.redelegate : dic.stake,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.black.withValues(alpha: 0.3),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
