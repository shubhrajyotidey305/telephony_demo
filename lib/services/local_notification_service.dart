import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:telephony/telephony.dart';
import 'package:telephony_demo/services/message_link.dart';
import 'package:telephony_demo/services/weather.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static void initialize() {
    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: AndroidInitializationSettings("@mipmap/ic_launcher"));

    _notificationsPlugin.initialize(initializationSettings);
  }

  static void display(SmsMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      const NotificationDetails notificationDetails = NotificationDetails(
          android: AndroidNotificationDetails(
        "telephony",
        "telephony channel",
        importance: Importance.max,
        priority: Priority.high,
      ));

      // Example API call for testing
      WeatherModel weatherModel = WeatherModel();
      var weatherData = await weatherModel.getCityWeather(message.body!);
      double temp = weatherData['main']['temp'];
      int cityTemperature = temp.toInt();
      String weatherMessage = weatherModel.getMessage(cityTemperature);

      //Example code for if there are links
      MessageModel messageModel = MessageModel();
      List<String?> links = messageModel.getMessageLink(message.body!);
      if (kDebugMode) {
        print(links);
      }

      await _notificationsPlugin.show(
        id,
        message.body,
        weatherMessage,
        notificationDetails,
      );
    } on Exception catch (e) {
      log(e.toString());
    }
  }
}
