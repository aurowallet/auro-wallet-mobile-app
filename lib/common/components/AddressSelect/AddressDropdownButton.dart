import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_svg/svg.dart';

enum AddressItemTypes { addressbook, account, empty }

class DropdownAddressItem {
  DropdownAddressItem(
      {required this.name, required this.address, required this.type,required this.addressKey});
  final String name;
  final String address;
  final AddressItemTypes type;
  final String addressKey;
}

class AddressDropdownButton extends StatefulWidget {
  AddressDropdownButton({
    required this.items,
    required this.onChoose,
  });

  final List<DropdownAddressItem> items;
  final Function(String? text) onChoose;
  @override
  _AddressDropdownButtonState createState() => _AddressDropdownButtonState();
}

class _AddressDropdownButtonState extends State<AddressDropdownButton> {
  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).main;
    var dropdownWidth = MediaQuery.of(context).size.width - 40;
    var customButtonWidth = 40;
    var offsetX = customButtonWidth - dropdownWidth;
    return FittedBox(
        child: Container(
      width: 16,
      child: Center(
          child: DropdownButtonHideUnderline(
              child: DropdownButton2(
        customButton: SvgPicture.asset(
          'assets/images/public/icon_address.svg',
          width: 10,
          height: 10,
        ),
        offset: Offset(offsetX, -30),
        itemPadding: EdgeInsets.symmetric(horizontal: 8),
        dropdownPadding: EdgeInsets.symmetric(vertical: 4),
        alignment: Alignment.center,
        dropdownMaxHeight: 200,
        items: widget.items
            .map(
              (item) => DropdownMenuItem<String>(
                  value: item.addressKey,
                  child: Center(
                    child: item.type != AddressItemTypes.empty
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SvgPicture.asset(
                                        item.type == AddressItemTypes.account
                                            ? 'assets/images/assets/wallet_manage.svg'
                                            : 'assets/images/setting/contact.svg',
                                        width: 24,
                                        height: 24,
                                        color: ColorsUtil.hexColor(0x808080)),
                                    Padding(padding: EdgeInsets.only(left: 4)),
                                    Text(item.name,
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            color:
                                                ColorsUtil.hexColor(0x808080))),
                                  ]),
                              Text(
                                '${Fmt.address(item.address, pad: 6)}',
                                style: TextStyle(
                                    color: ColorsUtil.hexColor(0x808080),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400),
                              )
                            ],
                          )
                        : Container(
                            child: Text(
                            dic['emptyAddress']!,
                            style: TextStyle(
                                color: ColorsUtil.hexColor(0x808080),
                                fontSize: 16,
                                fontWeight: FontWeight.w400),
                          )),
                  )),
            )
            .toList(),
        dropdownDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
        ),
        dropdownElevation: 8,
        onChanged: (String? value) {
          widget.onChoose(value);
        },
        dropdownWidth: MediaQuery.of(context).size.width - 40,
      ))),
    ));
  }
}
