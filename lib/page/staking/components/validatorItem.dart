
import 'package:flutter/material.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:auro_wallet/store/staking/types/validatorData.dart';
import 'package:roundcheckbox/roundcheckbox.dart';

class ValidatorItem extends StatelessWidget {
  ValidatorItem({required this.data, this.showSelected});

  final ValidatorData data;
  final bool? showSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(top: 10),
        child: Material(
          color: Color(0xFFF9FAFC),
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: () {
              Navigator.pop(context, data);
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: Colors.black.withValues(alpha: 0.05), width: 0.5)),
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ItemLogo(
                      name: data.name,
                      logo: data.logo,
                      address: data.address,
                    ),
                    Container(
                      width: 10,
                    ),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            data.name == null
                                ? Fmt.address(data.address, pad: 10)
                                : Fmt.stringSlice(data.name!, 16,
                                    withEllipsis: true, ellipsisCounted: true),
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.w500)),
                        Padding(
                          padding: EdgeInsets.only(top: 5),
                        ),
                        Text(Fmt.address(data.address, pad: 6),
                            style: TextStyle(
                                color: Colors.black.withValues(alpha: 0.5),
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                height: 1.2)),
                      ],
                    )),
                    (showSelected == true
                        ? RoundCheckBox(
                            size: 18,
                            borderColor: Colors.transparent,
                            isChecked: showSelected == true,
                            uncheckedColor: Colors.white,
                            checkedColor: Theme.of(context).primaryColor,
                            checkedWidget: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 12,
                            ),
                            onTap: (bool? checkedFlag) {},
                          )
                        : Container())
                  ],
                )),
          ),
        ));
  }
}

class ItemLogo extends StatefulWidget {
  ItemLogo({this.name, required this.logo, this.radius = 15, this.address});

  final String? name;
  final String logo;
  final double? radius;
  final String? address; // Fallback for display when name is empty

  @override
  ItemLogoState createState() => ItemLogoState();
}

class ItemLogoState extends State<ItemLogo> {
  bool loadError = false;

  onLoadError(exception, stackTrace) {
    setState(() {
      loadError = true;
    });
  }

  /// Get display character: name first char > address first char > 'U'
  String _getDisplayChar() {
    if (widget.name != null && widget.name!.isNotEmpty) {
      return widget.name!.substring(0, 1).toUpperCase();
    }
    if (widget.address != null && widget.address!.isNotEmpty) {
      return widget.address!.substring(0, 1).toUpperCase();
    }
    return 'U';
  }

  @override
  Widget build(BuildContext context) {
    final showText = widget.logo.isEmpty || loadError;
    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: Color(0x4D000000),
      onBackgroundImageError: !showText ? onLoadError : null,
      backgroundImage: !showText
          ? NetworkImage(
              widget.logo,
              // 'https://picsum.photos/250?image=10',
            )
          : null,
      child: showText
          ? Text(
              _getDisplayChar(),
              style: TextStyle(fontSize: 16, color: Colors.white),
            )
          : null,
    );
  }
}
