class AccountUpdateInfo {
  String label;
  List<AccountDetail> children;

  AccountUpdateInfo({required this.label, required this.children});

  Map<String, dynamic> toJson() => {
        'label': label,
        'children': children.map((x) => x.toJson()).toList(),
      };
}

class Detail {
  String label;
  String value;

  Detail({required this.label, required this.value});

  Map<String, dynamic> toJson() => {
        'label': label,
        'value': value,
      };
}

class AccountDetail {
  String label;
  List<Detail> children;

  AccountDetail({required this.label, required this.children});

  Map<String, dynamic> toJson() => {
        'label': label,
        'children': children.map((x) => x.toJson()).toList(),
      };
}

class TransactionDetail {
  String label;
  List<dynamic> children;

  TransactionDetail({required this.label, required this.children});

  Map<String, dynamic> toJson() => {
        'label': label,
        'children': children.map((x) => x.toJson()).toList(),
      };
}

class DataItem {
  final String label;
  final dynamic value; 
  final List<DataItem>? children; 

  DataItem({required this.label, this.value, this.children});

  factory DataItem.fromJson(Map<String, dynamic> json) {
    var childrenList = json['children'] as List?;
    List<DataItem>? childrenItems;
    if (childrenList != null) {
      childrenItems = childrenList
          .map<DataItem>((childJson) => DataItem.fromJson(childJson))
          .toList();
    }

    return DataItem(
      label: json['label'],
      value: json['value'],
      children: childrenItems,
    );
  }
}