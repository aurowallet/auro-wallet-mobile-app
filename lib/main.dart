import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:auro_wallet/app.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:auro_wallet/store/settings/settings.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await initHiveForFlutter(); // fluter graphql init

  // get_storage dependency
  await GetStorage.init('configuration');

  runApp(
      Phoenix(
        child: WalletApp(),
      )
  );
  configLoading();
}

void configLoading() {
  EasyLoading.instance
    ..indicatorWidget = Image.asset('assets/images/public/loading.gif', width: 80, height: 80,)
    ..displayDuration = const Duration(milliseconds: 2000)
    ..loadingStyle = EasyLoadingStyle.custom
    ..maskType = EasyLoadingMaskType.black
    ..backgroundColor = Colors.transparent
    ..indicatorColor = Colors.transparent
    ..textColor = Colors.white
    ..maskColor = Colors.black
    ..userInteractions = true
    ..dismissOnTap = true;
}
