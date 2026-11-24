import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/db/hero_dao.dart';
import '../core/providers/app_providers.dart';
import '../core/theme/app_theme.dart';
import '../models/hero_profile.dart';

class RoomUpgradeScreen extends ConsumerStatefulWidget {
  const RoomUpgradeScreen({super.key});

  @override
  ConsumerState<RoomUpgradeScreen> createState() => _RoomUpgradeScreenState();
}

class _RoomUpgradeScreenState extends ConsumerState<RoomUpgradeScreen> {
  int _selectedLevel = 1;
  String? _feedbackMessage;
  bool _feedbackSuccess = false;
  bool _isUpgrading = false;

  @override
  void initState() {
    super.initState();
    final hero = ref.read(heroProfileProvider).valueOrNull;
    if (hero != null) {
      _selectedLevel = (hero.roomLevel < 8) ? hero.roomLevel + 1 : 8;
    }
  }

  String _getRoomImage(int level) {
    switch (level) {
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

  Future<void> _handleUpgrade(HeroProfile hero, int targetLevel) async {
    setState(() {
      _isUpgrading = true;
      _feedbackMessage = null;
    });

    final result = await ref.read(heroProfileProvider.notifier).upgradeRoomTo(targetLevel);

    setState(() {
      _isUpgrading = false;
      _feedbackMessage = result.message;
      _feedbackSuccess = result.success;
      if (result.success) {
        _selectedLevel = targetLevel;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final heroAsync = ref.watch(heroProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: heroAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (hero) {
          final isCurrentActive = _selectedLevel == hero.roomLevel;
          final isUnlocked = _selectedLevel <= hero.roomLevel;
          final isNextTarget = _selectedLevel == hero.roomLevel + 1;
          final cost = HeroDao.roomUpgradeCosts[_selectedLevel] ?? 0;
          final reqHeroLevel = HeroDao.roomRequiredHeroLevels[_selectedLevel] ?? 1;

          final roomTitle = HeroDao.roomNames[_selectedLevel] ?? 'Kamar Lv.$_selectedLevel';
          final roomDesc = HeroDao.roomDescriptions[_selectedLevel] ?? '';

          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  children: [
                    // --- 1. CONTEXTUAL TASK FLOW HEADER ---
                    Container(
                      color: AppColors.surfaceNav,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Back Button
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 38,
                              height: 38,
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
                              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                            ),
                          ),

                          // Header Title
                          Text(
                            'Upgrade Kamar',
                            style: GoogleFonts.boogaloo(
                              fontSize: 26,
                              color: Colors.white,
                            ),
                          ),

                          // Live Coin Counter
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
                                const Icon(Icons.monetization_on, color: AppColors.accent, size: 18),
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
                    ),

                    // --- 2. SCROLLABLE CONTENT ---
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // LIVE STAGE PREVIEW BACKDROP
                            Container(
                              height: 220,
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: AppColors.outline, width: 2),
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Image.asset(
                                      _getRoomImage(_selectedLevel),
                                      fit: BoxFit.cover,
                                      errorBuilder: (ctx, err, stack) => Container(
                                        color: const Color(0xFFDDD6FE),
                                        child: const Center(
                                          child: Icon(Icons.bed, size: 50, color: AppColors.primary),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Badge Kiri Atas
                                  Positioned(
                                    top: 10,
                                    left: 10,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isCurrentActive ? AppColors.surfaceNav : AppColors.primary,
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
                                      child: Text(
                                        isCurrentActive
                                            ? 'Lobi Aktif: Lv.$_selectedLevel'
                                            : 'Pratinjau: Lv.$_selectedLevel',
                                        style: GoogleFonts.capriola(
                                          fontSize: 11,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Badge Kanan Atas (Syarat)
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isUnlocked
                                            ? AppColors.accentContainer
                                            : AppColors.surfaceContainerHigh,
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
                                      child: Text(
                                        isUnlocked ? 'Terbuka' : 'Syarat: Hero Lv.$reqHeroLevel',
                                        style: GoogleFonts.capriola(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isUnlocked
                                              ? AppColors.onAccentContainer
                                              : AppColors.onSurface,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // SELECTED ROOM INFO & UPGRADE ACTION CARD
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
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
                                        Text(
                                          'Lv.$_selectedLevel — $roomTitle',
                                          style: GoogleFonts.boogaloo(
                                            fontSize: 22,
                                            color: AppColors.onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          roomDesc,
                                          style: GoogleFonts.capriola(
                                            fontSize: 13,
                                            color: AppColors.onSurface,
                                            height: 1.4,
                                          ),
                                        ),
                                        const SizedBox(height: 14),

                                        // Action Footer
                                        Row(
                                          children: [
                                            // Cost Badge
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: AppColors.surfaceContainer,
                                                borderRadius: BorderRadius.circular(9999),
                                                border: Border.all(color: AppColors.outline, width: 2),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.monetization_on,
                                                    color: AppColors.accent,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    isUnlocked ? 'Aktif' : '$cost Coin',
                                                    style: GoogleFonts.splineSansMono(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.bold,
                                                      color: AppColors.onSurface,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 10),

                                            // Action Button
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: (_isUpgrading || isUnlocked || !isNextTarget)
                                                    ? (isUnlocked
                                                        ? null
                                                        : () {
                                                            setState(() {
                                                              _feedbackMessage =
                                                                  'Buka level kamar secara berurutan! Selesaikan Lv.${hero.roomLevel + 1} terlebih dahulu.';
                                                              _feedbackSuccess = false;
                                                            });
                                                          })
                                                    : () => _handleUpgrade(hero, _selectedLevel),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: isUnlocked
                                                      ? AppColors.success
                                                      : (isNextTarget
                                                          ? AppColors.primary
                                                          : AppColors.outlineVariant),
                                                  foregroundColor: Colors.white,
                                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                    side: const BorderSide(color: AppColors.outline, width: 2),
                                                  ),
                                                  elevation: 0,
                                                  shadowColor: Colors.transparent,
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      isUnlocked
                                                          ? Icons.check
                                                          : Icons.arrow_upward,
                                                      color: AppColors.accent,
                                                      size: 18,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      isUnlocked
                                                          ? 'Sudah Terbuka'
                                                          : (isNextTarget
                                                              ? 'Upgrade ke Lv.$_selectedLevel ($cost)'
                                                              : 'Terkunci (Lv.$_selectedLevel)'),
                                                      style: GoogleFonts.capriola(
                                                        fontSize: 13,
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
                                      ],
                                    ),
                                  ),

                                  // FEEDBACK BANNER
                                  if (_feedbackMessage != null) ...[
                                    const SizedBox(height: 12),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: _feedbackSuccess
                                            ? AppColors.accentContainer
                                            : AppColors.surfaceContainerHigh,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: AppColors.outline, width: 2),
                                      ),
                                      child: Text(
                                        _feedbackMessage!,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.capriola(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: _feedbackSuccess
                                              ? AppColors.onAccentContainer
                                              : AppColors.error,
                                        ),
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 20),

                                  // SECTION TITLE
                                  Row(
                                    children: [
                                      const Icon(Icons.meeting_room, color: AppColors.primary, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        'PROGRES 8 LEVEL KAMAR',
                                        style: GoogleFonts.splineSansMono(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.surfaceNav,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // 8-LEVEL PROGRESSION GRID (2 COLUMNS)
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                      childAspectRatio: 1.45,
                                    ),
                                    itemCount: 8,
                                    itemBuilder: (ctx, index) {
                                      final lv = index + 1;
                                      return _buildRoomTierCard(hero, lv);
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoomTierCard(HeroProfile hero, int level) {
    final isSelected = _selectedLevel == level;
    final isUnlocked = level <= hero.roomLevel;
    final isMax = level == 8;
    final cost = HeroDao.roomUpgradeCosts[level] ?? 0;
    final name = HeroDao.roomNames[level] ?? 'Lv.$level';

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLevel = level;
          _feedbackMessage = null;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accentContainer
              : (isUnlocked ? AppColors.surfaceContainerLow : AppColors.surfaceContainer),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.outline : AppColors.outlineVariant,
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: AppColors.outline,
                    offset: Offset(0, 3),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lv.$level',
                  style: GoogleFonts.boogaloo(
                    fontSize: 20,
                    color: AppColors.onSurface,
                  ),
                ),
                if (isMax)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.outline, width: 1),
                    ),
                    child: Text(
                      'MAX',
                      style: GoogleFonts.capriola(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onAccent,
                      ),
                    ),
                  )
                else if (isUnlocked)
                  const Icon(Icons.check_circle, color: AppColors.success, size: 18)
                else
                  const Icon(Icons.lock, color: AppColors.outline, size: 16),
              ],
            ),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.capriola(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            Text(
              isUnlocked ? 'Aktif' : (level == 1 ? 'Gratis' : '$cost Coin'),
              style: GoogleFonts.splineSansMono(
                fontSize: 11,
                color: isUnlocked ? AppColors.success : AppColors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
