import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis_auth/auth_io.dart' as googleAuth;
import 'package:http/http.dart' as http;
import 'package:pulse_viz/camera_screen.dart';
class NotificationController {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  void requestPermission() async {
    NotificationSettings settings =
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((message) {
      print('Notification received in foreground');

      if (Platform.isAndroid) {
        initLocalNotifications(context, message);
        showNotification(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("User clicked on notification when app was in background");
      handleNotificationNavigation(context, message);
    });
  }

  void initLocalNotifications(
      BuildContext context, RemoteMessage message) async {
    var androidInitializationSettings =
    const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitializationSettings = const DarwinInitializationSettings();

    var initializationSettings = InitializationSettings(
        android: androidInitializationSettings, iOS: iosInitializationSettings);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (payload) {
          handleNotificationNavigation(context, message);
        });
  }

  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel androidNotificationChannel =
    AndroidNotificationChannel(
        Random.secure().nextInt(100000).toString(), 'heart attack channel',
        importance: Importance.max);

    AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(androidNotificationChannel.id.toString(),
        androidNotificationChannel.name.toString(),
        channelDescription: 'my Description for channel',
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'ticker',
    );

    const DarwinNotificationDetails iosNotificationDetails =
    DarwinNotificationDetails(
        presentAlert: true, presentBadge: true, presentSound: true);

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: iosNotificationDetails);

    Future.delayed(Duration.zero, () {
      _flutterLocalNotificationsPlugin.show(0, message.notification!.title,
          message.notification!.body, notificationDetails);
    });
  }

  void handleNotificationNavigation(
      BuildContext context, RemoteMessage message) {
      print('Notification navigation');
      Navigator.push(context, MaterialPageRoute(builder: (context)=>CameraScreen()));
  }

  Future<String> getAccessKey() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "newpulseviz",
      "private_key_id": "a16f94fbce9286729b71eef43ae9613c816a2e95",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDJotDpn7NXKUV3\nOQoIWUxRjWROIzLO+L3EGYfNc2vYifj2zTU/UaEQxxyVDxPUHy9KonznHbcFEpVC\nRn6vkwqk9N+oDX5S++UHszZY0Y4t8PKNWeMAX8+UTTxxrXllrhxDDZbXg7a/DOi5\nVWB7MdL/xVx+DiK6xLsYaR+j3FnAQx5I9nvEtBFvXMhbcUhTZ8r44swccKx3H+VB\nubiye8btDYNo6TLuxJkFEaupyxhUok5370x/qmnBe5WnSVhCSREYLnbQKM2wkw4y\nBydXtJG+2TMgpYk0A3CtLChVy1W6YDtVKHZDwqn2hTGk2vPFIJ3LuAaavZ4PiLgQ\nbDCiSjJzAgMBAAECggEAA/Tj8JGnrUAsEsjVv5AxBTCnFTlvl8wdvSlbFtb6+MbM\nUdt4/gMWDAQ8NViUZQcvoGFL3iUhIEJbF2/WsI9MGCyN7vhE0FANEHedy2RhS9l8\niPWIlMtMgXZ6hyiGR06BU3eCzDvTbDBOqMRaHlC9+TLgO8D/QXb2zOXTLx31zOX7\nWYL0iT/L0Yt3EQEuNMAOjGWnkm8EisXNyzlKBeQVDIUBDRtH9TzHqliLHvCDPYzf\njYC8GObVNKjHrVqEf/lwfj+CdkfO5LRkenN77CuUCZDlgwutymzrNelJdT3hRi8G\nYzHAHiJnqM1YIY+nZswlSfKhrUgl4lyZqBWov8ap8QKBgQDj/5H/HiYhNDAKx0ad\nNEdXlBYPZATF1ThMbx88plIQ/8dd4+6KLWPR1iiwI0LPGfIWR0c0wQ/XbUXwPzQH\nNgWubY2JaHGE5+mxDx+NeMvM8q4qtdUaAOiDIJHvFSHimeRKVDA8yP7vXG/TDZOD\nkobTMVVVxcFps+cWLPq0UDnPbQKBgQDiZmVGEMo9/5jpR60D61Eppg2jntLSxHkz\nffvHdT/RrSn26m/lkQ6VMUHfXGc0g4YyJKfGMxJjc0RPYhKPDw/u3y6FiLUPWblz\nqXs7+uDDxgKbVxGP02luxwdwFv1abg+JDBcEjPmEnRGZu41Rc5Yw56OpSOCATM3S\nUw6VHgZ9XwKBgQDFgWszmSZmtRK5A4+ENvlmQH4rrvUDe4VdkRV6MIn+99P43a6S\nPGewKtjsXF9PkKZJ7k0cwfG7KInhaJ7lcELTq0tksPlFrLCgFP28S9wgGkoN7Z5A\n/HBuxxQkDCZiafV8/hkbTvKo32Zvad9TpubspFvMBZdaveF9MFGtSaIKsQKBgHzw\nszz6cRHL50/93S5Hg6/vUqGUOZZVFOnkwbjuLL0CyiDYec3/wkN1PnwMW2wwlTNA\n5VHMx34Yk38XiVRnpIxXoC3TJtCE3IJG6ppMNhP0R2YAo9Fyg0G+Fo22MjTgfjRM\ndrttLRoRMDBdv3xOxHjSrI/0huhm+kLy0R5bxosTAoGAAje8AWnd3Zb/iijCiw9r\nAGgcnkHYD5kPhXukdk7WK2vXp1Aq99A39R/09fog+VBqUidy1kiEJt95gJQorbFw\n1gkL9BMT9+psaS/t+fTX6R4CelhQ00oojb088bxFvY4SGv0o3YqDlHDoOV+0YNfG\nZK5vUSPulakWnTCPE6TmDhg=\n-----END PRIVATE KEY-----\n",
      "client_email": "firebase-adminsdk-fbsvc@newpulseviz.iam.gserviceaccount.com",
      "client_id": "117665353121754922235",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40newpulseviz.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/firebase.messaging",
      "https://www.googleapis.com/auth/datastore"
    ];

    final client = await googleAuth.clientViaServiceAccount(
        googleAuth.ServiceAccountCredentials.fromJson(serviceAccountJson),
        scopes);

    final accessCredentials =
    await googleAuth.obtainAccessCredentialsViaServiceAccount(
        googleAuth.ServiceAccountCredentials.fromJson(serviceAccountJson),
        scopes,
        client);

    client.close();

    return accessCredentials.accessToken.data;
  }

  void notifyDoctors(int roomNumber) async {
    try {
      final serverKey = await getAccessKey();
      String endPoint =
          'https://fcm.googleapis.com/v1/projects/newpulseviz/messages:send';
      final fireStore = FirebaseFirestore.instance;

      final result = await fireStore.collection('users').where('onDuty',isEqualTo: true).get();




      for(var doc in result.docs){
        final data = doc.data();
        final recToken = data['fcmToken'];

        final Map<String, dynamic> message = {
          'message': {
            'token': recToken,
            'notification': {
              'title': 'PulseViz',
              'body': 'A patient is experiencing heart attack in Room #${roomNumber.toString()}, please respond immediately!',
            },
          }
        };
        final response = await http.post(Uri.parse(endPoint),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $serverKey'
            },
            body: jsonEncode(message));
        if (response.statusCode == 200) {
          print('notification sent');
        } else {
          print(response.body);
          print('error occured notifying');
        }

      }


    } catch (e) {
      print('error occured notifying $e');
    }
  }


}
