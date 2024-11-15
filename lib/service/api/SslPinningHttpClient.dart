import 'dart:convert';
import 'dart:io';

import 'package:auro_wallet/common/consts/certConfig.dart';
import 'package:auro_wallet/common/consts/enums.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/settings/settings.dart';
import 'package:auro_wallet/utils/index.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';

class SslPinningHttpClient {
  AppStore store = globalAppStore;

  static Client createClient({CertificateKeys? nextType, String? uri}) {
    String nextPem = "";
    SettingsStore? settings = globalAppStore.settings;
    Map<String, dynamic>? certificateKeyData = settings?.certificateKeyData;
    String lastAuroApiPem = baseUrlPem;
    String lastAuroGraphql = auroPem;
    String lastZekoPem = zekoPem;
    if (certificateKeyData != null) {
      lastAuroApiPem = certificateKeyData[CertificateKeys.auro_api.name] != null
          ? certificateKeyData[CertificateKeys.auro_api.name]!
          : lastAuroApiPem;
      lastAuroGraphql =
          certificateKeyData[CertificateKeys.auro_graphql.name] != null
              ? certificateKeyData[CertificateKeys.auro_graphql.name]!
              : lastAuroGraphql;
      lastZekoPem =
          certificateKeyData[CertificateKeys.zeko_graphql.name] != null
              ? certificateKeyData[CertificateKeys.zeko_graphql.name]!
              : lastZekoPem;
    }
    switch (nextType) {
      case CertificateKeys.auro_api:
        nextPem = lastAuroApiPem;
        break;
      case CertificateKeys.auro_graphql:
        nextPem = lastAuroGraphql;
        break;
      case CertificateKeys.zeko_graphql:
        nextPem = lastZekoPem;
        break;
      default:
    }
    if (nextPem.isEmpty) {
      final httpClient =
          HttpClient(context: SecurityContext(withTrustedRoots: true));
      return IOClient(httpClient);
    }

    if (nextType != null &&
        settings?.certExpiredCheckStatus[nextType.name] == null) {
      X509CertificateData certData = X509Utils.x509CertificateFromPem(nextPem);
      DateTime? expirationDate = certData.tbsCertificate?.validity.notAfter;
      settings?.certExpiredCheckStatus[nextType.name] = true;
      if (expirationDate != null) {
        DateTime now = DateTime.now();
        Duration remaining = expirationDate.difference(now);
        if (remaining.inMilliseconds <= 7 * 60 * 60 * 1000) {
          webApi.setting.getNewestCert(getOrigin(uri!), nextType);
        }
      }
    }
    final context = SecurityContext(withTrustedRoots: false);
    Uint8List certBytes = utf8.encode(nextPem);
    context.setTrustedCertificatesBytes(certBytes);
    final httpClient = HttpClient(context: context);
    httpClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) {
      print(
          "SSL Pinning: Certificate for host $host does not match any pinned certificates.${uri}");
      return false;
    };

    return IOClient(httpClient);
  }
}
