import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/db/hero_dao.dart';
import '../core/providers/app_providers.dart';
import '../core/theme/app_theme.dart';
import '../models/quest.dart';

class AddQuestScreen extends ConsumerStatefulWidget {
  final bool initialIsTimed;

  const AddQuestScreen({
    super.key,
    this.initialIsTimed = false,
  });

  @override
  ConsumerState<AddQuestScreen> createState() => _AddQuestScreenState();
}

class _AddQuestScreenState extends ConsumerState<AddQuestScreen> {
  final TextEditingController _titleController = TextEditingController(text: 'Kumpulkan Tugas PBO');
  String _selectedCategory = 'Kuliah';
  bool _isTimed = false;
  int _durationMinutes = 25;
  String _selectedDifficulty = 'normal'; // 'easy', 'normal', 'hard'
  String _selectedRepeat = 'daily'; // 'once', 'daily', 'weekly'
  TimeOfDay? _alarmTime = const TimeOfDay(hour: 14, minute: 0);

  @override
  void initState() {
    super.initState();
    _isTimed = widget.initialIsTimed;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Map<String, int> _getCurrentReward() {
    return HeroDao.calculateQuestReward(
      difficulty: _selectedDifficulty,
      isTimed: _isTimed,
    );
  }

  Future<void> _handleSaveQuest() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama quest tidak boleh kosong!')),
      );
      return;
    }

    final reward = _getCurrentReward();
    final timeStr = _alarmTime != null
        ? '${_alarmTime!.hour.toString().padLeft(2, '0')}:${_alarmTime!.minute.toString().padLeft(2, '0')}'
        : null;

    final newQuest = Quest(
      title: title,
      category: _selectedCategory.toLowerCase(),
      difficulty: _selectedDifficulty,
      xpReward: reward['xp'] ?? 30,
      coinReward: reward['coins'] ?? 20,
      isTimed: _isTimed,
      durationMinutes: _isTimed ? _durationMinutes : 0,
      alarmTime: timeStr,
      repeatRule: _selectedRepeat,
      isCompleted: false,
      createdAt: DateTime.now().toIso8601String(),
    );

    await ref.read(questsProvider.notifier).addQuest(newQuest);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reward = _getCurrentReward();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  // --- HEADER ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 40),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.outline, width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.outline,
                              offset: Offset(0, 3),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.auto_awesome, color: AppColors.accent, size: 20),
                            const SizedBox(width: 6),
                            Text(
                              _isTimed ? 'Quest Ber-Timer' : 'Quest Baru',
                              style: GoogleFonts.boogaloo(
                                fontSize: 24,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
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
                          child: const Icon(Icons.close, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // --- MAIN FORM CARD ---
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.outline, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x474A2E70),
                          offset: Offset(0, 6),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Field 1: Nama Quest
                        Row(
                          children: [
                            const Icon(Icons.colorize, color: AppColors.primary, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'Nama Quest',
                              style: GoogleFonts.capriola(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.outline, width: 2),
                          ),
                          child: TextField(
                            controller: _titleController,
                            style: GoogleFonts.capriola(fontSize: 14, color: AppColors.onSurface),
                            decoration: const InputDecoration(
                              hintText: 'mis. Baca 20 halaman buku',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Field 2: Kategori
                        Row(
                          children: [
                            const Icon(Icons.menu_book, color: AppColors.primary, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'Kategori',
                              style: GoogleFonts.capriola(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.outline, width: 2),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCategory,
                              isExpanded: true,
                              items: ['Kuliah', 'Kesehatan', 'Produktivitas', 'Keuangan', 'Pribadi']
                                  .map((c) => DropdownMenuItem(
                                        value: c,
                                        child: Text(
                                          c,
                                          style: GoogleFonts.capriola(
                                            fontSize: 14,
                                            color: AppColors.onSurface,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedCategory = val);
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Field 3: Mode Quest Selector (Pengingat vs Ber-Timer)
                        Row(
                          children: [
                            const Icon(Icons.timer, color: AppColors.primary, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'Mode Quest',
                              style: GoogleFonts.capriola(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: _buildModeButton(
                                label: 'Pengingat',
                                subtitle: 'Langsung centang',
                                isSelected: !_isTimed,
                                onTap: () => setState(() => _isTimed = false),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildModeButton(
                                label: 'Ber-Timer',
                                subtitle: 'Wajib selesai timer',
                                isSelected: _isTimed,
                                onTap: () => setState(() => _isTimed = true),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Field 4: Durasi Timer (Hanya jika Ber-Timer)
                        if (_isTimed) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainer,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.outline, width: 2),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Durasi Timer',
                                      style: GoogleFonts.capriola(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.onSurface,
                                      ),
                                    ),
                                    Text(
                                      '$_durationMinutes Menit',
                                      style: GoogleFonts.splineSansMono(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [15, 25, 45, 60].map((mins) {
                                    final isSel = _durationMinutes == mins;
                                    return Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 3),
                                        child: GestureDetector(
                                          onTap: () => setState(() => _durationMinutes = mins),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 6),
                                            decoration: BoxDecoration(
                                              color: isSel
                                                  ? AppColors.accentContainer
                                                  : AppColors.surfaceContainerLow,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: isSel
                                                    ? AppColors.outline
                                                    : AppColors.outlineVariant,
                                                width: 1.5,
                                              ),
                                            ),
                                            child: Text(
                                              '${mins}m',
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.capriola(
                                                fontSize: 12,
                                                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                                color: AppColors.onSurface,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],

                        // Field 5: Tingkat Kesulitan (Easy, Normal, Hard)
                        Row(
                          children: [
                            const Icon(Icons.bolt, color: AppColors.accent, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'Tingkat Kesulitan',
                              style: GoogleFonts.capriola(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: ['easy', 'normal', 'hard'].map((diff) {
                            final isSel = _selectedDifficulty == diff;
                            Color c;
                            if (diff == 'easy') {
                              c = AppColors.success;
                            } else if (diff == 'hard') {
                              c = AppColors.error;
                            } else {
                              c = AppColors.warning;
                            }

                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 3),
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedDifficulty = diff),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSel ? c : AppColors.surfaceContainer,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppColors.outline, width: 2),
                                      boxShadow: isSel
                                          ? const [
                                              BoxShadow(
                                                color: AppColors.outline,
                                                offset: Offset(0, 2),
                                                blurRadius: 0,
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Text(
                                      diff.toUpperCase(),
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.capriola(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isSel ? Colors.white : AppColors.onSurface,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 14),

                        // Hadiah Preview Card (XP & Coin)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.accentContainer,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.outline, width: 2),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Hadiah Penyelesaian:',
                                style: GoogleFonts.capriola(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onAccentContainer,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: AppColors.primary, size: 18),
                                  const SizedBox(width: 4),
                                  Text(
                                    '+${reward['xp']} XP',
                                    style: GoogleFonts.splineSansMono(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.onAccentContainer,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Icon(Icons.monetization_on, color: AppColors.accent, size: 18),
                                  const SizedBox(width: 4),
                                  Text(
                                    '+${reward['coins']} Coin',
                                    style: GoogleFonts.splineSansMono(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.onAccentContainer,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Field 6: Jam Alarm / Pengingat
                        Row(
                          children: [
                            const Icon(Icons.alarm, color: AppColors.secondary, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'Jam Pengingat / Alarm',
                              style: GoogleFonts.capriola(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: _alarmTime ?? TimeOfDay.now(),
                            );
                            if (picked != null) {
                              setState(() => _alarmTime = picked);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainer,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.outline, width: 2),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _alarmTime != null
                                      ? '${_alarmTime!.hour.toString().padLeft(2, '0')}:${_alarmTime!.minute.toString().padLeft(2, '0')}'
                                      : 'Pilih Jam Alarm',
                                  style: GoogleFonts.splineSansMono(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                                const Icon(Icons.access_time, color: AppColors.primary, size: 20),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Field 7: Pengulangan (Sekali, Harian, Mingguan)
                        Row(
                          children: [
                            const Icon(Icons.repeat, color: AppColors.primary, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'Pengulangan',
                              style: GoogleFonts.capriola(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _buildRepeatPill('Sekali', 'once'),
                            const SizedBox(width: 6),
                            _buildRepeatPill('Harian', 'daily'),
                            const SizedBox(width: 6),
                            _buildRepeatPill('Mingguan', 'weekly'),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Primary Save Button
                        ElevatedButton.icon(
                          onPressed: _handleSaveQuest,
                          icon: const Icon(Icons.check, color: Colors.white, size: 20),
                          label: Text(
                            'Simpan Quest',
                            style: GoogleFonts.capriola(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: const BorderSide(color: AppColors.outline, width: 2),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeButton({
    required String label,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.outline, width: 2),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: AppColors.outline,
                    offset: Offset(0, 2),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Text(
              label,
              style: GoogleFonts.capriola(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.onSurface,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.capriola(
                fontSize: 10,
                color: isSelected ? Colors.white70 : AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepeatPill(String label, String value) {
    final isSelected = _selectedRepeat == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRepeat = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.secondary : AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.outline, width: 1.5),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.capriola(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : AppColors.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
