import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/subjects.dart';

class LocalNotificationService{
  LocalNotificationService();

  var flutterLocalNotPlugin=FlutterLocalNotificationsPlugin();

  final BehaviorSubject<String?> onNotificationClick= BehaviorSubject();

  Future<void>intialize()async{

    /*flutterLocalNotPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestPermission();*/

    const AndroidInitializationSettings androidInitializationSettings=AndroidInitializationSettings('ic_stat_add_alert');

    final InitializationSettings initializationSettings=InitializationSettings(android: androidInitializationSettings);

    await flutterLocalNotPlugin.initialize(initializationSettings,onSelectNotification: onSelectNotification);
  }

  void onDidReceiveLocalNotification(int id, String? title, String? body, String? payload) {
    print("ID $id");
  }


  void onSelectNotification(String? payload) {
    print("Payload $payload");
    if(payload!=null && payload.isNotEmpty){
      onNotificationClick.add(payload);
    }
  }

  Future<NotificationDetails> _notificationDetails()async{
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails('channel_id', 'channel_name',
      channelDescription: 'description',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,);

    return const NotificationDetails(android: androidNotificationDetails);
  }

  Future<void> showNotification({required int id,required String title,required String body})async{
    final details=await _notificationDetails();
    await flutterLocalNotPlugin.show(id, title, body,details);
  }

  Future<void> showPayloadNotification({required int id,required String title,required String body,required String payload})async{
    final details=await _notificationDetails();
    await flutterLocalNotPlugin.show(id, title, body,details,payload: payload);
  }
}