class Currency {
  Currency({required this.code});
  final String code;
  String get symbol {
    switch (code) {
      case 'cny':
        return '￥';
      case 'usd':
        return r'$';
      case 'rub':
        return '₽';
    }
    return '';
  }
}