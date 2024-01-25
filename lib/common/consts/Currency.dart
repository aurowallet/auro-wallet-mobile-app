class Currency {
  String key;
  String value;
  String symbol;

  Currency({
    required this.key,
    required this.value,
    required this.symbol,
  });
}
/// add currency
final List<Currency> currencyConfig = [
  Currency(key: "usd", value: "USD", symbol: "\$"),
  Currency(key: "cny", value: "CNY", symbol: "￥"),
  Currency(key: "rub", value: "RUB", symbol: "₽"),
  Currency(key: "eur", value: "EUR", symbol: "€"),
  Currency(key: "gbp", value: "GBP", symbol: "£"),
  Currency(key: "try", value: "TRY", symbol: "₺"),
  Currency(key: "uah", value: "UAH", symbol: "₴"),
];
