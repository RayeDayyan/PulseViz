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
      "private_key_id": "fed1cbd7bc8e10f89106244f80bbbc78706a02ca",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCn+E/KHZq1unxA\nH1o1NEISkr3enQBI42mK7a08GzZdTZifRMurm58d69Lu0+NU92XrPqO0QKH/6wGj\npZBasEh4inX5vSyWMJ3hfDyrpooEjUv1PurSC34iQa3ih7d5zLfecGpTHrL7JzGf\nvnDiFBcP08OC7vRY9q869bQVC2RzBjulqczBU+h9WFH0I/QVGk81J3Iu/8rS9kdj\nVMIIDqoWkr2HrSCuiEeIDte7S0BxSc2WVhuayGLDkcbCHZ+XrPv9DnBNTXRD2QZl\n1kcg/oo8aI2kr98/vp/3vGYWnCoJaQGWfIv/HlKl5HT2Pq4Tu1/BZsbx/Q88GqfV\nbYuj47RbAgMBAAECggEAF50vrnUCAolwnV0rA+7QWScbHVhKKXUbKeZnI9uZhX16\ntu1nir0qnfzA30WXoKLVR8C7KASsIbvqs5R7mlxNG/EvS8heI9E66O/b4a/cmG46\n3wQU5CmsdmlwZjf5QdzXfqSkNgJLXEay0cfmu8niQh3dzyMD5BvuH6ZaRlkfKpJb\n51Oc2ysylhc2M5FPIZAmLylLvX6TYZqVo60FPxa4Ciw6S3gU4FuNtpv16c6zWEGV\nSAhQ0BsXUc9r2I1bpED/ztt+osGnsZY2BUv2LYcnJic9AsCqBaQ1oZPYzQ3TKRho\nHyHNQ2ImEBnDnEcBzYLGO6tZXlQo97y2k9nAQLVwvQKBgQDXxXT8kEQ5r2oDBbOL\ndk5dJymweyvjOl395yh+LKG17tuQVfhAfKUtyz6t+PkUOPyF8zpfZAzRUrPl9DI3\nkhRCb2aQ4z+LxyDlFpURMqeSaCn3YF90iS6+4f4S3JIJjXsG2UQGGFu069J2BY8U\nh9+4YSG3uoZoVh0xWTYiUFWd3QKBgQDHSVhxXc7aRDuD/lwbIW94GKW/2L7jdwf6\nLbPmt7x/4Gk2O5n/bWCeZN4nA8evvi/6qynToAceVD27rxYJmrBMhxqZNSu5ImDB\nlsZNk5yJn79MQsuDFhTdtwYgMBbDZEEwwLIypsXpARSaEH8yDzYBP8zjDAU1zRbk\nPEX30xIDlwKBgH42azLdNHtFp04zRI3cWwRURyeLNOXKm3ZMg7wiYUkpeddY4kje\nYESEMZrUGuaAWv4Dg26O+IxswvxMth8ZXK5ruWQg+WfKx+wZJIMVzT1vnrSr88oY\nAHb5fIQN74KU9pTP++FQ2DvhAY+1urb4r52Le4ycF8jqLlNSar7xnNMlAoGAUUf/\nBK4IMknmJF3YX1Bx0H/tCqRypv/jhwyg9Zc3EMkM4IvKsb2AzNnDKhKGnY1qsEij\nlKcOgDZHv4cX6+7lvTDVjmt7W9VDtXGzi+yKyi8XrRkJPHwDIrMFkpdKkYMQe7v8\ncmBHFFPWfUgBOP+vPS8yd+BtN5ZgodJbj0rNbB0CgYAoLU42fqzXtWCf3e9yX8I1\nWMNRbkATmXs+iakrvVXmoAWZXRo9kLxWCobCAP1buN20TtqwlBIbun6eFzF/kxQY\nXC65SRpOX4ZtBFP7N1u2OT1fCIV0Ut1s/irDbp6e31KLYcxMMM6gmgH2knSdnM1u\n9aVASXS2EFN576GiL5H1Hg==\n-----END PRIVATE KEY-----\n",
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


      //final recToken = 'ddiCjn_fSl6GEkKFjl5qhQ:APA91bHy1DACxT0CKGPSS96d1pNO-QzRbLf07WdwtOK_Rw_AMWOvrF1t0AABwbviY4k56uvHb-yl48QErtjWi19IQkGMhxgV0b--HqnKAyWVGNYHMUT31FY';


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
        };

      }


    } catch (e) {
      print('error occured notifying');
    }
  }


}
