import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import '../db/settings_dao.dart';
import '../db/wallet_dao.dart';

class AlarmScheduler {
  static final AlarmScheduler instance = AlarmScheduler._internal();
  AlarmScheduler._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    if (Platform.isAndroid) {
      await AndroidAlarmManager.initialize();
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification click or action
      },
    );

    _isInitialized = true;
  }

  /// Schedule alarm for a quest with a specific time 'HH:mm'
  Future<void> scheduleQuestAlarm({
    required int questId,
    required String title,
    required String timeString, // Format 'HH:mm'
  }) async {
    try {
      final parts = timeString.split(':');
      if (parts.length != 2) return;
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;

      final now = DateTime.now();
      var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'remindo_quest_channel',
        'Remindo Quest Reminder',
        channelDescription: 'Pengingat misi dan alarm quest Remindo',
        importance: Importance.max,
        priority: Priority.high,
        fullScreenIntent: true,
        playSound: true,
      );

      const NotificationDetails platformDetails =
          NotificationDetails(android: androidDetails);

      // Using local notifications instant or periodic display
      await flutterLocalNotificationsPlugin.show(
        questId,
        'Misi Baru: $title',
        'Waktunya menyelesaikan misi dan kumpulkan XP & Koin!',
        platformDetails,
        payload: 'quest:$questId',
      );
    } catch (_) {}
  }

  /// Background entry point for financial notification evaluation
  @pragma('vm:entry-point')
  static Future<void> triggerFinancialReport() async {
    final settingsDao = SettingsDao();
    final walletDao = WalletDao();

    final settings = await settingsDao.getNotificationSettings();
    if (!settings.isEnabled) return;

    final summary = await walletDao.getFinancialSummary();
    final balance = summary['balance'] ?? 0;
    final income = summary['income'] ?? 0;
    final expense = summary['expense'] ?? 0;

    String body = settings.message;
    List<String> details = [];
    if (settings.includeIncome) details.add('Pemasukan: Rp $income');
    if (settings.includeExpense) details.add('Pengeluaran: Rp $expense');
    if (settings.includeBalance) details.add('Sisa Saldo: Rp $balance');
    if (details.isNotEmpty) {
      body = '$body\n${details.join(' | ')}';
    }

    final localNotif = FlutterLocalNotificationsPlugin();
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'remindo_wallet_channel',
      'Remindo Laporan Keuangan',
      channelDescription: 'Laporan keuangan dan uang saku Remindo',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await localNotif.show(
      999,
      settings.title,
      body,
      platformDetails,
      payload: 'wallet_report',
    );
  }

  /// Cancels an alarm for a quest
  Future<void> cancelQuestAlarm(int questId) async {
    await flutterLocalNotificationsPlugin.cancel(questId);
    if (Platform.isAndroid) {
      await AndroidAlarmManager.cancel(questId);
    }
  }
}
