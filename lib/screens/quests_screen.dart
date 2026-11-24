import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers/app_providers.dart';
import '../core/router/app_router.dart';
import '../core/theme/pixel_theme.dart';
import '../core/utils/responsive.dart';
import '../models/quest.dart';
import '../widgets/pixel_scaffold.dart';

class QuestsScreen extends ConsumerStatefulWidget {
  const QuestsScreen({super.key});

  @override
  ConsumerState<QuestsScreen> createState() => _QuestsScreenState();
}

class _QuestsScreenState extends ConsumerState<QuestsScreen> {
  String _selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    final questsAsync = ref.watch(questsProvider);
    final heroAsync = ref.watch(heroProfileProvider);

    return PixelScaffold(
      currentTabIndex: 1,
      floatingActionButton: FloatingActionButton(
        backgroundColor: PixelColors.coinGold,
        foregroundColor: PixelColors.deepPurple,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: PixelColors.deepPurple, width: 2),
        ),
        onPressed: () => _showAddQuestDialog(context),
        child: const Icon(Icons.add, size: 28),
      ),
      body: Column(
        children: [
          // ==========================================
          // 1. RIBBON BANNER HEADER ("PAPAN MISI HARIAN")
          // ==========================================
          Padding(
            padding: EdgeInsets.fromLTRB(
              Responsive.px(context, 14),
              12,
              Responsive.px(context, 14),
              8,
            ),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: PixelColors.badgePurple,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: PixelColors.deepPurple, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x334A2E70),
                    offset: Offset(0, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('⚔️', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 8),
                  Text(
                    'PAPAN MISI HARIAN',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text('⚔️', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),

          // ==========================================
          // 2. CATEGORY FILTER TABS
          // ==========================================
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: Responsive.px(context, 14), vertical: 4),
            child: Row(
              children: [
                _filterChip('Semua', 'all'),
                const SizedBox(width: 8),
                _filterChip('Harian', 'daily'),
                const SizedBox(width: 8),
                _filterChip('Mingguan', 'weekly'),
                const SizedBox(width: 8),
                _filterChip('Epik', 'epic'),
                const SizedBox(width: 8),
                _filterChip('Fokus ⏱', 'timed'),
              ],
            ),
          ),

          // ==========================================
          // 3. STREAK BANNER
          // ==========================================
          heroAsync.maybeWhen(
            data: (hero) => Padding(
              padding: EdgeInsets.fromLTRB(
                Responsive.px(context, 14),
                6,
                Responsive.px(context, 14),
                6,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: PixelColors.cardParchmentGold,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: PixelColors.deepPurple, width: 1.5),
                ),
                child: Row(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Streak: ${hero.streakDays} Hari Berturut-turut! (+20% XP)',
                        style: const TextStyle(
                          color: PixelColors.textDark,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            orElse: () => const SizedBox.shrink(),
          ),

          // ==========================================
          // 4. QUESTS LIST
          // ==========================================
          Expanded(
            child: questsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: PixelColors.badgePurple),
              ),
              error: (err, _) => Center(
                child: Text('Error: $err', style: const TextStyle(color: PixelColors.redExpense)),
              ),
              data: (quests) {
                final filtered = quests.where((q) {
                  if (_selectedCategory == 'all') return true;
                  if (_selectedCategory == 'timed') return q.isTimed;
                  return q.category == _selectedCategory;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Container(
                      margin: const EdgeInsets.all(24),
                      padding: const EdgeInsets.all(20),
                      decoration: PixelDecorations.card(
                        color: PixelColors.cardParchment,
                        radius: 16,
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('📜', style: TextStyle(fontSize: 32)),
                          SizedBox(height: 10),
                          Text(
                            'Belum ada misi pada kategori ini.',
                            style: TextStyle(
                              color: PixelColors.textDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Tekan tombol (+) kuning di bawah untuk menambah misi baru!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: PixelColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.fromLTRB(
                    Responsive.px(context, 14),
                    6,
                    Responsive.px(context, 14),
                    80, // Space for FAB
                  ),
                  itemCount: filtered.length + 1, // +1 for History link at bottom
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    if (index == filtered.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: InkWell(
                          onTap: () => _showHistoryModal(context),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: PixelDecorations.button(
                              color: PixelColors.cardParchment,
                              radius: 12,
                            ),
                            alignment: Alignment.center,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.history_edu_rounded, size: 16, color: PixelColors.badgePurple),
                                SizedBox(width: 6),
                                Text(
                                  'Lihat Riwayat & Statistik Quest',
                                  style: TextStyle(
                                    color: PixelColors.textDark,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    final quest = filtered[index];
                    return _PixelQuestCard(quest: quest);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String categoryKey) {
    final isSelected = _selectedCategory == categoryKey;

    return InkWell(
      onTap: () => setState(() => _selectedCategory = categoryKey),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? PixelColors.badgePurple : PixelColors.cardParchment,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: PixelColors.deepPurple, width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : PixelColors.textDark,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  void _showAddQuestDialog(BuildContext context) {
    final titleController = TextEditingController();
    String category = 'daily';
    String difficulty = 'normal';
    int xp = 50;
    int coins = 30;
    bool isTimed = false;
    int duration = 25;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          decoration: BoxDecoration(
            color: PixelColors.cardParchment,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: PixelColors.deepPurple, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '⚔️ Tambah Misi Baru',
                    style: TextStyle(
                      color: PixelColors.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: PixelColors.deepPurple),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleController,
                style: const TextStyle(color: PixelColors.textDark, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: 'Nama Misi (contoh: Belajar Kalkulus)',
                  hintStyle: const TextStyle(color: PixelColors.textMuted),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: PixelColors.deepPurple, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: PixelColors.deepPurple, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: PixelColors.badgePurple, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: category,
                      dropdownColor: PixelColors.cardParchment,
                      style: const TextStyle(color: PixelColors.textDark, fontSize: 13, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        labelText: 'Kategori',
                        labelStyle: const TextStyle(color: PixelColors.textMuted),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: PixelColors.deepPurple, width: 1.5),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'daily', child: Text('Harian')),
                        DropdownMenuItem(value: 'weekly', child: Text('Mingguan')),
                        DropdownMenuItem(value: 'epic', child: Text('Epik')),
                      ],
                      onChanged: (val) => setModalState(() => category = val ?? 'daily'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: difficulty,
                      dropdownColor: PixelColors.cardParchment,
                      style: const TextStyle(color: PixelColors.textDark, fontSize: 13, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        labelText: 'Tingkat',
                        labelStyle: const TextStyle(color: PixelColors.textMuted),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: PixelColors.deepPurple, width: 1.5),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'easy', child: Text('Mudah')),
                        DropdownMenuItem(value: 'normal', child: Text('Normal')),
                        DropdownMenuItem(value: 'hard', child: Text('Sulit')),
                      ],
                      onChanged: (val) {
                        setModalState(() {
                          difficulty = val ?? 'normal';
                          if (difficulty == 'easy') {
                            xp = 30;
                            coins = 20;
                          } else if (difficulty == 'normal') {
                            xp = 50;
                            coins = 30;
                          } else {
                            xp = 100;
                            coins = 60;
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: PixelColors.deepPurple, width: 1.5),
                ),
                child: SwitchListTile(
                  title: const Text(
                    'Quest Bertimer (Mode Fokus)',
                    style: TextStyle(color: PixelColors.textDark, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'Gunakan timer pomodoro & countdown',
                    style: TextStyle(color: PixelColors.textMuted, fontSize: 11),
                  ),
                  value: isTimed,
                  activeColor: PixelColors.badgePurple,
                  onChanged: (v) => setModalState(() => isTimed = v),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: PixelColors.coinGold,
                  foregroundColor: PixelColors.textDark,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: PixelColors.deepPurple, width: 2),
                  ),
                  elevation: 2,
                ),
                onPressed: () {
                  if (titleController.text.trim().isEmpty) return;
                  final newQuest = Quest(
                    title: titleController.text.trim(),
                    category: category,
                    difficulty: difficulty,
                    xpReward: xp,
                    coinReward: coins,
                    isTimed: isTimed,
                    durationMinutes: duration,
                    createdAt: DateTime.now().toIso8601String(),
                  );
                  ref.read(questsProvider.notifier).addQuest(newQuest);
                  Navigator.pop(ctx);
                },
                child: const Text('Simpan Misi Baru ⚔️', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHistoryModal(BuildContext context) async {
    final history = await ref.read(questDaoProvider).getQuestHistory();

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: PixelColors.cardParchment,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: PixelColors.deepPurple, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '📜 Riwayat Misi Selesai',
                  style: TextStyle(
                    color: PixelColors.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: PixelColors.deepPurple),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: history.isEmpty
                  ? const Center(
                      child: Text(
                        'Belum ada riwayat misi yang selesai.',
                        style: TextStyle(color: PixelColors.textMuted),
                      ),
                    )
                  : ListView.separated(
                      itemCount: history.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final h = history[i];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: PixelColors.deepPurple, width: 1.5),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: PixelColors.greenSuccess, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      h.title,
                                      style: const TextStyle(
                                        color: PixelColors.textDark,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      '+${h.xpEarned} XP  |  +${h.coinEarned} 🪙',
                                      style: const TextStyle(
                                        color: PixelColors.badgePurple,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                h.completedAt.split('T').first,
                                style: const TextStyle(color: PixelColors.textMuted, fontSize: 10),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PixelQuestCard extends ConsumerWidget {
  final Quest quest;

  const _PixelQuestCard({required this.quest});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDone = quest.isCompleted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: PixelDecorations.card(
        color: isDone ? PixelColors.cardParchmentGold : PixelColors.cardParchment,
        radius: 12,
      ),
      child: Row(
        children: [
          // Pixel Checkbox
          GestureDetector(
            onTap: isDone
                ? null
                : () {
                    ref.read(questsProvider.notifier).completeQuest(quest.id!);
                    ref.read(heroProfileProvider.notifier).loadProfile();
                  },
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: isDone ? PixelColors.greenSuccess : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: PixelColors.deepPurple,
                  width: 2,
                ),
              ),
              child: isDone
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : null,
            ),
          ),
          const SizedBox(width: 12),

          // Title & Rewards
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quest.title,
                  style: TextStyle(
                    color: isDone ? PixelColors.textMuted : PixelColors.textDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    // XP Reward Chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: PixelColors.badgePurple,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: PixelColors.deepPurple, width: 1),
                      ),
                      child: Text(
                        '+${quest.xpReward} XP',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),

                    // Coin Reward Chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: PixelColors.coinGold,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: PixelColors.deepPurple, width: 1),
                      ),
                      child: Text(
                        '+${quest.coinReward} 🪙',
                        style: const TextStyle(
                          color: PixelColors.textDark,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),

                    if (quest.isTimed) ...[
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: PixelColors.blueFocus,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: PixelColors.deepPurple, width: 1),
                        ),
                        child: Text(
                          '${quest.durationMinutes}m ⏱',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Timed action button
          if (quest.isTimed && !isDone)
            IconButton(
              icon: const Icon(Icons.play_circle_fill_rounded, color: PixelColors.blueFocus, size: 28),
              onPressed: () => Navigator.pushNamed(context, AppRouter.timedQuest),
            ),
        ],
      ),
    );
  }
}
