import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers/app_providers.dart';
import '../core/utils/responsive.dart';
import '../models/transaction.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  String _type = 'expense'; // 'expense' | 'income'
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _selectedCategory = 'Makanan & Minuman';

  final List<String> _expenseCategories = [
    'Makanan & Minuman',
    'Transportasi',
    'Buku & Kuliah',
    'Jajan & Hiburan',
    'Tagihan / Pulsa',
    'Tabungan',
    'Lainnya',
  ];

  final List<String> _incomeCategories = [
    'Uang Saku',
    'Gaji / Magang',
    'Hadiah',
    'Penjualan',
    'Lainnya',
  ];

  @override
  Widget build(BuildContext context) {
    final categories = _type == 'expense' ? _expenseCategories : _incomeCategories;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: const Text(
          'Catat Transaksi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: ResponsiveWrapper(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(Responsive.px(context, 20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Type Toggle
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _type = 'expense';
                            _selectedCategory = _expenseCategories.first;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _type == 'expense' ? const Color(0xFFEF4444) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Pengeluaran',
                            style: TextStyle(
                              color: _type == 'expense' ? Colors.white : Colors.white60,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _type = 'income';
                            _selectedCategory = _incomeCategories.first;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _type == 'income' ? const Color(0xFF10B981) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Pemasukan',
                            style: TextStyle(
                              color: _type == 'income' ? Colors.white : Colors.white60,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Amount Input
              const Text('Jumlah Uang (Rp)', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  prefixText: 'Rp ',
                  prefixStyle: const TextStyle(color: Colors.white70, fontSize: 24),
                  hintText: '0',
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),

              const SizedBox(height: 20),

              // Category Selector
              const Text('Kategori', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                    selectedColor: _type == 'expense' ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                    backgroundColor: const Color(0xFF1E293B),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Note Input
              const Text('Catatan (Opsional)', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Contoh: Beli es kopi & snack',
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),

              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _type == 'expense' ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  final amount = int.tryParse(_amountController.text.replaceAll(RegExp(r'[^0-9]'), ''));
                  if (amount == null || amount <= 0) return;

                  final item = TransactionItem(
                    type: _type,
                    amount: amount,
                    category: _selectedCategory,
                    note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
                    createdAt: DateTime.now().toIso8601String(),
                  );

                  await ref.read(walletSummaryProvider.notifier).addTransaction(item);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('Simpan Transaksi', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
