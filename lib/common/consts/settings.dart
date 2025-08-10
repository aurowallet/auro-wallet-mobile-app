
export 'package:auro_wallet/common/consts/apiConfig.dart';

class COIN {
  static const String coinSymbol = 'MINA';
  static const int decimals = 9;
  static const String name = "Mina Protocol";
}


const int SECONDS_OF_DAY = 24 * 60 * 60; // seconds of one day
const int SECONDS_OF_YEAR = 365 * 24 * 60 * 60; // seconds of one year

/// app versions
const String app_version = 'v2.2.0(1187)';

final Map<String, String> languageConfig = {
  "en": 'English',
  "zh": '中文（简体）',
  "tr": "Türkçe",
  "uk": "Українська мова",
  "ru": "Русский"
};

// ** language contrubute url
final String contributeMoreLanguage =
    "https://hosted.weblate.org/projects/aurowallet/";
