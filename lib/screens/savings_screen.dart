import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers/app_providers.dart';
import '../core/utils/responsive.dart';
import '../models/savings_goal.dart';

class SavingsScreen extends ConsumerWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(savingsGoalsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: const Text(
          'Peti Tabungan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: ResponsiveWrapper(
        child: goalsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFF59E0B))),
          error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
          data: (goals) {
            if (goals.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.savings_outlined, color: Colors.white38, size: 64),
                    const SizedBox(height: 12),
                    const Text('Belum ada target tabungan.', style: TextStyle(color: Colors.white54)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B)),
                      onPressed: () => _showAddGoalDialog(context, ref),
                      child: const Text('Buat Target Tabungan', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: EdgeInsets.all(Responsive.px(context, 16)),
              itemCount: goals.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final goal = goals[index];
                return _SavingsCard(goal: goal);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFF59E0B),
        foregroundColor: Colors.white,
        onPressed: () => _showAddGoalDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final targetController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Target Tabungan Baru', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Nama Target (contoh: HP Baru)',
                hintStyle: TextStyle(color: Colors.white38),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: targetController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Target Jumlah (Rp)',
                hintStyle: TextStyle(color: Colors.white38),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B)),
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
            child: const Text('Buat Target', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _SavingsCard extends ConsumerWidget {
  final SavingsGoal goal;

  const _SavingsCard({required this.goal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = goal.progressPercentage;
    final percentInt = (progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155)),
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
                      color: const Color(0xFFF59E0B).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.savings, color: Color(0xFFF59E0B), size: 20),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    goal.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                '$percentInt%',
                style: const TextStyle(
                  color: Color(0xFFF59E0B),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFF0F172A),
              color: const Color(0xFFF59E0B),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 10),

          // Amount Details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Terkumpul: Rp ${goal.savedAmount}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                'Target: Rp ${goal.targetAmount}',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Setor Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => _showDepositDialog(context, ref),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Simpan Setoran', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
        backgroundColor: const Color(0xFF1E293B),
        title: Text('Setor Tabungan: ${goal.title}', style: const TextStyle(color: Colors.white, fontSize: 15)),
        content: TextField(
          controller: depositController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Jumlah Uang Setoran (Rp)',
            hintStyle: TextStyle(color: Colors.white38),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B)),
            onPressed: () async {
              final amount = int.tryParse(depositController.text.replaceAll(RegExp(r'[^0-9]'), ''));
              if (amount != null && amount > 0) {
                await ref.read(walletSummaryProvider.notifier).depositSavings(goal.id!, amount);
                ref.read(savingsGoalsProvider.notifier).loadGoals();
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Setor', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
