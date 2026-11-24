import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers/app_providers.dart';
import '../core/theme/pixel_theme.dart';
import '../core/utils/responsive.dart';
import '../models/savings_goal.dart';
import '../widgets/pixel_scaffold.dart';

class SavingsScreen extends ConsumerWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(savingsGoalsProvider);

    return PixelScaffold(
      showBackButton: true,
      currentTabIndex: -1,
      floatingActionButton: FloatingActionButton(
        backgroundColor: PixelColors.coinGold,
        foregroundColor: PixelColors.deepPurple,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: PixelColors.deepPurple, width: 2),
        ),
        onPressed: () => _showAddGoalDialog(context, ref),
        child: const Icon(Icons.add, size: 28),
      ),
      body: Column(
        children: [
          // Ribbon Header
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
                  Text('📦', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 8),
                  Text(
                    'PETI TABUNGAN MAHASISWA',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Goals List
          Expanded(
            child: goalsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: PixelColors.badgePurple),
              ),
              error: (err, _) => Center(
                child: Text('Error: $err', style: const TextStyle(color: PixelColors.redExpense)),
              ),
              data: (goals) {
                if (goals.isEmpty) {
                  return Center(
                    child: Container(
                      margin: const EdgeInsets.all(24),
                      padding: const EdgeInsets.all(24),
                      decoration: PixelDecorations.card(
                        color: PixelColors.cardParchment,
                        radius: 16,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🪙', style: TextStyle(fontSize: 36)),
                          const SizedBox(height: 12),
                          const Text(
                            'Belum Ada Peti Tabungan',
                            style: TextStyle(
                              color: PixelColors.textDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Buat target tabungan pertamamu untuk memotivasi menyisihkan uang saku!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: PixelColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 14),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: PixelColors.coinGold,
                              foregroundColor: PixelColors.textDark,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: PixelColors.deepPurple, width: 2),
                              ),
                            ),
                            onPressed: () => _showAddGoalDialog(context, ref),
                            child: const Text('Buat Target Tabungan 📦', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    80,
                  ),
                  itemCount: goals.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final goal = goals[index];
                    return _PixelSavingsCard(goal: goal);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final targetController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: PixelColors.cardParchment,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: PixelColors.deepPurple, width: 2),
        ),
        title: const Text(
          '📦 Target Tabungan Baru',
          style: TextStyle(color: PixelColors.textDark, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: const TextStyle(color: PixelColors.textDark, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'Nama Target (contoh: HP Baru / Buku)',
                hintStyle: const TextStyle(color: PixelColors.textMuted),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: PixelColors.deepPurple, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: targetController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: PixelColors.textDark, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'Target Jumlah (Rp)',
                hintStyle: const TextStyle(color: PixelColors.textMuted),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: PixelColors.deepPurple, width: 1.5),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: PixelColors.textMuted, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: PixelColors.coinGold,
              foregroundColor: PixelColors.textDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: PixelColors.deepPurple, width: 1.5),
              ),
            ),
            onPressed: () {
              final title = titleController.text.trim();
              final target = int.tryParse(targetController.text.replaceAll(RegExp(r'[^0-9]'), ''));
              if (title.isNotEmpty && target != null && target > 0) {
                final newGoal = SavingsGoal(
                  title: title,
                  targetAmount: target,
                  savedAmount: 0,
                  createdAt: DateTime.now().toIso8601String(),
                );
                ref.read(savingsGoalsProvider.notifier).addGoal(newGoal);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Simpan Target', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _PixelSavingsCard extends ConsumerWidget {
  final SavingsGoal goal;

  const _PixelSavingsCard({required this.goal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = goal.progressPercentage;
    final percentInt = (progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: PixelDecorations.card(
        color: PixelColors.cardParchment,
        radius: 14,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: PixelColors.coinGold.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: PixelColors.coinGold, width: 1.5),
                    ),
                    child: const Text('📦', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    goal.title,
                    style: const TextStyle(
                      color: PixelColors.textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: PixelColors.badgePurple,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: PixelColors.deepPurple, width: 1),
                ),
                child: Text(
                  '$percentInt%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress Bar
          Container(
            height: 10,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: PixelColors.deepPurple, width: 1.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.transparent,
                valueColor: const AlwaysStoppedAnimation<Color>(PixelColors.coinGold),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Amount Details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Terkumpul: Rp ${_formatNumber(goal.savedAmount)}',
                style: const TextStyle(color: PixelColors.greenSuccess, fontSize: 11, fontWeight: FontWeight.bold),
              ),
              Text(
                'Target: Rp ${_formatNumber(goal.targetAmount)}',
                style: const TextStyle(color: PixelColors.textMuted, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Setor Button
          InkWell(
            onTap: () => _showDepositDialog(context, ref),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: PixelDecorations.button(
                color: PixelColors.coinGold,
                radius: 10,
              ),
              alignment: Alignment.center,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 16, color: PixelColors.deepPurple),
                  SizedBox(width: 4),
                  Text(
                    'Simpan Setoran',
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
        ],
      ),
    );
  }

  void _showDepositDialog(BuildContext context, WidgetRef ref) {
    final depositController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: PixelColors.cardParchment,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: PixelColors.deepPurple, width: 2),
        ),
        title: Text(
          'Setor ke: ${goal.title}',
          style: const TextStyle(color: PixelColors.textDark, fontSize: 15, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: depositController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: PixelColors.textDark, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: 'Jumlah Uang Setoran (Rp)',
            hintStyle: const TextStyle(color: PixelColors.textMuted),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: PixelColors.deepPurple, width: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: PixelColors.textMuted, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: PixelColors.coinGold,
              foregroundColor: PixelColors.textDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: PixelColors.deepPurple, width: 1.5),
              ),
            ),
            onPressed: () async {
              final amount = int.tryParse(depositController.text.replaceAll(RegExp(r'[^0-9]'), ''));
              if (amount != null && amount > 0) {
                await ref.read(walletSummaryProvider.notifier).depositSavings(goal.id!, amount);
                ref.read(savingsGoalsProvider.notifier).loadGoals();
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Setor Sekarang', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  static String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
