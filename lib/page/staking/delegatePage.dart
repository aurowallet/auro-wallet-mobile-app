import 'dart:math';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/staking/validatorsPage.dart';
import 'package:auro_wallet/page/staking/components/validatorItem.dart';
import 'package:auro_wallet/store/assets/types/token.dart';
import 'package:collection/collection.dart';
import 'package:auro_wallet/page/assets/token/TokenDetail.dart';
import 'package:auro_wallet/store/assets/types/tokenPendingTx.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:auro_wallet/common/components/txConfirmDialog.dart';
import 'package:auro_wallet/common/components/networkFeeDisplay.dart';
import 'package:auro_wallet/common/components/inputItem.dart';
import 'package:auro_wallet/common/components/normalButton.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/staking/types/validatorData.dart';
import 'package:auro_wallet/store/assets/types/transferData.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:auro_wallet/store/wallet/wallet.dart';
import 'package:mobx/mobx.dart';
import 'package:auro_wallet/store/assets/types/fees.dart';

class DelegateParams {
  DelegateParams({
    this.manualAddValidator = false,
    this.validatorData,
    this.isRedelegate = false,
  });

  bool manualAddValidator;
  ValidatorData? validatorData;
  bool isRedelegate;
}

class DelegatePage extends StatefulWidget {
  static final String route = '/staking/delegate';

  DelegatePage(this.store);

  final AppStore store;

  @override
  _DelegatePageState createState() => _DelegatePageState(store);
}

class _DelegatePageState extends State<DelegatePage>
    with SingleTickerProviderStateMixin {
  _DelegatePageState(this.store);

  final AppStore store;

  final TextEditingController _nonceCtrl = new TextEditingController();
  final TextEditingController _feeCtrl = new TextEditingController();
  final TextEditingController _memoCtrl = new TextEditingController();
  final TextEditingController _validatorCtrl = new TextEditingController();
  ReactionDisposer? _monitorFeeDisposer;
  bool _submitDisabled = true;
  bool submitting = false;
  var _loading = Observable(true);
  bool inputDirty = false;
  double? currentFee;
  double? defaultFee;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      DelegateParams params =
          ModalRoute.of(context)!.settings.arguments as DelegateParams;
      _onFeeLoaded(store.assets!.transferFees);
      _monitorFeeDisposer =
          reaction((_) => store.assets!.transferFees, _onFeeLoaded);
      _feeCtrl.addListener(_onFeeInputChange);
      if (params.manualAddValidator) {
        _validatorCtrl.addListener(_monitorSummitStatus);
      }
      _updateSubmitState();
      _loadData();
    });
  }

  @override
  void dispose() {
    _memoCtrl.dispose();
    _nonceCtrl.dispose();
    _feeCtrl.dispose();
    _validatorCtrl.dispose();
    _monitorFeeDisposer?.call();
    super.dispose();
  }

  void _onFeeInputChange() {
    setState(() {
      if (_feeCtrl.text.isNotEmpty) {
        inputDirty = true;
        try {
          currentFee = double.parse(Fmt.parseNumber(_feeCtrl.text));
        } catch (e) {
          currentFee = defaultFee ?? store.assets!.transferFees.medium;
        }
      } else {
        // When fee is cleared, restore to default fee
        inputDirty = false;
        currentFee = defaultFee ?? store.assets!.transferFees.medium;
      }
    });
  }

  void _monitorSummitStatus() {
    if (_validatorCtrl.text.isEmpty) {
      if (!_submitDisabled) {
        setState(() {
          _submitDisabled = true;
        });
      }
    } else if (_submitDisabled) {
      setState(() {
        _submitDisabled = false;
      });
    }
  }

  void _updateSubmitState() {
    DelegateParams params =
        ModalRoute.of(context)!.settings.arguments as DelegateParams;
    
    bool shouldDisable = false;
    if (params.manualAddValidator) {
      shouldDisable = _validatorCtrl.text.isEmpty;
    } else {
      bool hasValidator = params.validatorData != null;
      if (!hasValidator && store.settings!.isMainnet) {
        hasValidator = store.staking!.validatorsInfo.isNotEmpty;
      }
      shouldDisable = !hasValidator;
    }
    
    if (_submitDisabled != shouldDisable) {
      setState(() {
        _submitDisabled = shouldDisable;
      });
    }
  }

  void _onFeeLoaded(Fees fees) {
    print('_onFeeLoaded');
    if (fees.medium > 0) {
      defaultFee = fees.medium;
    }
    if (!inputDirty) {
      setState(() {
        currentFee = fees.medium;
      });
    }
  }

  double _getEffectiveFee() {
    if (_feeCtrl.text.isNotEmpty) {
      try {
        return double.parse(Fmt.parseNumber(_feeCtrl.text));
      } catch (e) {
      }
    }
    if (currentFee != null) {
      return currentFee!;
    }
    return store.assets!.transferFees.medium;
  }

  Future<void> _loadData() async {
    await Future.wait([
      webApi.assets.fetchAllTokenAssets(),
      webApi.assets.queryTxFees(),
      webApi.assets.fetchPendingTokenList(
          widget.store.wallet!.currentAddress,
          widget.store.assets!.mainTokenNetInfo.tokenAssestInfo
                  ?.inferredNonce ??
              "0")
    ]);
    runInAction(() {
      _loading.value = false;
    });
  }

  void _onAdvanceConfirm(String fee, String nonce) {
    if (fee.isNotEmpty) {
      _feeCtrl.text = fee;
    } else {
      _feeCtrl.clear();
    }
    if (nonce.isNotEmpty) {
      _nonceCtrl.text = nonce;
    } else {
      _nonceCtrl.clear();
    }
  }

  String _floorToDecimals(double value, int decimals) {
    double multiplier = pow(10, decimals).toDouble();
    return ((value * multiplier).floor() / multiplier).toStringAsFixed(decimals);
  }

  int? _parseNonce(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  String? _validateBalance() {
    AppLocalizations dic = AppLocalizations.of(context)!;
    double? showBalance =
        store.assets!.mainTokenNetInfo.tokenBaseInfo?.showBalance;
    double availableBalanceStr =
        (showBalance != null ? showBalance : 0) as double;
    BigInt available =
        BigInt.from(pow(10, COIN.decimals) * availableBalanceStr);
    final int decimals = COIN.decimals;
    double fee = _getEffectiveFee();
    if (available / BigInt.from(pow(10, decimals)) - fee <= 0) {
      return dic.balanceNotEnough;
    }
    return null;
  }

  Future<String?> _validateValidator() async {
    AppLocalizations dic = AppLocalizations.of(context)!;
    DelegateParams params =
        ModalRoute.of(context)!.settings.arguments as DelegateParams;
    if (params.manualAddValidator) {
      if (_validatorCtrl.text.isEmpty) {
        return dic.inputNodeAddress;
      }
      bool isValid =
          await webApi.account.isAddressValid(_validatorCtrl.text.trim());
      if (!isValid) {
        return dic.sendAddressError;
      }
      return null;
    }
    return null;
  }

  Future<bool> _validate() async {
    String? amountError = _validateBalance();
    if (amountError != null) {
      UI.toast(amountError);
      return false;
    }
    String? addressError = await _validateValidator();
    if (addressError != null) {
      UI.toast(addressError);
      return false;
    }
    return true;
  }

  void _unFocus() {
    FocusScope.of(context).requestFocus(new FocusNode());
  }

  void _handleSubmit() async {
    List<TokenPendingTx>? tempTxList = widget
        .store.assets!.tokenPendingTxList[widget.store.wallet!.currentAddress];

    if (tempTxList != null && tempTxList.length > 0) {
      bool? isAgree =
          await UI.showTokenTxDialog(context: context, txList: tempTxList);
      if (isAgree == null || !isAgree) {
        return;
      }
    }
    _unFocus();
    if (_nonceCtrl.text.isEmpty && currentFee == null) {
      if (_loading.value) {
        // waiting nonce data from server
        setState(() {
          submitting = true;
        });
        await asyncWhen((r) => _loading.value == false);
        setState(() {
          submitting = false;
        });
      }
    }
    if (await _validate()) {
      AppLocalizations dic = AppLocalizations.of(context)!;
      String memo = _memoCtrl.text.trim();
      double fee;
      bool shouldShowNonce = false;
      int inferredNonce;
      if (_nonceCtrl.text.isNotEmpty) {
        shouldShowNonce = true;
        inferredNonce = int.parse(_nonceCtrl.text);
      } else {
        inferredNonce = int.parse(
            store.assets!.mainTokenNetInfo.tokenAssestInfo?.inferredNonce ??
                "0");
      }
      fee = _getEffectiveFee();
      DelegateParams params =
          ModalRoute.of(context)!.settings.arguments as DelegateParams;
      ValidatorData? validatorData = params.validatorData;
      ValidatorData? effectiveValidator = validatorData;
      if (!params.manualAddValidator && effectiveValidator == null) {
        if (store.staking!.validatorsInfo.isNotEmpty) {
          effectiveValidator = store.staking!.validatorsInfo.first;
        }
      }
      if (!params.manualAddValidator && effectiveValidator == null) {
        UI.toast(dic.inputNodeAddress);
        return;
      }
      String validatorAddress = params.manualAddValidator
          ? _validatorCtrl.text.trim()
          : effectiveValidator!.address;
      List<TxItem> txItems = [];
      // if (!params.manualAddValidator) {
      //   txItems.add(TxItem(label: dic.producerName, value: validatorData!.name ?? Fmt.address(validatorAddress, pad: 8)));
      // }
      txItems.addAll([
        TxItem(
          label: dic.providerAddress,
          value: validatorAddress,
        ),
        TxItem(
          label: dic.fromAddress,
          value: store.wallet!.currentAddress,
        ),
        TxItem(
          label: dic.fee,
          value: '${fee.toString()} ${COIN.coinSymbol}',
        ),
      ]);
      if (shouldShowNonce) {
        txItems.add(TxItem(label: "Nonce ", value: '$inferredNonce'));
      }
      if (memo.isNotEmpty) {
        txItems.add(TxItem(label: dic.memo2, value: memo));
      }
      bool isWatchMode =
          store.wallet!.currentWallet.walletType == WalletStore.seedTypeNone;
      String validateName;
      bool isLedger =
          store.wallet!.currentWallet.walletType == WalletStore.seedTypeLedger;
      if (params.manualAddValidator) {
        validateName = Fmt.address(validatorAddress, pad: 10);
      } else {
        validateName =
            effectiveValidator!.name ?? Fmt.address(validatorAddress, pad: 10);
      }
      bool exited = false;
      await UI.showTxConfirm(
          context: context,
          title: dic.sendDetail,
          items: txItems,
          isLedger: isLedger,
          headLabel: dic.nodeProviders,
          headValue: Text(
            validateName,
            style: TextStyle(
                fontSize: 20, color: Colors.black, fontWeight: FontWeight.w600),
          ),
          disabled: isWatchMode,
          buttonText: isWatchMode ? dic.watchMode : dic.confirm,
          onConfirm: () async {
            String? privateKey;
            if (!isLedger) {
              String? password = await UI.showPasswordDialog(
                  context: context,
                  wallet: store.wallet!.currentWallet,
                  inputPasswordRequired: false,
                  isTransaction: true,
                  store: store);
              if (password == null) {
                return false;
              }
              privateKey = await webApi.account.getPrivateKey(
                  store.wallet!.currentWallet,
                  store.wallet!.currentWallet.currentAccountIndex,
                  password);
              if (privateKey == null) {
                UI.toast(dic.passwordError);
                return false;
              }
            }
            Map txInfo = {
              "privateKey": privateKey,
              "accountIndex": store.wallet!.currentWallet.currentAccountIndex,
              "fromAddress": store.wallet!.currentAddress,
              "toAddress": validatorAddress,
              "fee": fee,
              "nonce": inferredNonce,
              "memo": memo,
            };
            TransferData? data;
            if (isLedger) {
              // data = await webApi.account
              //     .ledgerSign(txInfo, context: context, isDelegation: true);
              print('stake: start sign ledger');
              final tx = await webApi.account
                  .ledgerSign(txInfo, context: context, isDelegation: true);
              if (tx == null) {
                return false;
              }
              if (!exited) {
                data = await webApi.account
                    .sendTxBody(tx, context: context, isDelegation: true);
              }
            } else {
              data = await webApi.account
                  .signAndSendDelegationTx(txInfo, context: context);
            }
            if (data == null) {
              return false;
            }
            if (mounted) {
              widget.store.triggerBalanceRefresh();
              globalTokenRefreshKey.currentState?.show();
              await widget.store.assets!.setNextToken(widget.store.assets!.mainTokenNetInfo);
              Navigator.pushNamedAndRemoveUntil(
                context,
                TokenDetailPage.route,
                ModalRoute.withName('/'),
              );
              return true;
            }
            return false;
          });
      exited = true;
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        AppLocalizations dic = AppLocalizations.of(context)!;
        final fees = store.assets!.transferFees;
        DelegateParams params =
            ModalRoute.of(context)!.settings.arguments as DelegateParams;
        ValidatorData? validatorData = params.validatorData;
        bool isRedelegate = params.isRedelegate;

        Token mainTokenNetInfo = store.assets!.mainTokenNetInfo;
        String? currentValidatorAddress = mainTokenNetInfo
            .tokenAssestInfo?.delegateAccount?.publicKey;

        double realBottom = MediaQuery.of(context).viewInsets.bottom;
        double nextBottom = realBottom > 0 ? realBottom - 102 : realBottom;
        nextBottom = nextBottom.isNegative ? 0 : nextBottom;
        return Scaffold(
          appBar: AppBar(
            title: Text(isRedelegate ? dic.redelegate : dic.stake),
            shadowColor: Colors.transparent,
            centerTitle: true,
          ),
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.white,
          body: SafeArea(
            maintainBottomViewPadding: true,
            child: Builder(
              builder: (BuildContext context) {
                // Manual input mode - show old staking page layout with InputItem components
                if (params.manualAddValidator) {
                  return Column(
                    children: <Widget>[
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.fromLTRB(20, 28, 20, 0),
                          children: <Widget>[
                            Container(
                              child: Column(
                                children: [
                                  InputItem(
                                    padding: const EdgeInsets.only(top: 0),
                                    label: dic.nodeProviders,
                                    controller: _validatorCtrl,
                                    placeholder: '',
                                  ),
                                  InputItem(
                                    label: dic.memo,
                                    initialValue: '',
                                    controller: _memoCtrl,
                                    placeholder: '',
                                  ),
                                ],
                              ),
                            ),
                            _buildNetworkFeeDisplay(fees),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 38, right: 38, top: 12, bottom: 30),
                        child: NormalButton(
                          color: ColorsUtil.hexColor(0x6D5FFE),
                          text: dic.next,
                          disabled: _submitDisabled,
                          onPressed: _handleSubmit,
                        ),
                      )
                    ],
                  );
                }
                
                return Column(
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      color: Color(0x1A00D395),
                      child: Text(
                        dic.stakeInfoBanner,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF00D395),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                        children: <Widget>[
                          if (isRedelegate) ...[
                            Text(
                              dic.fromValidator,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black.withValues(alpha: 0.6),
                              ),
                            ),
                            SizedBox(height: 8),
                            _buildCurrentValidatorCard(context, currentValidatorAddress),
                            SizedBox(height: 20),
                          ],
                          Text(
                            isRedelegate ? dic.toValidator : dic.stakingProviderName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black.withValues(alpha: 0.6),
                            ),
                          ),
                          SizedBox(height: 8),
                          _buildToValidatorCard(context, validatorData, params.manualAddValidator),
                          if (!isRedelegate) _buildAprEstimates(context),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                          left: 38, right: 38, top: 12, bottom: 30 + nextBottom),
                      child: NormalButton(
                        color: ColorsUtil.hexColor(0x6D5FFE),
                        text: dic.next,
                        disabled: _submitDisabled,
                        onPressed: _handleSubmit,
                      ),
                    )
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildNetworkFeeDisplay(Fees fees, {bool showAdvanceButton = true}) {
    return NetworkFeeDisplay(
      currentFee: currentFee ?? fees.medium,
      transferFees: fees,
      onAdvanceConfirm: _onAdvanceConfirm,
      currentNonce: _parseNonce(store.assets!.accountsInfo[store.wallet!.currentAddress]?.inferredNonce),
      advanceFee: _feeCtrl.text,
      advanceNonce: _nonceCtrl.text,
      showFeeButtons: !store.settings!.isZekoNet,
      showAdvanceButton: showAdvanceButton,
    );
  }

  Widget _buildCurrentValidatorCard(BuildContext context, String? validatorAddress) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    final ValidatorData? validator = validatorAddress != null
        ? store.staking!.allValidators.firstWhereOrNull((v) => v.address == validatorAddress)
        : null;
    
    String displayName = validator?.name ?? 
        (validatorAddress != null ? Fmt.address(validatorAddress, pad: 8) : dic.currentValidator);
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF9FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05), width: 0.5),
      ),
      child: Row(
        children: [
          if (validator != null)
            _buildValidatorLogo(validator)
          else
            _defaultLogoWithAddress(validatorAddress),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              displayName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToValidatorCard(BuildContext context, ValidatorData? validatorData, bool manualAdd) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    bool isMainnet = store.settings!.isMainnet;
    
    if (manualAdd) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black.withValues(alpha: 0.1), width: 1),
        ),
        child: TextField(
          controller: _validatorCtrl,
          decoration: InputDecoration(
            hintText: dic.inputNodeAddress,
            hintStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.black.withValues(alpha: 0.3),
            ),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
      );
    }
    
    ValidatorData? defaultValidator;
    if (isMainnet && validatorData == null && store.staking!.validatorsInfo.isNotEmpty) {
      defaultValidator = store.staking!.validatorsInfo.first;
    }
    
    ValidatorData? displayValidator = validatorData ?? defaultValidator;
    
    return GestureDetector(
      onTap: () {
        DelegateParams params =
            ModalRoute.of(context)!.settings.arguments as DelegateParams;
        Navigator.pushReplacementNamed(
          context, 
          ValidatorsPage.route,
          arguments: {
            'isRedelegate': params.isRedelegate,
            'selectedValidatorAddress': displayValidator?.address,
          },
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFFF9FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05), width: 0.5),
        ),
        child: Row(
          children: [
            if (displayValidator != null) ...[
              _buildValidatorLogo(displayValidator),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  displayValidator.name ?? Fmt.address(displayValidator.address, pad: 8),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
            ] else ...[
              Expanded(
                child: Text(
                  dic.selectValidator,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
            Icon(
              Icons.chevron_right,
              color: Colors.black.withValues(alpha: 0.3),
              size: 30,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValidatorLogo(ValidatorData validator) {
    return ItemLogo(
      name: validator.name,
      logo: validator.logo,
      radius: 20,
      address: validator.address,
    );
  }

  Widget _defaultLogoWithAddress(String? address) {
    return ItemLogo(
      name: null,
      logo: '',
      radius: 20,
      address: address,
    );
  }

  Widget _buildAprEstimates(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    bool isMainnet = store.settings!.isMainnet;
    
    double? apr = store.staking!.stakingAPR;
    Token mainTokenNetInfo = store.assets!.mainTokenNetInfo;
    double balance = mainTokenNetInfo.tokenBaseInfo?.showBalance ?? 0.0;
    
    String oneEpochEst = '--';
    String threeMonthEst = '--';
    String sixMonthEst = '--';
    
    if (isMainnet && apr != null && apr > 0 && balance > 0) {
      double aprDecimal = apr / 100;
      
      double oneEpochValue = balance * aprDecimal * (DAYS_PER_EPOCH / DAYS_PER_YEAR);
      double threeMonthValue = balance * aprDecimal * (DAYS_PER_THREE_MONTHS / DAYS_PER_YEAR);
      double sixMonthValue = balance * aprDecimal * (DAYS_PER_SIX_MONTHS / DAYS_PER_YEAR);
      
      oneEpochEst = _floorToDecimals(oneEpochValue, 4);
      threeMonthEst = _floorToDecimals(threeMonthValue, 4);
      sixMonthEst = _floorToDecimals(sixMonthValue, 4);
    }
    
    return Container(
      margin: EdgeInsets.only(top: 20),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF9FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05), width: 0.5),
      ),
      child: Column(
        children: [
          _buildEstimateRow(dic.epochEstimate, '$oneEpochEst ${COIN.coinSymbol}'),
          SizedBox(height: 12),
          _buildEstimateRow(dic.threeMonthsEstimate, '$threeMonthEst ${COIN.coinSymbol}'),
          SizedBox(height: 12),
          _buildEstimateRow(dic.sixMonthsEstimate, '$sixMonthEst ${COIN.coinSymbol}'),
        ],
      ),
    );
  }

  Widget _buildEstimateRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black.withValues(alpha: 0.5),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

class ValidatorSelector extends StatelessWidget {
  ValidatorSelector({required this.validatorData});

  final ValidatorData validatorData;

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dic.stakingProviderName,
          textAlign: TextAlign.left,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xD9000000)),
        ),
        GestureDetector(
          onTap: () async {
            Navigator.pop(context);
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
              height: 50,
              margin: EdgeInsets.only(top: 6),
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                // color:  ColorsUtil.hexColor(0xF6F7F8),
                border: Border.all(color: Color(0x1A000000), width: 0.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      validatorData.name ?? Fmt.address(validatorData.address),
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Color(0xD9000000)),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 15,
                      color: Colors.black,
                    )
                  ])),
        )
      ],
    );
  }
}
