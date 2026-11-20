import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers/app_providers.dart';
import '../core/utils/responsive.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(walletSummaryProvider);
    final transactionsAsync = ref.watch(transactionsListProvider(null));

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: const Text(
          'Dompetku (Uang Saku)',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined, color: Colors.white70),
            onPressed: () => Navigator.pushNamed(context, '#wallet-notification'),
          ),
        ],
      ),
      body: ResponsiveWrapper(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(Responsive.px(context, 16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- SALDO UTAMA CARD ---
              summaryAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6))),
                error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
                data: (summary) {
                  final balance = summary['balance'] ?? 0;
                  final income = summary['income'] ?? 0;
                  final expense = summary['expense'] ?? 0;

                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E1E2E), Color(0xFF2D1B69)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.5)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withOpacity(0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sisa Saldo Uang Jajan',
                          style: TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Rp ${balance.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            // Income
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.arrow_downward, color: Color(0xFF10B981), size: 14),
                                        SizedBox(width: 4),
                                        Text('Masuk', style: TextStyle(color: Colors.white60, fontSize: 11)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Rp $income',
                                      style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Expense
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.arrow_upward, color: Color(0xFFEF4444), size: 14),
                                        SizedBox(width: 4),
                                        Text('Keluar', style: TextStyle(color: Colors.white60, fontSize: 11)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Rp $expense',
                                      style: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // --- BUTTON ROW: Catat Transaksi & Peti Tabungan ---
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        await Navigator.pushNamed(context, '#add-transaction');
                        ref.invalidate(transactionsListProvider(null));
                        ref.read(walletSummaryProvider.notifier).loadSummary();
                      },
                      icon: const Icon(Icons.add_circle_outline, size: 18),
                      label: const Text('Catat Transaksi', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFBBF24),
                        side: const BorderSide(color: Color(0xFFFBBF24)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pushNamed(context, '#savings'),
                      icon: const Icon(Icons.savings_outlined, size: 18),
                      label: const Text('Peti Tabungan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // --- TRANSACTIONS LIST ---
              const Text(
                'Riwayat Transaksi',
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              transactionsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6))),
                error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
                data: (txList) {
                  if (txList.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(24),
                      alignment: Alignment.center,
                      child: const Text('Belum ada transaksi.', style: TextStyle(color: Colors.white54, fontSize: 13)),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: txList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final item = txList[i];
                      final isIncome = item.type == 'income';
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: (isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                                color: isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.category,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  if (item.note != null && item.note!.isNotEmpty)
                                    Text(
                                      item.note!,
                                      style: const TextStyle(color: Colors.white60, fontSize: 11),
                                    ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${isIncome ? '+' : '-'}Rp ${item.amount}',
                                  style: TextStyle(
                                    color: isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  item.createdAt.split('T').first,
                                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
