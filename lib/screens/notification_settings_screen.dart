import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers/app_providers.dart';
import '../core/utils/responsive.dart';
import '../models/notification_settings.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends ConsumerState<NotificationSettingsScreen> {
  final List<String> _allDays = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  NotificationSettings? _editable;

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(notificationSettingsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: const Text(
          'Jadwal Laporan Keuangan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: ResponsiveWrapper(
        child: settingsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6))),
          error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
          data: (settings) {
            _editable ??= settings;
            final s = _editable!;

            return SingleChildScrollView(
              padding: EdgeInsets.all(Responsive.px(context, 16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Master Switch
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: SwitchListTile(
                      title: const Text('Aktifkan Notifikasi Dompet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: const Text('Kirimkan ringkasan berkala uang jajan & tabungan', style: TextStyle(color: Colors.white54, fontSize: 11)),
                      value: s.isEnabled,
                      activeColor: const Color(0xFF8B5CF6),
                      onChanged: (val) => setState(() => _editable = s.copyWith(isEnabled: val)),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Display Mode (Home / Lock / Auto)
                  const Text('Mode Tampilan Saat Alarm Berbunyi', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Column(
                      children: [
                        _modeRadio('auto', 'Otomatis (Sesuai Layar)', 'Layar Terkunci -> Popup Kunci; Layar Terbuka -> Stiker', s.displayMode),
                        const Divider(color: Color(0xFF334155), height: 1),
                        _modeRadio('home', 'Stiker Mengambang', 'Selalu tampil sebagai stiker floating widget di atas aplikasi', s.displayMode),
                        const Divider(color: Color(0xFF334155), height: 1),
                        _modeRadio('lock', 'Layar Kunci Penuh', 'Tampil full screen alarm langsung di lockscreen', s.displayMode),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Daily Schedule
                  const Text('Jadwal Ringkasan Harian', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Laporan Harian', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                            Switch(
                              value: s.dailyEnabled,
                              activeColor: const Color(0xFF8B5CF6),
                              onChanged: (v) => setState(() => _editable = s.copyWith(dailyEnabled: v)),
                            ),
                          ],
                        ),
                        if (s.dailyEnabled) ...[
                          const SizedBox(height: 8),
                          const Text('Pilih Hari:', style: TextStyle(color: Colors.white60, fontSize: 11)),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            children: _allDays.map((day) {
                              final isSel = s.dailyDays.contains(day);
                              return FilterChip(
                                label: Text(day),
                                selected: isSel,
                                onSelected: (sel) {
                                  final days = List<String>.from(s.dailyDays);
                                  if (sel) {
                                    days.add(day);
                                  } else {
                                    days.remove(day);
                                  }
                                  setState(() => _editable = s.copyWith(dailyDays: days));
                                },
                                selectedColor: const Color(0xFF8B5CF6),
                                backgroundColor: const Color(0xFF0F172A),
                                labelStyle: TextStyle(
                                  color: isSel ? Colors.white : Colors.white60,
                                  fontSize: 11,
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Jam Laporan:', style: TextStyle(color: Colors.white60, fontSize: 12)),
                              TextButton.icon(
                                style: TextButton.styleFrom(
                                  backgroundColor: const Color(0xFF0F172A),
                                  foregroundColor: const Color(0xFF8B5CF6),
                                ),
                                onPressed: () async {
                                  final time = await showTimePicker(
                                    context: context,
                                    initialTime: const TimeOfDay(hour: 20, minute: 0),
                                  );
                                  if (time != null) {
                                    final formatted =
                                        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                                    setState(() => _editable = s.copyWith(dailyTime: formatted));
                                  }
                                },
                                icon: const Icon(Icons.access_time, size: 16),
                                label: Text(s.dailyTime, style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Content Checklist
                  const Text('Informasi yang Disertakan', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Column(
                      children: [
                        CheckboxListTile(
                          title: const Text('Sertakan Total Pemasukan', style: TextStyle(color: Colors.white, fontSize: 12)),
                          value: s.includeIncome,
                          activeColor: const Color(0xFF8B5CF6),
                          onChanged: (v) => setState(() => _editable = s.copyWith(includeIncome: v ?? true)),
                        ),
                        const Divider(color: Color(0xFF334155), height: 1),
                        CheckboxListTile(
                          title: const Text('Sertakan Total Pengeluaran', style: TextStyle(color: Colors.white, fontSize: 12)),
                          value: s.includeExpense,
                          activeColor: const Color(0xFF8B5CF6),
                          onChanged: (v) => setState(() => _editable = s.copyWith(includeExpense: v ?? true)),
                        ),
                        const Divider(color: Color(0xFF334155), height: 1),
                        CheckboxListTile(
                          title: const Text('Sertakan Sisa Saldo Dompet', style: TextStyle(color: Colors.white, fontSize: 12)),
                          value: s.includeBalance,
                          activeColor: const Color(0xFF8B5CF6),
                          onChanged: (v) => setState(() => _editable = s.copyWith(includeBalance: v ?? true)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Save Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      await ref.read(notificationSettingsProvider.notifier).saveSettings(s);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Jadwal laporan berhasil disimpan!')),
                        );
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Simpan Pengaturan Jadwal', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _modeRadio(String key, String title, String subtitle, String currentMode) {
    return RadioListTile<String>(
      value: key,
      groupValue: currentMode,
      activeColor: const Color(0xFF8B5CF6),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 11)),
      onChanged: (val) {
        if (val != null) {
          setState(() => _editable = _editable!.copyWith(displayMode: val));
        }
      },
    );
  }
}
