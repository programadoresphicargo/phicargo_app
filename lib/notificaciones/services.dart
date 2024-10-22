import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:phicargo/Asignacion/inicio.dart';

// Instancia del package
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Este es el método que inicializa el objeto de notificaciones
Future<void> initNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings();

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

// Este es el método que muestra la notificación
Future<void> showNotificacion(String titulo, String mensaje) async {
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
    'your channel id',
    'your channel name',
    importance: Importance.max,
    priority: Priority.high,
  );

  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidNotificationDetails,
  );

  await flutterTts.setLanguage("es-MX");
  await flutterTts.setPitch(1);
  await flutterTts.speak(titulo + mensaje);

  await flutterLocalNotificationsPlugin.show(
      1, titulo, mensaje, notificationDetails);
}
