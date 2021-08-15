import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'main.dart';

class AppLocalizationsDelegate extends LocalizationsDelegate<I18n> {
  const AppLocalizationsDelegate(this.overriddenLocale);

  final Locale overriddenLocale;

  @override
  bool isSupported(Locale locale) => ['en', 'zh'].contains(locale.languageCode);

  @override
  Future<I18n> load(Locale locale) {
    return SynchronousFuture<I18n>(I18n(overriddenLocale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => true;
}

class I18n {
  I18n(this.locale);

  final Locale locale;

  static I18n of(BuildContext context) {
    return Localizations.of<I18n>(context, I18n)!;
  }

  static Map<String, Map<String, Map<String, String>>> _localizedValues = {
    'en': {
      'main': enMain,
    },
    'zh': {
      'main': zhMain,
    },
  };

  Map<String, String> get main {
    return _localizedValues[locale.languageCode]!['main']!;
  }

}
