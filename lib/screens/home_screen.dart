import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/db/hero_dao.dart';
import '../core/providers/app_providers.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_theme.dart';
import '../models/hero_profile.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _bobbingController;
  String? _toastMessage;
  Timer? _toastTimer;

  @override
  void initState() {
    super.initState();
    _bobbingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bobbingController.dispose();
    _toastTimer?.cancel();
    super.dispose();
  }

  void _showToast(String message) {
    _toastTimer?.cancel();
    setState(() {
      _toastMessage = message;
    });
    _toastTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _toastMessage = null;
        });
      }
    });
  }

  String _getRoomImageAsset(int roomLevel) {
    switch (roomLevel) {
      case 1:
        return 'assets/images/kamarkosong.jpg';
      case 2:
        return 'assets/images/kamar_lv2_preview.jpg';
      case 3:
        return 'assets/images/kamar2.jpg';
      case 4:
        return 'assets/images/kamar1.jpg';
      case 5:
        return 'assets/images/kamar_lv2_preview.jpg';
      case 6:
      case 7:
      case 8:
      default:
        return 'assets/images/kamar_lv8_max.jpg';
    }
  }

  int _getNextRoomCost(int currentLevel) {
    final nextLevel = currentLevel + 1;
    return HeroDao.roomUpgradeCosts[nextLevel] ?? 0;
  }

  void _showQuickAddModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: AppColors.outline, width: 2),
          boxShadow: const [
            BoxShadow(
              color: AppColors.outline,
              offset: Offset(0, -4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tambah Cepat',
                  style: GoogleFonts.boogaloo(
                    fontSize: 22,
                    color: AppColors.onSurface,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.outline),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildQuickActionTile(
              icon: Icons.timer,
              iconColor: AppColors.secondary,
              title: 'Quest Ber-Timer (Fokus/Pomodoro)',
              subtitle: 'Mulai sesi belajar dengan hitungan mundur',
              onTap: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(context, AppRouter.hashAddQuest);
              },
            ),
            const SizedBox(height: 10),
            _buildQuickActionTile(
              icon: Icons.alarm,
              iconColor: AppColors.accent,
              title: 'Quest Pengingat (Tugas/Harian)',
              subtitle: 'Catat tugas dengan jam alarm pengingat',
              onTap: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(context, AppRouter.hashAddQuestReminder);
              },
            ),
            const SizedBox(height: 10),
            _buildQuickActionTile(
              icon: Icons.add_card,
              iconColor: AppColors.primary,
              title: 'Catat Transaksi Dompetku',
              subtitle: 'Input pemasukan atau pengeluaran harian',
              onTap: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(context, AppRouter.addTransaction);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outline, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.outline, width: 2),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.capriola(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.capriola(
                      fontSize: 11,
                      color: AppColors.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.outline),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final heroAsync = ref.watch(heroProfileProvider);
    final questsAsync = ref.watch(questsProvider);

    final uncompletedCount = questsAsync.maybeWhen(
      data: (quests) => quests.where((q) => !q.isCompleted).length,
      orElse: () => 2,
    );

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: heroAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, stack) => Center(
          child: Text('Gagal memuat profil: $err'),
        ),
        data: (hero) {
          final nextCost = _getNextRoomCost(hero.roomLevel);
          final xpRatio = (hero.xpNext > 0)
              ? (hero.xp / hero.xpNext).clamp(0.0, 1.0)
              : 0.0;

          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  children: [
                    // --- 1. TOP STATUS HUD ---
                    _buildTopStatusHud(hero, xpRatio),

                    // --- 2. MAIN ROOM STAGE ---
                    Expanded(
                      child: Stack(
                        children: [
                          // Background Image
                          Positioned.fill(
                            child: Image.asset(
                              _getRoomImageAsset(hero.roomLevel),
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, stack) => Container(
                                color: const Color(0xFFDDD6FE),
                                child: const Center(
                                  child: Icon(Icons.bed, size: 60, color: AppColors.primary),
                                ),
                              ),
                            ),
                          ),

                          // Top Lobby Action Bar
                          Positioned(
                            top: 12,
                            left: 12,
                            right: 12,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Atur Capsule (Left)
                                _buildAturButton(),

                                // Upgrade Kamar Capsule (Right)
                                _buildUpgradeRoomButton(hero, nextCost),
                              ],
                            ),
                          ),

                          // Animated Character and Pet in Room
                          Positioned(
                            bottom: 80,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: AnimatedBuilder(
                                animation: _bobbingController,
                                builder: (context, child) {
                                  final offset = 6.0 * _bobbingController.value;
                                  return Transform.translate(
                                    offset: Offset(0, -offset),
                                    child: child,
                                  );
                                },
                                child: GestureDetector(
                                  onTap: () {
                                    _showToast('Halo, ${hero.name}! Streak belajarmu: ${hero.streakDays} hari! ✨');
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      // Hero Character
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: AppColors.outline, width: 2),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Color(0x334A2E70),
                                              offset: Offset(0, 4),
                                              blurRadius: 0,
                                            ),
                                          ],
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: Image.asset(
                                          'assets/images/karakter_hero_hoodie_ungu.jpg',
                                          fit: BoxFit.cover,
                                          errorBuilder: (ctx, err, stack) => const Icon(
                                            Icons.person,
                                            size: 40,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Tuxedo Pet
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: AppColors.outline, width: 2),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Color(0x334A2E70),
                                              offset: Offset(0, 3),
                                              blurRadius: 0,
                                            ),
                                          ],
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: Image.asset(
                                          'assets/images/pet_kucing_tuxedo.jpg',
                                          fit: BoxFit.cover,
                                          errorBuilder: (ctx, err, stack) => const Icon(
                                            Icons.pets,
                                            size: 24,
                                            color: AppColors.accent,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Toast feedback in center
                          if (_toastMessage != null)
                            Positioned(
                              top: 70,
                              left: 20,
                              right: 20,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceNav,
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
                                  child: Text(
                                    _toastMessage!,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.capriola(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          // Bottom Overlay: Quest Ready Notification Bubble
                          Positioned(
                            bottom: 14,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, AppRouter.quests);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.outline, width: 2),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x474A2E70),
                                        offset: Offset(0, 4),
                                        blurRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: AppColors.outline, width: 2),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '!',
                                            style: GoogleFonts.capriola(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '$uncompletedCount quest siap!',
                                        style: GoogleFonts.capriola(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.onSurface,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Icons.auto_awesome,
                                        color: AppColors.accent,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --- 3. BOTTOM NAVIGATION BAR (5 SLOTS) ---
                    _buildBottomNavigationBar(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopStatusHud(HeroProfile hero, double xpRatio) {
    return Container(
      color: AppColors.surfaceNav,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Room Level Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary,
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Kamar',
                  style: GoogleFonts.capriola(
                    fontSize: 10,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
                Text(
                  'Lv.${hero.roomLevel}',
                  style: GoogleFonts.boogaloo(
                    fontSize: 20,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // XP Bar Hero
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'XP Hero',
                      style: GoogleFonts.capriola(
                        fontSize: 11,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${hero.xp} / ${hero.xpNext}',
                      style: GoogleFonts.splineSansMono(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(9999),
                    border: Border.all(color: AppColors.outline, width: 2),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: xpRatio,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Coin Counter Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                  Icons.monetization_on,
                  color: AppColors.accent,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  '${hero.coins}',
                  style: GoogleFonts.splineSansMono(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAturButton() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRouter.settings);
      },
      child: Container(
        padding: const EdgeInsets.only(left: 4, right: 10, top: 4, bottom: 4),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.outline, width: 2),
              ),
              child: const Icon(Icons.settings, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 6),
            Text(
              'Atur',
              style: GoogleFonts.capriola(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeRoomButton(HeroProfile hero, int nextCost) {
    final isMax = hero.roomLevel >= 8;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRouter.roomUpgrade);
      },
      child: Container(
        padding: const EdgeInsets.only(left: 4, right: 6, top: 4, bottom: 4),
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(14),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.outline, width: 2),
              ),
              child: const Icon(Icons.arrow_upward, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 6),
            Text(
              'Upgrade Kamar',
              style: GoogleFonts.capriola(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.onAccent,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.surfaceNav,
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(color: AppColors.outline, width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.monetization_on, color: AppColors.accent, size: 12),
                  const SizedBox(width: 3),
                  Text(
                    isMax ? 'MAX' : '$nextCost',
                    style: GoogleFonts.splineSansMono(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      color: AppColors.surfaceNav,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 1. Home (Active)
          _buildNavItem(
            icon: Icons.home,
            label: 'Home',
            isActive: true,
            onTap: () {},
          ),

          // 2. Quests
          _buildNavItem(
            icon: Icons.assignment,
            label: 'Quests',
            isActive: false,
            onTap: () {
              Navigator.pushNamed(context, AppRouter.quests);
            },
          ),

          // 3. Center (+) Quick Add FAB
          GestureDetector(
            onTap: () => _showQuickAddModal(context),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outline, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.outline,
                    offset: Offset(0, 2),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
          ),

          // 4. Wallet
          _buildNavItem(
            icon: Icons.account_balance_wallet,
            label: 'Wallet',
            isActive: false,
            onTap: () {
              Navigator.pushNamed(context, AppRouter.wallet);
            },
          ),

          // 5. Hero
          _buildNavItem(
            icon: Icons.person,
            label: 'Hero',
            isActive: false,
            onTap: () {
              Navigator.pushNamed(context, AppRouter.customize);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: isActive
            ? BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.outlineVariant, width: 2),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.capriola(
                fontSize: 10,
                color: Colors.white,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
