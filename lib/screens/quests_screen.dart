import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers/app_providers.dart';
import '../core/utils/responsive.dart';
import '../models/quest.dart';

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

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: const Text(
          'Papan Quest',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white70),
            onPressed: () => _showHistoryModal(context),
          ),
        ],
      ),
      body: ResponsiveWrapper(
        child: Column(
          children: [
            // Category Filter Pills
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: const Color(0xFF1E293B),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
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
                    _filterChip('Bertimer', 'timed'),
                  ],
                ),
              ),
            ),

            // Quests List
            Expanded(
              child: questsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6))),
                error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
                data: (quests) {
                  final filtered = quests.where((q) {
                    if (_selectedCategory == 'all') return true;
                    if (_selectedCategory == 'timed') return q.isTimed;
                    return q.category == _selectedCategory;
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text(
                        'Belum ada misi pada kategori ini.\nTekan + untuk menambahkan!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: EdgeInsets.all(Responsive.px(context, 16)),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final quest = filtered[index];
                      return _QuestCard(quest: quest);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF8B5CF6),
        foregroundColor: Colors.white,
        onPressed: () => _showAddQuestDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _filterChip(String label, String categoryKey) {
    final isSelected = _selectedCategory == categoryKey;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) {
          setState(() => _selectedCategory = categoryKey);
        }
      },
      selectedColor: const Color(0xFF8B5CF6),
      backgroundColor: const Color(0xFF334155),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.white70,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
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
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Tambah Misi Baru',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: titleController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Nama Misi (contoh: Belajar Matematika)',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: category,
                      dropdownColor: const Color(0xFF0F172A),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: const InputDecoration(labelText: 'Kategori', labelStyle: TextStyle(color: Colors.white60)),
                      items: const [
                        DropdownMenuItem(value: 'daily', child: Text('Harian')),
                        DropdownMenuItem(value: 'weekly', child: Text('Mingguan')),
                        DropdownMenuItem(value: 'epic', child: Text('Epik')),
                      ],
                      onChanged: (val) => setModalState(() => category = val ?? 'daily'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: difficulty,
                      dropdownColor: const Color(0xFF0F172A),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: const InputDecoration(labelText: 'Tingkat', labelStyle: TextStyle(color: Colors.white60)),
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
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Quest Bertimer (Mode Fokus)', style: TextStyle(color: Colors.white, fontSize: 13)),
                value: isTimed,
                activeColor: const Color(0xFF8B5CF6),
                onChanged: (v) => setModalState(() => isTimed = v),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                child: const Text('Simpan Misi', style: TextStyle(fontWeight: FontWeight.bold)),
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
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Riwayat Misi Selesai',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: history.isEmpty
                  ? const Center(child: Text('Belum ada riwayat.', style: TextStyle(color: Colors.white54)))
                  : ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (context, i) {
                        final h = history[i];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.check_circle, color: Color(0xFF10B981)),
                          title: Text(h.title, style: const TextStyle(color: Colors.white, fontSize: 13)),
                          subtitle: Text(
                            '+${h.xpEarned} XP  |  +${h.coinEarned} Koin',
                            style: const TextStyle(color: Color(0xFFFBBF24), fontSize: 11),
                          ),
                          trailing: Text(
                            h.completedAt.split('T').first,
                            style: const TextStyle(color: Colors.white38, fontSize: 11),
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

class _QuestCard extends ConsumerWidget {
  final Quest quest;

  const _QuestCard({required this.quest});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: quest.isCompleted ? const Color(0xFF10B981).withOpacity(0.5) : const Color(0xFF334155),
        ),
      ),
      child: Row(
        children: [
          // Checkbox complete
          GestureDetector(
            onTap: quest.isCompleted
                ? null
                : () {
                    ref.read(questsProvider.notifier).completeQuest(quest.id!);
                    ref.read(heroProfileProvider.notifier).loadProfile();
                  },
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: quest.isCompleted ? const Color(0xFF10B981) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: quest.isCompleted ? const Color(0xFF10B981) : const Color(0xFF8B5CF6),
                  width: 2,
                ),
              ),
              child: quest.isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : null,
            ),
          ),
          const SizedBox(width: 14),

          // Title & Rewards
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quest.title,
                  style: TextStyle(
                    color: quest.isCompleted ? Colors.white38 : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    decoration: quest.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '+${quest.xpReward} XP',
                        style: const TextStyle(color: Color(0xFFA78BFA), fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '+${quest.coinReward} Koin',
                        style: const TextStyle(color: Color(0xFFFBBF24), fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (quest.isTimed) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${quest.durationMinutes}m ⏱',
                          style: const TextStyle(color: Color(0xFF60A5FA), fontSize: 10),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Action if timed
          if (quest.isTimed && !quest.isCompleted)
            IconButton(
              icon: const Icon(Icons.play_circle_fill, color: Color(0xFF3B82F6), size: 30),
              onPressed: () => Navigator.pushNamed(context, '#timed-quest'),
            ),
        ],
      ),
    );
  }
}
