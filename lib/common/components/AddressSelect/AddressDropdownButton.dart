import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

enum AddressItemTypes { addressbook, account, empty }

class DropdownAddressItem {
  DropdownAddressItem(
      {required this.name,
      required this.address,
      required this.type,
      required this.addressKey});
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
    AppLocalizations dic = AppLocalizations.of(context)!;
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
        alignment: Alignment.center,
        menuItemStyleData: const MenuItemStyleData(
          height: 40,
        ),
        dropdownStyleData: DropdownStyleData(
            maxHeight: 200,
            width: MediaQuery.of(context).size.width - 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: Color(0xFFF9FAFC),
            ),
            offset: Offset(offsetX, -30),
            elevation: 8),
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
                                      colorFilter: ColorFilter.mode(
                                          Color(0xFF000000)
                                              .withValues(alpha: 0.8),
                                          BlendMode.srcIn),
                                    ),
                                    Padding(padding: EdgeInsets.only(left: 4)),
                                    Text(item.name,
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xFF000000)
                                                .withValues(alpha: 0.8))),
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
                            dic.emptyAddress,
                            style: TextStyle(
                                color: ColorsUtil.hexColor(0x808080),
                                fontSize: 16,
                                fontWeight: FontWeight.w400),
                          )),
                  )),
            )
            .toList(),
        onChanged: (String? value) {
          widget.onChoose(value);
        },
      ))),
    ));
  }
}
