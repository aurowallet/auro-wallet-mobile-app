import 'package:flutter/material.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/staking/types/validatorData.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:mobx/mobx.dart';
import 'package:collection/collection.dart';
import 'package:auro_wallet/page/staking/components/searchInput.dart';
import 'package:auro_wallet/page/staking/components/validatorItem.dart';
import 'package:auro_wallet/common/components/normalButton.dart';
import 'package:auro_wallet/page/staking/delegatePage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;

class ValidatorsPage extends StatefulWidget {
  ValidatorsPage(this.store);
  static final String route = '/staking/validators';

  final AppStore store;

  @override
  _ValidatorsPageState createState() => _ValidatorsPageState(store);
}

class _ValidatorsPageState extends State<ValidatorsPage> with SingleTickerProviderStateMixin {
  _ValidatorsPageState(this.store);

  final AppStore store;
  List<ValidatorData> validatorsList = [];
  List<ValidatorData> uiList = [];
  late ReactionDisposer monitorListDisposer;
  TextEditingController editingController = new TextEditingController();
  String? keywords;
  String selectedValidatorAddress = '';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      monitorListDisposer = reaction((_) => store.staking!.validatorsInfo, _onListChange);
      editingController.addListener(_onKeywordsChange);
      Future.delayed(const Duration(milliseconds: 230), () {
        validatorsList = store.staking!.validatorsInfo;
        setState(() {
          uiList = validatorsList;
        });
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    monitorListDisposer();
    editingController.dispose();
  }

  void _onKeywordsChange() {
    setState(() {
      keywords = editingController.text.trim();
      uiList = _filter(validatorsList);
    });
  }

  void _onListChange(List<ValidatorData> vs) {
    validatorsList = vs;
    setState(() {
      uiList = _filter(vs);
    });
  }

  List<ValidatorData> _filter(List<ValidatorData> list) {
    if(keywords == null || keywords!.isEmpty) {
      return list;
    }
    var res =  list.where((element){
      return (element.address != null && element.address.toLowerCase().contains(keywords!.toLowerCase()))
          || (element.name != null && element.name!.toLowerCase().contains(keywords!.toLowerCase()));
    }).toList();
    if (selectedValidatorAddress.isNotEmpty
        && res.where((element) => element.address == selectedValidatorAddress).length == 0) {
      selectedValidatorAddress = '';
    }
    return res;
  }

  void _handleStake() async {
    if (selectedValidatorAddress.isEmpty) {
      return;
    }
    ValidatorData? selectedValidator = validatorsList.firstWhereOrNull((validator) => validator.address == selectedValidatorAddress);
    if (selectedValidator != null) {
      Navigator.pushNamed(context, DelegatePage.route, arguments: DelegateParams(validatorData: selectedValidator, manualAddValidator: false));
    }
  }

  void _toggle (String validatorAddress, bool isChecked) {
    if (isChecked) {
      UI.unfocus(context);
      setState(() {
        selectedValidatorAddress = validatorAddress;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> i18n = I18n.of(context).main;
    Color primaryColor = Theme.of(context).primaryColor;
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(i18n['nodeProviders']!, style: TextStyle(fontSize: 20),),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: SafeArea(
            child: Column(
              children: [
                SearchInput(editingController: editingController,),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(left: 28, right: 28, bottom: 20, top: 12),
                    itemCount: uiList.length + 1,
                    itemBuilder: (context, index) {
                      if (index == uiList.length) {
                        return ManualAddValidatorButton();
                      }
                      return ValidatorItem(
                        data: uiList[index],
                        checked: selectedValidatorAddress ==  uiList[index].address,
                        toggle: _toggle,
                      );
                    },
                  )
                ),
               Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                 child:  NormalButton(
                   disabled: selectedValidatorAddress.isEmpty,
                   color: ColorsUtil.hexColor(0x6D5FFE),
                   text: I18n.of(context).main['next']!,
                   onPressed: _handleStake,
                 ),
               )
              ],
            )
        )
    );
  }
}

class ManualAddValidatorButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Map<String, String> i18n = I18n.of(context).main;
    var theme = Theme.of(context).textTheme;
    return Padding(
        padding: EdgeInsets.only(top: 10),
        child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, DelegatePage.route, arguments: DelegateParams(validatorData: null, manualAddValidator: true));
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
                padding:const EdgeInsets.symmetric(vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(i18n['manualAdd']!, style: theme.headline5!.copyWith(
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
    );
  }
}