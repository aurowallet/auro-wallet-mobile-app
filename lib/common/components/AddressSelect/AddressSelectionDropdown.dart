import 'package:auro_wallet/common/components/AddressSelect/AddressDropdownButton.dart';
import 'package:auro_wallet/store/settings/types/contactData.dart';
import 'package:flutter/material.dart';

class AddressSelectionDropdown extends StatefulWidget {
  AddressSelectionDropdown({required this.addressList, required this.onSelect});

  final List<DropdownAddressItem> addressList;
  final void Function(ContactData) onSelect;

  @override
  _AddressSelectionDropdownState createState() =>
      _AddressSelectionDropdownState();
}

class _AddressSelectionDropdownState extends State<AddressSelectionDropdown> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onChoose(String? addressKey) async {
    if (addressKey!.isNotEmpty) {
      DropdownAddressItem selectItem =
          widget.addressList.firstWhere((o) => o.addressKey == addressKey);
      widget.onSelect(
          ContactData(name: selectItem.name, address: selectItem.address));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      child: AddressDropdownButton(
        items: [...widget.addressList.toList()],
        onChoose: onChoose,
      ),
    );
  }
}
