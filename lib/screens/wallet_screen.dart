import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers/app_providers.dart';
import '../core/router/app_router.dart';
import '../core/theme/pixel_theme.dart';
import '../core/utils/responsive.dart';
import '../widgets/pixel_scaffold.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(walletSummaryProvider);
    final transactionsAsync = ref.watch(transactionsListProvider(null));

    return PixelScaffold(
      currentTabIndex: 3,
      floatingActionButton: FloatingActionButton(
        backgroundColor: PixelColors.coinGold,
        foregroundColor: PixelColors.deepPurple,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: PixelColors.deepPurple, width: 2),
        ),
        onPressed: () async {
          await Navigator.pushNamed(context, AppRouter.addTransaction);
          ref.invalidate(transactionsListProvider(null));
          ref.read(walletSummaryProvider.notifier).loadSummary();
        },
        child: const Icon(Icons.add, size: 28),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          Responsive.px(context, 14),
          12,
          Responsive.px(context, 14),
          80, // Space for FAB
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ==========================================
            // 1. RIBBON HEADER BANNER ("DOMPETKU")
            // ==========================================
            Container(
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
                  Text('💰', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 8),
                  Text(
                    'DOMPETKU — CATATAN KEUANGAN',
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

            const SizedBox(height: 12),

            // ==========================================
            // 2. SALDO UTAMA PARCHMENT CARD
            // ==========================================
            summaryAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(color: PixelColors.badgePurple),
                ),
              ),
              error: (err, _) => Center(
                child: Text('Error: $err', style: const TextStyle(color: PixelColors.redExpense)),
              ),
              data: (summary) {
                final balance = summary['balance'] ?? 0;
                final income = summary['income'] ?? 0;
                final expense = summary['expense'] ?? 0;

                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: PixelDecorations.card(
                    color: PixelColors.cardParchment,
                    radius: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Sisa Saldo Uang Jajan',
                            style: TextStyle(
                              color: PixelColors.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: PixelColors.badgePurple,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Aktif',
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Rp ${_formatNumber(balance)}',
                        style: const TextStyle(
                          color: PixelColors.textDark,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Income & Expense Breakdown Row
                      Row(
                        children: [
                          // Masuk
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: PixelColors.deepPurple, width: 1.5),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.arrow_downward_rounded, color: PixelColors.greenSuccess, size: 14),
                                      SizedBox(width: 4),
                                      Text(
                                        'Masuk',
                                        style: TextStyle(color: PixelColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '+Rp ${_formatNumber(income)}',
                                    style: const TextStyle(
                                      color: PixelColors.greenSuccess,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Keluar
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: PixelColors.deepPurple, width: 1.5),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.arrow_upward_rounded, color: PixelColors.redExpense, size: 14),
                                      SizedBox(width: 4),
                                      Text(
                                        'Keluar',
                                        style: TextStyle(color: PixelColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '-Rp ${_formatNumber(expense)}',
                                    style: const TextStyle(
                                      color: PixelColors.redExpense,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      fontFamily: 'monospace',
                                    ),
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

            const SizedBox(height: 12),

            // ==========================================
            // 3. ACTION ROW: Catat Transaksi & Peti Tabungan
            // ==========================================
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      await Navigator.pushNamed(context, AppRouter.addTransaction);
                      ref.invalidate(transactionsListProvider(null));
                      ref.read(walletSummaryProvider.notifier).loadSummary();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: PixelDecorations.button(
                        color: PixelColors.badgePurple,
                        radius: 12,
                      ),
                      alignment: Alignment.center,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_circle_outline, color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Catat Uang',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () => Navigator.pushNamed(context, AppRouter.savings),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: PixelDecorations.button(
                        color: PixelColors.coinGold,
                        radius: 12,
                      ),
                      alignment: Alignment.center,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.savings_rounded, color: PixelColors.deepPurple, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Peti Tabungan',
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
                ),
              ],
            ),

            const SizedBox(height: 18),

            // ==========================================
            // 4. RIWAYAT TRANSAKSI
            // ==========================================
            const Text(
              'Riwayat Transaksi Terkini',
              style: TextStyle(
                color: PixelColors.textDark,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            transactionsAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(color: PixelColors.badgePurple),
                ),
              ),
              error: (err, _) => Center(
                child: Text('Error: $err', style: const TextStyle(color: PixelColors.redExpense)),
              ),
              data: (txList) {
                if (txList.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: PixelDecorations.card(
                      color: PixelColors.cardParchment,
                      radius: 14,
                    ),
                    alignment: Alignment.center,
                    child: const Column(
                      children: [
                        Text('🪙', style: TextStyle(fontSize: 28)),
                        SizedBox(height: 8),
                        Text(
                          'Belum ada transaksi tercatat.',
                          style: TextStyle(
                            color: PixelColors.textDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Tekan tombol (+) untuk mencatat uang saku pertama!',
                          style: TextStyle(
                            color: PixelColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: txList.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final item = txList[i];
                    final isIncome = item.type == 'income';

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: PixelDecorations.card(
                        color: PixelColors.cardParchment,
                        radius: 12,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isIncome
                                  ? PixelColors.greenSuccess.withOpacity(0.18)
                                  : PixelColors.redExpense.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isIncome ? PixelColors.greenSuccess : PixelColors.redExpense,
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                              color: isIncome ? PixelColors.greenSuccess : PixelColors.redExpense,
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
                                  style: const TextStyle(
                                    color: PixelColors.textDark,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                if (item.note != null && item.note!.isNotEmpty)
                                  Text(
                                    item.note!,
                                    style: const TextStyle(
                                      color: PixelColors.textMuted,
                                      fontSize: 11,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${isIncome ? '+' : '-'}Rp ${_formatNumber(item.amount)}',
                                style: TextStyle(
                                  color: isIncome ? PixelColors.greenSuccess : PixelColors.redExpense,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              Text(
                                item.createdAt.split('T').first,
                                style: const TextStyle(
                                  color: PixelColors.textMuted,
                                  fontSize: 10,
                                ),
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
    );
  }

  static String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
