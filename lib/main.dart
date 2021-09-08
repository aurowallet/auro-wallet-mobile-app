import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:auro_wallet/app.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:auro_wallet/service/notification.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:auro_wallet/store/settings/settings.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter(); // fluter graphql init

  var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
  var initializationSettingsIOS = IOSInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );
  var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  var initialised = await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification:  (String? payload) async {
        if (payload != null) {
          debugPrint('notification payload: ' + payload);
          selectNotificationSubject.add(payload);
        }
      });
  print('notification_plugin initialised: $initialised');

  // get_storage dependency
  await GetStorage.init();

  // get graph ql endpoint
  String graphqlEndpoint = await SettingsStore.loadEndpointGlobally();

  runApp(
      Phoenix(
        child: WalletApp(graphqlEndpoint: graphqlEndpoint),
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
