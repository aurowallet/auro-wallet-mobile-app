import 'package:auro_wallet/page/settings/contact/contactEditPage.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/settings/settings.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/common/components/normalButton.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:auro_wallet/store/settings/types/contactData.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    var contactInputs = await Navigator.of(context).pushNamed(ContactEditPage.route, arguments: {
      "name": initName, "address": initAddress});
    List<String>? inputs  = contactInputs as List<String>?;
    // List<String>? inputs = await showDialog<List<String>>(
    //   context: context,
    //   builder: (_) {
    //     return AddressBookDialog(
    //         name: initName,
    //         address: initAddress,
    //         onOk:(String? name, String? address) {
    //           if (name == null || name.isEmpty
    //               || address == null || address.isEmpty
    //           ) {
    //             UI.toast(i18n['urlError_1']!);
    //             return false;
    //           }
    //           return true;
    //         }
    //     );
    //   },
    // );
    if (inputs == null) {
      return null;
    }
    String name = inputs[0].trim();
    String address = inputs[1].trim();
    return {
      "name": name,
      "address": address
    };
  }
  void _addContact() async {
    var nameAndAddressMap = await _showAddressDialog(null, null);
    if (nameAndAddressMap == null) {
      return;
    }
    String name = nameAndAddressMap["name"]!;
    String address = nameAndAddressMap["address"]!;
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

  Widget _renderEmpty() {
    var i18n = I18n.of(context).settings;
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          'assets/images/setting/empty_contact.svg',
          width: 100,
          height: 100,
        ),
        Text(
          i18n['noAddress']!,
          style: TextStyle(
              color: Colors.black.withOpacity(0.3),
              fontSize: 12,
              fontWeight: FontWeight.w400
          ),
        )
      ],
    );
  }

  Widget _renderContactList(BuildContext context, bool isToSelect) {
    var i18n = I18n.of(context).main;
    var contacts = widget.store.contactList;
    if (contacts.length == 0) {
      return this._renderEmpty();
    }
    return ListView.separated(
      itemCount: contacts.length,
        padding: EdgeInsets.symmetric(horizontal: 20),
        separatorBuilder: (BuildContext context, int index) =>  Container(
          color: Colors.black.withOpacity(0.1),
          height: 0.5,
          margin: EdgeInsets.symmetric(vertical: 10),
        ),
        itemBuilder: (BuildContext context, int index) {
          final contact = contacts[index];
          return Padding(
            key: Key(contact.address + contact.name),
            padding: EdgeInsets.zero,
            child: ContactItem(
              name: contact.name,
              address: contact.address,
              store: widget.store,
              showEditDialog: !isToSelect ? _showAddressDialog : null,
            ),
          );
        }
    );
  }
  @override
  Widget build(BuildContext context) {
    var i18n = I18n.of(context).main;
    final Map? params = ModalRoute.of(context)!.settings.arguments as Map?;
    var isToSelect = false;
    if (params != null) {
      isToSelect = params['isToSelect'] as bool;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(i18n['addressbook']!),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Observer(
          builder: (_){
            return Column(
              children: [
                Expanded(
                  child: _renderContactList(context, isToSelect),
                ),
                Container(
                  padding: EdgeInsets.only(left: 38, right: 38, top: 12, bottom: 30),
                  child: NormalButton(
                    text: I18n.of(context).main['add']!,
                    onPressed: _addContact ,
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
  final Function? showEditDialog;
  final SettingsStore store;
  BuildContext? _ctx;

  void _onClick () async {
    if (this.showEditDialog != null) {
      var nameAndAddressMap = await this.showEditDialog!(this.name, this.address);
      if (nameAndAddressMap == null) {
        return;
      }
      String name = nameAndAddressMap["name"]!;
      String address = nameAndAddressMap["address"]!;
      this.store.updateContact(ContactData(name: name, address: address), this.address);
    } else {
      var contact = this.store.contactList.firstWhere((element) => element.address == this.address);
      Navigator.of(this._ctx!).pop(contact);
    }
  }
  @override
  Widget build(BuildContext context) {
    _ctx = context;
    return Container(
        margin: margin,
        padding: EdgeInsets.zero,
        child: ListTile(
          leading: null,
          minLeadingWidth: 0,
          minVerticalPadding: 0,
          contentPadding: EdgeInsets.symmetric(vertical: 10),
          title: Text(name, style: TextStyle(
              fontSize: 16,
              color: Colors.black, fontWeight: FontWeight.w600
          )),
          subtitle: Padding(
            padding: EdgeInsets.only(top: 5),
            child: Text(address, style: TextStyle(
                fontSize: 14,
                color: Colors.black.withOpacity(0.3), fontWeight: FontWeight.w500
            )),
          ),
          onTap: _onClick,
        )
    );
  }
}