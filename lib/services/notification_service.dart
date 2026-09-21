import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/jornada.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(initSettings);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  Future<void> programarRecordatorioJornada(Jornada jornada) async {
    try {
      await init();

      final parts = jornada.fecha.split('-');
      if (parts.length != 3) return;
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);

      final jornadaDate = DateTime(year, month, day);
      final reminderDate = jornadaDate.subtract(const Duration(days: 1));
      final scheduledTime = DateTime(
        reminderDate.year,
        reminderDate.month,
        reminderDate.day,
        18,
        0,
      );

      final now = DateTime.now();
      if (scheduledTime.isBefore(now) || jornadaDate.isBefore(now) ||
          (jornadaDate.year == now.year && jornadaDate.month == now.month && jornadaDate.day == now.day)) {
        return;
      }

      final tzDateTime = tz.TZDateTime.from(scheduledTime, tz.local);

      const androidDetails = AndroidNotificationDetails(
        'recordatorios_jornadas_channel',
        'Recordatorios de Jornadas',
        channelDescription: 'Canal para recordatorios de jornadas comunitarias próximas',
        importance: Importance.max,
        priority: Priority.high,
      );

      const iosDetails = DarwinNotificationDetails();

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final notificationId = jornada.id.hashCode;

       await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        '¡Tu jornada es mañana!',
        '${jornada.titulo} — mañana a las ${jornada.hora} en ${jornada.direccionReferencia.isNotEmpty ? jornada.direccionReferencia : 'Punto de encuentro'}',
        tzDateTime,
        details,
        androidScheduleMode: AndroidScheduleMode.inexact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {}
  }

  Future<void> cancelarRecordatorio(String jornadaId) async {
    try {
      await init();
      await flutterLocalNotificationsPlugin.cancel(jornadaId.hashCode);
    } catch (_) {}
  }
}
