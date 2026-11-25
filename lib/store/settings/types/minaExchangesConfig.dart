import 'package:auro_wallet/common/consts/settings.dart';

class MinaExchange {
  const MinaExchange({
    required this.id,
    required this.enabled,
    required this.name,
    required this.iconUrl,
    required this.url,
    required this.description,
  });

  final String id;
  final bool enabled;
  final String name;
  final String iconUrl;
  final String url;
  final Map<String, String> description;

  String descriptionFor(String language) {
    final normalized = language.replaceAll('-', '_');
    final base = normalized.split('_').first;
    for (final key in [normalized, base == 'zh' ? 'zh_CN' : base, 'en']) {
      final text = description[key];
      if (text != null && text.isNotEmpty) return text;
    }
    return '';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'enabled': enabled,
    'name': name,
    'iconUrl': iconUrl,
    'url': url,
    'description': description,
  };
}

class MinaExchangesConfig {
  const MinaExchangesConfig({required this.enabled, required this.exchanges});

  final bool enabled;
  final List<MinaExchange> exchanges;

  List<MinaExchange> get available =>
      enabled ? exchanges.where((item) => item.enabled).toList() : [];

  static MinaExchangesConfig? parse(Object? value) {
    if (value is! Map ||
        value['schemaVersion'] != 1 ||
        value['enabled'] is! bool ||
        value['exchanges'] is! List)
      return null;
    try {
      final exchanges = (value['exchanges'] as List).map((item) {
        final icon = Uri.parse(
          BASE_INFO_URL,
        ).resolve(item['iconUrl'] as String);
        final url = Uri.parse(item['url'] as String);
        if (!['http', 'https'].contains(url.scheme) ||
            url.host.isEmpty ||
            !['http', 'https'].contains(icon.scheme) ||
            icon.host.isEmpty) {
          throw const FormatException('Invalid exchange URL');
        }
        return MinaExchange(
          id: item['id'] as String,
          enabled: item['enabled'] as bool,
          name: item['name'] as String,
          iconUrl: icon.toString(),
          url: url.toString(),
          description: Map<String, String>.unmodifiable(
            item['description'] ?? {},
          ),
        );
      }).toList();
      return MinaExchangesConfig(
        enabled: value['enabled'],
        exchanges: List.unmodifiable(exchanges),
      );
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> toJson() => {
    'schemaVersion': 1,
    'enabled': enabled,
    'exchanges': exchanges,
  };
}
