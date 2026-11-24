import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../core/providers/app_providers.dart';
import '../core/theme/app_theme.dart';
import '../models/quest.dart';

class TimedQuestScreen extends ConsumerStatefulWidget {
  final Quest? quest;

  const TimedQuestScreen({
    super.key,
    this.quest,
  });

  @override
  ConsumerState<TimedQuestScreen> createState() => _TimedQuestScreenState();
}

class _TimedQuestScreenState extends ConsumerState<TimedQuestScreen> {
  late int _totalSeconds;
  late int _remainingSeconds;
  Timer? _timer;
  bool _isRunning = false;

  // Music Player State
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isMusicOn = true;
  String _selectedTrack = 'Lo-Fi Hujan';
  double _volume = 0.65;

  String? _feedbackMessage;

  @override
  void initState() {
    super.initState();
    final duration = widget.quest?.durationMinutes ?? 25;
    _totalSeconds = duration * 60;
    _remainingSeconds = _totalSeconds;
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      await _audioPlayer.setVolume(_volume);
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    } catch (_) {}
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      setState(() => _isRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds > 0) {
          setState(() {
            _remainingSeconds--;
          });
        } else {
          timer.cancel();
          setState(() => _isRunning = false);
        }
      });
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = _totalSeconds;
      _isRunning = false;
    });
  }

  Future<void> _handleCompleteQuest() async {
    _timer?.cancel();
    setState(() => _isRunning = false);

    final questId = widget.quest?.id;
    final elapsedSeconds = _totalSeconds - _remainingSeconds;
    final focusMinutes = (elapsedSeconds / 60).ceil();

    if (questId != null) {
      await ref.read(questsProvider.notifier).completeQuest(
        questId,
        focusMinutes: focusMinutes > 0 ? focusMinutes : 1,
        hasTimerBonus: true,
      );
      await ref.read(heroProfileProvider.notifier).loadProfile();
    }

    final rawXp = widget.quest?.xpReward ?? 100;
    final bonusXp = (rawXp * 1.20).round();
    final coins = widget.quest?.coinReward ?? 60;

    setState(() {
      _feedbackMessage = 'Quest selesai tepat waktu! +$bonusXp XP & +$coins Coin diraih! 🎉';
    });
  }

  String _formatTime(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_totalSeconds > 0)
        ? (_remainingSeconds / _totalSeconds).clamp(0.0, 1.0)
        : 0.0;

    final questTitle = widget.quest?.title ?? 'Kumpulkan Tugas PBO';
    final questDiff = widget.quest?.difficulty ?? 'Hard';
    final questXp = widget.quest?.xpReward ?? 100;
    final questCoin = widget.quest?.coinReward ?? 60;

    return Scaffold(
      backgroundColor: AppColors.surfaceNav,
      body: Stack(
        children: [
          // Background Cozy Focus Art
          Positioned.fill(
            child: Image.asset(
              'assets/images/cozy_focus_bg.jpg',
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) => Container(
                color: const Color(0xFF2A1745),
              ),
            ),
          ),
          // Darker overlay for contrast
          Positioned.fill(
            child: Container(
              color: AppColors.surfaceNav.withValues(alpha: 0.55),
            ),
          ),

          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  children: [
                    // --- 1. CONTEXTUAL HEADER ---
                    Container(
                      color: AppColors.surfaceNav.withValues(alpha: 0.95),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.outline, width: 2),
                                boxShadow: const [
                                  BoxShadow(
                                    color: AppColors.outline,
                                    offset: Offset(0, 2),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                            ),
                          ),
                          Text(
                            'Mode Fokus',
                            style: GoogleFonts.boogaloo(
                              fontSize: 26,
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.outline, width: 1.5),
                            ),
                            child: Text(
                              'TIMED',
                              style: GoogleFonts.capriola(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --- 2. MAIN RELAXING FOCUS STAGE ---
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Active Timed Quest Info Card
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(AppRadius.lg),
                                border: Border.all(color: AppColors.outline, width: 2),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x474E2F1B),
                                    offset: Offset(0, 4),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceContainer,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: AppColors.outline, width: 2),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: Image.asset(
                                      'assets/images/karakter_hero_hoodie_ungu.jpg',
                                      fit: BoxFit.cover,
                                      errorBuilder: (ctx, err, stack) => const Icon(
                                        Icons.person,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Quest Aktif',
                                              style: GoogleFonts.capriola(
                                                fontSize: 10,
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                              decoration: BoxDecoration(
                                                color: AppColors.error,
                                                borderRadius: BorderRadius.circular(4),
                                                border: Border.all(color: AppColors.outline, width: 1),
                                              ),
                                              child: Text(
                                                questDiff.toUpperCase(),
                                                style: GoogleFonts.capriola(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          questTitle,
                                          style: GoogleFonts.capriola(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.onSurface,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              '+$questXp XP',
                                              style: GoogleFonts.splineSansMono(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.onSurface,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '+$questCoin Coin',
                                              style: GoogleFonts.splineSansMono(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.accent,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Centered Cozy Pixel Timer Card
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceNav.withValues(alpha: 0.95),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: AppColors.outline, width: 2),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x55000000),
                                    offset: Offset(0, 6),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(9999),
                                      border: Border.all(color: AppColors.outline, width: 1.5),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.timer, color: AppColors.accent, size: 14),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Sisa Waktu Pengerjaan',
                                          style: GoogleFonts.capriola(
                                            fontSize: 11,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // Digital Display
                                  Text(
                                    _formatTime(_remainingSeconds),
                                    style: GoogleFonts.splineSansMono(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  // Progress Bar
                                  Container(
                                    height: 14,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(9999),
                                      border: Border.all(color: AppColors.outline, width: 2),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: progress,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.accent,
                                          borderRadius: BorderRadius.circular(9999),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  Text(
                                    'Fokus santai · Bonus +20% XP jika selesai tepat waktu',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.capriola(
                                      fontSize: 10,
                                      color: AppColors.outlineVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Timer Controls
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: _toggleTimer,
                                          icon: Icon(
                                            _isRunning ? Icons.pause : Icons.play_arrow,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          label: Text(
                                            _isRunning ? 'Jeda' : (_remainingSeconds < _totalSeconds ? 'Lanjut' : 'Mulai'),
                                            style: GoogleFonts.capriola(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.secondary,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                              side: const BorderSide(color: AppColors.outline, width: 2),
                                            ),
                                            elevation: 0,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: _resetTimer,
                                          icon: const Icon(Icons.restart_alt, color: Colors.white, size: 20),
                                          label: Text(
                                            'Reset',
                                            style: GoogleFonts.capriola(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                              side: const BorderSide(color: AppColors.outline, width: 2),
                                            ),
                                            elevation: 0,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Pengaturan Musik Fokus
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(AppRadius.lg),
                                border: Border.all(color: AppColors.outline, width: 2),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x474E2F1B),
                                    offset: Offset(0, 4),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.music_note, color: AppColors.primary, size: 22),
                                          const SizedBox(width: 8),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Musik Fokus',
                                                style: GoogleFonts.capriola(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.onSurface,
                                                ),
                                              ),
                                              Text(
                                                _isMusicOn
                                                    ? 'Sedang diputar: $_selectedTrack'
                                                    : 'Musik dijeda',
                                                style: GoogleFonts.capriola(
                                                  fontSize: 10,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() => _isMusicOn = !_isMusicOn);
                                        },
                                        child: Container(
                                          width: 52,
                                          height: 28,
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            color: _isMusicOn ? AppColors.success : AppColors.surfaceContainerHigh,
                                            borderRadius: BorderRadius.circular(9999),
                                            border: Border.all(color: AppColors.outline, width: 2),
                                          ),
                                          child: Align(
                                            alignment: _isMusicOn ? Alignment.centerRight : Alignment.centerLeft,
                                            child: Container(
                                              width: 20,
                                              height: 20,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                                border: Border.all(color: AppColors.outline, width: 1.5),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Track Buttons Grid
                                  Row(
                                    children: [
                                      _buildTrackBtn('Lo-Fi Hujan', Icons.grain),
                                      const SizedBox(width: 6),
                                      _buildTrackBtn('8-Bit Santai', Icons.videogame_asset),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      _buildTrackBtn('Kafe Malam', Icons.local_cafe),
                                      const SizedBox(width: 6),
                                      _buildTrackBtn('File MP3', Icons.audio_file),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  // Volume Slider
                                  Row(
                                    children: [
                                      const Icon(Icons.volume_up, color: AppColors.primary, size: 18),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Volume',
                                        style: GoogleFonts.capriola(fontSize: 11, color: AppColors.onSurface),
                                      ),
                                      Expanded(
                                        child: Slider(
                                          value: _volume,
                                          min: 0.0,
                                          max: 1.0,
                                          activeColor: AppColors.primary,
                                          onChanged: (val) {
                                            setState(() => _volume = val);
                                            _audioPlayer.setVolume(val);
                                          },
                                        ),
                                      ),
                                      Text(
                                        '${(_volume * 100).round()}%',
                                        style: GoogleFonts.splineSansMono(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Feedback Banner
                            if (_feedbackMessage != null) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.accentContainer,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.outline, width: 2),
                                ),
                                child: Text(
                                  _feedbackMessage!,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.capriola(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onAccentContainer,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                            ],

                            // Complete Quest Now CTA
                            ElevatedButton.icon(
                              onPressed: _handleCompleteQuest,
                              icon: const Icon(Icons.check_circle, color: Colors.white, size: 22),
                              label: Text(
                                'Selesaikan Quest',
                                style: GoogleFonts.capriola(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(color: AppColors.outline, width: 2),
                                ),
                                elevation: 0,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackBtn(String title, IconData icon) {
    final isSelected = _selectedTrack == title;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTrack = title;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accentContainer : AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.outline : AppColors.outlineVariant,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: AppColors.onSurface),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.capriola(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
