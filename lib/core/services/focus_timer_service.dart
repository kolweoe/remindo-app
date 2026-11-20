import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../db/quest_dao.dart';
import '../db/settings_dao.dart';

enum FocusTimerState { idle, running, paused, completed }

class FocusTimerService {
  static final FocusTimerService instance = FocusTimerService._internal();
  FocusTimerService._internal();

  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  final ValueNotifier<int> remainingSecondsNotifier = ValueNotifier<int>(0);
  final ValueNotifier<FocusTimerState> stateNotifier =
      ValueNotifier<FocusTimerState>(FocusTimerState.idle);

  int _activeQuestId = 0;
  int _totalDurationSeconds = 0;
  int _elapsedSeconds = 0;
  String _questTitle = 'Fokus Misi';

  int get remainingSeconds => remainingSecondsNotifier.value;
  int get elapsedSeconds => _elapsedSeconds;
  FocusTimerState get state => stateNotifier.value;
  int get activeQuestId => _activeQuestId;

  Future<void> start({
    required int questId,
    required String questTitle,
    required int durationMinutes,
    bool playMusic = true,
  }) async {
    _activeQuestId = questId;
    _questTitle = questTitle;
    _totalDurationSeconds = durationMinutes * 60;
    _elapsedSeconds = 0;
    remainingSecondsNotifier.value = _totalDurationSeconds;
    stateNotifier.value = FocusTimerState.running;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), _onTick);

    // Check setting for focus music
    final settingsDao = SettingsDao();
    final musicEnabled = (await settingsDao.getSetting('focus_music_enabled', defaultValue: 'true')) == 'true';

    if (playMusic && musicEnabled) {
      try {
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
        // Can be customized with custom focus track or bundled audio
        // await _audioPlayer.play(AssetSource('audio/focus_lofi.mp3'));
      } catch (_) {}
    }

    _updateNotification();
  }

  void _onTick(Timer timer) {
    if (remainingSecondsNotifier.value > 0) {
      remainingSecondsNotifier.value -= 1;
      _elapsedSeconds += 1;
      if (remainingSecondsNotifier.value % 60 == 0) {
        _updateNotification();
      }
    } else {
      finishTimer();
    }
  }

  void pause() {
    if (stateNotifier.value == FocusTimerState.running) {
      _timer?.cancel();
      stateNotifier.value = FocusTimerState.paused;
      _audioPlayer.pause();
      _updateNotification();
    }
  }

  void resume() {
    if (stateNotifier.value == FocusTimerState.paused) {
      stateNotifier.value = FocusTimerState.running;
      _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
      _audioPlayer.resume();
      _updateNotification();
    }
  }

  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
    stateNotifier.value = FocusTimerState.idle;
    remainingSecondsNotifier.value = 0;
    try {
      await _audioPlayer.stop();
    } catch (_) {}
    await _notifications.cancel(888);
  }

  Future<void> finishTimer() async {
    await stop();
    stateNotifier.value = FocusTimerState.completed;

    // Automatically complete quest in database with bonus
    final questDao = QuestDao();
    final focusMinutes = (_totalDurationSeconds / 60).round();
    await questDao.completeQuest(
      _activeQuestId,
      focusMinutes: focusMinutes,
      hasTimerBonus: true,
    );

    // Show completion notification
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'remindo_timer_complete',
      'Remindo Fokus Selesai',
      channelDescription: 'Notifikasi saat sesi fokus selesai',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );
    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await _notifications.show(
      889,
      'Selamat! Misi Selesai 🎉',
      'Kamu berhasil menyelesaikan "$_questTitle" selama $focusMinutes menit! +20% Bonus XP & Koin telah ditambahkan!',
      platformDetails,
    );
  }

  Future<void> _updateNotification() async {
    final minutes = remainingSecondsNotifier.value ~/ 60;
    final seconds = remainingSecondsNotifier.value % 60;
    final timeStr =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'remindo_timer_channel',
      'Remindo Mode Fokus',
      channelDescription: 'Penghitung waktu sesi fokus berjalan',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      onlyAlertOnce: true,
      showWhen: false,
    );

    final NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await _notifications.show(
      888,
      'Mode Fokus Berjalan: $_questTitle',
      'Sisa waktu: $timeStr',
      platformDetails,
      payload: 'focus_running',
    );
  }

  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
  }
}
