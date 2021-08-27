import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/settings/settings.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:auro_wallet/common/components/formPanel.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:auro_wallet/common/components/normalButton.dart';
import 'package:auro_wallet/common/components/addressBookDialog.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:auro_wallet/store/settings/types/contactData.dart';

class ContactListPage extends StatefulWidget {
  final SettingsStore store;
  static final String route = '/profile/contacts';
  ContactListPage(this.store);
  @override
  _ContactListPageState createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {

  final Api api = webApi;

  Future<Map<String, String>?> _showAddressDialog(String? initName, String? initAddress) async {
    var i18n = I18n.of(context).main;
    List<String>? inputs = await showDialog<List<String>>(
      context: context,
      builder: (_) {
        return AddressBookDialog(
            name: initName,
            address: initAddress,
            onOk:(String? name, String? address) {
              if (name == null || name.isEmpty
                  || address == null || address.isEmpty
              ) {
                UI.toast(i18n['urlError_1']!);
                return false;
              }
              return true;
            }
        );
      },
    );
    if (inputs == null) {
      return null;
    }
    String name = inputs[0].trim();
    String address = inputs[1].trim();
    name = name.trim();
    address = address.trim();
    bool isValid = await webApi.account.isAddressValid(address);
    if (!isValid) {
      UI.toast(i18n['sendAddressError']!);
      return null;
    }
    return {
      "name": name,
      "address": address
    };
  }
  void _addContact() async {
    var i18n = I18n.of(context).main;
    var nameAndAddressMap = await _showAddressDialog(null, null);
    if (nameAndAddressMap == null) {
      return;
    }
    String name = nameAndAddressMap["name"]!;
    String address = nameAndAddressMap["address"]!;
    if (widget.store.contactList.any((element) => element.address == address)) {
      UI.toast(i18n['repeatContact']!);
      return;
    }
    widget.store.addContact({
      "name": name,
      "address": address
    });
  }
  void _removeContact (ContactData contact) async {
    var i18n = I18n.of(context).main;
    bool? rejected = await UI.showConfirmDialog(context: context, contents: [
      i18n['confirmDeleteNode']!
    ], okText: i18n['confirm']!, cancelText: i18n['cancel']!);
    if (rejected != true) {
      return;
    }
    widget.store.removeContact(contact);
  }
  Widget _renderContactList(BuildContext context) {
    var i18n = I18n.of(context).main;
    final Map? params = ModalRoute.of(context)!.settings.arguments as Map;
    var isToSelect = false;
    if (params != null) {
      isToSelect = params['isToSelect'] as bool;
    }
    var contacts = widget.store.contactList;
    if (contacts.length == 0) {
      return Container();
    }
    List<Widget> list = contacts.map((contact) {
      return GestureDetector(
        child: Padding(
          key: Key(contact.address + contact.name),
          padding: EdgeInsets.zero,
          child: Slidable(
            actionPane: SlidableDrawerActionPane(),
            actionExtentRatio: 0.2,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30,),
              child: ContactItem(
                name: contact.name,
                address: contact.address,
                store: widget.store,
                showEditDialog: _showAddressDialog,
              ),
            ),
            secondaryActions: <Widget>[
              IconSlideAction(
                caption: i18n['delete']!,
                color: ColorsUtil.hexColor(0xF95051),
                icon: Icons.delete,
                onTap: () {
                  _removeContact(contact);
                },
              ),
            ],
          ),
        ),
        behavior: HitTestBehavior.opaque,
        onTap: isToSelect ? (){
          Navigator.of(context).pop(contact);
        } : null,
      );
    })
        .toList();
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 30, right: 30, top: 20),
          ),
          ...list
        ],
      )
    );
  }
  @override
  Widget build(BuildContext context) {
    var i18n = I18n.of(context).main;

    return Scaffold(
      appBar: AppBar(
        title: Text(i18n['addressbook']!),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Observer(
          builder: (_){
            return Column(
              children: [
                Expanded(
                  child: ListView(
                      children: [
                        _renderContactList(context),
                      ]
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  child: NormalButton(
                    text: I18n.of(context).main['add']!,
                    onPressed: _addContact,
                  ),
                ),
              ],
            );
          }
        ),
      ),
    );
  }
}

class ContactItem extends StatelessWidget {
  ContactItem(
      {
        required this.name,
        required this.address,
        required this.store,
        required this.showEditDialog,
        this.margin = const EdgeInsets.only(top: 0),
      });
  final String name;
  final String address;
  final EdgeInsetsGeometry margin;
  final Function showEditDialog;
  final SettingsStore store;

  void _onClick () async {
    var nameAndAddressMap = await this.showEditDialog(this.name, this.address);
    if (nameAndAddressMap == null) {
      return;
    }
    String name = nameAndAddressMap["name"]!;
    String address = nameAndAddressMap["address"]!;
    this.store.updateContact(ContactData(name: name, address: address), this.address);
  }
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    return FormPanel(
        margin: margin,
        padding: EdgeInsets.symmetric(vertical: 10),
        child: ListTile(
          leading: null,
          title: Text(name, style: theme.headline4!.copyWith(
              color: ColorsUtil.hexColor(0x333333), fontWeight: FontWeight.w500
          )),
          subtitle: Padding(
            padding: EdgeInsets.only(top: 5),
            child: Text(address, style: theme.headline5!.copyWith(
                color: ColorsUtil.hexColor(0x666666), fontWeight: FontWeight.w500
            )),
          ),
          onTap: _onClick,
        )
    );
  }
}