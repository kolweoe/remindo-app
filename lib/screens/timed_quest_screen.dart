import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/focus_timer_service.dart';
import '../core/utils/responsive.dart';

class TimedQuestScreen extends ConsumerStatefulWidget {
  const TimedQuestScreen({super.key});

  @override
  ConsumerState<TimedQuestScreen> createState() => _TimedQuestScreenState();
}

class _TimedQuestScreenState extends ConsumerState<TimedQuestScreen> {
  final FocusTimerService _timerService = FocusTimerService.instance;
  int _selectedMinutes = 25;
  bool _playMusic = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: const Text(
          'Mode Fokus Belajar',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: ResponsiveWrapper(
        child: ValueListenableBuilder<FocusTimerState>(
          valueListenable: _timerService.stateNotifier,
          builder: (context, state, _) {
            return ValueListenableBuilder<int>(
              valueListenable: _timerService.remainingSecondsNotifier,
              builder: (context, remainingSec, _) {
                final isRunning = state == FocusTimerState.running;
                final isPaused = state == FocusTimerState.paused;
                final isIdle = state == FocusTimerState.idle;

                final displaySeconds = isIdle ? _selectedMinutes * 60 : remainingSec;
                final minutes = displaySeconds ~/ 60;
                final seconds = displaySeconds % 60;
                final timeString =
                    '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

                return Padding(
                  padding: EdgeInsets.all(Responsive.px(context, 20)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Bonus XP info banner
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF8B5CF6)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bolt, color: Color(0xFFFBBF24), size: 18),
                            SizedBox(width: 6),
                            Text(
                              '+20% Bonus XP untuk Sesi Fokus Selesai!',
                              style: TextStyle(
                                color: Color(0xFFE9D5FF),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 36),

                      // Circular Timer Representation
                      Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF1E293B),
                          border: Border.all(
                            color: isRunning
                                ? const Color(0xFF10B981)
                                : const Color(0xFF8B5CF6),
                            width: 6,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (isRunning
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFF8B5CF6))
                                  .withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                timeString,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 44,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isRunning
                                    ? 'FOKUS BERJALAN'
                                    : (isPaused ? 'DIJEDA' : 'SIAP MULAI'),
                                style: TextStyle(
                                  color: isRunning
                                      ? const Color(0xFF10B981)
                                      : Colors.white54,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 36),

                      // Duration Selector (when idle)
                      if (isIdle) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [15, 25, 45, 60].map((mins) {
                            final isSel = _selectedMinutes == mins;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: ChoiceChip(
                                label: Text('${mins}m'),
                                selected: isSel,
                                onSelected: (_) => setState(() => _selectedMinutes = mins),
                                selectedColor: const Color(0xFF8B5CF6),
                                backgroundColor: const Color(0xFF1E293B),
                                labelStyle: TextStyle(
                                  color: isSel ? Colors.white : Colors.white70,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.music_note, color: Colors.white70, size: 18),
                            const SizedBox(width: 8),
                            const Text('Musik Fokus Lo-Fi', style: TextStyle(color: Colors.white70, fontSize: 13)),
                            Switch(
                              value: _playMusic,
                              activeColor: const Color(0xFF8B5CF6),
                              onChanged: (v) => setState(() => _playMusic = v),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Control Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isIdle)
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8B5CF6),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () {
                                _timerService.start(
                                  questId: 1,
                                  questTitle: 'Sesi Fokus $_selectedMinutes Menit',
                                  durationMinutes: _selectedMinutes,
                                  playMusic: _playMusic,
                                );
                              },
                              icon: const Icon(Icons.play_arrow_rounded, size: 24),
                              label: const Text('Mulai Fokus', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                            ),

                          if (isRunning) ...[
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF59E0B),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () => _timerService.pause(),
                              icon: const Icon(Icons.pause),
                              label: const Text('Jeda'),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.redAccent,
                                side: const BorderSide(color: Colors.redAccent),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () => _timerService.stop(),
                              icon: const Icon(Icons.stop),
                              label: const Text('Hentikan'),
                            ),
                          ],

                          if (isPaused) ...[
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () => _timerService.resume(),
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Lanjutkan'),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.redAccent,
                                side: const BorderSide(color: Colors.redAccent),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () => _timerService.stop(),
                              icon: const Icon(Icons.stop),
                              label: const Text('Batalkan'),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
