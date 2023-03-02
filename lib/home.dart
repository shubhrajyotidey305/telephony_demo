import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:telephony/telephony.dart';
import 'package:telephony_demo/services/local_notification_service.dart';

onBackgroundMessage(SmsMessage message) {
  log("onBackgroundMessage called ${message.body}");
  LocalNotificationService.display(message);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _message = "";
  final telephony = Telephony.instance;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  onMessage(SmsMessage message) async {
    log("message received on flutter side: ${message.body}");
    LocalNotificationService.display(message);
    setState(() {
      _message = message.body ?? "Error reading message body.";
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.

    final bool? result = await telephony.requestPhoneAndSmsPermissions;

    if (result != null && result) {
      telephony.listenIncomingSms(
          onNewMessage: onMessage, onBackgroundMessage: onBackgroundMessage);
    }

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text('Telephony'),
        backgroundColor: Colors.green.shade600,
        actions: [
          IconButton(
              onPressed: () async {
                await GoogleSignIn().disconnect();
                FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    'phone',
                    (route) => false,
                  );
                }
              },
              icon: const Icon(Icons.logout_rounded)),
        ],
      ),
      body: Center(child: Text("Latest received SMS: $_message")),
    ));
  }
}
