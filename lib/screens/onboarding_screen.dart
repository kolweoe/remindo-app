import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/providers/app_providers.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_theme.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final TextEditingController _nameController = TextEditingController(text: 'Raka');
  String _selectedStarter = 'Laki-laki'; // 'Laki-laki' or 'Perempuan'
  String _selectedFocus = 'Kuliah'; // 'Kuliah', 'Keuangan', 'Kebiasaan'
  String? _feedbackMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleStartAdventure() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _feedbackMessage = 'Harap isi nama Heromu terlebih dahulu!';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _feedbackMessage = 'Selamat datang, $name! Masuk ke Kamar Lv.1 dengan Hero $_selectedStarter...';
    });

    final starterKey = _selectedStarter == 'Perempuan' ? 'chibi_female' : 'chibi_male';

    await ref.read(heroProfileProvider.notifier).createHero(
      name: name,
      starterAvatar: starterKey,
      focusGoal: _selectedFocus,
    );

    // Refresh provider and navigate to Home
    ref.invalidate(hasHeroProfileProvider);
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRouter.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- TOP BRAND & WELCOME HEADER ---
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(9999),
                      border: Border.all(color: AppColors.outline, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.outline,
                          offset: Offset(0, 2),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          color: AppColors.accent,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'REMINDO • 100% OFFLINE RPG',
                          style: GoogleFonts.capriola(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Mulai Petualanganmu!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.boogaloo(
                      fontSize: 32,
                      color: AppColors.onSurface,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Ubah tugas harian & catatan keuangan jadi progres karakter dan kamar impianmu.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.capriola(
                      fontSize: 14,
                      color: AppColors.onSurface,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- MAIN HERO SETUP CARD ---
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.outline, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x474E2F1B),
                          offset: Offset(0, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Field 1: Nama Hero
                        Row(
                          children: [
                            const Icon(Icons.badge, color: AppColors.primary, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'Nama Heromu',
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
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(color: AppColors.outline, width: 2),
                          ),
                          child: TextField(
                            controller: _nameController,
                            style: GoogleFonts.capriola(
                              fontSize: 14,
                              color: AppColors.onSurface,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Masukkan nama panggilan...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Field 2: Starter Character Picker
                        Row(
                          children: [
                            const Icon(Icons.face, color: AppColors.primary, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'Pilih Karakter Awal',
                              style: GoogleFonts.capriola(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            // Option 1: Hero Chibi Laki-laki
                            Expanded(
                              child: _buildStarterButton(
                                label: 'Laki-laki',
                                imageAsset: 'assets/images/hero_chibi_male.jpg',
                                isSelected: _selectedStarter == 'Laki-laki',
                                onTap: () {
                                  setState(() {
                                    _selectedStarter = 'Laki-laki';
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Option 2: Hero Chibi Perempuan
                            Expanded(
                              child: _buildStarterButton(
                                label: 'Perempuan',
                                imageAsset: 'assets/images/hero_chibi_female.jpg',
                                isSelected: _selectedStarter == 'Perempuan',
                                onTap: () {
                                  setState(() {
                                    _selectedStarter = 'Perempuan';
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Field 3: Fokus Utama
                        Row(
                          children: [
                            const Icon(Icons.flag, color: AppColors.secondary, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'Fokus Utama',
                              style: GoogleFonts.capriola(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildGoalPill('Kuliah'),
                            const SizedBox(width: 8),
                            _buildGoalPill('Keuangan'),
                            const SizedBox(width: 8),
                            _buildGoalPill('Kebiasaan'),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Starter Bonus Banner
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.accentContainer,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.outline, width: 2),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.redeem, color: AppColors.primary, size: 24),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Bonus Pemula',
                                      style: GoogleFonts.capriola(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.onAccentContainer,
                                      ),
                                    ),
                                    Text(
                                      '+50 Coin & Kamar Lv.1 siap dipakai!',
                                      style: GoogleFonts.capriola(
                                        fontSize: 11,
                                        color: AppColors.onAccentContainer,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Feedback Banner
                        if (_feedbackMessage != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.outline, width: 2),
                            ),
                            child: Text(
                              _feedbackMessage!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.capriola(
                                fontSize: 12,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),

                        // Primary CTA Button
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleStartAdventure,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              side: const BorderSide(color: AppColors.outline, width: 2),
                            ),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              boxShadow: const [
                                BoxShadow(
                                  color: AppColors.outline,
                                  offset: Offset(0, 3),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.play_arrow, color: AppColors.accent, size: 20),
                                const SizedBox(width: 6),
                                Text(
                                  _isLoading ? 'Menyiapkan...' : 'Mulai di Kamar Hero',
                                  style: GoogleFonts.capriola(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- FOOTER RESTORE LINK ---
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRouter.settings);
                    },
                    child: Text(
                      'Sudah punya cadangan? Pulihkan Data',
                      style: GoogleFonts.capriola(
                        fontSize: 13,
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStarterButton({
    required String label,
    required String imageAsset,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentContainer : AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? AppColors.outline : AppColors.outlineVariant,
            width: 2,
          ),
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
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.standard),
                border: Border.all(color: AppColors.outline, width: 2),
                color: AppColors.surfaceContainerLow,
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.person,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.capriola(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalPill(String goal) {
    final isSelected = _selectedFocus == goal;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFocus = goal;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(AppRadius.standard),
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
          child: Text(
            goal,
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
