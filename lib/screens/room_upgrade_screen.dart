import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers/app_providers.dart';
import '../core/db/hero_dao.dart';
import '../core/theme/pixel_theme.dart';
import '../core/utils/responsive.dart';
import '../widgets/pixel_scaffold.dart';

class RoomUpgradeScreen extends ConsumerWidget {
  const RoomUpgradeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heroAsync = ref.watch(heroProfileProvider);

    return PixelScaffold(
      showBackButton: true,
      currentTabIndex: -1, // Sub-route
      body: heroAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: PixelColors.badgePurple),
        ),
        error: (err, _) => Center(
          child: Text('Error: $err', style: const TextStyle(color: PixelColors.redExpense)),
        ),
        data: (hero) {
          final currentLevel = hero.roomLevel;
          final isMaxLevel = currentLevel >= 8;
          final nextLevel = currentLevel + 1;
          final cost = HeroDao.roomUpgradeCosts[nextLevel] ?? 200;
          final canAfford = hero.coins >= cost;

          return SingleChildScrollView(
            padding: EdgeInsets.all(Responsive.px(context, 16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Ribbon Header
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
                      Text('⭐', style: TextStyle(fontSize: 16)),
                      SizedBox(width: 8),
                      Text(
                        'UPGRADE KAMAR HERO (Lv.1 – Lv.8)',
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

                // Hero Coins Status
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: PixelDecorations.card(
                    color: PixelColors.cardParchment,
                    radius: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Koin Tersedia:',
                        style: TextStyle(color: PixelColors.textMuted, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          const Text('🪙', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 4),
                          Text(
                            '${hero.coins}',
                            style: const TextStyle(
                              color: PixelColors.coinGold,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Current Room Preview Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: PixelDecorations.card(
                    color: PixelColors.cardParchmentGold,
                    radius: 16,
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.bed_rounded, size: 54, color: PixelColors.deepPurple),
                      const SizedBox(height: 8),
                      Text(
                        'Tingkat Kamar Saat Ini: Lv.$currentLevel',
                        style: const TextStyle(
                          color: PixelColors.textDark,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isMaxLevel
                            ? '🎉 Kamar telah mencapai level maksimal!'
                            : 'Upgrade ke Lv.$nextLevel untuk memperluas dekorasi kamar',
                        style: const TextStyle(color: PixelColors.textMuted, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Daftar Tingkat Kamar',
                  style: TextStyle(color: PixelColors.textDark, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // Level Progress List
                Column(
                  children: List.generate(8, (i) {
                    final lvl = i + 1;
                    final isUnlocked = lvl <= currentLevel;
                    final isNext = lvl == nextLevel;
                    final upgradeCost = HeroDao.roomUpgradeCosts[lvl] ?? 0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: PixelDecorations.card(
                        color: isUnlocked
                            ? PixelColors.cardParchmentGold
                            : (isNext ? Colors.white : PixelColors.cardParchment),
                        radius: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isUnlocked ? Icons.check_circle_rounded : (isNext ? Icons.lock_open_rounded : Icons.lock_rounded),
                                color: isUnlocked
                                    ? PixelColors.greenSuccess
                                    : (isNext ? PixelColors.coinGold : PixelColors.textMuted),
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Kamar Hero Lv.$lvl',
                                style: TextStyle(
                                  color: isUnlocked || isNext ? PixelColors.textDark : PixelColors.textMuted,
                                  fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          if (isUnlocked)
                            const Text(
                              'Terbuka ✓',
                              style: TextStyle(color: PixelColors.greenSuccess, fontSize: 11, fontWeight: FontWeight.bold),
                            )
                          else
                            Text(
                              '$upgradeCost 🪙',
                              style: TextStyle(
                                color: isNext ? PixelColors.coinGold : PixelColors.textMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 16),

                // Upgrade Action Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isMaxLevel
                        ? Colors.grey.shade400
                        : (canAfford ? PixelColors.coinGold : Colors.grey.shade400),
                    foregroundColor: PixelColors.textDark,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: PixelColors.deepPurple, width: 2),
                    ),
                    elevation: 2,
                  ),
                  onPressed: isMaxLevel || !canAfford
                      ? null
                      : () async {
                          final success = await ref.read(heroProfileProvider.notifier).upgradeRoom();
                          if (context.mounted && success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Kamar berhasil di-upgrade ke Lv.$nextLevel! 🎉'),
                                backgroundColor: PixelColors.badgePurple,
                              ),
                            );
                          }
                        },
                  child: Text(
                    isMaxLevel
                        ? 'Tingkat Maksimum Tercapai ⭐'
                        : (canAfford ? 'Upgrade Sekarang ($cost 🪙)' : 'Koin Belum Cukup ($cost 🪙)'),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
