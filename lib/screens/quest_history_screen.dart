import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/providers/app_providers.dart';
import '../core/theme/app_theme.dart';
import '../models/quest.dart';

class QuestHistoryScreen extends ConsumerStatefulWidget {
  const QuestHistoryScreen({super.key});

  @override
  ConsumerState<QuestHistoryScreen> createState() => _QuestHistoryScreenState();
}

class _QuestHistoryScreenState extends ConsumerState<QuestHistoryScreen> {
  String _selectedFilter = 'Semua'; // 'Semua', 'Hari Ini', 'Minggu Ini', 'Bulan Ini'

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(questStatsProvider);
    final historyAsync = ref.watch(questHistoryProvider(_selectedFilter));

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              children: [
                // --- 1. CONTEXTUAL HEADER ---
                Container(
                  color: AppColors.surfaceNav,
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
                        'Riwayat & Statistik',
                        style: GoogleFonts.boogaloo(
                          fontSize: 26,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 38), // Balance spacer
                    ],
                  ),
                ),

                // --- 2. SCROLLABLE CONTENT ---
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Top Summary KPIs
                        statsAsync.when(
                          loading: () => const SizedBox(height: 70),
                          error: (err, _) => const SizedBox.shrink(),
                          data: (stats) {
                            final total = stats['total_completed'] ?? 0;
                            final coins = stats['total_coins'] ?? 0;
                            final focusMins = stats['total_focus_minutes'] ?? 0;

                            return Row(
                              children: [
                                Expanded(
                                  child: _buildKpiCard(
                                    icon: Icons.task_alt,
                                    iconColor: AppColors.primary,
                                    value: '$total',
                                    label: 'Selesai',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildKpiCard(
                                    icon: Icons.monetization_on,
                                    iconColor: AppColors.accent,
                                    value: '$coins',
                                    label: 'Total Coin',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildKpiCard(
                                    icon: Icons.timer,
                                    iconColor: AppColors.secondary,
                                    value: '${focusMins}m',
                                    label: 'Fokus',
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 14),

                        // Weekly Completion Chart Card
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: Border.all(color: AppColors.outline, width: 2),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x334E2F1B),
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
                                  Text(
                                    'Quest Selesai Mingguan',
                                    style: GoogleFonts.capriola(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.accentContainer,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: AppColors.outline, width: 1),
                                    ),
                                    child: Text(
                                      'Aktivitas 7 Hari',
                                      style: GoogleFonts.splineSansMono(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.onAccentContainer,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Bar Chart Row (Sen s/d Min)
                              SizedBox(
                                height: 90,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    _buildBarCol('Sen', 0.6, AppColors.primary),
                                    _buildBarCol('Sel', 0.9, AppColors.success),
                                    _buildBarCol('Rab', 0.5, AppColors.primary),
                                    _buildBarCol('Kam', 0.75, AppColors.secondary),
                                    _buildBarCol('Jum', 0.85, AppColors.success),
                                    _buildBarCol('Sab', 0.4, AppColors.accent),
                                    _buildBarCol('Min', 0.65, AppColors.primary),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Filter Tabs: Semua | Hari Ini | Minggu Ini | Bulan Ini
                        Row(
                          children: [
                            _buildFilterTab('Semua'),
                            const SizedBox(width: 6),
                            _buildFilterTab('Hari Ini'),
                            const SizedBox(width: 6),
                            _buildFilterTab('Minggu Ini'),
                            const SizedBox(width: 6),
                            _buildFilterTab('Bulan Ini'),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // History List
                        historyAsync.when(
                          loading: () => const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: CircularProgressIndicator(color: AppColors.primary),
                            ),
                          ),
                          error: (err, _) => Center(child: Text('Error: $err')),
                          data: (historyList) {
                            if (historyList.isEmpty) {
                              return Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.outline, width: 2),
                                ),
                                child: Center(
                                  child: Text(
                                    'Belum ada riwayat untuk filter $_selectedFilter.',
                                    style: GoogleFonts.capriola(
                                      fontSize: 13,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                ),
                              );
                            }

                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: historyList.length,
                              separatorBuilder: (ctx, index) => const SizedBox(height: 10),
                              itemBuilder: (ctx, i) {
                                final h = historyList[i];
                                return _buildHistoryItem(h);
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outline, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x334E2F1B),
            offset: Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.splineSansMono(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.capriola(
              fontSize: 10,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarCol(String day, double heightFactor, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 22,
          height: 60 * heightFactor,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            border: Border.all(color: AppColors.outline, width: 1.5),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          day,
          style: GoogleFonts.capriola(
            fontSize: 10,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTab(String label) {
    final isSelected = _selectedFilter == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.secondary : AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.outline, width: 1.5),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.capriola(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : AppColors.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(QuestHistory history) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outline, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x334E2F1B),
            offset: Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.outline, width: 1.5),
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  history.title,
                  style: GoogleFonts.capriola(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  history.focusMinutes > 0
                      ? '${history.completedAt.split('T').first} • Fokus ${history.focusMinutes}m (+20%)'
                      : '${history.completedAt.split('T').first} • Selesai Tepat Waktu',
                  style: GoogleFonts.capriola(
                    fontSize: 10,
                    color: AppColors.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+${history.xpEarned} XP',
                style: GoogleFonts.splineSansMono(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                '+${history.coinEarned} Coin',
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
    );
  }
}
