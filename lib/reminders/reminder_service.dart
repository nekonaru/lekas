import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ReminderService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);
  }

  // TODO: implement timezone-aware scheduling (H-3, H-1, 3h, 30min)
  Future<void> schedule(int id, DateTime when, String title, String body) async {}

  Future<void> cancel(int id) async => _plugin.cancel(id);
}